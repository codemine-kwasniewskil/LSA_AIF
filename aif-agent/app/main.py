"""
FastAPI application entry point.

Routes:
  GET  /              — chat UI (index.html)
  GET  /health        — CF health check
  POST /chat          — SSE streaming chat endpoint
  GET  /admin         — admin dashboard (requires X-Admin-Token or ?token=)
  GET  /admin/usage   — JSON usage data
  POST /admin/reset-session/{sid} — clear one session's token counters
"""

import logging
import os
import uuid

# Load .env file when present (local dev). No-op in CF where env vars are set via cf set-env.
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import FileResponse, HTMLResponse, JSONResponse, StreamingResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

from app import db
from app import provider as prov
from app import state
from app.agent import agent_stream
from app.usage_tracker import tracker

# ── logging ───────────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s — %(message)s",
)
logger = logging.getLogger(__name__)

# ── app ───────────────────────────────────────────────────────────────────────
app = FastAPI(title="SAP AIF Knowledge Agent", docs_url=None, redoc_url=None)

STATIC_DIR = os.path.join(os.path.dirname(__file__), "static")
app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")

ADMIN_TOKEN = os.environ.get("ADMIN_TOKEN", "admin-change-me")


# ── health ────────────────────────────────────────────────────────────────────


@app.get("/health")
async def health():
    return {"status": "ok", "sessions": len(state.sessions)}


# ── chat UI ───────────────────────────────────────────────────────────────────


@app.get("/")
async def index():
    return FileResponse(os.path.join(STATIC_DIR, "index.html"))


# ── chat endpoint ─────────────────────────────────────────────────────────────


MAX_USER_MSG_CHARS = 1_000


class ChatRequest(BaseModel):
    message: str
    session_id: str | None = None


class ProviderRequest(BaseModel):
    provider: str


@app.post("/chat")
async def chat(req: ChatRequest):
    if not req.message.strip():
        raise HTTPException(status_code=400, detail="message is required")
    if len(req.message) > MAX_USER_MSG_CHARS:
        raise HTTPException(status_code=400, detail=f"Message too long (max {MAX_USER_MSG_CHARS} chars)")

    # Assign or reuse session ID
    sid = req.session_id if req.session_id else str(uuid.uuid4())

    async def event_stream():
        async for chunk in agent_stream(req.message.strip(), sid):
            yield chunk

    return StreamingResponse(
        event_stream(),
        media_type="text/event-stream",
        headers={
            "X-Session-Id": sid,
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",   # disable nginx buffering (BTP router)
        },
    )


# ── admin: auth helper ────────────────────────────────────────────────────────


def _check_admin(request: Request) -> None:
    token = (
        request.headers.get("X-Admin-Token")
        or request.query_params.get("token")
        or ""
    )
    if token != ADMIN_TOKEN:
        raise HTTPException(status_code=403, detail="Invalid admin token")


# ── admin: dashboard page ─────────────────────────────────────────────────────


@app.get("/admin")
async def admin_ui(request: Request):
    _check_admin(request)
    return FileResponse(os.path.join(STATIC_DIR, "admin.html"))


# ── admin: usage JSON ─────────────────────────────────────────────────────────


@app.get("/admin/usage")
async def admin_usage(request: Request):
    _check_admin(request)
    return JSONResponse(tracker.summary())


# ── admin: reset a session ────────────────────────────────────────────────────


@app.post("/admin/reset-session/{session_id}")
async def admin_reset_session(session_id: str, request: Request):
    _check_admin(request)
    removed_tracker = tracker.reset_session(session_id)
    removed_history = state.sessions.pop(session_id, None) is not None
    return {
        "session_id": session_id,
        "tracker_cleared": removed_tracker,
        "history_cleared": removed_history,
    }


# ── chat sessions list ────────────────────────────────────────────────────────


@app.get("/chat/sessions")
async def chat_sessions():
    """List all sessions (most-recent first) with a preview of the first user message."""
    return JSONResponse(db.list_sessions())


# ── chat history ─────────────────────────────────────────────────────────────


@app.get("/chat/history/{session_id}")
async def chat_history(session_id: str):
    """Return visible conversation messages for a session (no auth — session_id is the token)."""
    raw = state.sessions.get(session_id, [])
    visible = []
    for msg in raw:
        role = msg.get("role")
        content = msg.get("content")
        if role == "user":
            if isinstance(content, str):
                visible.append({"role": "user", "text": content})
            # skip tool_result batches (list with type == "tool_result")
        elif role == "assistant":
            if isinstance(content, list):
                text = " ".join(b["text"] for b in content if b.get("type") == "text")
                if text:
                    visible.append({"role": "assistant", "text": text})
    return JSONResponse(visible)


# ── admin: limits management ─────────────────────────────────────────────────


class LimitsRequest(BaseModel):
    daily_token_limit: int | None = None
    session_token_limit: int | None = None
    session_request_limit: int | None = None


@app.get("/admin/limits")
async def admin_get_limits(request: Request):
    _check_admin(request)
    return JSONResponse({
        "daily_token_limit": tracker.daily_token_limit,
        "session_token_limit": tracker.session_token_limit,
        "session_request_limit": tracker.session_request_limit,
    })


@app.post("/admin/limits")
async def admin_set_limits(req: LimitsRequest, request: Request):
    _check_admin(request)
    tracker.set_limits(
        daily_token_limit=req.daily_token_limit,
        session_token_limit=req.session_token_limit,
        session_request_limit=req.session_request_limit,
    )
    return JSONResponse({
        "ok": True,
        "daily_token_limit": tracker.daily_token_limit,
        "session_token_limit": tracker.session_token_limit,
        "session_request_limit": tracker.session_request_limit,
    })


# ── public: session usage ─────────────────────────────────────────────────────


@app.get("/chat/usage/{session_id}")
async def chat_usage(session_id: str):
    """Return token usage for one session (session_id is the auth token)."""
    data = tracker.get_session(session_id)
    if data is None:
        return JSONResponse({"input": 0, "output": 0, "cache_read": 0,
                             "requests": 0, "total": 0, "token_pct": 0,
                             "session_token_limit": tracker.session_token_limit,
                             "session_request_limit": tracker.session_request_limit})
    return JSONResponse(data)


# ── public: current provider ──────────────────────────────────────────────────


@app.get("/chat/provider")
async def chat_provider():
    """Return the currently active provider label (no auth — display only)."""
    cfg = prov.get_config()
    return JSONResponse({"key": cfg["key"], "label": cfg["label"]})


# ── admin: provider management ────────────────────────────────────────────────


@app.get("/admin/provider")
async def admin_get_provider(request: Request):
    _check_admin(request)
    providers = prov.list_providers()
    # Annotate each with whether its API key is configured
    for p in providers:
        p["configured"] = prov.is_configured(p["key"])
    return JSONResponse({"current": prov.get_key(), "providers": providers})


@app.post("/admin/provider")
async def admin_set_provider(req: ProviderRequest, request: Request):
    _check_admin(request)
    try:
        prov.set_key(req.provider)
        cfg = prov.get_config()
        return {"ok": True, "current": cfg["key"], "label": cfg["label"]}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
