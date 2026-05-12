"""
Shared session store — dict-like interface backed by SQLite.

Callers use it exactly as before (sessions[sid], sessions.get(sid, []),
sessions.pop(sid, None), len(sessions)) — the DB layer is transparent.
An in-memory cache avoids repeated DB reads for the same active session.
"""

from app import db


class _SessionStore:
    def __init__(self) -> None:
        self._cache: dict[str, list] = {}

    # ── dict-like interface ───────────────────────────────────────────────────

    def get(self, session_id: str, default=None):
        if session_id in self._cache:
            return self._cache[session_id]
        history = db.load_session(session_id)
        if history:
            self._cache[session_id] = history
            return history
        return default

    def __setitem__(self, session_id: str, history: list) -> None:
        self._cache[session_id] = history
        db.save_session(session_id, history)

    def __getitem__(self, session_id: str) -> list:
        result = self.get(session_id)
        if result is None:
            raise KeyError(session_id)
        return result

    def __contains__(self, session_id: object) -> bool:
        return session_id in self._cache or bool(db.load_session(str(session_id)))

    def __len__(self) -> int:
        return db.count_sessions()

    def pop(self, session_id: str, default=None):
        self._cache.pop(session_id, None)
        deleted = db.delete_session(session_id)
        return [] if deleted else default


# Module-level singleton — imported by agent.py and main.py
sessions = _SessionStore()
