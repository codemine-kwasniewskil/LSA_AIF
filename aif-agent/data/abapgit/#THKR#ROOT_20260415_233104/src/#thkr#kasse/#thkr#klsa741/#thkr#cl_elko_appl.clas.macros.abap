*"* use this source file for any macro definitions you need
*"* in the implementation part of the class

DEFINE export_memory.
  EXPORT &1 FROM &2  TO MEMORY ID &3.
END-OF-DEFINITION.

DEFINE import_memory.
  IMPORT &1 TO &2    FROM MEMORY ID &3.
END-OF-DEFINITION.
