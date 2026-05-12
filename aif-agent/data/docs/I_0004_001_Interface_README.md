# Interface Analysis: `FREMDV | I_0004_001 | 00001`
## EMSA — Inbound BIC File from Zentrales Mahngericht (Central Dunning Court)

---

## 1. Overview

| Property | Value |
|---|---|
| **Namespace** | `FREMDV` |
| **Interface** | `I_0004_001` |
| **Version** | `00001` |
| **Direction** | **Inbound (I)** — EMSA sends BIC flat-file → SAP processes it |
| **Purpose** | Processes payment orders, collection proceedings, and business partner data from the central dunning office (EMSA) into SAP FI/PSM |
| **Counterpart** | Outbound `O_0004_002` — IST-Rückmeldung EMSA (actuals feedback) |
| **External System** | **EMSA** (Einheitliche Mahnstelle / central dunning court, "Zentrales Mahngericht") |
| **File Format** | **BIC** (Buchungsidentifikationscode) — fixed-width/separator flat file |

---

## 2. Data Structures

| Role | Structure | Description |
|---|---|---|
| **Root (SAP)** | `/THKR/S_AIF_SAP` | Root processing structure (header + LINE table) |
| **Raw (file)** | `/THKR/S_AIF_BIC` | Raw inbound BIC file structure |
| **Check FM** | `/THKR/AIF_ZALLGE_CHK_INTERFACE` | Pre-processing validation |
| **Init FM** | `/THKR/AIF_ZALLGE_FIELD_OVWR` | Field override initialization |
| **BIC Line** | `/THKR/S_AIF_BIC_ZEILE_IST_RUEC` | 84-field BIC line structure (all inbound BIC interfaces share this) |

---

## 3. Action Pipeline

| Seq | ACTIONNR | Action Name | Stop Condition | Purpose |
|---|---|---|---|---|
| 1 | 100 | `ACT_GP_INS` | `GP` | Insert/create Business Partner (Geschäftspartner) |
| 2 | 110 | `ACT_GP_CHG` | `GP` | Change/update Business Partner |
| 3 | 200 | `ACT_AO` | `AO` | Create/post FI Anordnung (payment order) |
| 4 | 400 | `ACT_AO` | `AO_REFERENCE` | Post referenced/linked Anordnung |
| 5 | 500 | `ACT_STORNO` | `STORNO` | Reverse/cancel a posted document |
| 6 | 900 | `ACT_APN` | — | Create APN notification record |
| 7 | 910 | `ACT_PROT_LST` | — | Write processing protocol list |
| 8 | 999 | `ACT_DEL_PROC_TAB` | — | Delete processing table (cleanup) |

Stop conditions mean: if the preceding stop-condition record type is present in the message and fails, AIF stops at that action for the affected line.

---

## 4. Field Mappings — BIC Line Record Types

The AIF field mapping (`aif_t_fmap`) maps BIC file columns (`AIFCHECK = {col_nr}_{name}`) to SAP target fields (`FIELDSAP`). The `FIELDRAW` value identifies the BIC record type (Satzart).

### Record Type 10 — Geschäftspartner (Business Partner Master Data)

Maps BIC line fields to Business Partner structure (`S_AIF_SAP`):

| SAP Field | BIC Source (`AIFCHECK`) | Description |
|---|---|---|
| `BU_GROUP` | — | BP grouping (empty → from interface default) |
| `BP_ACTION` | `%U` | Action constant: Update |
| `BU_TYPE` | `38_RES4` | Business partner type (Natural/Legal person) |
| `BU_NAME1–4` | `38_RES4` | Name lines |
| `BU_SORT1` | `38_RES4` | Sort name |
| `BU_BPEXT` | `23_LIFNR` | External BP number (vendor/debtor number) |
| `BU_BIRTHDT` | `46_NAME2` | Date of birth |
| `BU_AUGRP` | `%0008` | Authorization group constant |
| `BU_LANGU` | `@/THKR/SST` | Language (derived from SST key) |
| `LAND1` | `@/THKR/SST` | Country (derived from SST key) |
| `PARTNER` | `@BU_BPEXT` | SAP BP number (cross-reference to external) |
| `AD_PSTCD1` | `22_RES1` | Postal code |
| `AD_CITY1` | `24_RES2` | City |
| `AD_STREET` | `39_RES5` | Street |
| `AD_HSNM1` | `39_RES5` | House number |
| `AD_TITLE` | `@BU_TYPE` | Title (derived from BP type) |
| `AD_TITLE1` | `38_RES4` | Title text |
| `/THKR/GSBER` | `12_OEH` | Business area (from Ordnungseinheit) |
| `/THKR/SST` | `HEADER-EMPF` | Subsystem type (from file header EMPF field) |
| `DST_OLD` | `12_OEH` | Old Dienststelle code |
| `EP` | `09_AOB` | Einzelplan (budget section) |
| `IBAN` | `65_IBAN` | IBAN |
| `BANKK` | `63_BIC` | BIC/SWIFT |
| `BANKN` | `65_IBAN` | Bank account number (derived from IBAN) |
| `BANKS` | `65_IBAN` | Bank country key |
| `CUSTOMER-T_CUSTOMER_COMPANY` | — | Customer company data sub-table |
| `VENDOR-T_VENDOR_COMPANY` | — | Vendor company data sub-table |
| `T_MANDATE` | — | SEPA mandate sub-table |

### Record Type 13 — Kontokorrent (Clearing Account Assignment)

| SAP Field | BIC Source | Description |
|---|---|---|
| `AKONT` | `@GP!/THKR/SST` | Reconciliation account (derived from BP + SST) |
| `BUKRS` | `12_OEH` | Company code |
| `ZUAWA` | — | Sort key |

### Record Type 16 — Zahlungsbedingungen (Payment Terms)

| SAP Field | BIC Source | Description |
|---|---|---|
| `AKONT` | `@GP!/THKR/SST` | Reconciliation account |
| `BUKRS` | `12_OEH` | Company code |
| `REPRF` | — | Check double invoice flag |
| `ZUAWA` | — | Sort key |

### Record Type 18 — SEPA Mandat (SEPA Direct Debit Mandate)

| SAP Field | BIC Source | Description |
|---|---|---|
| `/THKR/GSBER` | `12_OEH` | Business area |
| `PAY_TYPE` | `76_MDTSTRG` | Mandate type (SEPA CORE/B2B) |
| `SEPA_CRDID` | `70_UCI` | Creditor ID (UCI) |
| `SEPA_MNDID` | `75_MDTREFER` | Mandate reference |
| `SEPA_SIGN_CITY` | `68_UORT` | Signing city |
| `SEPA_SIGN_DATE` | `69_UDATUM` | Signing date |
| `SEPA_STATUS` | `71_MGUELTIG` | Mandate validity status |
| `SEPA_VAL_FROM_DATE` | `69_UDATUM` | Valid from date |
| `SEPA_VAL_TO_DATE` | `%99991231` | Valid to date (constant: open-ended) |

### Record Type 20 — Anordnung (Payment Order — Primary)

The main FI posting record. Creates a financial document in SAP.

| SAP Field | BIC Source | Description |
|---|---|---|
| `BUKRS` | `12_OEH` | Company code |
| `BLART` | `@AO_SST` | Document type (derived from SST key) |
| `BLDAT` | — | Document date |
| `BUDAT` | — | Posting date |
| `BKTXT` | `32_KASSZ` | Header text ← **Kassenzeichen** |
| `XBLNR` | `32_KASSZ` | Reference document number ← **Kassenzeichen** |
| `GJAHR` | `04_HHJ` | Fiscal year |
| `WAERS` | `31_LFD` | Currency |
| `MWSKZ` | `01_BTYP` | Tax code |
| `PSOFN` | `28_AKTZ` | PSO function (Aktenzeichen) |
| `PSOTY` | `01_BTYP` | PSO type (Buchungstyp) |
| `PSOXB` | `HEADER-EMPF` | PSO external reference |
| `MABER` | `%ZALLGE` | Dunning area (constant: ZALLGE) |
| `MANSP` | `19_TXTSL` | Dunning block indicator |
| `MONAT` | — | Fiscal period |
| `ZFBDT` | `17_FDATUM` | **Baseline date for due date** ← see below |
| `ZLSCH` | `@PSOTY` | Payment method (derived from Buchungstyp) |
| `BVTYP` | `@PARTNER` | Payment partner type (derived from BP) |
| `PARTNER` | `@AO_BPEXT` | Business partner |
| `AO_SST` | `HEADER-EMPF` | AIF Anordnung SST |
| `AO_BPEXT` | `23_LIFNR` | External BP number for AO |
| `AO_BU_TYPE` | `38_RES4` | BP type for AO |
| `DST_OLD` | `12_OEH` | Old Dienststelle |
| `EP` | `09_AOB` | Einzelplan |
| `GLBLID` | `49_DSTNR` | Global ID (Dienststelle number) |
| `T_KONT` | — | Line item sub-table |

### Record Type 21 — Konto-Zeile (FI Line Item)

| SAP Field | BIC Source | Description |
|---|---|---|
| `FIKRS` | `12_OEH` | FM area |
| `FIPEX` | `10_KAP` | Commitment item (Finanzposition / Kapitel) |
| `FISTL` | `12_OEH` | Funds center |
| `FKBER` | `12_OEH` | Functional area |
| `GEBER` | `09_AOB` | Fund (Einzelplan) |
| `GSBER` | `12_OEH` | Business area |
| `HKONT` | `12_OEH` | G/L account |
| `KOSTL` | `12_OEH` | Cost center |
| `AUFNR` | `12_OEH` | Internal order |
| `MWSKZ` | `@AO!BLART` | Tax code (derived from document type) |
| `SGTXT` | `%*` | Item text (wildcard from message) |
| `WRBTR` | `15_BETR1` | Amount |

### Record Type 25 — Anordnung mit Referenz (Payment Order with Reference)

Same mapping as type 20, with the following addition:
- `BKTXT` ← `41_URKASS` (Urkassenzeichen instead of Kassenzeichen)
- `XBLNR` ← `32_KASSZ`
- `PSOAK` ← `%A` (PSO additional flag constant)

### Record Type 26 — Konto-Zeile für Referenz-Anordnung

Same mapping as type 21, with:
- `MWSKZ` ← `@AO_REFERENCE!BLART`

### Record Type 27 — Storno-Kopf (Reversal Header)

| SAP Field | BIC Source | Description |
|---|---|---|
| `AO_SST` | `HEADER-EMPF` | Anordnung SST |
| `BKTXT` | `41_URKASS` | Reversal reference (Urkassenzeichen) |
| `BLART` | `@AO_SST` | Document type |
| `DST_OLD` | `12_OEH` | Old Dienststelle |
| `EP` | `09_AOB` | Einzelplan |
| `GLBLID` | `49_DSTNR` | Global ID |
| `PSOTY` | `01_BTYP` | PSO type |
| `PSOXB` | `HEADER-EMPF` | PSO external reference |
| `XREF1_HD` | `@AO_SST` | Header reference |

### Record Type 50 — Storno-Detail (Reversal Details)

| SAP Field | BIC Source | Description |
|---|---|---|
| `KASSZ` | `41_URKASS` | Kassenzeichen being reversed |
| `GLBLID` | `49_DSTNR` | Global ID |
| `PROC_STATUS` | `%ST` | Processing status constant |
| `SST` | `%X` | Constant SST flag |
| `STGRD` | `%14` | Reversal reason code (constant: 14) |
| `ST_SST` | `HEADER-EMPF` | SST from header |
| `WF_STATUS` | `@ST_SST` | Workflow status (derived from SST) |

### Record Type 90 — Protokoll Kopf (Protocol Header)

| SAP Field | BIC Source | Description |
|---|---|---|
| `DIENSTSTELLE` | `49_DSTNR` | Department number |
| `EINZELPLAN` | `09_AOB` | Budget section |
| `VERFAHRENSKUERZEL` | `50_VFKZ` | Procedure abbreviation |

### Record Type 91 — Protokoll Summe (Protocol Summary)

| SAP Field | BIC Source | Description |
|---|---|---|
| `BUCHUNGSTYP` | `01_BTYP` | Posting type |
| `GLBLID` | `49_DSTNR` | Global ID |
| `SUMME` | `15_BETR1` | Total amount |

### Record Type 92 — APN Liste (Application Notification List)

The full record-level notification with all business fields:

| SAP Field | BIC Source | Description |
|---|---|---|
| `AKTENZEICHEN` | `28_AKTZ` | File reference number |
| `BVBREFERENZ` | `65_IBAN` | Payment transaction reference (IBAN) |
| `DIENSTSTELLE` | `49_DSTNR` | Department |
| `FAELLIG` | `17_FDATUM` | **Due date** ← see Section 5 below |
| `GLBLID` | `49_DSTNR` | Global ID |
| `KAP` | `10_KAP` | Budget chapter |
| `KASSENZEICHEN` | `32_KASSZ` | Cash reference |
| `NAME` | `38_RES4` | Debtor name |
| `OEH` | `12_OEH` | Ordnungseinheit |
| `ORT` | `24_RES2` | City |
| `PLZ` | `22_RES1` | Postal code |
| `POS` | `07_QPOSNR` | Source line item position |
| `QUELLE` | `05_QUELLE` | Source system |
| `SATZNR` | `06_QBELNR` | Source document number |
| `SOLL` | `15_BETR1` | Target/planned amount |
| `TITEL` | `11_TITEL` | Budget title |
| `TYP` | `01_BTYP` | Booking type |
| `UKTO` | `13_MSN` | Dunning level reference |
| `VERFAHRENSKUERZEL` | `50_VFKZ` | Procedure abbreviation |
| `ZAHLUNGSGRUND` | `29_GRUND` | Reason for payment |

---

## 5. Field `17_FDATUM` — Fälligkeitsdatum (Payment Due Date)

### In the BIC Line Structure (`/THKR/S_AIF_BIC_ZEILE_IST_RUEC`)

```
Field position:  17
Field name:      17_FDATUM
Data type:       CHAR(8)
Format:          YYYYMMDD  (SAP internal date format)
```

The naming convention for all BIC line fields is `{column_number}_{abbreviation}`:
- `17` = **column 17** in the BIC flat-file record
- `FDATUM` = **Fälligkeitsdatum** = **Payment Due Date**

### Business Meaning

The **legal due date** of the claim or payment order sent by EMSA (the dunning court). This is the date by which the debtor must pay. In the context of EMSA (central dunning court), this date comes from the original court ruling or administrative decision mandating payment.

### SAP Mapping — Three Uses

| Record Type | SAP Field | SAP Description | Usage |
|---|---|---|---|
| **20** (Anordnung) | `BSEG-ZFBDT` | Baseline Date for Due Date Calculation | SAP uses this date to calculate net payment due dates, prompt-payment discount dates, and dunning dates in FI |
| **25** (Anordnung + Referenz) | `BSEG-ZFBDT` | Same as type 20 | Same semantics |
| **92** (APN Liste) | `FAELLIG` | Fälligkeitsdatum in APN notification | Human-readable due date for monitoring/reporting |

### Why `ZFBDT` Is Critical

`BSEG-ZFBDT` is the baseline date SAP uses for:
- Calculating **net payment due date** (ZFBDT + payment terms net days)
- Determining **dunning eligibility** (document is past due when ZFBDT + grace days < today)
- **Prompt payment discounts** (discount validity based on ZFBDT)

By writing the EMSA court-mandated due date here, SAP respects the original legal deadline rather than recalculating from the posting date. This ensures dunning and payment processing in SAP aligns with the legal proceedings.

### Position in the Full BIC Line

```
Col 01: 01_BTYP     Buchungstyp          (1 char)   posting type
Col 02: 02_MERKM    Merkmal              (1 char)   characteristic
Col 03: 03_FIRMA    Firma                (2 char)   company
Col 04: 04_HHJ      Haushaltsjahr        (4 char)   fiscal year
Col 05: 05_QUELLE   Quelle               (8 char)   source system
Col 06: 06_QBELNR   Quellbelegnummer     (8 char)   source document number
Col 07: 07_QPOSNR   Quellpositionsnr.    (3 char)   source line item
Col 08: 08_USERKZ   Userkennzeichen      (8 char)   user ID
Col 09: 09_AOB      Anordnungsobjekt     (3 char)   Einzelplan
Col 10: 10_KAP      Kapitel              (12 char)  budget chapter (full FIPEX)
Col 11: 11_TITEL    Titel                (6 char)   budget title
Col 12: 12_OEH      Ordnungseinheit      (8 char)   org unit / Behörde
Col 13: 13_MSN      Mahnstufennummer     (6 char)   dunning level
Col 14: 14_REFER    Referenz             (8 char)   reference
Col 15: 15_BETR1    Betrag 1             (20 char)  main amount
Col 16: 16_BETR2    Betrag 2             (20 char)  secondary amount
▶▶ Col 17: 17_FDATUM  Fälligkeitsdatum  (8 char)   DUE DATE  ←
Col 18: 18_BETR3    Betrag 3             (20 char)  tertiary amount
Col 19: 19_TXTSL    Textsteuerschlüssel  (2 char)   dunning block key (→ MANSP)
Col 20: 20_BETR4    Betrag 4             (20 char)
Col 21: 21_BKZ      Buchungskennzeichen  (1 char)   posting indicator
Col 22: 22_RES1     Reserve 1            (20 char)  → postal code (AD_PSTCD1)
Col 23: 23_LIFNR    Lieferantennummer    (10 char)  vendor/debtor number
Col 24: 24_RES2     Reserve 2            (35 char)  → city (AD_CITY1)
Col 25: 25_BVNR     Buchungsvorgangsnr.  (3 char)
Col 26: 26_RES3     Reserve 3            (27 char)
Col 27: 27_ZWEG     Zahlungsweg          (3 char)   payment channel
Col 28: 28_AKTZ     Aktenzeichen         (20 char)  file reference → PSOFN
Col 29: 29_GRUND    Zahlungsgrund        (90 char)  reason for payment
Col 30: 30_BNR      Belegnummer          (8 char)   document number
Col 31: 31_LFD      Laufende Nr.         (3 char)   → currency (WAERS)
Col 32: 32_KASSZ    Kassenzeichen        (16 char)  cash reference → XBLNR/BKTXT
...
Col 41: 41_URKASS   Urkassenzeichen      (16 char)  original cash reference
...
Col 63: 63_BIC      BIC                  (11 char)  bank identifier code
Col 65: 65_IBAN     IBAN                 (34 char)  IBAN
...
Col 84: 84_ERECHACCKEY  E-Rechnung key   (40 char)  e-invoice access key
```

---

## 6. Interface Init and Check Functions

### `FUBA_INIT`: `/THKR/AIF_ZALLGE_FIELD_OVWR`

Executed before AIF starts processing each message. Reads customizing to set field overrides — allows specific BIC fields to be overwritten with fixed values or derived values at the message level (e.g., forcing a specific `BUKRS` or `FIKRS` regardless of what the file contains).

### `FUBA_CHECK`: `/THKR/AIF_ZALLGE_CHK_INTERFACE`

General interface validation — checks that the inbound message meets basic structural and business rule requirements before the action pipeline starts. Rejects messages that don't satisfy the interface contract.

---

## 7. Multi-Index Table (Deduplication Key)

**Table:** `/THKR/MI_0004001`

```
Key fields:
  MANDT    Client
  MSGGUID  AIF message GUID
  COUNTER  Line counter
  [.INCLUDE /AIF/IFKEYS]  AIF interface keys
  [.INCLUDE /AIF/ADMIN]   AIF admin fields
  PID      Process ID
  HHJ      Haushaltsjahr     (from /THKR/BIC_HHJ)
  KASSZ    Kassenzeichen     (from /THKR/BIC_KASSZ)
  URKASS   Urkassenzeichen   (from /THKR/BIC_URKASS)
  AKTZ     Aktenzeichen      (from /THKR/BIC_AKTZ)
```

The table description is "AIF Multi-Index Tabelle für Polizei" / "Multi-Index Tabelle für SolumStar" — EMSA and SolumStar (the BIC cash system) share the same multi-index key structure: `HHJ + KASSZ + URKASS + AKTZ`.

AIF uses this table to detect duplicate inbound messages. If a message with the same key combination has already been processed successfully, AIF rejects the duplicate.

---

## 8. Data Flow

```
EMSA (central dunning court) creates BIC flat-file
        │
        ▼
SAP Application Server (file picked up by AIF)
        │
        ▼
AIF reads file → DDICSTRUCTURERAW: /THKR/S_AIF_BIC
                 → each line parsed into /THKR/S_AIF_BIC_ZEILE_IST_RUEC
        │
        ▼
FUBA_INIT: /THKR/AIF_ZALLGE_FIELD_OVWR
  → apply field overrides from customizing
        │
        ▼
FUBA_CHECK: /THKR/AIF_ZALLGE_CHK_INTERFACE
  → structural/business validation
        │
        ▼
AIF Field Mapping: raw BIC fields → /THKR/S_AIF_SAP
  → 17_FDATUM  → ZFBDT  (for record types 20, 25)
  → 17_FDATUM  → FAELLIG (for record type 92)
  → other field mappings per record type (10–92)
        │
        ▼
Action pipeline:
  100: ACT_GP_INS  → create/insert Business Partner
  110: ACT_GP_CHG  → change Business Partner
  200: ACT_AO      → post FI Anordnung (BKPF/BSEG)
                      17_FDATUM → BSEG-ZFBDT (baseline due date)
  400: ACT_AO      → post referenced Anordnung
  500: ACT_STORNO  → reverse FI document
  900: ACT_APN     → store APN notification
  910: ACT_PROT_LST→ write protocol
  999: ACT_DEL_PROC_TAB → cleanup
        │
        ▼
FI Documents posted in SAP (BKPF/BSEG)
Business Partners created/updated (BUT000/BUT021)
Kassenzeichen registered (XBLNR, BKTXT)
Multi-index table /THKR/MI_0004001 updated (dedup key)
        │
        ▼
→ O_0004_002 (IST-Rückmeldung EMSA) sends actuals back to EMSA
```

---

## 9. Key ABAP Objects

| Object | Type | Location | Purpose |
|---|---|---|---|
| `/THKR/S_AIF_SAP` | Structure | `fremdv` | Root processing structure |
| `/THKR/S_AIF_BIC` | Structure | `fremdv` | Raw BIC file structure |
| `/THKR/S_AIF_BIC_ZEILE_IST_RUEC` | Structure | `fremdv` | 84-field BIC line (all BIC interfaces) |
| `/THKR/MI_0004001` | Table | `fremdv` | AIF multi-index (dedup) — HHJ/KASSZ/URKASS/AKTZ |
| `/THKR/AIF_ZALLGE_CHK_INTERFACE` | Function Module | `zallge` | Generic interface check |
| `/THKR/AIF_ZALLGE_FIELD_OVWR` | Function Module | `zallge` | Field override initialization |
| `/THKR/BIC_HHJ` | Data Element | `fremdv` | Haushaltsjahr (CHAR 4) |
| `/THKR/BIC_KASSZ` | Data Element | `fremdv` | Kassenzeichen |
| `/THKR/BIC_URKASS` | Data Element | `fremdv` | Urkassenzeichen |
| `/THKR/BIC_AKTZ` | Data Element | `fremdv` | Aktenzeichen |
