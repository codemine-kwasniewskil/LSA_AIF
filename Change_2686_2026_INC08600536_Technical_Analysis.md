# Change 2686/2026 / INC08600536 — Technical Analysis

**Ticket:** INC08600536  
**Change:** 2686/2026  
**System:** SAP AIF — HKR Land Sachsen-Anhalt (namespace `/THKR/`, operated by T-Systems)

---

## Change Request 1 — Infomail: Errors-Only Output + CSV Format

### Background

Processes STIEWI (SMS-Reise), PTRAVEL (KIDICAP Ptravel Reiko), and SAMBA (Beihilfe) currently receive an Infomail after each AIF processing run containing **all records** — both successes and errors — as a fixed-width RTF attachment. The customer requests:

- Only **error records** in the mail  
- Format changed to **CSV**

### Affected Interfaces

| NS | IFNAME | IFVER | Description | Direction |
|----|--------|-------|-------------|-----------|
| FREMDV | I_0032_001 | 00001 | SMS-Reise (Stiewi) | Inbound |
| FREMDV | I_0009_001 | 00001 | KIDICAP Ptravel Reiko | Inbound |
| FREMDV | I_0010_001 | 00001 | Beihilfe Samba | Inbound |

> Note: STIEWI, PTRAVEL, SAMBA are process names appearing in interface descriptions — all three interfaces reside in namespace **FREMDV**.

### Current Technical Mechanism

All three interfaces share the same post-processing action chain:

| Step | Action | Function Module | Description |
|------|--------|-----------------|-------------|
| 900 | ACT_APN | `/THKR/AIF_ZALLGE_ACT_APN` | Aggregate processing statistics (APN protocol) |
| 910 | ACT_PROT_LST | `/THKR/AIF_ZALLGE_ACT_PROT_LST` | Generate and email the LST protocol |
| 999 | ACT_DEL_PROC_TAB | — | Cleanup |

Additionally, I_0009_001 has:

| Step | Action | FM | Description |
|------|--------|----|-------------|
| 925 | ACT_WRITE_ERR_TO_TAB | `/THKR/AIF_FREMDV_ACT_WRT_RK_ER` | Write errors to table |
| 930 | ACT_SEND_RKO_TO_POL | `/THKR/AIF_FREMDV_ACT_FWD_RK_PO` | Forward to police interface |

**What the LST is:**

The LST (Liste / Übergabeprotokoll) is a fixed-width plain-text processing report built by class `/THKR/CL_AIF_FILE_BASICS`, method `CREATE_LST_BODY`. It contains one entry per processed record (4 lines per record):

```
Typ | Quelle | Satz-Nr | Pos | Kap | Titel | Ukto | OEH | Fällig | Soll
Kassenzeichen | BVB/Referenz | Aktenzeichen | Buch-Nr.
Name | PLZ | Ort | HÜL-Nr.
Zahlungsgrund
```

The report is sent as an **RTF email attachment** via `CL_BCS` (`i_attachment_type = 'rtf'`). The `CREATE_LST_BODY` method loops over all records and routes each to either `CREATE_LST_SUCCESS` (status `S`) or `CREATE_LST_ERROR` (status `E`/`A`) — both are included in the output.

**Relevant source files:**

- Class: `src/#thkr#sst/#thkr#aif/#thkr#aif_zallge/#thkr#cl_aif_file_basics.clas.abap`
- Action FM: `src/#thkr#sst/#thkr#aif/#thkr#aif_zallge/#thkr#aif_zallge_act.fugr.#thkr#aif_zallge_act_prot_lst.abap`

### Gap Analysis

| # | Gap | Location |
|---|-----|----------|
| 1 | Mail contains both success and error records | `CREATE_LST_BODY` in `/THKR/CL_AIF_FILE_BASICS` |
| 2 | File format is fixed-width text wrapped in RTF | `SEND_MAIL` — hardcoded `i_attachment_type = 'rtf'` |
| 3 | No CSV serialisation logic exists in the codebase | — |

### Proposed Solution

**Approach: New standalone FM (low risk — no changes to shared class)**

Create a new function module `/THKR/AIF_ZALLGE_ACT_PROT_ERR_CSV` in function group `#THKR#AIF_ZALLGE_ACT` that:

1. Loops over `DATA-LST` records
2. Calls `/THKR/CL_AIF_FILE_BASICS=>GET_PROCESSING_STATUS` to identify error records (status `E` or `A`) — skips successes
3. Serialises error records to CSV (`;`-delimited)
4. Sends mail reusing `GET_RECIPIENT_LIST` and `GET_MAILS_FOR_RECIPIENT_LIST` from `/THKR/CL_AIF_FILE_BASICS`, but with `i_attachment_type = 'txt'` and a `.csv` filename suffix

**Proposed CSV field set:**

```
TYP;QUELLE;SATZNR;POS;KAP;TITEL;UKTO;OEH;FAELLIG;SOLL;FEHLERNUMMER;FEHLERTEXT
```

**AIF configuration changes:**

| Table | Change |
|-------|--------|
| `aif_t_func` | INSERT: `NS=ZALLGE, IFACTION=ACT_PROT_LST_ERR_CSV, FUNCNR=10, FUNCTION=/THKR/AIF_ZALLGE_ACT_PROT_ERR_CSV` |
| `aif_t_ifact` | UPDATE step 910 on I_0009_001, I_0010_001, I_0032_001 from `ACT_PROT_LST` → `ACT_PROT_LST_ERR_CSV` |

> The existing `ACT_PROT_LST` action remains unchanged — no regression risk for other interfaces using it.

### Estimated Complexity: **Medium**

New FM + 1 `aif_t_func` entry + 3 `aif_t_ifact` record updates. CSV formatting logic must be written from scratch (no existing builder in codebase). Mail send infrastructure already works; only attachment type and content change. Customising transport required for `aif_t_ifact` / `aif_t_func` entries.

---

## Change Request 2 — FV0006 eStA: Per-Department Ist-Rückmeldung

### Background

Interface FV0006 (eSTA / GeKo-Geldstrafe) currently sends one **Ist-Rückmeldung** (actual-value feedback) file covering all departments in a single run. The customer requests **separate output files per department**.

> **Note:** As of the date of this analysis, the official change request document from the customer is still missing. Implementation should be blocked until it is received.

### Affected Interfaces

| NS | IFNAME | IFVER | Description | Direction |
|----|--------|-------|-------------|-----------|
| FREMDV | I_0006_001 | 00001 | eSTA (GeKo-Geldstrafe) | Inbound |
| FREMDV | O_0006_002 | 00001 | IST-Rückmeldung eSTA (GeKo-Geldstrafe) | Outbound |

The relevant interface for this change is **O_0006_002** (outbound feedback).

### Current Technical Mechanism

| Step | Action | Function Module |
|------|--------|-----------------|
| 0 | IST_RUECK_CSV | `/THKR/AIF_FREMDV_ACT_RUECK` |

The FM `/THKR/AIF_FREMDV_ACT_RUECK`:

1. Takes the full `T_RUECK` table — all departments combined in one table
2. Calls `lo_rueck->modify_output_tab()` to format lines
3. Writes a **single output file** using logical filename `/THKR/AIF_O_0006_002_IST`
4. Filename is constructed by value-mapping FM `/THKR/AIF_VMAP_IST_RUECK_FNAME`:
   ```
   BI<fipex2>_<datum><gko_lower>.<fistl4>.txt
   ```
   where `<fistl4>` = `FISTL[0:4]` of the **first record** (meaningless when records span multiple departments)

**Department identifier in the data:**

| AIF field | SAP field | Description |
|-----------|-----------|-------------|
| `FGAZ_DINR` | `FISTL[0:4]` | Dienstnummer — first 4 characters of Finanzstelle |

> No `KOSTL`, `WERKS`, `BUKRS`, or `ABTEILUNG` fields exist in the O_0006_002 mapping. The split key is exclusively `FISTL[0:4]`.

**Relevant source files:**

- Action FM: `src/#thkr#sst/#thkr#aif/#thkr#aif_fremdv/#thkr#aif_fremdv_rueck.fugr.#thkr#aif_fremdv_act_rueck.abap`
- Filename mapping FM: `src/#thkr#sst/#thkr#aif/#thkr#aif_zallge/#thkr#aif_zallge_map.fugr.#thkr#aif_vmap_ist_rueck_fname.abap`

### Gap Analysis

| # | Gap | Location |
|---|-----|----------|
| 1 | All T_RUECK lines written to a single file — no grouping by department | `/THKR/AIF_FREMDV_ACT_RUECK` |
| 2 | Filename uses `FISTL[0:4]` of first record only — not meaningful for multi-department data | `/THKR/AIF_VMAP_IST_RUECK_FNAME` |
| 3 | No loop-per-department exists in the current outbound processing | FM + AIF mapping design |

### Proposed Solution

**Modify the action FM to group by `FISTL[0:4]` and write one file per group.**

Create a new function module `/THKR/AIF_FREMDV_ACT_RUECK_DEPT` in function group `#THKR#AIF_FREMDV_RUECK`:

```abap
FUNCTION /thkr/aif_fremdv_act_rueck_dept.
  " 1. Collect unique FISTL[0:4] (= department keys) from T_RUECK
  DATA: lt_dept_keys TYPE SORTED TABLE OF char4 WITH UNIQUE KEY table_line.
  LOOP AT <lt_table> ASSIGNING FIELD-SYMBOL(<ls_line>).
    ASSIGN COMPONENT 'FISTL' OF STRUCTURE <ls_line> TO FIELD-SYMBOL(<lv_fistl>).
    INSERT <lv_fistl>(4) INTO TABLE lt_dept_keys.
  ENDLOOP.

  " 2. For each department: filter lines, format, write file
  LOOP AT lt_dept_keys INTO DATA(lv_dept).
    DATA(lt_dept_lines) = VALUE #( FOR ls IN <lt_table>
                                   WHERE ( fistl(4) = lv_dept )
                                   ( ls ) ).
    " Build filename: BI<fipex2>_<datum><gko_lower>.<fistl4>.txt
    " (same convention as current — unique per dept via <fistl4> suffix)
    " Call modify_output_tab + write file per department
  ENDLOOP.
ENDFUNCTION.
```

**Key point on filename:** The existing naming convention `BI<fipex2>_<datum><gko_lower>.<fistl4>.txt` already produces a **unique filename per department** because `<fistl4>` = `FISTL[0:4]`. No filename convention change is needed — the formula just needs to be applied per-group instead of once for the entire table.

**AIF configuration changes:**

| Table | Change |
|-------|--------|
| `aif_t_func` | INSERT: `NS=ZALLGE, IFACTION=IST_RUECK_CSV_DEPT, FUNCNR=10, FUNCTION=/THKR/AIF_FREMDV_ACT_RUECK_DEPT` |
| `aif_t_ifact` | UPDATE step 0 on O_0006_002 from `IST_RUECK_CSV` → `IST_RUECK_CSV_DEPT` |

**Open questions to confirm with business / eSTA team before implementation:**

- How many departments are expected? (Determines if a fixed list or dynamic grouping is better)
- Can the downstream eSTA system handle receiving **multiple files** per processing run?
- What should happen if `FISTL` is empty for a record?
- Is a same-day rerun scenario possible that could produce duplicate filenames?
- Verify that the logical filename `/THKR/AIF_O_0006_002_IST` resolves to a **directory** (not a fixed single filename) in `FILE_GET_NAME` parameterisation

### Estimated Complexity: **Medium**

Grouping logic is straightforward ABAP (loop, collect unique keys, filter sub-table, write file per group). AIF configuration change is minimal (1 action + 1 `aif_t_ifact` update). Main risks: edge cases with empty `FISTL`, duplicate filenames on same-day reruns, and downstream eSTA compatibility with multiple files. No structural schema change required.

---

## Summary

| # | Interface(s) | Change | New FM | Config changes | Status | Complexity |
|---|---|---|---|---|---|---|
| 1 | I_0009_001, I_0010_001, I_0032_001 | Errors-only CSV Infomail | `/THKR/AIF_ZALLGE_ACT_PROT_ERR_CSV` | 1 `aif_t_func` + 3 `aif_t_ifact` | Ready to implement | Medium |
| 2 | O_0006_002 | Per-department Ist-Rückmeldung | `/THKR/AIF_FREMDV_ACT_RUECK_DEPT` | 1 `aif_t_func` + 1 `aif_t_ifact` | **Blocked — customer CR missing** | Medium |
