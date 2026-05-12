# Interface Analysis: `FREMDV | O_0027_002 | 00001`
## IST-Rückmeldung Polizei — Actuals Feedback to Police System

---

## 1. Overview

| Property | Value |
|---|---|
| **Namespace** | `FREMDV` |
| **Interface** | `O_0027_002` |
| **Version** | `00001` |
| **Direction** | **Outbound (O)** — SAP sends data to Police system |
| **Purpose** | Sends payment actuals (IST-Rückmeldung) from SAP back to the Police specialist system (KLRP) |
| **Counterpart** | Inbound interface `I_0027_001` (Police XML inbound, BTC format / SAP PSO XML) |

---

## 2. Data Structures

| Role | Structure | Description |
|---|---|---|
| **Root (SAP)** | `/THKR/S_AIF_SAP_RUECK_KLRP_RT` | Root structure for Police IST-Rückmeldung |
| **Raw (file)** | `/THKR/S_AIF_FILE_RUECK` | Raw output file structure |
| **Header** | `/THKR/S_AIF_BIC_HEADER` | BIC file header (contains filename parts: START, VERFA, GENNR, EMPF, DIENSTNR) |
| **Lines** | `/THKR/T_AIF_BIC_ZEILE` | Table of output lines |
| **Footer** | `/THKR/S_AIF_BIC_FOOTER` | BIC file footer |
| **IDX_CTRL** | `/THKR/T_AIF_RUECK_IDX_CTRL` | Index control table (deduplication) |

The root structure `KLRP_RT` contains four components: `COMMON`, `HEADER`, `LINE` (table), and `FOOTER` — a standard **BIC file format** layout.

---

## 3. Action Pipeline

| Step | ACTIONNR | Namespace | Action | Function Module |
|---|---|---|---|---|
| 1 | 10 | `ZALLGE` | `ACT_WRITE_FILE` | `/THKR/AIF_FREMDV_ACT_WRITE_FIL` |

Only **one action**: write the prepared output to a file.

---

## 4. Action: `ACT_WRITE_FILE` — `/THKR/AIF_FREMDV_ACT_WRITE_FIL`

**Source:** `#thkr#aif_fremdv_act.fugr.#thkr#aif_fremdv_act_write_fil.abap`

**What it does:**

1. Reads `HEADER`, `LINE`, `FOOTER`, and `COMMON` components via field symbols from the `DATA` changing parameter
2. If `LINE` table is not empty:
   - Instantiates `/THKR/CL_AIF_RUECK` which reads interface properties from `/THKR/FILE_PPROP` (file separator, codepage, CR/LF style) and `/THKR/FILE_FLDS` (field layout)
   - Calls `lo_rueck->modify_output_tab()` which:
     - Optionally adds a header line (column names)
     - Formats each row using configured field widths/alignment from `/THKR/FILE_FLDS`
     - Prepends BIC header line and appends BIC footer line if configured
   - **Builds filename** from BIC header: `START + VERFA (lowercase) + GENNR + '.' + EMPF + '.' + DIENSTNR`
     - Example pattern: `000BO` + `verfahren` + `0001` + `.IST.3101`
   - Resolves logical filename `/THKR/AIF_O_0027_002_OUT` via `get_filepath()`
   - Checks if file already exists and whether overwrite is allowed (per `/THKR/FILE_PPROP`)
   - Writes the string table to the file with configured encoding and line endings
3. If `LINE` table is empty → sets SUCCESS = `'Y'` (no error, nothing to send)

---

## 5. Field Mappings — Two Record Types

The mapping table defines **two record type blocks**, distinguished by constant `01_BTYP`:

### Record Type IBA — Ausgaben (Expenditures / Outgoing Payments)

| Output Field | SAP Source | VMAP Function | Notes |
|---|---|---|---|
| `01_BTYP` | `%IBA` | — | Constant "IBA" (Ausgaben) |
| `04_HHJ` | `GJAHR` | — | Fiscal year |
| `05_QUELLE` | `@HEADER-VERFA` | — | Procedure code from header |
| `09_AOB` | `FIPEX` | — | Commitment item |
| `10_KAP` | `FIPEX` | — | Chapter from FIPEX |
| `11_TITEL` | `FIPEX` | — | Title from FIPEX |
| `12_OEH` | `FISTL` | — | Fund center |
| `13_MSN` | `%00` | — | Constant "00" |
| `15_BETR1` | `GEZAHLT` | `MAP_15_BETR1` | **Amount paid** (formatted) |
| `17_FDATUM` | `BUDAT` | — | Posting date |
| `26_RES3` | `IBAN` | — | IBAN |
| `29_GRUND` | `SGTXT` | — | Item text / reason |
| `38_RES4` | `BUSINESSPARTNER_NAME` | — | Payee name |
| `39_RES5` | `BANKA` | — | Bank name |
| `41_URKASS` | `XBLNR` | — | Reference document number (Kassenzeichen) |
| `44_DST` | `FISTL` | `MAP_IST_DST_OLD` | Dienststelle (department) mapped from fund center |
| `46_NAME2` | `BUSINESSPARTNER_NAME` | — | Name line 2 |
| `49_DSTNR` | `@HEADER-DIENSTNR` | — | Service number from header |
| `52_AUSPC` | `BELNR` | — | SAP accounting document number |
| `63_BIC` | `SWIFT` | — | BIC/SWIFT code |
| `65_IBAN` | `IBAN` | — | IBAN (repeated) |

### Record Type IBE — Einnahmen (Revenue / Incoming Payments)

Same structure as IBA with the following differences:

| Output Field | SAP Source | Notes |
|---|---|---|
| `01_BTYP` | `%IBE` | Constant "IBE" (Einnahmen) |
| `29_GRUND` | `VERWZW` | Purpose of payment (not item text) |
| `38_RES4` | `EINZAHLER` | Payer name (not business partner) |
| `46_NAME2` | `EINZAHLER` | Payer name line 2 |

---

## 6. Value Mappings (VMAPs)

| VMAP | Function Module | Purpose |
|---|---|---|
| `MAP_GENNR` | `/THKR/AIF_VMAP_GENNR` | Generation number — sequential file counter per procedure |
| `MAP_15_BETR1` | *(ZALLGE namespace)* | Amount formatting for output |
| `MAP_IST_DST_OLD` | *(ZALLGE namespace)* | Maps FISTL fund center → old Dienststelle number |

### MAP_GENNR — Generation Number Logic

**Source:** `#thkr#aif_fremdv_map.fugr.#thkr#aif_vmap_gennr.abap`

Delegates to `/THKR/CL_IF_INITIAL_CHECK->gen_gen()` with VERFA (procedure code) as input.
Reads the Single Index Table ordered by `CREATE_DATE DESC`, increments the last GENNR by 1.
Returns a 4-digit alpha-padded number (e.g. `0001`, `0002`, ...).
Starts at `0001` if no prior entries exist.

Used in the BIC filename to uniquely identify each file generation per procedure.

---

## 7. Check Function: `/THKR/AIF_FREMDV_CHK_IST_RUECK`

**Source:** `#thkr#aif_fremdv_chk.fugr.#thkr#aif_fremdv_chk_ist_rueck.abap`

Determines **which payment records qualify for output**. The IST type is configured per interface via value map `ZALLGE/MAP_IST_RUECK_TYPE` (keyed by SST — Subsystem type):

| IST Type | Filter Logic |
|---|---|
| `N` | **Unpaid only** — GEZAHLT = 0.00 |
| `T` | **Partial or fully settled** — (amount ≠ paid AND paid ≠ 0) OR (amount = paid AND open = 0) |
| `G` | **Fully paid only** — amount = paid AND open = 0.00 |
| `A` | **All** payment states |

For each qualifying record, calls `chk_record_should_be_sent()` which performs **deduplication** via the Multi-Index Table (keyed by BUKRS + GJAHR + LOTKZ + BELNR + GEZAHLT). A record already in the table is skipped unless the `RESEND` flag is set.

> **Note:** The comment `"Delta-Logik ist in die CDS-View gewandert"` confirms that delta selection logic has been moved to the CDS view. The AIF check now handles only the IST type filter.

**Input parameters:**
| Param | Field | Description |
|---|---|---|
| `VALUE1` | Sollbetrag | Target/planned amount |
| `VALUE2` | Gezahlter Betrag | Amount paid |
| `VALUE3` | Offener Betrag | Open/remaining amount |
| `VALUE4` | RESEND | Force re-send flag |
| `VALUE5` | SST | Subsystem type (used to look up IST type) |

---

## 8. Output File

| Property | Value |
|---|---|
| **Logical filename** | `/THKR/AIF_O_0027_002_OUT` |
| **Format** | BIC file (fixed-width or separator-based) |
| **Filename pattern** | `{START}{verfa}{GENNR}.{EMPF}.{DIENSTNR}` |
| **Example** | `000BOklrp0001.IST.3101` |
| **Overwrite protection** | Configurable per interface in `/THKR/FILE_PPROP` |
| **Encoding / EOL** | Configurable (codepage + CR/LF mode) in `/THKR/FILE_PPROP` |

---

## 9. Data Flow

```
CDS View (Police/KLRP actuals data)
        │
        ▼
AIF Message root: /THKR/S_AIF_SAP_RUECK_KLRP_RT
        │
        ├─ HEADER (/THKR/S_AIF_BIC_HEADER)
        │    └─ VERFA, GENNR, EMPF, DIENSTNR, START
        │
        ├─ LINE table
        │    ├─ Financial: FIPEX, FISTL, GJAHR, BUDAT, BELNR, GEZAHLT
        │    ├─ Partner:   BUSINESSPARTNER_NAME / EINZAHLER, IBAN, SWIFT, BANKA
        │    └─ Reference: XBLNR (Kassenzeichen)
        │
        └─ CHECK: CHK_IST_RUECK
              └─ Filter by IST type (N/T/G/A) + deduplication via Multi-Index Table
                        │
                        ▼
              ACTION 10: ACT_WRITE_FILE
              /THKR/AIF_FREMDV_ACT_WRITE_FIL
                        │
                        ▼
              /THKR/CL_AIF_RUECK.modify_output_tab()
              → Format rows (field widths from /THKR/FILE_FLDS)
              → Add BIC header / footer lines
              → Build filename from HEADER fields
                        │
                        ▼
              Output file on SAP application server
              Logical filename: /THKR/AIF_O_0027_002_OUT
                        │
                        ▼
              Police system picks up file (BIC format)
```

---

## 10. CDS View Layer (Data Source)

Four CDS views form the data extraction pipeline for this interface:

### View Stack (top → bottom)

```
/THKR/CDS_AIF_IST_RM_SEL          ← AIF data source (selection view)
        │
        └── /THKR/CDS_AIF_IST_RM_CUBE    ← Aggregation cube
                │
                ├── /THKR/CDS_BJFMIFIIT          ← FM document items journal (base)
                ├── I_AccountingDocument (BKPF)   ← Accounting header
                ├── /THKR/CDS_BJBSEG             ← Vendor/Customer BSEG lines (wrttp 54/57)
                ├── /THKR/CDS_BJBSEG2            ← Clearing BSEG lines (wrttp 61)
                ├── /thkr/bpcube                  ← Business Partner (vendor + customer)
                └── /THKR/CDS_AIF_MI_UNION_IST_RM ← AlreadySent flag (dedup)

/THKR/CDS_AIF_IST_RM_IBAN          ← IBAN/BIC from clearing document (FEBEP)
```

---

### `/THKR/CDS_AIF_IST_RM_CUBE` — Base Cube
**Source:** `#thkr#cds_aif_ist_rm_cube.ddls.asddls`

The core data extraction view. Reads FM document items and joins to accounting and business partner data.

**Key joins:**

| Join | On | Purpose |
|---|---|---|
| `I_AccountingDocument` (BKPF) | bukrs + knbelnr + kngjahr | Document header (Kassenzeichen=`DocumentReferenceID`, lotkz, type, psofn/kassendatum) |
| `/THKR/CDS_BJBSEG` (bsegSI) | bukrs + knbelnr + kngjahr, wrttp 54/57, koart K/D | Vendor/Customer line: valutadatum, augbl/auggj/augdt, sgtxt, gsber, wrbtr |
| `/THKR/CDS_BJBSEG2` (bsegAN) | bukrs + knbelnr + kngjahr + knbuzei, wrttp 61 | Clearing line: augbl/auggj/augdt, sgtxt |
| `/thkr/bpcube` (_bp_lief / _bp_kund) | lifnr / kunnr | Business partner name, address, PLZ, city |
| `/THKR/CDS_AIF_MI_UNION_IST_RM` (_aif) | Kassenzeichen + bukrs + hhj + lotkz + trbtr=gezahlt | `AlreadySent` = `'X'` if record is in any multi-index table |

**Value type logic (wrttp):**

| wrttp | btart | Field | Meaning |
|---|---|---|---|
| `54` | `0100` | `sollOriginalbetrag` | Original planned amount (Soll) |
| `57` | `0250` | `gezahlt` | Paid amount (Zahlbetrag) |
| `61` | `0100`, augbl='' | `gezahlt` | Incoming payment, not yet cleared |
| `61` | `0100`, augbl≠'' | `gezahlt` = 0 | Incoming payment already cleared |

**WHERE filter:** only wrttp `54` or `57`, koart `K` or `D`, and `BelegSstKey` (Reference1) must not be empty.

**Derived fields:**

| Field | Logic |
|---|---|
| `AlreadySent` | `'X'` if `_aif.SstKey IS NOT NULL` — record already transmitted |
| `erledigt` | `'X'` if augbl is not empty (document cleared/settled) |
| `kapitel` | `FIPEX[1..4]` — chapter |
| `titel` | `FIPEX[5..9]` — title |
| `wrbtr` | BSEG amount × −1 if Haben (H), positive if Soll (S) |

---

### `/THKR/CDS_AIF_IST_RM_SEL` — Selection View
**Source:** `#thkr#cds_aif_ist_rm_sel.ddls.asddls`

Aggregation layer on top of the cube. Groups records and sums amounts. This is the **AIF interface data source**.

**Association:** `/THKR/CDS_AIF_IST_RM_IBAN` joined on `belnr = augbl AND bukrs` to fetch IBAN/BIC from the clearing document.

**Key aggregations:**

| Output Field | Logic |
|---|---|
| `Original` | `SUM(sollOriginalbetrag)` — total planned amount |
| `Gezahlt` | `SUM(gezahlt)` — total paid |
| `Soll` | `SUM(offenesSoll)` — remaining open amount |
| `buchungsdatum` | `MAX(CAST(zhldt AS INT4))` — latest posting date |
| `belnr` | `MIN(knbelnr)` — earliest document number |

**IBAN/BIC sourcing** (via `_iban` association):

| Interface Field | Source |
|---|---|
| `iban` | `_iban._febep.piban` |
| `bic` | `_iban._febep.paswi` |
| `einzahler` | `_iban._febep.partn` |
| `verwendungszweck` | `_iban._febep.sgtxt` |

---

### `/THKR/CDS_AIF_IST_RM_IBAN` — IBAN Lookup
**Source:** `#thkr#cds_aif_ist_rm_iban.ddls.asddls`

Retrieves IBAN and BIC from the bank statement item (`FEBEP`) linked via the clearing document.

The link key is encoded in `BKPF.bktxt`:
- Characters 1–8 → `kukey` (FEBEP key)
- Characters 9–13 → `esnum` (FEBEP item number)

---

### `/THKR/CDS_AIF_MI_UNION_IST_RM` — Multi-Index Union (AlreadySent)
**Source:** `#thkr#cds_aif_mi_union_ist_rm.ddls.asddls`

UNION of all outbound multi-index tables across all IST-Rückmeldung interfaces. Each entry represents a record that has already been successfully transmitted. Used in the CUBE to set the `AlreadySent` flag.

**O_0027_002 (Police) entry:**

```abap
select from /thkr/mi_0027002
{
  key 'KLRP' as SstKey,   ← Police system identifier
  key kassz,              ← Kassenzeichen
  key belnr,
  key bukrs,
  key lotkz,
  key gjahr,
      waers,
      gezahlt
}
```

This is how the delta logic works: the CDS view marks records as `AlreadySent = 'X'` by joining to `/THKR/MI_0027002`. The AIF check function additionally uses this table via `chk_record_should_be_sent()` for record-level deduplication.

---

### Complete Data Flow with CDS

```
/THKR/CDS_BJFMIFIIT (FM items, wrttp 54/57)
  + BKPF (Kassenzeichen, lotkz, kassendatum)
  + BSEG (valutadatum, augbl, sgtxt, BP)
  + /thkr/bpcube (name, address)
  + /THKR/MI_0027002 → AlreadySent flag
        │
        ▼
/THKR/CDS_AIF_IST_RM_CUBE
        │  GROUP BY + SUM(gezahlt, soll, original)
        ▼
/THKR/CDS_AIF_IST_RM_SEL  ← AIF data source
  + FEBEP (IBAN, BIC via bktxt kukey/esnum)
        │
        ▼ AIF picks up records, applies field mappings
        │  → CHK_IST_RUECK filters by IST type (N/T/G/A)
        │  → dedup check vs /THKR/MI_0027002
        ▼
ACT_WRITE_FILE → BIC output file
```

---

## 11. Triggering Report: `/THKR/R_SEND_IST_RUECK`

Transaction: `/THKR/R_SEND_IST_RUE`

This is the report that reads SAP FI actuals and submits them to AIF, which then processes them through interface O_0027_002 to produce the output file.

### Program Structure

```
/THKR/R_SEND_IST_RUECK          ← main report
  INCLUDE /THKR/R_SEND_IST_RUECK_TOP  ← types and declarations
  INCLUDE /THKR/R_SEND_IST_RUECK_SSC  ← selection screen
  INCLUDE /THKR/R_SEND_IST_RUECK_C01  ← class lcl_appl implementation
```

Single OO class `lcl_appl` with class-level static methods.

### Selection Screen Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `p_fikrs` | `FIKRS` | `1000` | Financial management area |
| `so_bukrs` | range | — | Company code |
| `so_gjahr` | range | — | Fiscal year |
| `so_belnr` | range | — | Document number |
| `so_blart` | range | — | Document type |
| `so_budat` | range | — | Posting date |
| `so_lotkz` | range | — | Lot number (Kassenzeichen group) |
| `so_fipex` | range | — | Commitment item (Finanzposition) |
| `so_fictr` | range | — | Funds center |
| `so_xblnr` | range | — | External reference (Kassenzeichen) |
| `p_disp` | flag | — | Display ALV preview only |
| `p_send` | flag | — | **Must be checked to actually send to AIF** |
| `p_q_ns` | `/AIF/NS` | `FREMDV` | AIF queue namespace |
| `p_q_name` | name | — | AIF queue name for O_0027_002 |
| `p_sst` | SST key | — | Optional: single recipient (single-message mode) |
| `p_resend` | flag | `false` | Resend already-transmitted records |

### Execution Flow

```
START-OF-SELECTION → lcl_appl=>main()
  │
  ├─ get_data()
  │    ├─ /thkr/cl_fi_appl=>get_instance()→get_all_psm_fi_document_data()
  │    │    reads PSM-FM documents matching selection criteria
  │    ├─ SELECT bkpf FOR ALL ENTRIES → enriches with xref1_hd (SST key)
  │    └─ SORT mt_alv BY xref1_hd
  │
  └─ transfer_to_aif()
       ├─ Packs data into /THKR/S_AIF_FILE_RUECK structures
       ├─ Groups by xref1_hd (= recipient SST key from bkpf-xref1_hd)
       │    each group → one AIF message → one output file
       └─ /AIF/CL_ENABLER_XML=>TRANSFER_TO_AIF_MULT()
            → AIF queues messages for interface O_0027_002
            → ACT_WRITE_FILE produces BIC output file
```

**Single vs Multi mode** (controlled by `p_sst`):
- `p_sst` filled → `TRANSFER_TO_AIF()` — one message for the whole result set, SST key forced to `p_sst`
- `p_sst` empty → `TRANSFER_TO_AIF_MULT()` — one message per distinct `xref1_hd` value (one file per recipient system)

---

## 12. Code Quality Issues and Improvement Proposals

### Bug: Binary Search on Unsorted Standard Table

**File:** `#thkr#r_send_ist_rueck_c01.prog.abap`, line 121

```abap
" Current (fragile):
DATA: lt_aif TYPE STANDARD TABLE OF /thkr/s_aif_file_rueck.
READ TABLE lt_aif ... WITH KEY sst = <ls_alv>-xref1_hd BINARY SEARCH.
```

`BINARY SEARCH` on a `STANDARD TABLE` requires the table to be sorted by the key beforehand. This works today only because `mt_alv` is sorted by `xref1_hd` before the loop, causing entries to land in `lt_aif` in key order — an implicit dependency. If the sort in `get_data()` is ever changed, this silently reads wrong rows.

```abap
" Fix:
DATA: lt_aif TYPE SORTED TABLE OF /thkr/s_aif_file_rueck
      WITH UNIQUE KEY sst.
READ TABLE lt_aif ASSIGNING <ls_aif> WITH TABLE KEY sst = <ls_alv>-xref1_hd.
```

### Bug: Silent AIF Failures — No User Feedback

**File:** `#thkr#r_send_ist_rueck_c01.prog.abap`, lines 99–115 and 134–150

All 5 CATCH blocks are empty. AIF rejection (queue not found, interface misconfigured, enabler error) is swallowed silently — the user sees a green screen with no indication that nothing was sent.

```abap
" Current:
CATCH /aif/cx_enabler_base.
  " Generic Exception for AIF Enabler   ← lost silently

" Fix:
CATCH /aif/cx_enabler_base INTO DATA(lx_aif).
  MESSAGE lx_aif->get_text( ) TYPE 'E'.
```

### Dead Code: `call_xslt_transformation()`

**File:** `#thkr#r_send_ist_rueck_c01.prog.abap`, lines 155–216

Entire method body is commented out; the call site in `main()` is also commented out. This was an earlier XSLT-based approach, superseded by the AIF file output. Should be deleted.

### Minor: `FREE` vs `CLEAR` on Structure

**File:** `#thkr#r_send_ist_rueck_c01.prog.abap`, line 120

```abap
FREE: ls_aif_rueck.   " wrong — FREE is for releasing dynamic objects/references
CLEAR ls_aif_rueck.   " correct
```

### Design: `get_data()` Runs Unconditionally

`get_data()` always executes regardless of `p_send` and `p_disp`. For large fiscal-year selections this reads the full PSM-FM dataset even when running with both checkboxes unchecked. Guard with:

```abap
METHOD main.
  CHECK p_send = abap_true OR p_disp = abap_true.
  get_data( ).
  ...
```

### CDS: `CDS_AIF_MI_UNION_IST_RM` — Manual UNION Maintenance Burden

Every new outbound interface requires adding a `UNION SELECT` branch to this view and knowing the correct SST key string at development time. Consider a customizing-table-driven approach or using the AIF multi-index API directly.

### CDS: Authorization Checks Missing

All four CDS views (`CUBE`, `SEL`, `IBAN`, `MI_UNION`) have:
```cds
@AccessControl.authorizationCheck: #NOT_REQUIRED
```
FI document data with payment amounts and IBAN data should have at minimum `#CHECK` (implicit DCL).

### CDS: `CDS_AIF_IST_RM_CUBE` — Amount Join on `_aif` Association

```cds
and $projection.trbtr = _aif.gezahlt   ← joining on currency amount
```

Joining on an amount field is fragile — partial payments, rounding differences, or currency conversion can break the join, causing `AlreadySent = ''` for records that were genuinely sent (false positives on resend).

### CDS: `CDS_AIF_IST_RM_SEL` — GROUP BY With 36 Fields

The GROUP BY contains nearly all projected fields — each group contains exactly one row from the CUBE, making `SUM()`/`MAX()`/`MIN()` no-ops. The database executes a full GROUP BY sort/hash for no benefit. Additionally, `zhldt` appears both as a raw column and as `MAX(CAST(zhldt AS INT4))` — having it in GROUP BY negates the MAX aggregation.

---

## 13. Key ABAP Objects

| Object | Type | Location | Purpose |
|---|---|---|---|
| `/THKR/AIF_FREMDV_ACT_WRITE_FIL` | Function Module | `fremdv/aif_fremdv_act.fugr` | Write output file action |
| `/THKR/CL_AIF_RUECK` | Class | `fremdv/cl_aif_rueck.clas` | Core outbound formatting & dedup logic |
| `/THKR/AIF_FREMDV_CHK_IST_RUECK` | Function Module | `fremdv/aif_fremdv_chk.fugr` | IST type filter & dedup check |
| `/THKR/AIF_VMAP_GENNR` | Function Module | `fremdv/aif_fremdv_map.fugr` | Generation number calculation |
| `/THKR/S_AIF_SAP_RUECK_KLRP_RT` | Structure | `fremdv` | Root structure (DDIC) |
| `/THKR/FILE_PPROP` | Customizing Table | — | File output properties per interface |
| `/THKR/FILE_FLDS` | Customizing Table | — | Field layout/widths per interface |
