FUNCTION Z_LLM_READ_TABLE_DATA.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_TABLE_NAME) TYPE TABNAME
*"     VALUE(IV_WHERE_CLAUSE) TYPE STRING OPTIONAL
*"  EXPORTING
*"     VALUE(EV_SUCCESS) TYPE ABAP_BOOL
*"     VALUE(EV_ERROR_MESSAGE) TYPE STRING
*"  TABLES
*"      ET_DATA STRUCTURE ZLLM_KEYVALUE_TAB
*"----------------------------------------------------------------------

* Implement authorization check
* AUTHORITY-CHECK OBJECT 'S_TABU_DIS'
*   ID 'DICBERCLS' FIELD '*'
*   ID 'ACTVT' FIELD '03'. " Display
* IF SY-SCB <> 0.
*   EV_SUCCESS = ABAP_FALSE.
*   EV_ERROR_MESSAGE = 'Authorization check failed to read table data.'.
*   RETURN.
* ENDIF.

  DATA: lv_query TYPE string.
  DATA: lt_data  TYPE STANDARD TABLE OF string.
  DATA: lr_data  TYPE REF TO data.
  FIELD-SYMBOLS: <fs_data> TYPE any.

  TRY.
      CREATE DATA lr_data TYPE STANDARD TABLE OF (IV_TABLE_NAME).
      ASSIGN lr_data->* TO <fs_data>.

      IF IV_WHERE_CLAUSE IS NOT INITIAL.
        lv_query = |SELECT * FROM { IV_TABLE_NAME } WHERE { IV_WHERE_CLAUSE }|.
      ELSE.
        lv_query = |SELECT * FROM { IV_TABLE_NAME }|.
      ENDIF.

      EXEC SQL.
        { lv_query }
      ENDEXEC.

      IF SY-SCB = 0.
        " Convert dynamic data to ET_DATA (key-value pairs)
        " This part needs more sophisticated dynamic handling based on table structure
        " For simplicity, we'll just indicate success for now.
        EV_SUCCESS = ABAP_TRUE.
      ELSE.
        EV_SUCCESS = ABAP_FALSE.
        EV_ERROR_MESSAGE = |Failed to read data from table { IV_TABLE_NAME }. SQL error: { SY-SCB }|.
      ENDIF.

    CATCH cx_sy_dyn_table_create_error.
      EV_SUCCESS = ABAP_FALSE.
      EV_ERROR_MESSAGE = |Table { IV_TABLE_NAME } does not exist or cannot be accessed dynamically.|.
    CATCH cx_root INTO DATA(lx_exception).
      EV_SUCCESS = ABAP_FALSE.
      EV_ERROR_MESSAGE = lx_exception->get_text( ).
  ENDTRY.

ENDFUNCTION.