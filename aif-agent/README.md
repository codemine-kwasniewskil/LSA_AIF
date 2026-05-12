# SAP AIF Knowledge Agent

Browser-based AI assistant that answers technical questions about the custom SAP AIF (Application Interface Framework) interfaces of the HKR Land Sachsen-Anhalt system (THKR namespace, operated by T-Systems).

Powered by Claude Sonnet 4.6 (Anthropic) with tool use. Deployable to SAP BTP Cloud Foundry.

---

## What it does

Users open a chat UI in the browser and ask questions in natural language (German or English). The agent reads the local data files — AIF configuration tables (xlsx), ABAP source code (abapgit), and pre-generated README documentation — and answers with precise technical detail.

**Example questions it handles:**
- "What does interface I_0004_001 (EMSA) do?"
- "List all FREMDV inbound interfaces"
- "Show me the action pipeline for I_0013_002"
- "Which ABAP function module implements ACT_GP_INS?"
- "How does the IST-Rückmeldung outbound work?"
- "What fields are mapped in interface I_0024_001 (Überbrückungshilfe)?"

---

## Project structure

```
aif-agent/
├── manifest.yml              SAP BTP Cloud Foundry deployment config
├── requirements.txt          Python dependencies
├── runtime.txt               Python 3.11 pin for CF buildpack
├── Procfile                  uvicorn start command (CF fallback)
├── .cfignore                 Files excluded from cf push
├── setup_data.py             One-time data copy from parent lsa_aif_doc/
│
├── app/
│   ├── main.py               FastAPI app — routes, SSE /chat, /admin endpoints
│   ├── agent.py              Claude async streaming + tool-use loop
│   ├── tools.py              5 tool implementations (xlsx + abap file access)
│   ├── system_prompt.py      AIF specialist system prompt with project context
│   ├── usage_tracker.py      Token counter, daily/session limits, cost estimate
│   ├── state.py              Shared in-memory session store
│   └── static/
│       ├── index.html        Chat UI (Tailwind CSS, marked.js, SSE streaming)
│       └── admin.html        Token usage dashboard (auto-refresh, reset buttons)
│
└── data/                     Created by setup_data.py — bundled with cf push
    ├── xlsx/                 AIF configuration tables (aif_t_finf_de, ifact, fmap, func)
    ├── docs/                 Pre-generated README documentation (*.md)
    └── abapgit/              Full abapgit repository (#THKR#AIF_*)
```

**Total bundle size pushed to CF:** ~7–8 MB (data is 6 MB, code is ~1 MB).

---

## Architecture

```
Browser (Chat UI / Admin Dashboard)
        │  POST /chat → SSE streaming
        │  GET  /admin?token=…
        ▼
FastAPI (Python, SAP BTP CF)
        ├── AsyncAnthropic client — claude-sonnet-4-6
        ├── Tool-use loop (runs until no more tool calls)
        ├── UsageTracker — daily + session token limits
        └── Tools (read-only, sync, run in asyncio thread pool):
            ├── search_interfaces      ← aif_t_finf_de.xlsx
            ├── get_interface_details  ← all 4 xlsx tables joined
            ├── get_interface_readme   ← pre-generated *.md files
            ├── search_abap_code       ← grep across all .abap files
            └── read_abap_file         ← full source of one .abap file
```

### Data sources (bundled in `data/`)

| Folder | Source | Content |
|--------|--------|---------|
| `data/xlsx/` | `lsa_aif_doc/*.xlsx` | AIF_T_FINF (interface defs), AIF_T_IFACT (actions), AIF_T_FUNC (function modules), AIF_T_FMAP (field mappings) |
| `data/docs/` | `lsa_aif_doc/*.md` | Pre-generated interface README files |
| `data/abapgit/` | `lsa_aif_doc/#THKR#AIF_*/` | Full abapgit repo — fremdv, havweb, zallge, poli subfolders |

### AIF interfaces covered

| Namespace | Interfaces | Description |
|-----------|-----------|-------------|
| FREMDV | 31 inbound + 17 outbound | Foreign system integrations (SolumSTAR, EMSA, ELVIS, EDAS, Polizei, SERiD, …) |
| HAVWEB | 3 inbound | Budget plan upload (Einzelplan, Funktionenplan, Gruppierungsplan) |
| LABLMT | 1 | Limited info |
| NJIT | 1 | Limited info |

---

## Token usage control

All limits are set via CF environment variables and enforced before every Claude API call.

| Limit | Default | Env var |
|-------|---------|---------|
| Daily token budget | 500,000 | `MAX_DAILY_TOKENS` |
| Per-session tokens | 50,000 | `MAX_SESSION_TOKENS` |
| Per-session requests | 30 messages | `MAX_SESSION_REQUESTS` |

When a limit is hit the user receives a clear message in the chat UI. No tokens are spent.

**Cost reference (Claude Sonnet 4.6):**
- Input: $3.00 / 1M tokens
- Output: $15.00 / 1M tokens
- Cache read: $0.30 / 1M tokens
- Typical demo day (10 users × 20 questions): ~$1–3

**Admin dashboard** at `/admin?token=<ADMIN_TOKEN>`:
- Daily budget progress bar (green → yellow → red)
- Per-session token and request breakdown
- Running cost estimate
- Manual session reset button
- Auto-refreshes every 10 seconds

**Structured log line** emitted after every API call (captured by CF log drain / BTP Kibana):
```json
{"event":"token_usage","session_id":"…","input":1234,"output":456,"daily_total":12000,"daily_pct":2.4}
```

---

## Local development

### Prerequisites
- Python 3.11+
- Anthropic API key

### First-time setup

```bash
# 1. From the aif-agent/ directory — copy data files from parent lsa_aif_doc/
python setup_data.py

# 2. Install dependencies
pip install -r requirements.txt

# 3. Set secrets
export ANTHROPIC_API_KEY=sk-ant-...
export ADMIN_TOKEN=my-local-password   # any string, just for dev

# 4. Start the server
uvicorn app.main:app --reload --port 9000
```

**URLs:**
- Chat UI: `http://localhost:9000`
- Admin dashboard: `http://localhost:9000/admin?token=my-local-password`
- Health check: `http://localhost:9000/health`

---

## SAP BTP Cloud Foundry deployment

### One-time setup

```bash
# Copy data files into data/ (required before cf push)
python setup_data.py

# Login to BTP CF
cf login -a https://api.cf.<region>.hana.ondemand.com \
         -o <your-org> -s <your-space>
```

### Push and configure

```bash
# Push without starting (secrets not set yet)
cf push --no-start

# Set secrets — never put these in manifest.yml or git
cf set-env aif-knowledge-agent ANTHROPIC_API_KEY sk-ant-...
cf set-env aif-knowledge-agent ADMIN_TOKEN your-secure-password

# Optionally adjust token limits
cf set-env aif-knowledge-agent MAX_DAILY_TOKENS 500000
cf set-env aif-knowledge-agent MAX_SESSION_TOKENS 50000
cf set-env aif-knowledge-agent MAX_SESSION_REQUESTS 30

# Start the app
cf start aif-knowledge-agent
```

### Verify

```bash
cf logs aif-knowledge-agent --recent
cf app aif-knowledge-agent
```

**Access URLs:**
- Chat UI: `https://aif-knowledge-agent.<cf-domain>.hana.ondemand.com`
- Admin: `https://aif-knowledge-agent.<cf-domain>.hana.ondemand.com/admin?token=your-secure-password`

### Updating data files

When xlsx tables or abapgit source are updated in `lsa_aif_doc/`, re-run setup and re-push:

```bash
python setup_data.py
cf push
```

### CF service requirements

| Service | Required | Purpose |
|---------|----------|---------|
| Cloud Foundry runtime | Yes | App hosting |
| XSUAA | Optional | Enterprise SSO (add for production) |
| Credential Store | Optional | Better secret management than env vars |
| Object Store / HANA Cloud | No | Data is 6 MB, bundled in the app |

---

## Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/` | none | Chat UI |
| `GET` | `/health` | none | CF health check — returns `{"status":"ok"}` |
| `POST` | `/chat` | none | SSE streaming chat. Body: `{"message":"…","session_id":"…"}` |
| `GET` | `/admin` | `X-Admin-Token` header or `?token=` | Admin dashboard UI |
| `GET` | `/admin/usage` | same | Usage JSON for API consumers |
| `POST` | `/admin/reset-session/{id}` | same | Clear one session's counters and history |

### Chat SSE event types

```
data: {"type":"text",      "content":"streamed token text"}
data: {"type":"tool_call", "name":"search_interfaces"}
data: {"type":"done"}
data: {"type":"error",     "content":"limit message or error"}
```

---

## Known limitations

- **Session state resets on app restart** — in-memory only, acceptable for demo use. Add Redis or a persistent store for production.
- **Single worker** — `--workers 1` in the start command is required so all requests share the same in-memory session dict. For horizontal scaling, move sessions to Redis.
- **No authentication on chat UI** — suitable for internal demo access. Add XSUAA binding for enterprise SSO.
- **Daily counter resets** — based on UTC midnight. The counter also resets if the app is restarted during the day.
