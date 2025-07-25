FUNCTION Z_LLM_EXECUTE_BAPI.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_BAPI_NAME) TYPE BAPIFUNC
*"     VALUE(IT_INPUT_PARAMETERS) TYPE ZLLM_KEYVALUE_TAB OPTIONAL
*"  EXPORTING
*"     VALUE(EV_SUCCESS) TYPE ABAP_BOOL
*"     VALUE(EV_ERROR_MESSAGE) TYPE STRING
*"  TABLES
*"      ET_RETURN STRUCTURE BAPIRET2 OPTIONAL
*"      ET_OUTPUT_PARAMETERS STRUCTURE ZLLM_KEYVALUE_TAB OPTIONAL
*"----------------------------------------------------------------------

* Implement authorization check
* AUTHORITY-CHECK OBJECT 'S_BAPI'
*   ID 'BAPINAME' FIELD IV_BAPI_NAME
*   ID 'ACTVT' FIELD '16'. " Execute
* IF SY-SCB <> 0.
*   EV_SUCCESS = ABAP_FALSE.
*   EV_ERROR_MESSAGE = 'Authorization check failed to execute BAPI.'.
*   RETURN.
* ENDIF.

  DATA: lv_function_name TYPE funcname.
  DATA: lt_parameters    TYPE STANDARD TABLE OF rfc_param.
  DATA: ls_parameter     TYPE rfc_param.
  DATA: lr_data          TYPE REF TO data.
  FIELD-SYMBOLS: <fs_data> TYPE any.

  lv_function_name = IV_BAPI_NAME.

  TRY.
      CALL FUNCTION lv_function_name
        EXPORTING
*         (Dynamic parameters from IT_INPUT_PARAMETERS)
        IMPORTING
*         (Dynamic parameters to ET_OUTPUT_PARAMETERS)
        TABLES
          RETURN = ET_RETURN.

      EV_SUCCESS = ABAP_TRUE.

      " Populate ET_OUTPUT_PARAMETERS (simplified - needs dynamic handling)
      " For a real implementation, you would dynamically read the BAPI's export/table parameters
      " and convert them to key-value pairs.

    CATCH cx_sy_dyn_call_illegal_method cx_sy_dyn_call_illegal_parameter.
      EV_SUCCESS = ABAP_FALSE.
      EV_ERROR_MESSAGE = 'Invalid BAPI name or parameters.'.
    CATCH cx_sy_message_in_dynamic_call INTO DATA(lx_message).
      EV_SUCCESS = ABAP_FALSE.
      EV_ERROR_MESSAGE = lx_message->get_text( ).
    CATCH cx_root INTO DATA(lx_exception).
      EV_SUCCESS = ABAP_FALSE.
      EV_ERROR_MESSAGE = lx_exception->get_text( ).
  ENDTRY.

ENDFUNCTION.