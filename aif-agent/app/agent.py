"""
Claude tool-use agent with async streaming and multi-provider support.

agent_stream() is an async generator that yields SSE-formatted strings.
Each yielded string is a complete SSE event: "data: {...}\\n\\n"

Event types:
  {"type": "text",      "content": "..."}   — streamed text token
  {"type": "tool_call", "name": "..."}       — tool being executed (for UI indicator)
  {"type": "done"}                           — conversation turn complete
  {"type": "error",     "content": "..."}   — limit hit or unexpected error

Provider runners (_run_turn_anthropic, _run_turn_groq) are async generators that
yield ("text", str) tokens then a final ("done", (content_blocks, usage_dict)).
History is always stored in Anthropic dict format; converted on-the-fly for Groq.
"""

import asyncio
import json
import logging
import os

from anthropic import APIStatusError as AnthropicStatusError
from openai import APIStatusError as OpenAIStatusError

from app import provider as prov
from app import state
from app.system_prompt import SYSTEM_PROMPT
from app.tools import TOOL_DEFINITIONS, dispatch_tool
from app.usage_tracker import tracker

logger = logging.getLogger(__name__)

MAX_TOKENS = 1500
MAX_TOOL_RESULT_CHARS = 4_000
HISTORY_WINDOW = 10
MAX_TOOL_ITERATIONS = 5
MAX_RETRIES = 3

# Cached system prompt block — for Anthropic providers only
_SYSTEM_CACHED = [{"type": "text", "text": SYSTEM_PROMPT, "cache_control": {"type": "ephemeral"}}]


# ── Per-provider async generator runners ─────────────────────────────────────

async def _run_turn_anthropic(history: list, cfg: dict):
    """
    Async generator for Anthropic API.
    Yields ("text", str) for each token, then ("done", (content, usage)).
    content is a list of dicts in Anthropic format.
    """
    system = _SYSTEM_CACHED if cfg["supports_caching"] else SYSTEM_PROMPT
    yielded_text = False

    for attempt in range(MAX_RETRIES):
        try:
            async with prov.anthropic_client.messages.stream(
                model=cfg["model_id"],
                max_tokens=MAX_TOKENS,
                system=system,
                messages=history,
                tools=TOOL_DEFINITIONS,
            ) as stream:
                async for event in stream:
                    if (
                        event.type == "content_block_delta"
                        and hasattr(event.delta, "text")
                        and event.delta.text
                    ):
                        yielded_text = True
                        yield ("text", event.delta.text)
                message = await stream.get_final_message()
            break  # success
        except AnthropicStatusError as e:
            if e.status_code == 429 and attempt < MAX_RETRIES - 1 and not yielded_text:
                wait = 2 ** attempt
                logger.warning("Anthropic 429, retry %d in %ds", attempt + 1, wait)
                await asyncio.sleep(wait)
            else:
                raise

    content = []
    for block in message.content:
        if block.type == "text":
            content.append({"type": "text", "text": block.text})
        elif block.type == "tool_use":
            content.append({
                "type": "tool_use",
                "id": block.id,
                "name": block.name,
                "input": block.input,
            })

    usage = {
        "input": int(getattr(message.usage, "input_tokens", 0) or 0),
        "output": int(getattr(message.usage, "output_tokens", 0) or 0),
        "cache_read": int(getattr(message.usage, "cache_read_input_tokens", 0) or 0),
    }
    yield ("done", (content, usage))


async def _run_turn_groq(history: list, cfg: dict):
    """
    Async generator for Groq (OpenAI-compatible) API.
    Yields ("text", str) for each token, then ("done", (content, usage)).
    content is reconstructed in Anthropic dict format for uniform handling.
    """
    oai_messages = prov.to_openai_messages(SYSTEM_PROMPT, history)
    oai_tools = prov.to_openai_tools(TOOL_DEFINITIONS)

    # Retry only before streaming starts
    stream = None
    for attempt in range(MAX_RETRIES):
        try:
            stream = await prov.groq_client.chat.completions.create(
                model=cfg["model_id"],
                max_tokens=MAX_TOKENS,
                messages=oai_messages,
                tools=oai_tools,
                stream=True,
                stream_options={"include_usage": True},
            )
            break
        except OpenAIStatusError as e:
            if e.status_code == 429 and attempt < MAX_RETRIES - 1:
                wait = 2 ** attempt
                logger.warning("Groq 429, retry %d in %ds", attempt + 1, wait)
                await asyncio.sleep(wait)
            else:
                raise

    full_text = ""
    tool_calls_acc: dict[int, dict] = {}  # index → {id, name, args}
    input_tokens = output_tokens = 0

    async for chunk in stream:
        # Usage arrives in the final empty-choices chunk
        if chunk.usage:
            input_tokens = chunk.usage.prompt_tokens or 0
            output_tokens = chunk.usage.completion_tokens or 0
        if not chunk.choices:
            continue
        delta = chunk.choices[0].delta
        if delta.content:
            full_text += delta.content
            yield ("text", delta.content)
        if delta.tool_calls:
            for tc in delta.tool_calls:
                idx = tc.index
                if idx not in tool_calls_acc:
                    tool_calls_acc[idx] = {"id": "", "name": "", "args": ""}
                if tc.id:
                    tool_calls_acc[idx]["id"] = tc.id
                if tc.function:
                    if tc.function.name:
                        tool_calls_acc[idx]["name"] = tc.function.name
                    if tc.function.arguments:
                        tool_calls_acc[idx]["args"] += tc.function.arguments

    # Build content in Anthropic dict format
    content: list[dict] = []
    if full_text:
        content.append({"type": "text", "text": full_text})
    for idx in sorted(tool_calls_acc):
        tc = tool_calls_acc[idx]
        try:
            input_data = json.loads(tc["args"]) if tc["args"] else {}
        except json.JSONDecodeError:
            input_data = {}
        content.append({
            "type": "tool_use",
            "id": tc["id"] or f"call_{idx}",
            "name": tc["name"],
            "input": input_data,
        })

    usage = {"input": input_tokens, "output": output_tokens, "cache_read": 0}
    yield ("done", (content, usage))


async def _run_turn_aicore(history: list, cfg: dict):
    """
    Async generator for SAP AI Core (OpenAI-compatible API with OAuth2 token).
    Fetches/refreshes the token, then delegates to the same OpenAI streaming logic.
    Falls back to no-tools call if the model returns 404 on the tools request.
    """
    import os as _os
    client = await prov.get_aicore_client(cfg["deployment_id_env"])
    oai_messages = prov.to_openai_messages(SYSTEM_PROMPT, history)
    oai_tools = prov.to_openai_tools(TOOL_DEFINITIONS)

    deployment_id = _os.environ.get(cfg["deployment_id_env"], "?")
    base = f"{prov._AICORE_BASE_URL}/v2/inference/deployments/{deployment_id}"
    logger.info("AI Core call → %s/chat/completions (model=%s)", base, cfg["model_id"])

    stream = None
    use_tools = True

    for attempt in range(MAX_RETRIES):
        try:
            kwargs: dict = dict(
                model=cfg["model_id"],
                max_tokens=MAX_TOKENS,
                messages=oai_messages,
                stream=True,
            )
            if use_tools:
                kwargs["tools"] = oai_tools
            stream = await client.chat.completions.create(**kwargs)
            break
        except OpenAIStatusError as e:
            logger.warning("AI Core error %d: %s", e.status_code, e.message)
            if e.status_code == 404:
                raise RuntimeError(
                    f"SAP AI Core deployment not found (404).\n"
                    f"Deployment ID: {deployment_id}\n"
                    f"URL: {base}/chat/completions\n"
                    f"Check that the deployment is in RUNNING state in SAP BTP AI Core "
                    f"and that AICORE_RESOURCE_GROUP='{prov._AICORE_RESOURCE_GROUP}' is correct."
                ) from e
            elif e.status_code == 400 and use_tools and attempt == 0:
                # Model may not support tool use — retry without tools
                logger.warning("AI Core 400 with tools, retrying without tools")
                use_tools = False
            elif e.status_code == 429 and attempt < MAX_RETRIES - 1:
                wait = 2 ** attempt
                logger.warning("AI Core 429, retry %d in %ds", attempt + 1, wait)
                await asyncio.sleep(wait)
            elif e.status_code == 401 and attempt < MAX_RETRIES - 1:
                prov._aicore_token = ""
                client = await prov.get_aicore_client(cfg["deployment_id_env"])
            else:
                raise

    full_text = ""
    tool_calls_acc: dict[int, dict] = {}
    input_tokens = output_tokens = 0

    async for chunk in stream:
        if chunk.usage:
            input_tokens = chunk.usage.prompt_tokens or 0
            output_tokens = chunk.usage.completion_tokens or 0
        if not chunk.choices:
            continue
        delta = chunk.choices[0].delta
        if delta.content:
            full_text += delta.content
            yield ("text", delta.content)
        if delta.tool_calls:
            for tc in delta.tool_calls:
                idx = tc.index
                if idx not in tool_calls_acc:
                    tool_calls_acc[idx] = {"id": "", "name": "", "args": ""}
                if tc.id:
                    tool_calls_acc[idx]["id"] = tc.id
                if tc.function:
                    if tc.function.name:
                        tool_calls_acc[idx]["name"] = tc.function.name
                    if tc.function.arguments:
                        tool_calls_acc[idx]["args"] += tc.function.arguments

    content: list[dict] = []
    if full_text:
        content.append({"type": "text", "text": full_text})
    for idx in sorted(tool_calls_acc):
        tc = tool_calls_acc[idx]
        try:
            input_data = json.loads(tc["args"]) if tc["args"] else {}
        except json.JSONDecodeError:
            input_data = {}
        content.append({
            "type": "tool_use",
            "id": tc["id"] or f"call_{idx}",
            "name": tc["name"],
            "input": input_data,
        })

    usage = {"input": input_tokens, "output": output_tokens, "cache_read": 0}
    yield ("done", (content, usage))


async def _run_turn(history: list, provider_key: str):
    """Dispatch to the correct provider runner."""
    cfg = prov.get_config(provider_key)
    if cfg["client_type"] == "anthropic":
        async for item in _run_turn_anthropic(history, cfg):
            yield item
    elif cfg["client_type"] == "groq":
        async for item in _run_turn_groq(history, cfg):
            yield item
    elif cfg["client_type"] == "aicore":
        async for item in _run_turn_aicore(history, cfg):
            yield item
    else:
        raise ValueError(f"Unknown client_type: {cfg['client_type']}")


# ── History helpers ───────────────────────────────────────────────────────────

def _is_plain_user(msg: dict) -> bool:
    """True when msg is a regular user text message (not a tool_result batch)."""
    if msg.get("role") != "user":
        return False
    content = msg.get("content")
    if isinstance(content, str):
        return True
    if isinstance(content, list):
        return not any(b.get("type") == "tool_result" for b in content)
    return False


def _trim_history(history: list) -> list:
    """
    Drop leading messages until the history starts with a plain user text message.
    This prevents 'tool role without preceding tool_calls' errors when the
    HISTORY_WINDOW slice cuts in the middle of a tool-call sequence.
    """
    for i, msg in enumerate(history):
        if _is_plain_user(msg):
            return history[i:]
    return []


# ── Main agent loop ───────────────────────────────────────────────────────────

async def agent_stream(user_message: str, session_id: str):
    """
    Async generator — yields SSE event strings.
    Runs the full tool-use loop until the LLM stops calling tools.
    """

    allowed, reason = tracker.check_limits(session_id)
    if not allowed:
        yield _event("error", content=reason)
        return

    provider_key = prov.get_key()

    if not prov.is_configured(provider_key):
        yield _event(
            "error",
            content=f"Provider '{prov.get_config(provider_key)['label']}' is not configured "
                    f"(missing API key). Select a different provider in the admin panel.",
        )
        return

    history = _trim_history(list(state.sessions.get(session_id, [])))
    history.append({"role": "user", "content": user_message})

    try:
        tool_iterations = 0
        while True:
            content = None
            usage = None

            async for kind, value in _run_turn(history, provider_key):
                if kind == "text":
                    yield _event("text", content=value)
                elif kind == "done":
                    content, usage = value

            tracker.record(session_id, usage, provider_key)

            session_stats = tracker.get_session(session_id)
            if session_stats:
                yield _event("usage", **session_stats)

            tool_blocks = [b for b in content if b.get("type") == "tool_use"]

            if not tool_blocks:
                history.append({"role": "assistant", "content": content})
                state.sessions[session_id] = history[-HISTORY_WINDOW:]
                yield _event("done")
                return

            tool_iterations += 1
            if tool_iterations > MAX_TOOL_ITERATIONS:
                yield _event("error", content="Too many tool calls in one turn — stopping.")
                return

            history.append({"role": "assistant", "content": content})
            tool_results = []

            for block in tool_blocks:
                yield _event("tool_call", name=block["name"])
                logger.debug("Tool call: %s %s", block["name"], block["input"])

                result = await asyncio.to_thread(dispatch_tool, block["name"], block["input"])

                if len(result) > MAX_TOOL_RESULT_CHARS:
                    result = result[:MAX_TOOL_RESULT_CHARS] + "\n... (truncated)"

                tool_results.append({
                    "type": "tool_result",
                    "tool_use_id": block["id"],
                    "content": result,
                })

            history.append({"role": "user", "content": tool_results})
            state.sessions[session_id] = history[-HISTORY_WINDOW:]

    except Exception as exc:
        logger.exception("agent_stream error for session %s", session_id)
        yield _event("error", content=f"Unexpected error: {exc}")


# ── SSE helper ────────────────────────────────────────────────────────────────

def _event(event_type: str, **kwargs) -> str:
    payload = {"type": event_type, **kwargs}
    return f"data: {json.dumps(payload, ensure_ascii=False)}\n\n"
