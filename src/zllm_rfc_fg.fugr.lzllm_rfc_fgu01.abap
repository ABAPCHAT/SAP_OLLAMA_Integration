FUNCTION Z_LLM_GET_ABAP_SOURCE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_PROGRAM_NAME) TYPE PROGNAME
*"  EXPORTING
*"     VALUE(EV_SUCCESS) TYPE ABAP_BOOL
*"     VALUE(EV_ERROR_MESSAGE) TYPE STRING
*"  TABLES
*"      ET_SOURCE_CODE STRUCTURE ABAPTEXT
*"----------------------------------------------------------------------

* Implement authorization check
* AUTHORITY-CHECK OBJECT 'S_DEVELOP'
*   ID 'DEVCLASS' FIELD '*'
*   ID 'OBJTYPE' FIELD 'PROG'
*   ID 'OBJNAME' FIELD IV_PROGRAM_NAME
*   ID 'ACTVT' FIELD '03'. " Display
* IF SY-SCB <> 0.
*   EV_SUCCESS = ABAP_FALSE.
*   EV_ERROR_MESSAGE = 'Authorization check failed to read program source.'.
*   RETURN.
* ENDIF.

  READ REPORT IV_PROGRAM_NAME INTO ET_SOURCE_CODE.

  IF SY-SCB = 0.
    EV_SUCCESS = ABAP_TRUE.
  ELSE.
    EV_SUCCESS = ABAP_FALSE.
    EV_ERROR_MESSAGE = 'Program or class not found.'.
  ENDIF.

ENDFUNCTION.