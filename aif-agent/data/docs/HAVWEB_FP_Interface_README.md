# HAVWEB_FP Interface Documentation

## Overview
**Interface ID:** HAVWEB_FP (MI_0036002/SI_0036002)  
**Namespace:** /THKR/  
**Purpose:** Harbor web service financial position processing  
**Domain:** Harbor Financial Services

## AIF Raw Structures

### /THKR/S_AIF_RAW_HAVWEB_FP
**Purpose:** Raw HAVWEB financial position data structure

## AIF SAP Structures

### /THKR/S_AIF_SAP_HAVWEB_FP
**Purpose:** SAP HAVWEB financial position structure

## AIF Actions

### /THKR/AIF_HAVWEB_ACT_FP_XML
**Purpose:** Process financial position XML data
**Functionality:**
- Handles XML processing for financial positions
- Parses and validates FP XML structures
- Transforms data for SAP integration

## AIF Mappings

### /THKR/AIF_AMAP_HAVWEB_FP
**Purpose:** Map HAVWEB financial position data
**Functionality:**
- Transforms financial position data for HAVWEB integration
- Maps harbor-specific financial data structures
- Handles FP (Financial Position) mappings

## AIF Checks

## Key Integration Points

### Harbor Financial Systems
- **Financial Position Processing**: FP data handling
- **XML Integration**: XML-based financial data exchange
- **Harbor Finance**: Harbor-specific financial operations

### SAP Integration
- **FI Integration**: Financial accounting processing
- **Funds Management**: FM commitment processing
- **XML Processing**: SAP XML document handling

## Processing Flow

1. **XML Data Reception** → Financial position XML data
2. **XML Parsing** → Structure validation and parsing
3. **Financial Mapping** → SAP financial structure transformation
4. **Position Processing** → Financial position business logic
5. **Document Creation** → SAP financial document generation

## Error Handling

### Error Types
- **XML Parsing Errors**: Invalid XML structure
- **Financial Validation Errors**: FP data validation failures
- **Integration Errors**: SAP FI integration issues

### Recovery Mechanisms
- **XML Reprocessing**: Failed XML message restart
- **Financial Correction**: FP data correction
- **Document Recovery**: SAP document recreation</content>
<parameter name="filePath">c:\Users\LukaszKwasniewski\Documents\Claude-Projects\lsa_aif_doc\HAVWEB_FP_Interface_README.md