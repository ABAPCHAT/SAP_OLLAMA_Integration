FUNCTION Z_LLM_GET_DDIC_INFO.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_OBJECT_NAME) TYPE DDICNAME
*"  EXPORTING
*"     VALUE(EV_SUCCESS) TYPE ABAP_BOOL
*"     VALUE(EV_ERROR_MESSAGE) TYPE STRING
*"  TABLES
*"      ET_FIELDS STRUCTURE DFIES
*"----------------------------------------------------------------------

* Implement authorization check
* AUTHORITY-CHECK OBJECT 'S_DDIC'
*   ID 'DDIC_OBJ' FIELD IV_OBJECT_NAME
*   ID 'ACTVT' FIELD '03'. " Display
* IF SY-SCB <> 0.
*   EV_SUCCESS = ABAP_FALSE.
*   EV_ERROR_MESSAGE = 'Authorization check failed to read DDIC info.'.
*   RETURN.
* ENDIF.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME   = IV_OBJECT_NAME
    TABLES
      DFIES_TAB = ET_FIELDS
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.

  IF SY-SCB = 0.
    EV_SUCCESS = ABAP_TRUE.
  ELSEIF SY-SCB = 1.
    EV_SUCCESS = ABAP_FALSE.
    EV_ERROR_MESSAGE = 'DDIC object not found.'.
  ELSE.
    EV_SUCCESS = ABAP_FALSE.
    EV_ERROR_MESSAGE = 'Error retrieving DDIC information.'.
  ENDIF.

ENDFUNCTION.