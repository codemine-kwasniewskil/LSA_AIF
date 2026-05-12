interface /THKR/IF_PSEUDO_PROCESS
  public .


  data TESTMODE type FLAG .
  data CHUNK_SIZE type INT8 .

  methods PROCESS_DATA
    importing
      !I_TESTMODE type FLAG default ABAP_TRUE
      !I_CHUNKSIZE type NUM6 default 50000
    returning
      value(RESULTS) type /THKR/TOOLS_PSEUDO_RESULTS .
endinterface.
