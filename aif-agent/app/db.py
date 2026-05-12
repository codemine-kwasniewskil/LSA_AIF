"""
SQLite persistence layer for session history and token usage.

Database file: data/agent_state.db
  — local dev: survives uvicorn --reload restarts
  — CF: survives within one running instance; resets on cf push / app crash

Tables
------
session_history   one row per session, full JSON message list
token_usage       one row per LLM API call (audit log)
"""

import json
import logging
import os
import sqlite3
from threading import Lock

logger = logging.getLogger(__name__)

_DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")
_DB_PATH = os.environ.get(
    "AGENT_DB_PATH",
    os.path.join(_DATA_DIR, "agent_state.db"),
)
_write_lock = Lock()
_initialized = False


# ── connection & init ─────────────────────────────────────────────────────────

def _connect() -> sqlite3.Connection:
    conn = sqlite3.connect(_DB_PATH, check_same_thread=False, timeout=10)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL")   # allow concurrent readers
    conn.execute("PRAGMA foreign_keys=ON")
    return conn


def init() -> None:
    """Create tables if they don't exist. Idempotent — safe to call multiple times."""
    global _initialized
    if _initialized:
        return
    os.makedirs(os.path.dirname(_DB_PATH), exist_ok=True)
    conn = _connect()
    try:
        conn.executescript("""
            CREATE TABLE IF NOT EXISTS session_history (
                session_id  TEXT PRIMARY KEY NOT NULL,
                history     TEXT NOT NULL,
                updated_at  TEXT NOT NULL DEFAULT (datetime('now'))
            );

            CREATE TABLE IF NOT EXISTS token_usage (
                id            INTEGER PRIMARY KEY AUTOINCREMENT,
                date          TEXT    NOT NULL,
                session_id    TEXT    NOT NULL,
                provider_key  TEXT    NOT NULL,
                input_tokens  INTEGER NOT NULL DEFAULT 0,
                output_tokens INTEGER NOT NULL DEFAULT 0,
                cache_tokens  INTEGER NOT NULL DEFAULT 0,
                created_at    TEXT    NOT NULL DEFAULT (datetime('now'))
            );
            CREATE INDEX IF NOT EXISTS idx_usage_date ON token_usage(date);
            CREATE INDEX IF NOT EXISTS idx_usage_session ON token_usage(session_id, date);
        """)
        conn.commit()
        _initialized = True
        logger.info("DB initialised at %s", _DB_PATH)
    finally:
        conn.close()


def _ensure_init() -> None:
    if not _initialized:
        init()


# ── session history ───────────────────────────────────────────────────────────

def save_session(session_id: str, history: list) -> None:
    _ensure_init()
    payload = json.dumps(history, ensure_ascii=False)
    with _write_lock:
        conn = _connect()
        try:
            conn.execute(
                """INSERT INTO session_history(session_id, history, updated_at)
                   VALUES(?, ?, datetime('now'))
                   ON CONFLICT(session_id) DO UPDATE SET
                       history    = excluded.history,
                       updated_at = excluded.updated_at""",
                (session_id, payload),
            )
            conn.commit()
        finally:
            conn.close()


def load_session(session_id: str) -> list:
    _ensure_init()
    conn = _connect()
    try:
        row = conn.execute(
            "SELECT history FROM session_history WHERE session_id = ?",
            (session_id,),
        ).fetchone()
    finally:
        conn.close()
    if row:
        try:
            return json.loads(row["history"])
        except Exception:
            logger.warning("Corrupt session history for %s — discarding", session_id)
    return []


def delete_session(session_id: str) -> bool:
    """Remove session history. Returns True if a row was deleted."""
    _ensure_init()
    with _write_lock:
        conn = _connect()
        try:
            cur = conn.execute(
                "DELETE FROM session_history WHERE session_id = ?", (session_id,)
            )
            conn.commit()
            return cur.rowcount > 0
        finally:
            conn.close()


def count_sessions() -> int:
    _ensure_init()
    conn = _connect()
    try:
        return conn.execute("SELECT COUNT(*) FROM session_history").fetchone()[0]
    finally:
        conn.close()


def list_sessions() -> list:
    """
    Return all sessions ordered by most-recently updated first.
    Each entry: {session_id, preview (first user message, truncated), updated_at}.
    """
    _ensure_init()
    conn = _connect()
    try:
        rows = conn.execute(
            "SELECT session_id, history, updated_at FROM session_history ORDER BY updated_at DESC"
        ).fetchall()
    finally:
        conn.close()
    result = []
    for row in rows:
        preview = ""
        try:
            history = json.loads(row["history"])
            for msg in history:
                if msg.get("role") == "user" and isinstance(msg.get("content"), str):
                    preview = msg["content"][:80]
                    break
        except Exception:
            pass
        result.append({
            "session_id": row["session_id"],
            "preview": preview or "(empty)",
            "updated_at": row["updated_at"],
        })
    return result


# ── token usage ───────────────────────────────────────────────────────────────

def record_usage(
    date: str,
    session_id: str,
    provider_key: str,
    input_tokens: int,
    output_tokens: int,
    cache_tokens: int,
) -> None:
    _ensure_init()
    with _write_lock:
        conn = _connect()
        try:
            conn.execute(
                """INSERT INTO token_usage
                   (date, session_id, provider_key, input_tokens, output_tokens, cache_tokens)
                   VALUES(?, ?, ?, ?, ?, ?)""",
                (date, session_id, provider_key, input_tokens, output_tokens, cache_tokens),
            )
            conn.commit()
        finally:
            conn.close()


def load_daily_totals(date: str) -> dict:
    """
    Return per-provider aggregated totals for *date*.
    Shape: { provider_key: {"input": int, "output": int, "cache_read": int, "requests": int} }
    """
    _ensure_init()
    conn = _connect()
    try:
        rows = conn.execute(
            """SELECT provider_key,
                      COALESCE(SUM(input_tokens),  0) AS inp,
                      COALESCE(SUM(output_tokens), 0) AS out,
                      COALESCE(SUM(cache_tokens),  0) AS cache,
                      COUNT(*)                        AS reqs
               FROM token_usage
               WHERE date = ?
               GROUP BY provider_key""",
            (date,),
        ).fetchall()
    finally:
        conn.close()
    return {
        r["provider_key"]: {
            "input": r["inp"],
            "output": r["out"],
            "cache_read": r["cache"],
            "requests": r["reqs"],
        }
        for r in rows
    }


def load_session_totals(date: str) -> dict:
    """
    Return per-session aggregated totals for *date*.
    Shape: { session_id: {"input": int, "output": int, "cache_read": int,
                          "requests": int, "started_at_str": str} }
    """
    _ensure_init()
    conn = _connect()
    try:
        rows = conn.execute(
            """SELECT session_id,
                      COALESCE(SUM(input_tokens),  0) AS inp,
                      COALESCE(SUM(output_tokens), 0) AS out,
                      COALESCE(SUM(cache_tokens),  0) AS cache,
                      COUNT(*)                        AS reqs,
                      MIN(created_at)                 AS started
               FROM token_usage
               WHERE date = ?
               GROUP BY session_id""",
            (date,),
        ).fetchall()
    finally:
        conn.close()
    return {
        r["session_id"]: {
            "input": r["inp"],
            "output": r["out"],
            "cache_read": r["cache"],
            "requests": r["reqs"],
            "started_at_str": r["started"],
        }
        for r in rows
    }
