# SAP AIF Interfaces Documentation - HKR Land Sachsen-Anhalt

## Project Overview

**Namespace:** `/THKR/`  
**Owner:** T-Systems  
**Description:** AIF interfaces for Land Sachsen-Anhalt (Saxony-Anhalt state government)  
**Purpose:** Financial management, payment processing, and external system integrations

## Interface Summary

This documentation covers the main SAP AIF interfaces implemented for HKR Land Sachsen-Anhalt. Each interface has its own detailed README.md file.

### 1. FREMDV Interface Domain
**File:** [FREMDV_Interface_README.md](FREMDV_Interface_README.md)  
**Purpose:** External system integrations for payment confirmations and financial data exchange  
**Key Components:**
- Rückmeldung processing (payment confirmations)
- EDAS integration (Enterprise Data Access Service)
- Police system integration
- File-based data exchange (BIC format)

### 2. HAVWEB Interface Domain
**File:** [HAVWEB_Interface_README.md](HAVWEB_Interface_README.md)  
**Purpose:** Harbor and web service integrations for financial transactions  
**Key Components:**
- Harbor endpoint processing (EP)
- Financial position processing (FP)
- XML-based web service integration

### 3. ZALLGE Interface Domain
**File:** [ZALLGE_Interface_README.md](ZALLGE_Interface_README.md)  
**Purpose:** General AIF functions for financial processing and common operations  
**Key Components:**
- Anordnung processing (orders)
- Geschäftspartner processing (business partners)
- Mahnbescheid processing (dunning notices)
- Verrechnung processing (clearings)
- 80+ mapping functions for various data transformations

### 4. SERiD Interface
**File:** [SERiD_Interface_README.md](SERiD_Interface_README.md)  
**Purpose:** Police service interface for document processing and Rückmeldungen  
**Key Components:**
- RTF document processing
- Police service request handling
- Service status tracking

### 5. HAVWEB_EP Interface
**File:** [HAVWEB_EP_Interface_README.md](HAVWEB_EP_Interface_README.md)  
**Purpose:** Harbor web service endpoint processing  
**Key Components:**
- Web service endpoint management
- Harbor operations processing
- HTTP-based service integration

### 6. HAVWEB_FP Interface
**File:** [HAVWEB_FP_Interface_README.md](HAVWEB_FP_Interface_README.md)  
**Purpose:** Harbor web service financial position processing  
**Key Components:**
- Financial position XML processing
- Harbor finance data mapping
- SAP FI document integration

### 7. RUECKMELDUNG Interface
**File:** [RUECKMELDUNG_Interface_README.md](RUECKMELDUNG_Interface_README.md)  
**Purpose:** Payment confirmations and financial feedback processing  
**Key Components:**
- Payment status validation
- Rückmeldung data processing
- SAP FI/CO integration

### 8. EDAS Interface
**File:** [EDAS_Interface_README.md](EDAS_Interface_README.md)  
**Purpose:** Enterprise Data Access Service integration for external data processing  
**Key Components:**
- SZU processing (special users)
- Zero-amount record handling
- Financing parameter management

## Architecture Overview

### AIF Components Structure
```
├── Raw Structures (Input data)
├── SAP Structures (Processed data)
├── Actions (Business logic execution)
├── Mappings (Data transformation)
└── Checks (Validation rules)
```

### Key Integration Points
- **SAP FI/CO**: Financial accounting and controlling
- **SAP FM**: Funds management
- **SAP BP**: Business partner management
- **External Systems**: EDAS, OASIS, Police, Harbor systems

### Data Flow Pattern
1. **Data Reception** → External data input
2. **Validation** → Business rule checks
3. **Transformation** → SAP format mapping
4. **Processing** → Business logic execution
5. **Output** → Response generation

## Technical Implementation

### Function Groups
- `/THKR/AIF_FREMDV_*`: External system functions
- `/THKR/AIF_HAVWEB_*`: Harbor web functions
- `/THKR/AIF_ZALLGE_*`: General functions

### Key Classes
- `/THKR/CL_AIF_RUECK`: Rückmeldung processing
- `/THKR/CL_AIF_FILE_BASICS`: File handling
- `/THKR/CL_AIF_CHK`: Validation logic
- `/THKR/CL_AIF_MAP`: Mapping utilities

### Database Tables
- `/THKR/MI_*`: Multi-index tables
- `/THKR/SI_*`: Single-index tables
- `/THKR/S_AIF_*`: Structure tables
- `/THKR/T_*`: Transaction tables

## File Formats Supported
- **BIC Format**: Banking industry standard
- **XML Format**: Structured data exchange
- **CSV Format**: Bulk data processing
- **Flat Files**: Fixed-width formats

## Security and Authorization
- Interface-specific authorizations
- Company code restrictions
- System-specific permissions
- Data validation and sanitization

## Monitoring and Administration
- `/THKR/AIF_ANALYSE`: Analysis and monitoring
- `/THKR/AIF_MSG_READ`: Message reading utility
- `/THKR/AIF_RESTART`: Process restart functionality
- `/THKR/AIF_TOOL`: General administration tools

## Error Handling Framework
- BAL (Business Application Log) integration
- Custom error table logging
- Reprocessing capabilities
- Manual correction tools

## Development Standards
- Consistent naming conventions (`/THKR/`)
- Standardized function module interfaces
- Comprehensive documentation
- Error handling patterns

---

*This documentation provides a comprehensive overview of the SAP AIF interfaces implemented for HKR Land Sachsen-Anhalt. Each interface README.md file contains detailed technical specifications, data structures, processing logic, and integration points.*</content>
<parameter name="filePath">c:\Users\LukaszKwasniewski\Documents\Claude-Projects\lsa_aif_doc\README.md