REPORT zllm_ollama_chat_client.

* Selection screen elements for display and buttons
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS p_runmod TYPE string VISIBLE LENGTH 40 NO-DISPLAY.
  PARAMETERS p_availm TYPE string VISIBLE LENGTH 40 NO-DISPLAY.
  SELECTION-SCREEN PUSHBUTTON /10(15) but_getm USER-COMMAND get_models_cmd VISIBLE LENGTH 15.
  SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  " Input for general chat
  SELECTION-SCREEN BEGIN OF SCREEN 0100 AS WINDOW TITLE TEXT-003.
    CONTAINER input_container_name. " Custom container for input text editor
  SELECTION-SCREEN END OF SCREEN 0100.
  SELECTION-SCREEN PUSHBUTTON /10(15) but_send USER-COMMAND send_prompt_cmd VISIBLE LENGTH 15.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-004.
  " Output for Ollama response
  SELECTION-SCREEN BEGIN OF SCREEN 0101 AS WINDOW TITLE TEXT-005.
    CONTAINER output_container_name. " Custom container for output text editor
  SELECTION-SCREEN END OF SCREEN 0101.
SELECTION-SCREEN END OF BLOCK b3.

* Text elements for screen
* TEXT-001: 'Ollama Model Information'
* TEXT-002: 'Chat with Ollama'
* TEXT-003: 'Your Prompt'
* TEXT-004: 'Ollama Response'
* TEXT-005: 'Response'
* TEXT-006: 'Get Models'
* TEXT-007: 'Test Hello'
* TEXT-008: 'Send'

CLASS lcl_app DEFINITION.
  PUBLIC SECTION.
    METHODS display.
    METHODS handle_user_command IMPORTING ucomm TYPE sy-ucomm.
    METHODS initialize_text_editors.
    METHODS get_ollama_models.
    METHODS send_test_hello.
    METHODS send_prompt_to_ollama.

  PRIVATE SECTION.
    DATA: text_editor_input    TYPE REF TO cl_gui_textedit,
          text_editor_output   TYPE REF TO cl_gui_textedit,
          custom_container_in  TYPE REF TO cl_gui_custom_container,
          custom_container_out TYPE REF TO cl_gui_custom_container.

    METHODS set_text_editor_content IMPORTING text TYPE string CHANGING editor TYPE REF TO cl_gui_textedit.
    METHODS get_text_editor_content RETURNING VALUE(text) TYPE string CHANGING editor TYPE REF TO cl_gui_textedit.
    METHODS cleanup_controls.
    METHODS call_connector_api IMPORTING iv_method TYPE string
                                         iv_path TYPE string
                                         iv_request_body TYPE string OPTIONAL
                               RETURNING VALUE(ev_response_body) TYPE string
                                         VALUE(ev_status_code) TYPE i
                                         VALUE(ev_error_message) TYPE string.
ENDCLASS.

CLASS lcl_app IMPLEMENTATION.

  METHOD display.
    CALL SCREEN 100.
  ENDMETHOD.

  METHOD handle_user_command.
    CASE ucomm.
      WHEN 'GET_MODELS_CMD'.
        get_ollama_models( ).
      WHEN 'TEST_HELLO_CMD'.
        send_test_hello( ).
      WHEN 'SEND_PROMPT_CMD'.
        send_prompt_to_ollama( ).
      WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
        cleanup_controls( ).
        LEAVE TO SCREEN 0.
    ENDCASE.
  ENDMETHOD.

  METHOD initialize_text_editors.
    IF custom_container_in IS NOT BOUND.
      custom_container_in = NEW cl_gui_custom_container(
        container_name = 'INPUT_CONTAINER_NAME'
      ).
      text_editor_input = NEW cl_gui_textedit(
        parent = custom_container_in
      ).
      text_editor_input->set_toolbar_mode( cl_gui_textedit=>false ).
      text_editor_input->set_statusbar_mode( cl_gui_textedit=>false ).
      text_editor_input->set_wordwrap_behavior(
        wordwrap_mode     = cl_gui_textedit=>wordwrap_at_fixed_position
        wordwrap_position = 100
      ).
    ENDIF.

    IF custom_container_out IS NOT BOUND.
      custom_container_out = NEW cl_gui_custom_container(
        container_name = 'OUTPUT_CONTAINER_NAME'
      ).
      text_editor_output = NEW cl_gui_textedit(
        parent = custom_container_out
      ).
      text_editor_output->set_toolbar_mode( cl_gui_textedit=>false ).
      text_editor_output->set_statusbar_mode( cl_gui_textedit=>false ).
      text_editor_output->set_wordwrap_behavior(
        wordwrap_mode     = cl_gui_textedit=>wordwrap_at_fixed_position
        wordwrap_position = 100
      ).
      text_editor_output->set_readonly_mode( 1 ).
    ENDIF.

    cl_gui_cfw=>flush( ).
  ENDMETHOD.

  METHOD get_ollama_models.
    DATA: lv_response_body TYPE string.
    DATA: lv_status_code   TYPE i.
    DATA: lv_error_message TYPE string.

    lv_response_body = call_connector_api(
      iv_method = 'GET'
      iv_path   = '/ollama_models'
      IMPORTING
        ev_status_code   = lv_status_code
        ev_error_message = lv_error_message
    ).

    IF lv_status_code >= 200 AND lv_status_code < 300.
      TRY.
          DATA(lt_models) TYPE zllm_keyvalue_tab.
          /ui2/cl_json=>deserialize( EXPORTING json = lv_response_body CHANGING data = lt_models ).

          DATA(lv_running_model) TYPE string.
          DATA(lv_available_models) TYPE string.

          READ TABLE lt_models INTO DATA(ls_running) WITH KEY key = 'running_model'.
          IF sy-subrc = 0.
            lv_running_model = ls_running-value.
          ENDIF.

          READ TABLE lt_models INTO DATA(ls_available) WITH KEY key = 'available_models'.
          IF sy-subrc = 0.
            lv_available_models = ls_available-value.
          ENDIF.

          p_runmod = lv_running_model.
          p_availm = lv_available_models.

          MESSAGE `Models retrieved successfully.` TYPE 'S'.
        CATCH cx_sy_json_parse_error INTO DATA(lx_json_error).
          MESSAGE `Error parsing JSON response from connector.` TYPE 'E'.
          set_text_editor_content( text = |Error: { lx_json_error->get_text( ) }| CHANGING editor = text_editor_output ).
      ENDTRY.
    ELSE.
      MESSAGE `Error getting models from connector.` TYPE 'E'.
      set_text_editor_content( text = |Error: { lv_error_message } (Status: { lv_status_code })| CHANGING editor = text_editor_output ).
    ENDIF.
  ENDMETHOD.

  METHOD send_test_hello.
    DATA(lv_prompt) = 'Hello, Ollama!'.
    DATA(lv_request_body) = /ui2/cl_json=>serialize( data = VALUE zllm_keyvalue_tab( ( key = 'prompt' value = lv_prompt ) ) ).

    DATA: lv_response_body TYPE string.
    DATA: lv_status_code   TYPE i.
    DATA: lv_error_message TYPE string.

    lv_response_body = call_connector_api(
      iv_method       = 'POST'
      iv_path         = '/ollama_chat'
      iv_request_body = lv_request_body
      IMPORTING
        ev_status_code   = lv_status_code
        ev_error_message = lv_error_message
    ).

    IF lv_status_code >= 200 AND lv_status_code < 300.
      TRY.
          DATA(lt_response) TYPE zllm_keyvalue_tab.
          /ui2/cl_json=>deserialize( EXPORTING json = lv_response_body CHANGING data = lt_response ).
          READ TABLE lt_response INTO DATA(ls_response) WITH KEY key = 'response'.
          IF sy-subrc = 0.
            set_text_editor_content( text = ls_response-value CHANGING editor = text_editor_output ).
            MESSAGE `Test prompt sent successfully.` TYPE 'S'.
          ELSE.
            MESSAGE `Unexpected response format from connector.` TYPE 'E'.
            set_text_editor_content( text = |Error: Unexpected response format: { lv_response_body }| CHANGING editor = text_editor_output ).
          ENDIF.
        CATCH cx_sy_json_parse_error INTO DATA(lx_json_error).
          MESSAGE `Error parsing JSON response from connector.` TYPE 'E'.
          set_text_editor_content( text = |Error: { lx_json_error->get_text( ) }| CHANGING editor = text_editor_output ).
      ENDTRY.
    ELSE.
      MESSAGE `Error sending test prompt to connector.` TYPE 'E'.
      set_text_editor_content( text = |Error: { lv_error_message } (Status: { lv_status_code })| CHANGING editor = text_editor_output ).
    ENDIF.
  ENDMETHOD.

  METHOD send_prompt_to_ollama.
    DATA(lv_prompt) = get_text_editor_content( CHANGING editor = text_editor_input ).
    IF lv_prompt IS INITIAL.
      MESSAGE `Please enter a prompt.` TYPE 'I'.
      RETURN.
    ENDIF.

    DATA(lv_request_body) = /ui2/cl_json=>serialize( data = VALUE zllm_keyvalue_tab( ( key = 'prompt' value = lv_prompt ) ) ).

    DATA: lv_response_body TYPE string.
    DATA: lv_status_code   TYPE i.
    DATA: lv_error_message TYPE string.

    lv_response_body = call_connector_api(
      iv_method       = 'POST'
      iv_path         = '/ollama_chat'
      iv_request_body = lv_request_body
      IMPORTING
        ev_status_code   = lv_status_code
        ev_error_message = lv_error_message
    ).

    IF lv_status_code >= 200 AND lv_status_code < 300.
      TRY.
          DATA(lt_response) TYPE zllm_keyvalue_tab.
          /ui2/cl_json=>deserialize( EXPORTING json = lv_response_body CHANGING data = lt_response ).
          READ TABLE lt_response INTO DATA(ls_response) WITH KEY key = 'response'.
          IF sy-subrc = 0.
            set_text_editor_content( text = ls_response-value CHANGING editor = text_editor_output ).
            MESSAGE `Prompt sent successfully.` TYPE 'S'.
          ELSE.
            MESSAGE `Unexpected response format from connector.` TYPE 'E'.
            set_text_editor_content( text = |Error: Unexpected response format: { lv_response_body }| CHANGING editor = text_editor_output ).
          ENDIF.
        CATCH cx_sy_json_parse_error INTO DATA(lx_json_error).
          MESSAGE `Error parsing JSON response from connector.` TYPE 'E'.
          set_text_editor_content( text = |Error: { lx_json_error->get_text( ) }| CHANGING editor = text_editor_output ).
      ENDTRY.
    ELSE.
      MESSAGE `Error sending prompt to connector.` TYPE 'E'.
      set_text_editor_content( text = |Error: { lv_error_message } (Status: { lv_status_code })| CHANGING editor = text_editor_output ).
    ENDIF.
  ENDMETHOD.

  METHOD set_text_editor_content.
    DATA texts TYPE STANDARD TABLE OF char255.
    DATA(remaining_text) = text.
    WHILE strlen( remaining_text ) > 0.
      DATA(line) = substring( val = remaining_text
                              len = COND #( WHEN strlen( remaining_text ) > 255 THEN 255 ELSE strlen( remaining_text ) ) ).
      APPEND line TO texts.
      remaining_text = substring( val = remaining_text
                                  off = strlen( line ) ).
    ENDWHILE.
    editor->set_text_as_stream( texts ).
    cl_gui_cfw=>flush( ).
  ENDMETHOD.

  METHOD get_text_editor_content.
    DATA texts TYPE STANDARD TABLE OF char255.
    editor->get_text_as_stream( IMPORTING text = texts ).
    text = concat_lines_of( table = texts sep = cl_abap_char_utilities=>cr_lf ).
  ENDMETHOD.

  METHOD cleanup_controls.
    IF text_editor_input IS BOUND.
      text_editor_input->free( ).
    ENDIF.
    IF text_editor_output IS BOUND.
      text_editor_output->free( ).
    ENDIF.
    IF custom_container_in IS BOUND.
      custom_container_in->free( ).
    ENDIF.
    IF custom_container_out IS BOUND.
      custom_container_out->free( ).
    ENDIF.
  ENDMETHOD.

  METHOD call_connector_api.
    " Define the URL of your Python connector
    " This should point to the Flask endpoint
    CONSTANTS lc_connector_base_url TYPE string VALUE 'http://<YOUR_PYTHON_CONNECTOR_HOST>:5000'.

    DATA: lo_http_client TYPE REF TO cl_http_client.
    DATA: lv_full_url    TYPE string.
    DATA: lv_reason      TYPE string.

    CONCATENATE lc_connector_base_url iv_path INTO lv_full_url.

    CALL METHOD cl_http_client=>create_by_url
      EXPORTING
        url    = lv_full_url
      IMPORTING
        client = lo_http_client
      EXCEPTIONS
        OTHERS = 1.

    IF sy-subrc <> 0.
      ev_status_code = 500.
      ev_error_message = 'Error creating HTTP client.'.
      RETURN.
    ENDIF.

    lo_http_client->request->set_method( iv_method ).

    IF iv_method = 'POST'.
      lo_http_client->request->set_header_field( name  = 'Content-Type'
                                                value = 'application/json' ).
      lo_http_client->request->set_cdata( iv_request_body ).
    ENDIF.

    CALL METHOD lo_http_client->send
      EXCEPTIONS
        OTHERS = 1.

    IF sy-subrc <> 0.
      ev_status_code = 500.
      ev_error_message = 'Error sending HTTP request.'.
      lo_http_client->close( ).
      RETURN.
    ENDIF.

    CALL METHOD lo_http_client->receive
      EXCEPTIONS
        OTHERS = 1.

    IF sy-subrc <> 0.
      ev_status_code = 500.
      ev_error_message = 'Error receiving HTTP response.'.
      lo_http_client->close( ).
      RETURN.
    ENDIF.

    ev_status_code = lo_http_client->response->get_status( ).
    lv_reason      = lo_http_client->response->get_reason( ).
    ev_response_body = lo_http_client->response->get_cdata( ).

    lo_http_client->close( ).

    IF ev_status_code >= 400.
      ev_error_message = lv_reason.
      IF ev_response_body IS NOT INITIAL.
        ev_error_message = ev_response_body. " Use response body for more details if available
      ENDIF.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

DATA app TYPE REF TO lcl_app.

INITIALIZATION.
  app = NEW #( ).

AT SELECTION-SCREEN OUTPUT.
  PERFORM status_0100.

START-OF-SELECTION.
  app->display( ).

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100'.
  app->initialize_text_editors( ).
  " Set button texts
  but_getm = TEXT-006.
  but_test = TEXT-007.
  but_send = TEXT-008.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  app->handle_user_command( sy-ucomm ).
ENDMODULE.