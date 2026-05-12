# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository overview

This repository is the source of truth for **SAP AIF (Application Interface Framework) interfaces** for HKR Land Sachsen-Anhalt (namespace `/THKR/`, operated by T-Systems). It contains:

- Raw data files: `.xlsx` AIF configuration tables and abapgit exports (`.abap` source files)
- Generated documentation: `*.md` files per interface
- `aif-agent/` — a FastAPI + Claude web app that answers questions about the interfaces

## aif-agent: local development

```bash
# From aif-agent/ directory

# 1. Copy data from parent directory (required before first run and after xlsx/abap updates)
python setup_data.py

# 2. Install dependencies
pip install -r requirements.txt

# 3. Set env vars (or use .env file)
export ANTHROPIC_API_KEY=sk-ant-...
export ADMIN_TOKEN=any-string

# 4. Start the server
uvicorn app.main:app --reload --port 9000
```

URLs:
- Chat UI: `http://localhost:9000`
- Admin dashboard: `http://localhost:9000/admin?token=<ADMIN_TOKEN>`
- Health: `http://localhost:9000/health`

## aif-agent: architecture

```
Browser (Chat UI / Admin)
        │  POST /chat → SSE streaming
        ▼
FastAPI  app/main.py
        ├── app/agent.py       — async tool-use loop, SSE event generator
        ├── app/tools.py       — 5 read-only tools (xlsx + abap file access)
        ├── app/provider.py    — multi-provider registry (Claude, Groq, SAP AI Core)
        ├── app/usage_tracker.py — daily/session token limits + cost estimates
        ├── app/state.py       — _SessionStore (dict-like, backed by SQLite via db.py)
        ├── app/db.py          — SQLite session history + token audit log
        ├── app/system_prompt.py — AIF specialist system prompt (cached via Anthropic ephemeral cache)
        └── app/static/        — index.html (chat UI), admin.html (dashboard)
```

### Data flow
1. `POST /chat` → `agent_stream()` in `agent.py`
2. Agent loops: calls LLM → gets tool calls → `dispatch_tool()` in `tools.py` → back to LLM
3. Tool results are truncated to `MAX_TOOL_RESULT_CHARS = 4000` chars
4. History stored in `state.sessions` (in-memory cache + SQLite via `db.py`)
5. Each LLM call is tracked by `usage_tracker.py`; limits enforced before calling

### Five tools exposed to Claude
| Tool | Data source |
|------|------------|
| `search_interfaces` | `data/xlsx/aif_t_finf_de.xlsx` |
| `get_interface_details` | All 4 xlsx tables joined |
| `get_interface_readme` | `data/docs/*.md` |
| `search_abap_code` | grep across `data/abapgit/**/*.abap` |
| `read_abap_file` | Full source of one `.abap` file |

All tools are synchronous; called via `asyncio.to_thread()` from the async agent.

### Multi-provider support
`provider.py` supports: `claude-sonnet` (default), `claude-haiku`, `groq-llama3`, `aicore-gpt4o`, `aicore-gpt4o-mini`, `aicore-rpt1`. Active provider is switched at runtime via `POST /admin/provider`. History is always stored in Anthropic dict format; converted on-the-fly for OpenAI-compatible providers.

### Session persistence
`state.py` wraps a `_SessionStore` that looks like a dict but persists to SQLite (`data/agent_state.db`). Locally this survives `uvicorn --reload` restarts. On CF it resets on `cf push` or app crash.

## aif-agent: SAP BTP Cloud Foundry deployment

```bash
# Run setup_data.py first, then:
cf push --no-start
cf set-env aif-knowledge-agent ANTHROPIC_API_KEY sk-ant-...
cf set-env aif-knowledge-agent ADMIN_TOKEN your-password
cf start aif-knowledge-agent

# After xlsx/abap updates:
python setup_data.py
cf push
```

The app must run with `--workers 1` (enforced in `manifest.yml`) because sessions are in-memory. Disk quota is 512 MB; total bundle ~7–8 MB.

## Data files (parent directory — `lsa_aif_doc/`)

These are the authoritative source files. `setup_data.py` copies them into `aif-agent/data/`:

| File/folder | Contents |
|-------------|----------|
| `*.xlsx` | AIF config tables: `aif_t_finf_de` (interface defs), `aif_t_ifact` (actions), `aif_t_func` (function modules), `aif_t_fmap` (field mappings) |
| `*.md` | Generated interface documentation |
| `#THKR#AIF_*/` | abapgit export — subfolders: `fremdv`, `havweb`, `zallge`, `poli` |

`read_aif.ps1` is a PowerShell script to inspect a single interface directly from the xlsx files without the agent (usage: `.\read_aif.ps1 -IfName O_0027_002 -NS FREMDV`).

## Token limits (env vars)

| Env var | Default |
|---------|---------|
| `MAX_DAILY_TOKENS` | 500,000 |
| `MAX_SESSION_TOKENS` | 50,000 |
| `MAX_SESSION_REQUESTS` | 30 |
| `AGENT_DB_PATH` | `data/agent_state.db` |

## Key constants in agent.py

- `MAX_TOKENS = 1500` — max output tokens per LLM call
- `HISTORY_WINDOW = 10` — last N message pairs sent to LLM
- `MAX_TOOL_ITERATIONS = 5` — tool-use loop limit per turn
- `MAX_RETRIES = 3` — API call retries on transient errors
