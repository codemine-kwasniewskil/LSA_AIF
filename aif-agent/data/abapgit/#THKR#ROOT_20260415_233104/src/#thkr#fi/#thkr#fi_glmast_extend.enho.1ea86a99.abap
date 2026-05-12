"Name: \FU:MASTERIDOC_CREATE_GLMAST\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/FI_GLMAST_EXTEND.
** The SAP Standard avoids sending Secondory Costs accoarding to backward compatibility e.g. ERP6. ( 2353087 - No sending of secondary cost elements via GLMAST )
** This leads to the problem that the replication is not functional for all G/L accounts required by HKR.
** - Solution 1: Message Type COELEM doesn't fit - the standard IDoc for secondary costs COELEM is not working properly because of default values ( Cost Type )
**               which are set at target and further it isn't allowed to select by company code.
** + Solution 2: We copy this FuBa MASTERIDOC_CREATE_GLMAST with extensions -> /THKR/MASTERIDOC_CREATE_GLMAST and delete the Note 2353087 implementation
**              [ Commented Out line 70-94 ]. This includes the manual delivery (BD18) as well as Change Pointer implementation.

CALL FUNCTION '/THKR/MASTERIDOC_CREATE_GLMAST'
  EXPORTING
    ska1key            = ska1key
    rcvpfc             = rcvpfc
    rcvprn             = rcvprn
    rcvprt             = rcvprt
    sndpfc             = sndpfc
    sndprn             = sndprn
    sndprt             = sndprt
    mestyp             = mestyp
  IMPORTING
    created_comm_idocs = created_comm_idocs
  TABLES
    skatkey            = skatkey
    skb1key            = skb1key.

RETURN.

ENDENHANCEMENT.
