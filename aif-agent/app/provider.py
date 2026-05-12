"""
LLM provider registry, admin-controlled current provider, client instances,
and Anthropic ↔ OpenAI message-format converters.

Supported providers:
  claude-sonnet   — Anthropic Claude Sonnet 4.6
  claude-haiku    — Anthropic Claude Haiku 4.5
  groq-llama3     — Groq Llama 3.3 70B (OpenAI-compatible)
  aicore-gpt4o    — SAP AI Core GPT-4o deployment
  aicore-rpt1     — SAP AI Core RPT-1 (ABAP-specialized)

SAP AI Core uses OAuth2 client-credentials flow. The token is fetched lazily
and cached until 60 s before expiry.
"""

import json
import os
import time

import httpx
from anthropic import AsyncAnthropic
from openai import AsyncOpenAI

# ── Provider registry ─────────────────────────────────────────────────────────

PROVIDERS: dict[str, dict] = {
    "claude-sonnet": {
        "label": "Claude Sonnet 4.6",
        "client_type": "anthropic",
        "model_id": "claude-sonnet-4-6",
        "pricing": {"input": 3.0, "output": 15.0, "cache_read": 0.30},
        "supports_caching": True,
        "description": "Most capable — best for complex ABAP/AIF analysis",
    },
    "claude-haiku": {
        "label": "Claude Haiku 4.5",
        "client_type": "anthropic",
        "model_id": "claude-haiku-4-5-20251001",
        "pricing": {"input": 0.80, "output": 4.0, "cache_read": 0.08},
        "supports_caching": True,
        "description": "Fast & cheap — good for simple lookups",
    },
    "groq-llama3": {
        "label": "Groq — Llama 3.3 70B",
        "client_type": "groq",
        "model_id": "llama-3.3-70b-versatile",
        "pricing": {"input": 0.59, "output": 0.79, "cache_read": 0.0},
        "supports_caching": False,
        "description": "Open-source, very fast, ultra-low cost",
    },
    "aicore-gpt4o": {
        "label": "SAP AI Core — GPT-4o",
        "client_type": "aicore",
        "model_id": "gpt-4o",
        "deployment_id_env": "AICORE_DEPLOYMENT_ID",
        "pricing": {"input": 2.50, "output": 10.0, "cache_read": 0.0},
        "supports_caching": False,
        "description": "GPT-4o via SAP AI Core (BTP-hosted, EU data residency)",
    },
    "aicore-gpt4o-mini": {
        "label": "SAP AI Core — GPT-4o mini",
        "client_type": "aicore",
        "model_id": "gpt-4o-mini",
        "deployment_id_env": "AICORE_MINI_DEPLOYMENT_ID",
        "pricing": {"input": 0.15, "output": 0.60, "cache_read": 0.0},
        "supports_caching": False,
        "description": "GPT-4o mini via SAP AI Core — fast & cheap, good for simple queries",
    },
}

# ── Current provider (mutable, admin-controlled at runtime) ───────────────────

_current: str = os.environ.get("DEFAULT_PROVIDER", "aicore-gpt4o")


def get_key() -> str:
    return _current


def set_key(key: str) -> None:
    global _current
    if key not in PROVIDERS:
        raise ValueError(f"Unknown provider '{key}'. Valid: {list(PROVIDERS)}")
    _current = key


def get_config(key: str | None = None) -> dict:
    k = key or _current
    return {**PROVIDERS[k], "key": k}


def list_providers() -> list[dict]:
    return [{"key": k, **v, "active": k == _current} for k, v in PROVIDERS.items()]


def is_configured(key: str) -> bool:
    """Return True when the required API key / env vars are present."""
    cfg = PROVIDERS[key]
    if cfg["client_type"] == "anthropic":
        return bool(os.environ.get("ANTHROPIC_API_KEY"))
    if cfg["client_type"] == "groq":
        return bool(os.environ.get("GROQ_API_KEY"))
    if cfg["client_type"] == "aicore":
        return bool(
            os.environ.get("AICORE_CLIENT_ID")
            and os.environ.get("AICORE_CLIENT_SECRET")
            and os.environ.get(cfg["deployment_id_env"])
        )
    return False


# ── Standard clients ──────────────────────────────────────────────────────────

anthropic_client = AsyncAnthropic(api_key=os.environ.get("ANTHROPIC_API_KEY", ""))

groq_client = AsyncOpenAI(
    api_key=os.environ.get("GROQ_API_KEY", "no-key"),
    base_url="https://api.groq.com/openai/v1",
)

# ── SAP AI Core — OAuth2 token cache + client factory ────────────────────────

_AICORE_BASE_URL = os.environ.get("AICORE_BASE_URL", "https://api.ai.prod.eu-central-1.aws.ml.hana.ondemand.com")
_AICORE_AUTH_URL = os.environ.get("AICORE_AUTH_URL", "https://codemine-sa-lhxd53we.authentication.eu10.hana.ondemand.com")
_AICORE_CLIENT_ID = os.environ.get("AICORE_CLIENT_ID", "")
_AICORE_CLIENT_SECRET = os.environ.get("AICORE_CLIENT_SECRET", "")
_AICORE_RESOURCE_GROUP = os.environ.get("AICORE_RESOURCE_GROUP", "resource")

_aicore_token: str = ""
_aicore_token_expiry: float = 0.0


async def _fetch_aicore_token() -> str:
    """Fetch a new OAuth2 client-credentials token from SAP AI Core."""
    async with httpx.AsyncClient(timeout=15) as http:
        resp = await http.post(
            f"{_AICORE_AUTH_URL}/oauth/token",
            data={"grant_type": "client_credentials"},
            auth=(_AICORE_CLIENT_ID, _AICORE_CLIENT_SECRET),
        )
        resp.raise_for_status()
        data = resp.json()
    return data["access_token"], data.get("expires_in", 43200)


async def get_aicore_client(deployment_id_env: str) -> AsyncOpenAI:
    """
    Return an AsyncOpenAI client pointed at the given AI Core deployment.
    Fetches / refreshes the OAuth2 token as needed (cached, expires -60s early).
    """
    global _aicore_token, _aicore_token_expiry

    if not _aicore_token or time.time() >= _aicore_token_expiry:
        token, expires_in = await _fetch_aicore_token()
        _aicore_token = token
        _aicore_token_expiry = time.time() + expires_in - 60

    deployment_id = os.environ.get(deployment_id_env, "")
    # AI Core GPT-4o endpoint: /v2/inference/deployments/{id}/v1/chat/completions
    # The OpenAI SDK appends "chat/completions", so base_url must end with /v1
    return AsyncOpenAI(
        api_key=_aicore_token,
        base_url=f"{_AICORE_BASE_URL}/v2/inference/deployments/{deployment_id}/v1",
        default_headers={"AI-Resource-Group": _AICORE_RESOURCE_GROUP},
    )


# ── Message format converters ─────────────────────────────────────────────────

def to_openai_messages(system: str, history: list) -> list:
    """
    Convert Anthropic-format history + system string to an OpenAI messages list.
    Handles plain text, assistant text+tool_use blocks, and user tool_result blocks.
    """
    messages: list[dict] = [{"role": "system", "content": system}]

    for msg in history:
        role = msg["role"]
        content = msg["content"]

        if isinstance(content, str):
            messages.append({"role": role, "content": content})
            continue

        if role == "assistant":
            text = "".join(b.get("text", "") for b in content if b.get("type") == "text")
            tool_blocks = [b for b in content if b.get("type") == "tool_use"]
            oai: dict = {"role": "assistant", "content": text or None}
            if tool_blocks:
                oai["tool_calls"] = [
                    {
                        "id": b["id"],
                        "type": "function",
                        "function": {
                            "name": b["name"],
                            "arguments": json.dumps(b["input"]),
                        },
                    }
                    for b in tool_blocks
                ]
            messages.append(oai)

        elif role == "user":
            tool_results = [b for b in content if b.get("type") == "tool_result"]
            text_blocks = [b for b in content if b.get("type") == "text"]
            for tr in tool_results:
                rc = tr["content"]
                if isinstance(rc, list):
                    rc = "".join(c.get("text", "") for c in rc)
                messages.append({
                    "role": "tool",
                    "tool_call_id": tr["tool_use_id"],
                    "content": rc or "",
                })
            if text_blocks:
                messages.append({
                    "role": "user",
                    "content": "".join(b.get("text", "") for b in text_blocks),
                })

    return messages


def to_openai_tools(tools: list) -> list:
    """Convert Anthropic tool definitions to OpenAI function-calling format."""
    return [
        {
            "type": "function",
            "function": {
                "name": t["name"],
                "description": t.get("description", ""),
                "parameters": t.get("input_schema", {}),
            },
        }
        for t in tools
    ]
