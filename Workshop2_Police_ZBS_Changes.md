# Workshop 2 Police / ZBS — Required Changes

**Source:** Workshop 2 Police and ZBS, April 8–9, 2026 (HKR Saxony-Anhalt)  
**Agreed by all participants:** April 9, 2026, 13:55

---

## Short-Term Changes (Interim Solution — by end of April 2026)

### REQ-1: Fix BKTXT / XBLNR field swap

**Background:** The Kassenzeichen (cash register code) is being written into `BKTXT` instead of `XBLNR`. A workaround was patched on 11.03.2026 in `CL_PSO_XML_PROCESSING` (search priority flipped), but the underlying mapping remains incorrect. This is the root cause of the unusable IST-RM file reported by Mr. Döring on April 7, 2026.

**Prerequisites for other REQs:** REQ-3 and REQ-5 depend on XBLNR being correctly populated.

#### Fix for new cases — Owners: C. Seider, S. Scheithauer

| Object | File | Change |
|---|---|---|
| `/THKR/CL_PSO_XML_PROCESSING` | `#thkr#cl_pso_xml_processing.clas.abap` | Fix AIF field assignment so Kassenzeichen → XBLNR (not BKTXT); revert the 11.03.2026 search-priority workaround |
| `/THKR/AIF_ZALLGE_CHK_AUSAO_REF` | `zallge/#thkr#aif_zallge_chk.fugr.#thkr#aif_zallge_chk_ausao_ref.abap` | WHERE clause uses `bktxt` — flip to `xblnr` after field assignment fix |
| `/THKR/AIF_VMAP_ANTRAGSNUMMER` | `fremdv/#thkr#aif_fremdv_map.fugr.#thkr#aif_vmap_antragsnummer.abap` | Reads `bkpf.xblnr = @value_in3` — will work correctly once XBLNR is populated |

#### Fix for legacy cases (correction report) — Owners: C. Seider, P. Lehmann, S. Pieper

| Object | File | Change |
|---|---|---|
| New correction program | Model: `zallge/#thkr#aif_bkpf_tool.prog.abap` | New batch report: `SELECT bkpf WHERE bktxt IS NOT INITIAL AND xblnr IS INITIAL` for police document types → `UPDATE` swap BKTXT → XBLNR |

#### Deactivation of Kassenzeichen validation — Owner: P. Lehmann

| Object | Change |
|---|---|
| AIF check configuration for POLI interface | Deregister `/THKR/AIF_ZALLGE_CHK_AUSAO_REF` from the POLI interface check pipeline — **no source code change, AIF config only (SPRO)** |

---

### REQ-2: New CDS view for individual police payments (no summation)

**Background:** The current outbound flow uses `/THKR/CDS_AIF_IST_RM_SEL` which aggregates payments per Kassenzeichen (`SUM(gezahlt)`). Police require individual payment rows with DZ receipt number and receipt date. Additionally, DG receipts must **not** be transmitted via SST (Mr. Westendorf).

**Target date:** April 16, 2026 — Owners: P. Lehmann, C. Seider

| Object | File | Change |
|---|---|---|
| `/THKR/CDS_AIF_IST_RM_SEL_V2` | `#thkr#cds_aif_ist_rm_sel_v2.ddls.asddls` | Expose `ZAHL_BELNR` (DZ receipt number) and `psobt` (DZ receipt date) in projection |
| `/THKR/CL_IST_RM_CREATE` | `#thkr#cl_ist_rm_create.clas.abap` | (1) Extend `transfer_to_aif` method — map `ZAHL_BELNR` + `psobt` into AIF target structure `/THKR/S_AIF_RAW_RUECK`; (2) Add `WHERE blart NOT IN ('DG')` filter in `get_data()` |
| AIF outbound POLI mapping config | — | Wire new fields `ZAHL_BELNR` and `psobt` into the POLI outbound interface field mapping (SPRO) |

---

### REQ-3: Use DZ receipt date (Valuta) instead of booking date

**Background:** Original decision was to use booking date (`PSOBT`). Police explicitly requested the receipt date of the DZ receipt (actual payment date = `bseg.valut`) after investigating cash register number `3856-726506-9`. The booking date contains the budget-relevant date, not the claim-decisive date.

**Prerequisite:** REQ-1 must be fixed first — both value mapping FMs look up by `bkpf.xblnr` which is currently empty.

| Object | File | Change |
|---|---|---|
| `/THKR/AIF_VMAP_IST_VALUT` | `fremdv/#thkr#aif_fremdv_map.fugr.#thkr#aif_vmap_ist_valut.abap` | Already reads `bseg.valut` (DZ valuta date) — **no source change needed** |
| `/THKR/AIF_VMAP_IST_PSOBT` | `fremdv/#thkr#aif_fremdv_map.fugr.#thkr#aif_vmap_ist_psobt.abap` | Currently wired as the date field — **replace with `AIF_VMAP_IST_VALUT` in AIF config only** |
| AIF outbound POLI mapping config | — | Switch date field mapping from `AIF_VMAP_IST_PSOBT` → `AIF_VMAP_IST_VALUT` (SPRO) |

---

### REQ-4: Provision of actual feedback files to police (monthly → daily)

**Background:** No real IST-RM data has been imported into SAP-POL to date (data delivery started February 17, 2026 with file 003). Police need a complete backlog file (Jan–Mar 2026) plus ongoing regular delivery.

**No source code change required.**

| Step | Action |
|---|---|
| Backlog | Schedule `/THKR/R_SEND_IST_RUECK_V2` with `SO_CPU` range 01.01.2026–31.03.2026 — 4 monthly files (Jan, Feb, Mar, Apr) |
| Go-live | Configure `/THKR/R_SEND_IST_RUECK_V2` as a daily batch job with rolling date range |
| File: | `fremdv/#thkr#r_send_ist_rueck_v2.prog.abap` — no modification needed |

> **Note:** Prerequisite — REQ-1 and REQ-2 (DG exclusion) must be implemented before running production backlog files.

---

### Additional: Code Page Configuration

The code page for the IST-RM output file is configured per interface in custom customizing table **`/THKR/FILE_PPROP`** (maintenance view `/THKR/FILE_PPROPS`, transaction SM30).

Key: `NS` + `IFNAME` + `IFVERSION`  
Field: `CODEPAGE` — references SAP table `TCP00` (valid SAP code page numbers)

Used by:
- `aif_fremdv_act_rueck.abap` (line 69) — IST-RM feedback file
- `aif_fremdv_act_write_fil.abap` (line 157) — general file write
- `aif_fremdv_act_wrt_fi_ki.abap` (line 138) — KI file write

Table defined in: `zallge/#thkr#file_pprop.tabl.xml`

---

## Long-Term Changes (Target Solution — from May 2026)

**Goal:** Stable, maintainable and reliable interface architecture.

---

### REQ-5: AIF adjustment for CpD debtor handling (Document type 01)

**Background:** Police SST currently sends CpD debtor with running number 1, causing constant new GP creation. The target solution identifies the debtor by original Kassenzeichen (ZUONR) and reuses existing GPs for DG and D1 re-issue documents.

**Partial implementation already exists** in `CL_PSO_XML_PROCESSING` (CpD detection, GP creation, BPEXT logic present).

**3-step logic:**

| Step | Description | Object | File | Change |
|---|---|---|---|---|
| Step 1 | New GP creation: doctype=01 + KUNNR=0001 → read ZUONR as original KaZ → store in `BUT000.BPEXT` | `/THKR/CL_PSO_XML_PROCESSING` | `#thkr#cl_pso_xml_processing.clas.abap` | New branch: when doctype=01 and KUNNR=0001, use ZUONR directly as BPEXT (instead of current address-hash via `CREATE_CPD_BPEXT_ID`) |
| Step 2 | DG receipt: reuse existing GP by matching `BUT000.BPEXT = ZUONR` → transfer KaZ to XBLNR | `/THKR/AIF_VMAP_PARTNER` | `zallge/#thkr#aif_zallge_map_gp.fugr.#thkr#aif_vmap_partner.abap` | Already looks up GP via BPEXT — wire into DG document type routing in AIF config |
| Step 3 | D1 re-issue: same GP reuse logic; KaZ → XBLNR | AIF mapping for D1 blart | AIF config | Same `AIF_VMAP_PARTNER` lookup, ensure XBLNR populated from ZUONR |
| Config | Switch CpD identification for POLI document type 01 | AIF value map `MAP_PSO_XML_CPD` | AIF config (SPRO) | New entry or condition to distinguish ZUONR-based identification from hash-based path |

---

### REQ-6: Direct ZBS → HKR connection (with parallel delivery to SAP-POL)

**Background:** Currently ZBS delivers only delta amounts to SAP-POL (e.g. +€28.50, not the full amount). Target: ZBS delivers directly to HKR as a debit receipt on the original Kassenzeichen (`Ur-KaZ`), with parallel delivery to SAP-POL for operating cost accounting. ZBS objected to direct connection as it would reallocate resources — requires further alignment.

**No existing ZBS interface objects found in either repo. Entirely new development.**

| Object | Change |
|---|---|
| New AIF namespace/interface | New inbound AIF interface for ZBS (or new version under FREMDV namespace) |
| New inbound file structure | ZBS delta format definition |
| New mapping FM | Debit posting on existing KaZ — reuse pattern from `fremdv/#thkr#aif_bmap_reference.abap` |

---

### REQ-7: Fee increases as new acceptance orders (Verwaltungsgebühr €28.50)

**Background:** When an administrative offence (OWI) transitions to a fine (Bußgeld), a processing fee of €28.50 arises. ZBS currently sends only the delta to SAP-POL. Target: post the changed amount as a debit receipt on the original Kassenzeichen.

**No existing objects found. New development extending POLI inbound processing.**

| Object | File | Change |
|---|---|---|
| `/THKR/AO_REF_BLA` routing table | AIF config | Add new BLART/PSOTY entry for processing fee document type |
| `/THKR/CL_PSO_XML_PROCESSING` | `#thkr#cl_pso_xml_processing.clas.abap` | New routing branch for fee document — booking on `Ur-KaZ` |
| Reference FM pattern | `fremdv/#thkr#aif_bmap_reference.abap` | Reuse existing `aif_bmap_reference` pattern for back-reference on original KaZ |

---

### REQ-8: PTravel actual balances in IST-RM

**Background:** Recording actual balances in PTravel within the actual feedback (IST-RM). Differentiation via police account assignments. Not part of the interim solution — part of the final solution only.

**No PTravel-specific objects found in either repo. New development.**

| Object | File | Change |
|---|---|---|
| New or extended CDS view | `#thkr#cds_aif_ist_rm_cube` or new sibling | Add filter/differentiation by police-specific `GSBER`/`FISTL`/`FIPOS` account assignments |
| `/THKR/CL_DE_RUN_RM` | `#thkr#sst/#thkr#external_interface/#thkr#cl_de_run_rm.clas.abap` | Likely entry point — extend for PTravel actual postings |
| `/THKR/CDS_AIF_MI_UNION_IST_RM` | CDS view | Add police account assignment key/filter if PTravel delivers via new SST key |

---

## Summary: Critical Path

```
REQ-1 (BKTXT/XBLNR fix)
  ├──► REQ-3 (valuta date FM queries by xblnr — works only after fix)
  ├──► REQ-2 (CDS view DZ lookup works only after fix)
  └──► REQ-5 (GP reuse by XBLNR works only after fix)
```

**REQ-1 is the hard blocker for all other interim changes.**

---

## Open Items / Decisions Required

| # | Topic | Status |
|---|---|---|
| 1 | DG receipts must not be transmitted via SST — how to handle DG in existing data? | Open — Mr. Westendorf flagged as major problem |
| 2 | ZBS direct connection — resource allocation conflict with ZBS assignment to police | Open — ZBS objected |
| 3 | Traceability for fully paid/settled transactions that can no longer be changed | Open — merging documents from ZBS, SAP-POL, HKR in BW reporting proposed |
| 4 | avviso connection to AH1/600 test system | Pending — required before small test on 17.04.2026 |
| 5 | Exchange of experience with Baden-Württemberg re. direct HKR-OWI connection | Open — condition: OWI 21 version 4 required |

---

## Key Dates

| Date | Event |
|---|---|
| 09.04.2026 | Copy PH1/100 → AH1/600 completed (except avviso connection) |
| 16.04.2026 | Target date: REQ-2 CDS view for individual payments (P. Lehmann, C. Seider) |
| 17.04.2026 | "Small test" AH1/600 with AG/AN |
| 21.04.2026 | Test with police (Westendorf, Döring, Nitsch, Seider, Lehmann, Scheithauer, Sauer, Rost) |
| End of April 2026 | Implementation of full interim solution |
| May 2026 | Start development of target solution |
