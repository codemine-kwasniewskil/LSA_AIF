"""
Token usage tracking and limit enforcement.

In-memory accumulators are the working state.
Every API call is also persisted to SQLite (app/db.py) so counters survive
app restarts within the same day (and form a permanent audit log).
Daily totals reset automatically at midnight UTC.

record() accepts a provider_key so usage is broken down per provider.
"""

import json
import logging
import os
import time
from datetime import date
from threading import Lock

from app import db

logger = logging.getLogger(__name__)


class UsageTracker:
    def __init__(
        self,
        daily_token_limit: int = 500_000,
        session_token_limit: int = 50_000,
        session_request_limit: int = 30,
    ):
        self.daily_token_limit = daily_token_limit
        self.session_token_limit = session_token_limit
        self.session_request_limit = session_request_limit
        self._lock = Lock()
        self._reset_day()

    # ── internal helpers ─────────────────────────────────────────────────────

    def _reset_day(self) -> None:
        today = date.today().isoformat()
        self._today = today
        self._global: dict = {"input": 0, "output": 0, "cache_read": 0, "requests": 0}
        self._by_provider: dict[str, dict] = {}  # provider_key → same shape
        self._sessions: dict[str, dict] = {}
        # Reload persisted totals for today so a restart doesn't zero the counters
        try:
            for pkey, pdata in db.load_daily_totals(today).items():
                self._by_provider[pkey] = dict(pdata)
                for k in ("input", "output", "cache_read", "requests"):
                    self._global[k] += pdata[k]
            for sid, sdata in db.load_session_totals(today).items():
                self._sessions[sid] = {
                    "input": sdata["input"],
                    "output": sdata["output"],
                    "cache_read": sdata["cache_read"],
                    "requests": sdata["requests"],
                    "started_at": time.time(),  # approximate; exact value not critical
                }
        except Exception:
            # DB not yet initialised on very first import — silently continue
            pass

    def _ensure_fresh_day(self) -> None:
        if date.today().isoformat() != self._today:
            self._reset_day()

    def _get_or_create_session(self, sid: str) -> dict:
        if sid not in self._sessions:
            self._sessions[sid] = {
                "input": 0, "output": 0, "cache_read": 0,
                "requests": 0, "started_at": time.time(),
            }
        return self._sessions[sid]

    def _get_or_create_provider(self, key: str) -> dict:
        if key not in self._by_provider:
            self._by_provider[key] = {"input": 0, "output": 0, "cache_read": 0, "requests": 0}
        return self._by_provider[key]

    # ── public API ────────────────────────────────────────────────────────────

    def check_limits(self, session_id: str) -> tuple[bool, str]:
        """
        Call BEFORE each LLM request.
        Returns (allowed: bool, reason: str).
        """
        with self._lock:
            self._ensure_fresh_day()

            daily_used = self._global["input"] + self._global["output"]
            if daily_used >= self.daily_token_limit:
                return (
                    False,
                    f"The daily demo token budget ({self.daily_token_limit:,} tokens) has been "
                    f"reached. Please contact the demo organiser to continue.",
                )

            s = self._get_or_create_session(session_id)

            if s["requests"] >= self.session_request_limit:
                return (
                    False,
                    f"You have reached the session request limit "
                    f"({self.session_request_limit} messages). "
                    f"Please reload the page to start a new session.",
                )

            session_used = s["input"] + s["output"]
            if session_used >= self.session_token_limit:
                return (
                    False,
                    f"This session has used {session_used:,} tokens "
                    f"(limit: {self.session_token_limit:,}). "
                    f"Please reload the page to start a new session.",
                )

        return True, ""

    def record(self, session_id: str, usage: dict, provider_key: str) -> None:
        """
        Call AFTER each successful LLM response.
        usage: dict with keys input, output, cache_read (all ints).
        provider_key: one of the keys from provider.PROVIDERS.
        """
        inp = int(usage.get("input", 0) or 0)
        out = int(usage.get("output", 0) or 0)
        cache = int(usage.get("cache_read", 0) or 0)

        with self._lock:
            self._ensure_fresh_day()

            self._global["input"] += inp
            self._global["output"] += out
            self._global["cache_read"] += cache
            self._global["requests"] += 1

            p = self._get_or_create_provider(provider_key)
            p["input"] += inp
            p["output"] += out
            p["cache_read"] += cache
            p["requests"] += 1

            s = self._get_or_create_session(session_id)
            s["input"] += inp
            s["output"] += out
            s["cache_read"] += cache
            s["requests"] += 1

        # Persist to DB outside the lock (non-blocking for in-memory callers)
        try:
            db.record_usage(
                date=self._today,
                session_id=session_id,
                provider_key=provider_key,
                input_tokens=inp,
                output_tokens=out,
                cache_tokens=cache,
            )
        except Exception:
            logger.warning("Failed to persist usage to DB — counters still in memory", exc_info=True)

        logger.info(
            json.dumps({
                "event": "token_usage",
                "session_id": session_id,
                "provider": provider_key,
                "input": inp,
                "output": out,
                "cache_read": cache,
                "daily_total": self._global["input"] + self._global["output"],
                "daily_limit": self.daily_token_limit,
                "daily_pct": round(
                    100 * (self._global["input"] + self._global["output"]) / self.daily_token_limit,
                    1,
                ),
            })
        )

    def set_limits(
        self,
        daily_token_limit: int | None = None,
        session_token_limit: int | None = None,
        session_request_limit: int | None = None,
    ) -> None:
        """Update runtime limits. None values leave the existing limit unchanged."""
        with self._lock:
            if daily_token_limit is not None:
                self.daily_token_limit = max(1, daily_token_limit)
            if session_token_limit is not None:
                self.session_token_limit = max(1, session_token_limit)
            if session_request_limit is not None:
                self.session_request_limit = max(1, session_request_limit)

    def get_session(self, session_id: str) -> dict | None:
        """Return current token totals for one session, or None if unknown."""
        with self._lock:
            self._ensure_fresh_day()
            s = self._sessions.get(session_id)
            if s is None:
                return None
            total = s["input"] + s["output"]
            return {
                "input": s["input"],
                "output": s["output"],
                "cache_read": s["cache_read"],
                "requests": s["requests"],
                "total": total,
                "session_token_limit": self.session_token_limit,
                "session_request_limit": self.session_request_limit,
                "token_pct": round(100 * total / self.session_token_limit, 1) if self.session_token_limit else 0,
            }

    def reset_session(self, session_id: str) -> bool:
        """Remove a session's counters. Returns True if session existed."""
        with self._lock:
            if session_id in self._sessions:
                del self._sessions[session_id]
                return True
        return False

    def summary(self) -> dict:
        """Return full usage summary for the admin dashboard."""
        # Import here to avoid circular import at module load time
        from app.provider import PROVIDERS  # noqa: PLC0415

        with self._lock:
            self._ensure_fresh_day()
            daily_used = self._global["input"] + self._global["output"]

            # Per-provider cost + summary
            providers_summary = []
            total_cost = 0.0
            for key, pdata in self._by_provider.items():
                pricing = PROVIDERS.get(key, {}).get("pricing", {"input": 0, "output": 0, "cache_read": 0})
                cost = round(
                    pdata["input"] * pricing["input"] / 1_000_000
                    + pdata["output"] * pricing["output"] / 1_000_000
                    + pdata["cache_read"] * pricing.get("cache_read", 0) / 1_000_000,
                    4,
                )
                total_cost += cost
                providers_summary.append({
                    "key": key,
                    "label": PROVIDERS.get(key, {}).get("label", key),
                    "input": pdata["input"],
                    "output": pdata["output"],
                    "cache_read": pdata["cache_read"],
                    "requests": pdata["requests"],
                    "cost_usd": cost,
                })

            sessions_list = sorted(
                [
                    {
                        "session_id": sid,
                        "total_tokens": s["input"] + s["output"],
                        "input": s["input"],
                        "output": s["output"],
                        "cache_read": s["cache_read"],
                        "requests": s["requests"],
                        "started_ago_min": round((time.time() - s["started_at"]) / 60, 1),
                    }
                    for sid, s in self._sessions.items()
                ],
                key=lambda x: x["total_tokens"],
                reverse=True,
            )

            return {
                "date": self._today,
                "daily_used": daily_used,
                "daily_limit": self.daily_token_limit,
                "daily_remaining": max(0, self.daily_token_limit - daily_used),
                "daily_pct": round(100 * daily_used / self.daily_token_limit, 1),
                "global": dict(self._global),
                "session_count": len(self._sessions),
                "session_token_limit": self.session_token_limit,
                "session_request_limit": self.session_request_limit,
                "estimated_cost_usd": round(total_cost, 4),
                "by_provider": providers_summary,
                "sessions": sessions_list,
            }


# ── module-level singleton ────────────────────────────────────────────────────

tracker = UsageTracker(
    daily_token_limit=int(os.environ.get("MAX_DAILY_TOKENS", 1_000_000)),
    session_token_limit=int(os.environ.get("MAX_SESSION_TOKENS", 200_000)),
    session_request_limit=int(os.environ.get("MAX_SESSION_REQUESTS", 100)),
)
