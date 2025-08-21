prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_210200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2021.10.15'
,p_release=>'21.2.5'
,p_default_workspace_id=>100000
,p_default_application_id=>101
,p_default_id_offset=>0
,p_default_owner=>'BUSINESSDB'
);
end;
/
 
prompt APPLICATION 101 - Autocomplete Plug-in
--
-- Application Export:
--   Application:     101
--   Name:            Autocomplete Plug-in
--   Date and Time:   16:28 Wednesday August 20, 2025
--   Exported By:     BUSINESSDB
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 1
--   Manifest End
--   Version:         21.2.5
--   Instance ID:     1
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/business_db_apex_auto_complete
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(84003609119055356)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'BUSINESS.DB.APEX.AUTO.COMPLETE'
,p_display_name=>'APEX Autocomplete Item'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_javascript_file_urls=>'#PLUGIN_FILES#script#MIN#.js'
,p_css_file_urls=>'#PLUGIN_FILES#style#MIN#.css'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function create_data_json (',
'    p_item              in apex_plugin.t_item,',
'    p_in_value          in clob := empty_clob(),',
'    p_out_display_value out nocopy clob',
') return clob as',
'    -- record of context',
'    l_context     apex_exec.t_context;',
'    -- number of label column in data source',
'    l_d_col_no    pls_integer := 0;',
'    -- label variable',
'    l_d_value     varchar2(32767);',
'    -- number of value column in data source',
'    l_r_col_no    pls_integer := 0;',
'    -- value variable',
'    l_r_value     varchar2(32767);',
'    -- number of icon column in data source',
'    l_i_col_no    pls_integer := 0;',
'    -- icon variable',
'    l_i_value     varchar2(32767);',
'    -- number of group column in data source',
'    l_g_col_no    pls_integer := 0;',
'    -- group variable',
'    l_g_value     varchar2(32767);',
'    -- number of info column in data source',
'    l_info_col_no pls_integer := 0;',
'    -- info variable',
'    l_info_value  varchar2(32767);',
'    -- clob for return',
'    l_ret         clob := empty_clob();',
'    l_table_cols apex_t_varchar2;',
'    type table_cols is record (',
'            col_position number,',
'            col_name     varchar2(32767),',
'            col_id       varchar2(32767)',
'    );',
'    type table_cols_tab is table of table_cols index by binary_integer;',
'    l_cols_table table_cols_tab;',
'    c_display_as_table boolean := p_item.attribute_14 = ''table'';',
'begin',
'',
'    apex_debug.info(p_item.name || '' - LOV Definition: '' || p_item.lov_definition);',
'    apex_debug.info(p_item.name || '' - LOV Display Column: '' || p_item.lov_display_column);',
'    apex_debug.info(p_item.name || '' - LOV Return Column: '' || p_item.lov_return_column);',
'    apex_debug.info(p_item.name || '' - LOV Icon Column: '' || p_item.lov_icon_column);',
'    apex_debug.info(p_item.name || '' - LOV Group Column: '' || p_item.lov_group_column);',
'',
'    -- execute query and store it to context array',
'    l_context        := apex_exec.open_query_context(',
'        p_location  => apex_exec.c_location_local_db,',
'        -- dirty workaround to get also icon and group anbd other columns',
'        p_sql_query => replace(p_item.lov_definition, ''"''||p_item.lov_display_column||''","''||p_item.lov_return_column||''"'', ''*'')',
'    );',
'',
'    -- get position of label col',
'    l_d_col_no   := apex_exec.get_column_position(l_context, p_item.lov_display_column);',
'    ',
'    -- get position of value col',
'    l_r_col_no   := apex_exec.get_column_position(l_context, p_item.lov_return_column);',
'',
'    -- get position of icon col',
'    if p_item.lov_icon_column is not null then',
'        l_i_col_no   := apex_exec.get_column_position(l_context, p_item.lov_icon_column);',
'    end if;',
'',
'    -- get position of group col',
'    if p_item.lov_group_column is not null or instr(lower(p_item.lov_definition), ''GROUPS'') > 0 then',
'        l_g_col_no   := apex_exec.get_column_position(l_context, coalesce(p_item.lov_group_column, ''GROUPS''));',
'    end if;',
'    ',
'    -- get position of info col',
'    if p_item.attribute_13 = ''Y'' then',
'        l_info_col_no   := apex_exec.get_column_position(l_context, ''INFO'');',
'    end if;',
'',
'    -- check for table columns if display as table is set',
'    if c_display_as_table and p_item.attribute_15 is not null then',
'        l_table_cols := apex_string.split(p_item.attribute_15, '':'');',
'        for i in l_table_cols.first .. l_table_cols.last',
'        loop',
'            l_cols_table(i).col_position := apex_exec.get_column_position(l_context, l_table_cols(i));',
'            l_cols_table(i).col_id       := l_table_cols(i);',
'            l_cols_table(i).col_name     := apex_lang.message(l_table_cols(i));',
'        end loop;',
'    end if;',
'    ',
'    -- create data json for chart from cursor',
'    -- USE APEX_JSON to prevent security issues with string concatination',
'    apex_json.initialize_clob_output;',
'',
'    -- open json object - {',
'    apex_json.open_object;',
'    ',
'    -- open json array - [',
'    apex_json.open_array(''rows'');',
'    ',
'    -- loop through conext array',
'    while apex_exec.next_row(p_context => l_context) loop',
'        -- get display value',
'        if l_d_col_no > 0 then',
'            l_d_value := apex_exec.get_varchar2(l_context, l_d_col_no);',
'        end if;',
'       ',
'        -- get return value',
'        if l_r_col_no > 0 then',
'            l_r_value   := apex_exec.get_varchar2(l_context, l_r_col_no);',
'        else ',
'            l_r_value := l_d_value;',
'        end if;',
'',
'        -- get icon value',
'        if l_i_col_no > 0 then',
'            l_i_value   := apex_exec.get_varchar2(l_context, l_i_col_no);',
'        end if;',
'',
'        -- get group value',
'        if l_g_col_no > 0 then',
'            l_g_value   := apex_exec.get_varchar2(l_context, l_g_col_no);',
'        end if;',
'',
'        -- get info value',
'        if l_info_col_no > 0 then',
'            l_info_value   := apex_exec.get_varchar2(l_context, l_info_col_no);',
'        end if;',
'',
'        if l_r_value = p_in_value then',
'            p_out_display_value := p_out_display_value || l_d_value;',
'        end if;',
'       ',
'        -- open json object - {',
'        apex_json.open_object;',
'        ',
'        -- write display value to json',
'        if l_d_col_no > 0 then',
'            apex_json.write(''label'', l_d_value);',
'        end if;',
'        -- write return value to json',
'        if l_r_col_no > 0 then',
'            apex_json.write(''value'', l_r_value);',
'        end if;',
'',
'        -- write icon value to json',
'        if l_i_col_no > 0 then',
'            apex_json.write(''icon'', l_i_value);',
'        end if;',
'        ',
'        -- write group value to json',
'        if l_g_col_no > 0 then',
'            apex_json.write(''group'', l_g_value);',
'        end if;',
'',
'        -- write group value to json',
'        if l_info_col_no > 0 then',
'            apex_json.write(''info'', l_info_value);',
'        end if;',
'',
'        -- check for table columns if display as table is set',
'        if c_display_as_table and p_item.attribute_15 is not null and l_cols_table.count() > 0 then',
'            -- open json array - [',
'            apex_json.open_array(''tableColumns'');',
'            for i in l_cols_table.first .. l_cols_table.last',
'            loop',
'                if l_cols_table(i).col_position > 0 then',
'                    apex_json.open_object;',
'                    apex_json.write(''name'', l_cols_table(i).col_name);',
'                    apex_json.write(''value'', apex_exec.get_varchar2(l_context, l_cols_table(i).col_position));',
'                    apex_json.close_object;',
'                end if;',
'            end loop;',
'            ',
'            -- open json array - ]',
'            apex_json.close_array;',
'        end if;',
'        ',
'        -- Close json object - }',
'        apex_json.close_object;',
'    end loop;',
'',
'    -- don''t forget to cleanup',
'    apex_exec.close(l_context);',
'    ',
'    -- open json array - ]',
'    apex_json.close_array;',
'    ',
'    -- Close json object - }',
'    apex_json.close_object;',
'',
'    l_ret := apex_json.get_clob_output;',
'',
'    if p_out_display_value is null then',
'        p_out_display_value := to_clob(p_in_value);',
'    end if;',
'',
'    apex_json.free_output;',
'    return l_ret;',
'    ',
'-- and DON''T forget exeption handling including also the cleanup',
'exception',
'    when others then',
'        apex_exec.close(l_context);',
'        apex_json.close_all;',
'        apex_json.free_output;',
'        raise;',
'end;',
'',
'procedure p_ajax (',
'    p_item   in apex_plugin.t_item,',
'    p_plugin in apex_plugin.t_plugin,',
'    p_param  in apex_plugin.t_item_ajax_param,',
'    p_result in out nocopy apex_plugin.t_item_ajax_result',
') is',
'    -- clob that is send to client',
'    l_clob clob := empty_clob();',
'    -- only needed because function has out param',
'    l_tmp_clob clob := empty_clob();',
'begin',
'    l_clob := create_data_json(p_item => p_item, p_out_display_value => l_tmp_clob);',
'    apex_util.prn(p_clob => l_clob, p_escape => false);',
'end;',
'',
'procedure f_render (',
'    p_item   in apex_plugin.t_item,',
'    p_plugin in apex_plugin.t_plugin,',
'    p_param  in apex_plugin.t_item_render_param,',
'    p_result in out nocopy apex_plugin.t_item_render_result',
') as',
'    -- clob that is send to client as global variable',
'    l_clob clob := empty_clob();',
'    -- display value that is set on init',
'    vr_display_value clob := empty_clob();',
'    c_multi_selection constant boolean := case when p_item.attribute_01 = ''Y'' then true else false end;',
'    vr_input_type varchar2(20) := ''TEXT'';',
'    vr_btn_action varchar2(4000 char) := p_item.attribute_06;',
'begin',
'',
'    if p_item.attribute_08 = ''N'' then',
'        apex_util.prn(p_clob => ''<script type="text/javascript"> var gLOV_'' || p_item.name || ''='', p_escape => false);',
'',
'        apex_util.prn(',
'            p_clob => create_data_json(',
'                p_item              => p_item,',
'                p_in_value          => p_param.value,',
'                p_out_display_value => vr_display_value',
'            ),',
'            p_escape => false',
'        );',
'',
'        apex_util.prn(p_clob => '';</script>'', p_escape => false);',
'    end if;',
'',
'    if apex_application.g_debug then',
'        apex_plugin_util.debug_page_item( p_plugin => p_plugin, p_page_item => p_item );',
'    end if;',
'    ',
'    dbms_lob.createtemporary(lob_loc => l_clob, cache => false);',
'',
'    if c_multi_selection then',
'        vr_input_type := ''HIDDEN'';',
'        sys.dbms_lob.append(l_clob, ''<div class="apex-item-text apexautocomplete-ms-wrap" id="'' || p_item.name || ''_msc">'');',
'        sys.dbms_lob.append(l_clob, ''<ul class="apexautocomplete-ms-ul"></ul>'');',
'        sys.dbms_lob.append(l_clob, ''<input type="TEXT" id="'' || p_item.name || ''_msc_tf" class="apexautocomplete-ms-tf" placeholder="'' || apex_escape.html_attribute(p_item.placeholder) || ''">'');',
'        sys.dbms_lob.append(l_clob, ''</div>'');',
'    end if;',
'',
'    sys.dbms_lob.append(l_clob, ''<input type="'' || vr_input_type || ''" '' || apex_plugin_util.get_element_attributes(p_item, apex_plugin.get_input_name_for_page_item(false), ''apex-item-text''));',
'    sys.dbms_lob.append(l_clob, '' placeholder="'' || apex_escape.html_attribute(p_item.placeholder) || ''"'');',
'    sys.dbms_lob.append(l_clob, '' id="'' || p_item.name || ''"'');',
'    if p_item.is_required then',
'        sys.dbms_lob.append(l_clob, '' required="true" '');',
'    end if;',
'    sys.dbms_lob.append(l_clob, '' maxlength="'' || p_item.element_max_length || ''"'');',
'    sys.dbms_lob.append(l_clob, '' value="'' || vr_display_value || ''"'');',
'    sys.dbms_lob.append(l_clob, '' raw-value="'' || apex_escape.html_attribute(p_param.value) || ''"'');',
'    sys.dbms_lob.append(l_clob, '' size="'' || p_item.element_width || ''"/>'');',
'    apex_util.prn(p_clob => l_clob, p_escape => false);',
'',
'    if lower(vr_btn_action) like ''f?p=%'' then',
'        vr_btn_action := apex_util.prepare_url(',
'                                              p_url => vr_btn_action,',
'                                              p_triggering_element => p_item.name',
'                         );',
'    end if;',
'',
'    apex_javascript.add_onload_code(',
'        p_code => ''apexAutoCompleteItem(apex, $).initialize({'' ||',
'                apex_javascript.add_attribute(''itemName'', p_item.name, true ) ||',
'                apex_javascript.add_attribute(''escapeHTML'', p_item.escape_output, true ) ||',
'                apex_javascript.add_attribute(''ajaxID'', apex_plugin.get_ajax_identifier, true ) ||',
'                apex_javascript.add_attribute(''multiselection'', c_multi_selection, true ) ||',
'                apex_javascript.add_attribute(''maxSelections'', to_number(p_item.attribute_10), true ) ||',
'                apex_javascript.add_attribute(''displayType'', p_item.attribute_14, true ) ||',
'                apex_javascript.add_attribute(''maxResults'', to_number(p_item.attribute_02), true ) ||',
'                apex_javascript.add_attribute(''btnShow'', p_item.attribute_03, true ) ||',
'                apex_javascript.add_attribute(''btnLabel'', p_item.attribute_04, true ) ||',
'                apex_javascript.add_attribute(''btnIcon'', p_item.attribute_05, true ) ||',
'                apex_javascript.add_attribute(''nextBtnLabel'', apex_lang.message(''APEXAPP.BUTTON.NEXT''), true ) ||',
'                apex_javascript.add_attribute(''nextBtnIcon'', ''fa-arrow-right'', true ) ||',
'                apex_javascript.add_attribute(''previousBtnLabel'', apex_lang.message(''APEXAPP.BUTTON.PREVIOUS''), true ) ||',
'                apex_javascript.add_attribute(''previousBtnIcon'', ''fa-arrow-left'', true ) ||',
'                apex_javascript.add_attribute(''minListWidth'', p_item.attribute_11, true ) ||',
'                apex_javascript.add_attribute(''updateLOVbeforeSetValue'', p_item.attribute_12, true ) ||',
'                apex_javascript.add_attribute(''btnAction'', vr_btn_action, true ) ||',
'                apex_javascript.add_attribute(''cascadeParentItem'', apex_plugin_util.page_item_names_to_jquery(p_item.lov_cascade_parent_items), true ) ||',
'                apex_javascript.add_attribute(''itemsToSubmit'', apex_plugin_util.page_item_names_to_jquery(p_item.ajax_items_to_submit), true ) ||',
'                apex_javascript.add_attribute(''lovDisplayExtra'', p_item.lov_display_extra, false ) ||',
'            ''}'' || case when p_item.attribute_08 = ''N'' then '', gLOV_'' || p_item.name end || '');'');',
'',
'end;'))
,p_api_version=>2
,p_render_function=>'F_RENDER'
,p_ajax_function=>'P_AJAX'
,p_standard_attributes=>'VISIBLE:FORM_ELEMENT:SESSION_STATE:ESCAPE_OUTPUT:SOURCE:WIDTH:PLACEHOLDER:LOV:CASCADING_LOV'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'This LOV based autocomplete item plug-in allows you to create new DB entries and supports a table view for the lov entries.',
'',
'MIT License',
'',
'Copyright (c) 2025 Business-DB',
'',
'Permission is hereby granted, free of charge, to any person obtaining a copy',
'of this software and associated documentation files (the "Software"), to deal',
'in the Software without restriction, including without limitation the rights',
'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell',
'copies of the Software, and to permit persons to whom the Software is',
'furnished to do so, subject to the following conditions:',
'',
'The above copyright notice and this permission notice shall be included in all',
'copies or substantial portions of the Software.',
'',
'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR',
'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,',
'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE',
'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER',
'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,',
'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE',
'SOFTWARE.'))
,p_version_identifier=>'1.0'
,p_about_url=>'https://business-db.com'
,p_files_version=>526
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(84003808204055358)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Multi-Selection'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_is_translatable=>false
,p_help_text=>'Enable selection of multiple entries'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(84004295541055360)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Number of Results'
,p_attribute_type=>'INTEGER'
,p_is_required=>true
,p_default_value=>'5'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_is_translatable=>false
,p_help_text=>'Specify the maximum number of results in the search list that are shown'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(84004680037055360)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Add Button to List'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_is_translatable=>false
,p_help_text=>'Add a button to search list'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(84005083796055360)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Button Label'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'Add new Entry'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_is_translatable=>true
,p_depending_on_attribute_id=>wwv_flow_api.id(84004680037055360)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'Set label of the button'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(84005496727055360)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Button Icon'
,p_attribute_type=>'ICON'
,p_is_required=>false
,p_default_value=>'fa-plus'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(84004680037055360)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'Set icon of the button'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(84005822411055361)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Button Action'
,p_attribute_type=>'LINK'
,p_is_required=>true
,p_default_value=>'javascript:alert(''APEX'');void(0);'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(84004680037055360)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'Add url that is executed when button is clicked'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(84006237287055361)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>5
,p_prompt=>'Lazy Loading'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_is_translatable=>false
,p_help_text=>'Enable that the LOV is loaded with the page or after the page is loaded'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(84006680401055361)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>11
,p_prompt=>'Maximum number of selections'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(84003808204055358)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'Set a maximum number of possible selection for multi selection'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(84007084126055361)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_prompt=>'Min Width of Suggestion List'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_is_translatable=>false
,p_help_text=>'Set the min width of the suggestions list. If null then min-width is not set. You can use all css units, e.g. 400px, 80% and more.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(84007421936055361)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>120
,p_prompt=>'Refresh before setValue'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_is_translatable=>false
,p_help_text=>'Before value is set to Item the LOV is update to load new Display Values.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(84007872964055362)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>140
,p_prompt=>'Has as INFO Column in LOV Query'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(84008285680055362)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'list'
,p_help_text=>'If in the LOV query a column "INFO" is given then this will be shown, when the Option is activated.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(84008285680055362)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>130
,p_prompt=>'Display as'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'list'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(84008630170055362)
,p_plugin_attribute_id=>wwv_flow_api.id(84008285680055362)
,p_display_sequence=>10
,p_display_value=>'List'
,p_return_value=>'list'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(84009126012055362)
,p_plugin_attribute_id=>wwv_flow_api.id(84008285680055362)
,p_display_sequence=>20
,p_display_value=>'Table'
,p_return_value=>'table'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(84009659298055363)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>150
,p_prompt=>'Table Columns'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(84008285680055362)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'table'
,p_text_case=>'UPPER'
,p_help_text=>'Define which columns should be shown in the table e.g. NAME:CITY:STREET:STREET_NO. if Text Messages exists for these strings then they will be shown translated.'
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(84012484056055368)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_name=>'LOV'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2F2065736C696E742D64697361626C652D6E6578742D6C696E65206E6F2D756E757365642D766172730D0A636F6E737420617065784175746F436F6D706C6574654974656D203D2066756E6374696F6E2028617065782C202429207B0D0A2020202022';
wwv_flow_api.g_varchar2_table(2) := '75736520737472696374223B0D0A20202020636F6E7374206665617475726544657461696C73203D207B0D0A20202020202020206E616D653A2022415045582E44332E47414E5454222C0D0A202020202020202076657273696F6E3A2022312E30220D0A';
wwv_flow_api.g_varchar2_table(3) := '202020207D3B0D0A0D0A2020202066756E6374696F6E206973446566696E6564416E644E6F744E756C6C2870496E70757429207B0D0A202020202020202069662028747970656F662070496E70757420213D3D2022756E646566696E6564222026262070';
wwv_flow_api.g_varchar2_table(4) := '496E70757420213D3D206E756C6C2026262070496E70757420213D3D20222229207B0D0A20202020202020202020202072657475726E20747275653B0D0A20202020202020207D20656C7365207B0D0A20202020202020202020202072657475726E2066';
wwv_flow_api.g_varchar2_table(5) := '616C73653B0D0A20202020202020207D0D0A202020207D0D0A0D0A2020202072657475726E207B0D0A2020202020202020696E697469616C697A653A2066756E6374696F6E202870436F6E6669672C20704461746129207B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(6) := '2020617065782E64656275672E696E666F287B0D0A2020202020202020202020202020202022666374223A206665617475726544657461696C732E6E616D65202B2022202D20696E697469616C697A65222C0D0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(7) := '22617267756D656E7473223A2070436F6E6669672C0D0A20202020202020202020202020202020226665617475726544657461696C73223A206665617475726544657461696C730D0A2020202020202020202020207D293B0D0A0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(8) := '20202020636F6E7374206D756C746953656C656374696F6E203D2070436F6E6669672E6D756C746973656C656374696F6E2C0D0A20202020202020202020202020202020617065784974656D53656C203D20222322202B2070436F6E6669672E6974656D';
wwv_flow_api.g_varchar2_table(9) := '4E616D652C0D0A20202020202020202020202020202020776F726B4974656D53656C203D20617065784974656D53656C202B2028286D756C746953656C656374696F6E29203F20225F6D736322203A202222292C0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(10) := '2020696E7075744974656D53656C203D20617065784974656D53656C202B2028286D756C746953656C656374696F6E29203F20225F6D73635F746622203A202222292C0D0A20202020202020202020202020202020777261707065724944203D2070436F';
wwv_flow_api.g_varchar2_table(11) := '6E6669672E6974656D4E616D65202B20225F616377726170706572222C0D0A202020202020202020202020202020207772617070657253656C203D20222322202B207772617070657249442C0D0A20202020202020202020202020202020617065784974';
wwv_flow_api.g_varchar2_table(12) := '656D203D202428617065784974656D53656C292C0D0A20202020202020202020202020202020776F726B4974656D203D202428776F726B4974656D53656C292C0D0A20202020202020202020202020202020696E7075744974656D203D202428696E7075';
wwv_flow_api.g_varchar2_table(13) := '744974656D53656C292C0D0A2020202020202020202020202020202076616C756553706C6974203D20223A222C0D0A2020202020202020202020202020202072617756616C756541747472203D20227261772D76616C7565222C0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(14) := '2020202020202020696E697469616C56616C7565203D20617065784974656D2E617474722872617756616C756541747472293B0D0A2020202020202020202020206C657420777261707065722C0D0A202020202020202020202020202020206D6F64616C';
wwv_flow_api.g_varchar2_table(15) := '436F6E74656E742C0D0A20202020202020202020202020202020646174612C0D0A202020202020202020202020202020206C617374496E6465783B0D0A0D0A2020202020202020202020202F2F206573636170652068746D6C2069662072657175697265';
wwv_flow_api.g_varchar2_table(16) := '640D0A20202020202020202020202066756E6374696F6E2065736361706548544D4C287053747229207B0D0A202020202020202020202020202020206966202870436F6E6669672E65736361706548544D4C29207B0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(17) := '2020202020202072657475726E20617065782E7574696C2E65736361706548544D4C282222202B2070537472293B0D0A202020202020202020202020202020207D20656C7365207B0D0A202020202020202020202020202020202020202072657475726E';
wwv_flow_api.g_varchar2_table(18) := '20705374723B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2F20636C6F73652073756767657374696F6E206C6973740D0A20202020202020202020202066756E637469';
wwv_flow_api.g_varchar2_table(19) := '6F6E20636C6F736553756767657374696F6E4C6973742829207B0D0A20202020202020202020202020202020696620286D6F64616C436F6E74656E742E61747472282269732D6F70656E2229203D3D3D2022747275652229207B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(20) := '2020202020202020202020206D6F64616C436F6E74656E742E736C696465557028226661737422293B0D0A20202020202020202020202020202020202020206D6F64616C436F6E74656E742E61747472282269732D6F70656E222C202266616C73652229';
wwv_flow_api.g_varchar2_table(21) := '3B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2F206F70656E2073756767657374696F6E206C6973740D0A20202020202020202020202066756E6374696F6E206F7065';
wwv_flow_api.g_varchar2_table(22) := '6E53756767657374696F6E4C6973742829207B0D0A20202020202020202020202020202020696620286D6F64616C436F6E74656E742E61747472282269732D6F70656E2229203D3D3D202266616C73652229207B0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(23) := '2020202020207570646174654D6F64616C436F6E74656E742866616C7365293B0D0A20202020202020202020202020202020202020206D6F64616C436F6E74656E742E736C696465446F776E28226661737422293B0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(24) := '202020202020206D6F64616C436F6E74656E742E61747472282269732D6F70656E222C20227472756522293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2F2066756E';
wwv_flow_api.g_varchar2_table(25) := '6374696F6E20746F206765742061206C6162656C20666F7220612076616C75650D0A20202020202020202020202066756E6374696F6E2067657456616C75654C6162656C287056616C75652C207052657475726E4F726967696E616C56616C7565203D20';
wwv_flow_api.g_varchar2_table(26) := '7472756529207B0D0A202020202020202020202020202020206C6574207265743B0D0A0D0A20202020202020202020202020202020696620287052657475726E4F726967696E616C56616C756529207B0D0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(27) := '2020726574203D207056616C75653B0D0A202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020242E6561636828646174612C2066756E6374696F6E2028692C206F29207B0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(28) := '2020202020202F2F2065736C696E742D64697361626C652D6E6578742D6C696E65206571657165710D0A2020202020202020202020202020202020202020696620286F2E76616C7565203D3D207056616C756529207B0D0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(29) := '202020202020202020202020726574203D206F2E6C6162656C3B0D0A20202020202020202020202020202020202020202020202072657475726E2066616C73653B0D0A20202020202020202020202020202020202020207D0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(30) := '2020202020207D293B0D0A0D0A2020202020202020202020202020202072657475726E207265743B0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2F2066756E6374696F6E20746F207365742074686520726177207661';
wwv_flow_api.g_varchar2_table(31) := '6C75650D0A20202020202020202020202066756E6374696F6E2073657452617756616C7565287056616C756529207B0D0A202020202020202020202020202020206966202841727261792E69734172726179287056616C75652929207B0D0A2020202020';
wwv_flow_api.g_varchar2_table(32) := '202020202020202020202020202020617065784974656D2E617474722872617756616C7565417474722C207056616C75652E6A6F696E2876616C756553706C697429293B0D0A202020202020202020202020202020207D20656C7365207B0D0A20202020';
wwv_flow_api.g_varchar2_table(33) := '20202020202020202020202020202020617065784974656D2E617474722872617756616C7565417474722C207056616C7565293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D0D0A0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(34) := '20202F2F2066756E6374696F6E20746F2067657420746865207261772076616C75650D0A20202020202020202020202066756E6374696F6E2067657452617756616C75652829207B0D0A2020202020202020202020202020202069662028617065784974';
wwv_flow_api.g_varchar2_table(35) := '656D2E617474722872617756616C7565417474722920262620617065784974656D2E617474722872617756616C7565417474722920213D3D20222229207B0D0A202020202020202020202020202020202020202072657475726E20617065784974656D2E';
wwv_flow_api.g_varchar2_table(36) := '617474722872617756616C756541747472292E73706C69742876616C756553706C6974293B0D0A202020202020202020202020202020207D20656C7365207B0D0A202020202020202020202020202020202020202072657475726E205B5D3B0D0A202020';
wwv_flow_api.g_varchar2_table(37) := '202020202020202020202020207D0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2F20736574207468652076616C7565206F6620756920616E642061706578206974656D0D0A20202020202020202020202066756E6374';
wwv_flow_api.g_varchar2_table(38) := '696F6E207365744974656D56616C7565287056616C75652C20704C6162656C2C207053757070726573734368616E67654576656E7429207B0D0A202020202020202020202020202020206C65742076616C75654172726179203D205B5D3B0D0A20202020';
wwv_flow_api.g_varchar2_table(39) := '2020202020202020202020206C6574206C6162656C417272203D205B5D3B0D0A0D0A20202020202020202020202020202020696620286973446566696E6564416E644E6F744E756C6C287056616C75652929207B0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(40) := '2020202020206966202841727261792E69734172726179287056616C75652929207B0D0A20202020202020202020202020202020202020202020202076616C75654172726179203D207056616C75653B0D0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(41) := '20207D20656C7365207B0D0A20202020202020202020202020202020202020202020202076616C75654172726179203D20617065782E7574696C2E746F4172726179287056616C75652C2076616C756553706C6974293B0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(42) := '2020202020202020207D0D0A0D0A2020202020202020202020202020202020202020696620286973446566696E6564416E644E6F744E756C6C28704C6162656C2929207B0D0A202020202020202020202020202020202020202020202020696620284172';
wwv_flow_api.g_varchar2_table(43) := '7261792E6973417272617928704C6162656C2929207B0D0A202020202020202020202020202020202020202020202020202020206C6162656C417272203D20704C6162656C3B0D0A2020202020202020202020202020202020202020202020207D20656C';
wwv_flow_api.g_varchar2_table(44) := '7365207B0D0A202020202020202020202020202020202020202020202020202020206C6162656C417272203D20617065782E7574696C2E746F417272617928704C6162656C2C2076616C756553706C6974293B0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(45) := '2020202020202020207D0D0A20202020202020202020202020202020202020207D20656C7365207B0D0A202020202020202020202020202020202020202020202020242E656163682876616C756541727261792C2066756E6374696F6E2028692C207629';
wwv_flow_api.g_varchar2_table(46) := '207B0D0A202020202020202020202020202020202020202020202020202020206C6574206C6162656C203D2067657456616C75654C6162656C2876293B0D0A202020202020202020202020202020202020202020202020202020206C6162656C4172722E';
wwv_flow_api.g_varchar2_table(47) := '70757368286C6162656C293B0D0A2020202020202020202020202020202020202020202020207D293B0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D0D0A0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(48) := '202020696620286973446566696E6564416E644E6F744E756C6C2870436F6E6669672E6D617853656C656374696F6E732929207B0D0A202020202020202020202020202020202020202076616C75654172726179203D2076616C756541727261792E736C';
wwv_flow_api.g_varchar2_table(49) := '69636528302C2070436F6E6669672E6D617853656C656374696F6E73293B0D0A20202020202020202020202020202020202020206C6162656C417272203D206C6162656C4172722E736C69636528302C2070436F6E6669672E6D617853656C656374696F';
wwv_flow_api.g_varchar2_table(50) := '6E73293B0D0A202020202020202020202020202020207D0D0A0D0A2020202020202020202020202020202073657452617756616C75652876616C75654172726179293B0D0A0D0A20202020202020202020202020202020696620286D756C746953656C65';
wwv_flow_api.g_varchar2_table(51) := '6374696F6E29207B0D0A20202020202020202020202020202020202020206C65742076556C203D20776F726B4974656D2E66696E642822756C2E617065786175746F636F6D706C6574652D6D732D756C22293B0D0A0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(52) := '2020202020202076556C2E656D70747928293B0D0A0D0A20202020202020202020202020202020202020202F2F617065782E6974656D2870436F6E6669672E6974656D4E616D65292E73757070726573734368616E67654576656E74203D20747275653B';
wwv_flow_api.g_varchar2_table(53) := '0D0A2020202020202020202020202020202020202020617065784974656D2E76616C286C6162656C4172722E6A6F696E2876616C756553706C697429293B0D0A0D0A2020202020202020202020202020202020202020242E65616368286C6162656C4172';
wwv_flow_api.g_varchar2_table(54) := '722C2066756E6374696F6E2028692C206F29207B0D0A2020202020202020202020202020202020202020202020206C657420764C69203D202428223C6C693E22293B0D0A202020202020202020202020202020202020202020202020764C692E61646443';
wwv_flow_api.g_varchar2_table(55) := '6C6173732822617065786175746F636F6D706C6574652D6D732D6C6922293B0D0A0D0A2020202020202020202020202020202020202020202020206C6574207654657874203D202428223C7370616E3E22293B0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(56) := '20202020202020202076546578742E616464436C6173732822617065786175746F636F6D706C6574652D6D732D7465787422293B0D0A20202020202020202020202020202020202020202020202076546578742E68746D6C2865736361706548544D4C28';
wwv_flow_api.g_varchar2_table(57) := '6F29293B0D0A202020202020202020202020202020202020202020202020764C692E617070656E64287654657874293B0D0A0D0A2020202020202020202020202020202020202020202020206C6574206C52656D6F7665203D202428223C7370616E3E22';
wwv_flow_api.g_varchar2_table(58) := '293B0D0A2020202020202020202020202020202020202020202020206C52656D6F76652E616464436C6173732822666122293B0D0A2020202020202020202020202020202020202020202020206C52656D6F76652E616464436C617373282266612D636C';
wwv_flow_api.g_varchar2_table(59) := '6F736522293B0D0A2020202020202020202020202020202020202020202020206C52656D6F76652E616464436C6173732822617065786175746F636F6D706C6574652D6D732D72656D6F766522293B0D0A20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(60) := '20202020206C52656D6F76652E636C69636B2866756E6374696F6E202829207B0D0A2020202020202020202020202020202020202020202020202020202072656D6F76654974656D56616C75652876616C756541727261795B695D293B0D0A2020202020';
wwv_flow_api.g_varchar2_table(61) := '202020202020202020202020202020202020207D293B0D0A202020202020202020202020202020202020202020202020764C692E617070656E64286C52656D6F7665293B0D0A0D0A20202020202020202020202020202020202020202020202076556C2E';
wwv_flow_api.g_varchar2_table(62) := '617070656E6428764C69293B0D0A20202020202020202020202020202020202020207D293B0D0A202020202020202020202020202020207D20656C7365207B0D0A20202020202020202020202020202020202020202F2F2073696E676C652073656C6563';
wwv_flow_api.g_varchar2_table(63) := '74696F6E20697320696E70757420616E6420646F6573206E6F7420737570706F72742068746D6C0D0A20202020202020202020202020202020202020202F2F617065782E6974656D2870436F6E6669672E6974656D4E616D65292E737570707265737343';
wwv_flow_api.g_varchar2_table(64) := '68616E67654576656E74203D20747275653B0D0A2020202020202020202020202020202020202020617065784974656D2E76616C286C6162656C4172722E6A6F696E2876616C756553706C6974292E7265706C616365282F283C285B5E3E5D2B293E292F';
wwv_flow_api.g_varchar2_table(65) := '69672C20222229293B0D0A202020202020202020202020202020207D0D0A0D0A2020202020202020202020202020202069662028217053757070726573734368616E67654576656E7429207B0D0A20202020202020202020202020202020202020206170';
wwv_flow_api.g_varchar2_table(66) := '65784974656D2E7472696767657228226368616E676522293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2F2072656D6F65206974656D2066726F6D20756920616E64';
wwv_flow_api.g_varchar2_table(67) := '2061706578206974656D0D0A20202020202020202020202066756E6374696F6E2072656D6F76654974656D56616C7565287056616C756529207B0D0A202020202020202020202020202020206C65742076616C7565417272203D2067657452617756616C';
wwv_flow_api.g_varchar2_table(68) := '756528293B0D0A2020202020202020202020202020202069662028216973446566696E6564416E644E6F744E756C6C287056616C75652929207B0D0A202020202020202020202020202020202020202076616C7565417272203D2076616C75654172722E';
wwv_flow_api.g_varchar2_table(69) := '736C69636528302C202D31293B0D0A202020202020202020202020202020207D20656C7365207B0D0A2020202020202020202020202020202020202020636F6E737420696E646578203D2076616C75654172722E696E6465784F66287056616C7565293B';
wwv_flow_api.g_varchar2_table(70) := '0D0A202020202020202020202020202020202020202069662028696E646578203E202D3129207B0D0A20202020202020202020202020202020202020202020202076616C75654172722E73706C69636528696E6465782C2031293B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(71) := '202020202020202020202020207D0D0A202020202020202020202020202020207D0D0A202020202020202020202020202020207365744974656D56616C75652876616C7565417272293B0D0A2020202020202020202020207D0D0A0D0A20202020202020';
wwv_flow_api.g_varchar2_table(72) := '20202020202F2F2061646420616E206974656D20746F20756920616E642061706578206974656D0D0A20202020202020202020202066756E6374696F6E206164644974656D56616C7565287056616C756529207B0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(73) := '20206C65742076616C7565417272203D205B5D3B0D0A0D0A20202020202020202020202020202020696620286D756C746953656C656374696F6E29207B0D0A2020202020202020202020202020202020202020696E7075744974656D2E76616C28222229';
wwv_flow_api.g_varchar2_table(74) := '3B0D0A202020202020202020202020202020202020202069662028617065784974656D2E617474722872617756616C7565417474722920213D3D20222229207B0D0A20202020202020202020202020202020202020202020202076616C7565417272203D';
wwv_flow_api.g_varchar2_table(75) := '2067657452617756616C756528293B0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020696620286973446566696E6564416E644E6F744E756C6C';
wwv_flow_api.g_varchar2_table(76) := '2870436F6E6669672E6D617853656C656374696F6E732929207B0D0A2020202020202020202020202020202020202020636F6E7374206C656E203D2076616C75654172722E6C656E6774683B0D0A20202020202020202020202020202020202020206966';
wwv_flow_api.g_varchar2_table(77) := '20286C656E203C2070436F6E6669672E6D617853656C656374696F6E7329207B0D0A20202020202020202020202020202020202020202020202076616C75654172722E70757368287056616C7565293B0D0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(78) := '20207D20656C7365207B0D0A20202020202020202020202020202020202020202020202076616C75654172725B286C656E202D2031295D203D207056616C75653B0D0A20202020202020202020202020202020202020207D0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(79) := '2020202020207D20656C7365207B0D0A202020202020202020202020202020202020202076616C75654172722E70757368287056616C7565293B0D0A202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020736574';
wwv_flow_api.g_varchar2_table(80) := '4974656D56616C75652876616C7565417272293B0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2F20686967686C6967687420746578740D0A20202020202020202020202066756E6374696F6E20686967686C69676874';
wwv_flow_api.g_varchar2_table(81) := '5465787428705374722C2070456C656D656E7429207B0D0A20202020202020202020202020202020636F6E73742066696C746572203D206E65772052656745787028705374722C2022696722293B0D0A2020202020202020202020202020202061706578';
wwv_flow_api.g_varchar2_table(82) := '2E64656275672E696E666F287B0D0A202020202020202020202020202020202020202022666374223A206665617475726544657461696C732E6E616D65202B2022202D20686967686C6967687454657874222C0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(83) := '20202020202270537472223A20705374722C0D0A20202020202020202020202020202020202020202266696C746572223A2066696C7465722C0D0A20202020202020202020202020202020202020202270456C656D656E74223A2070456C656D656E742C';
wwv_flow_api.g_varchar2_table(84) := '0D0A2020202020202020202020202020202020202020226665617475726544657461696C73223A206665617475726544657461696C730D0A202020202020202020202020202020207D293B0D0A0D0A202020202020202020202020202020206966202870';
wwv_flow_api.g_varchar2_table(85) := '456C656D656E742E7465787428292026262070456C656D656E742E7465787428292E6D617463682866696C7465722929207B0D0A20202020202020202020202020202020202020206C657420646976203D202428223C6469763E22293B0D0A2020202020';
wwv_flow_api.g_varchar2_table(86) := '2020202020202020202020202020206C6574207370616E203D202428223C7370616E3E22293B0D0A20202020202020202020202020202020202020207370616E2E616464436C6173732822617065786175746F636F6D706C6574652D686967686C696768';
wwv_flow_api.g_varchar2_table(87) := '7422293B0D0A20202020202020202020202020202020202020207370616E2E68746D6C2870456C656D656E742E7465787428292E6D617463682866696C746572295B305D293B0D0A20202020202020202020202020202020202020206469762E61707065';
wwv_flow_api.g_varchar2_table(88) := '6E64287370616E293B0D0A2020202020202020202020202020202020202020696620287053747220213D3D20222229207B0D0A20202020202020202020202020202020202020202020202070456C656D656E742E68746D6C2870456C656D656E742E7465';
wwv_flow_api.g_varchar2_table(89) := '787428292E7265706C6163652866696C7465722C206469762E68746D6C282929293B0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D0D0A0D0A2020202020';
wwv_flow_api.g_varchar2_table(90) := '202020202020202F2F20736F72742062792074776F206B657973206F6620616E20617272206F66206F626A656374730D0A20202020202020202020202066756E6374696F6E2072616E6B6564536F72742866697273744B65792C207365636F6E644B6579';
wwv_flow_api.g_varchar2_table(91) := '29207B0D0A2020202020202020202020202020202072657475726E2066756E6374696F6E2028612C206229207B0D0A202020202020202020202020202020202020202069662028615B66697273744B65795D203C20625B66697273744B65795D29207B0D';
wwv_flow_api.g_varchar2_table(92) := '0A20202020202020202020202020202020202020202020202072657475726E202D313B0D0A20202020202020202020202020202020202020207D20656C73652069662028615B66697273744B65795D203E20625B66697273744B65795D29207B0D0A2020';
wwv_flow_api.g_varchar2_table(93) := '2020202020202020202020202020202020202020202072657475726E20313B0D0A20202020202020202020202020202020202020207D20656C7365207B0D0A20202020202020202020202020202020202020202020202069662028615B7365636F6E644B';
wwv_flow_api.g_varchar2_table(94) := '65795D203E20625B7365636F6E644B65795D29207B0D0A2020202020202020202020202020202020202020202020202020202072657475726E20313B0D0A2020202020202020202020202020202020202020202020207D20656C73652069662028615B73';
wwv_flow_api.g_varchar2_table(95) := '65636F6E644B65795D203C20625B7365636F6E644B65795D29207B0D0A2020202020202020202020202020202020202020202020202020202072657475726E202D313B0D0A2020202020202020202020202020202020202020202020207D20656C736520';
wwv_flow_api.g_varchar2_table(96) := '7B0D0A2020202020202020202020202020202020202020202020202020202072657475726E20303B0D0A2020202020202020202020202020202020202020202020207D0D0A20202020202020202020202020202020202020207D0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(97) := '20202020202020207D3B0D0A2020202020202020202020207D0D0A0D0A20202020202020202020202066756E6374696F6E20736574496E697469616C56616C75652829207B0D0A202020202020202020202020202020206C65742076616C7565203D2067';
wwv_flow_api.g_varchar2_table(98) := '657452617756616C756528293B0D0A202020202020202020202020202020206966202870436F6E6669672E6C6F76446973706C6179457874726129207B0D0A20202020202020202020202020202020202020207365744974656D56616C75652876616C75';
wwv_flow_api.g_varchar2_table(99) := '652C206E756C6C2C2074727565293B0D0A202020202020202020202020202020207D20656C7365207B0D0A2020202020202020202020202020202020202020696620286973446566696E6564416E644E6F744E756C6C2867657456616C75654C6162656C';
wwv_flow_api.g_varchar2_table(100) := '2876616C75652C2066616C7365292929207B0D0A2020202020202020202020202020202020202020202020207365744974656D56616C75652876616C75652C206E756C6C2C2074727565293B0D0A20202020202020202020202020202020202020207D0D';
wwv_flow_api.g_varchar2_table(101) := '0A202020202020202020202020202020207D0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2F206C6F6164206461746120666F7220746865206974656D0D0A20202020202020202020202066756E6374696F6E20676574';
wwv_flow_api.g_varchar2_table(102) := '44617461287043616C6C6261636B2C20705365744974656D56616C75652C207056616C75652C2070446973706C617956616C75652C207053757070726573734368616E67654576656E7429207B0D0A202020202020202020202020202020206C65742069';
wwv_flow_api.g_varchar2_table(103) := '74656D73546F5375626D6974203D205B5D3B0D0A0D0A20202020202020202020202020202020696620286973446566696E6564416E644E6F744E756C6C2870436F6E6669672E6974656D73546F5375626D69742929207B0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(104) := '2020202020202020206C657420617272203D2070436F6E6669672E6974656D73546F5375626D69742E73706C697428222C22293B0D0A20202020202020202020202020202020202020206974656D73546F5375626D6974203D206974656D73546F537562';
wwv_flow_api.g_varchar2_table(105) := '6D69742E636F6E63617428617272293B0D0A202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020696620286973446566696E6564416E644E6F744E756C6C2870436F6E6669672E63617363616465506172656E74';
wwv_flow_api.g_varchar2_table(106) := '4974656D2929207B0D0A20202020202020202020202020202020202020206C657420617272203D2070436F6E6669672E63617363616465506172656E744974656D2E73706C697428222C22293B0D0A202020202020202020202020202020202020202069';
wwv_flow_api.g_varchar2_table(107) := '74656D73546F5375626D6974203D206974656D73546F5375626D69742E636F6E63617428617272293B0D0A202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020617065782E7365727665722E706C7567696E280D';
wwv_flow_api.g_varchar2_table(108) := '0A202020202020202020202020202020202020202070436F6E6669672E616A617849442C207B0D0A2020202020202020202020202020202020202020706167654974656D733A206974656D73546F5375626D69742E6A6F696E28222C22290D0A20202020';
wwv_flow_api.g_varchar2_table(109) := '2020202020202020202020207D2C207B0D0A20202020202020202020202020202020202020206C6F6164696E67496E64696361746F723A20617065784974656D53656C2C0D0A2020202020202020202020202020202020202020737563636573733A2066';
wwv_flow_api.g_varchar2_table(110) := '756E6374696F6E2028704461746129207B0D0A20202020202020202020202020202020202020202020202064617461203D2070446174612E726F77733B0D0A2020202020202020202020202020202020202020202020207043616C6C6261636B28293B0D';
wwv_flow_api.g_varchar2_table(111) := '0A20202020202020202020202020202020202020202020202069662028705365744974656D56616C756529207B0D0A202020202020202020202020202020202020202020202020202020207365744974656D56616C7565287056616C75652C2070446973';
wwv_flow_api.g_varchar2_table(112) := '706C617956616C75652C207053757070726573734368616E67654576656E74293B0D0A2020202020202020202020202020202020202020202020207D0D0A20202020202020202020202020202020202020207D2C0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(113) := '2020202020206572726F723A2066756E6374696F6E20286429207B0D0A20202020202020202020202020202020202020202020202064617461203D205B5D3B0D0A202020202020202020202020202020202020202020202020617065782E64656275672E';
wwv_flow_api.g_varchar2_table(114) := '6572726F72287B0D0A2020202020202020202020202020202020202020202020202020202022666374223A206665617475726544657461696C732E6E616D65202B2022202D2067657444617461222C0D0A20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(115) := '202020202020202020226D7367223A20224572726F72207768696C65206C6F6164696E6720414A41582064617461222C0D0A2020202020202020202020202020202020202020202020202020202022657272223A20642C0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(116) := '2020202020202020202020202020202020226665617475726544657461696C73223A206665617475726544657461696C730D0A2020202020202020202020202020202020202020202020207D293B0D0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(117) := '7D2C0D0A202020202020202020202020202020202020202064617461547970653A20226A736F6E220D0A202020202020202020202020202020207D293B0D0A2020202020202020202020207D0D0A0D0A20202020202020202020202066756E6374696F6E';
wwv_flow_api.g_varchar2_table(118) := '20696E69744C6973742829207B0D0A20202020202020202020202020202020736574496E697469616C56616C756528293B0D0A202020202020202020202020202020207570646174654D6F64616C436F6E74656E7428293B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(119) := '20207D0D0A0D0A20202020202020202020202066756E6374696F6E20676574427574746F6E48544D4C28704C6162656C2C207049636F6E2C20704C696E6B2C20704F6E4D6F757365646F776E2C207049636F6E506F736974696F6E203D20226C222C2070';
wwv_flow_api.g_varchar2_table(120) := '486F74427574746F6E203D2066616C736529207B0D0A202020202020202020202020202020206C65742062746E203D202428223C613E22293B0D0A2020202020202020202020202020202062746E2E61747472282274797065222C2022627574746F6E22';
wwv_flow_api.g_varchar2_table(121) := '293B0D0A2020202020202020202020202020202062746E2E616464436C6173732822742D427574746F6E22293B0D0A202020202020202020202020202020206966202870486F74427574746F6E29207B0D0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(122) := '202062746E2E616464436C6173732822742D427574746F6E2D2D686F7422293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020202020202062746E2E616464436C6173732822617065782D6175746F636F6D706C657465';
wwv_flow_api.g_varchar2_table(123) := '2D6D6F64616C2D6469616C6F672D62746E22293B0D0A0D0A20202020202020202020202020202020696620287049636F6E202626207049636F6E506F736974696F6E203D3D3D20226C2229207B0D0A20202020202020202020202020202020202020206C';
wwv_flow_api.g_varchar2_table(124) := '65742062746E49636F6E203D202428223C7370616E3E22293B0D0A202020202020202020202020202020202020202062746E49636F6E2E616464436C6173732822742D49636F6E22293B0D0A202020202020202020202020202020202020202062746E49';
wwv_flow_api.g_varchar2_table(125) := '636F6E2E616464436C6173732822742D49636F6E2D2D6C65667422293B0D0A202020202020202020202020202020202020202062746E49636F6E2E616464436C6173732822666122293B0D0A202020202020202020202020202020202020202062746E49';
wwv_flow_api.g_varchar2_table(126) := '636F6E2E616464436C617373287049636F6E293B0D0A202020202020202020202020202020202020202062746E49636F6E2E637373282270616464696E672D7269676874222C202233707822293B0D0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(127) := '62746E2E617070656E642862746E49636F6E293B0D0A202020202020202020202020202020207D0D0A0D0A2020202020202020202020202020202069662028704C6162656C29207B0D0A20202020202020202020202020202020202020206C6574206274';
wwv_flow_api.g_varchar2_table(128) := '6E4C6162656C203D202428223C7370616E3E22293B0D0A202020202020202020202020202020202020202062746E4C6162656C2E616464436C6173732822742D427574746F6E2D6C6162656C22293B0D0A20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(129) := '2062746E4C6162656C2E7465787428704C6162656C293B0D0A202020202020202020202020202020202020202062746E4C6162656C2E617474722822617269612D68696464656E222C20227472756522293B0D0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(130) := '2020202062746E2E617070656E642862746E4C6162656C293B0D0A202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020696620287049636F6E202626207049636F6E506F736974696F6E20213D3D20226C222920';
wwv_flow_api.g_varchar2_table(131) := '7B0D0A20202020202020202020202020202020202020206C65742062746E49636F6E203D202428223C7370616E3E22293B0D0A202020202020202020202020202020202020202062746E49636F6E2E616464436C6173732822742D49636F6E22293B0D0A';
wwv_flow_api.g_varchar2_table(132) := '202020202020202020202020202020202020202062746E49636F6E2E616464436C6173732822742D49636F6E2D2D6C65667422293B0D0A202020202020202020202020202020202020202062746E49636F6E2E616464436C6173732822666122293B0D0A';
wwv_flow_api.g_varchar2_table(133) := '202020202020202020202020202020202020202062746E49636F6E2E616464436C617373287049636F6E293B0D0A202020202020202020202020202020202020202062746E49636F6E2E637373282270616464696E672D6C656674222C20223370782229';
wwv_flow_api.g_varchar2_table(134) := '3B0D0A202020202020202020202020202020202020202062746E2E617070656E642862746E49636F6E293B0D0A202020202020202020202020202020207D0D0A0D0A2020202020202020202020202020202069662028704C696E6B29207B0D0A20202020';
wwv_flow_api.g_varchar2_table(135) := '2020202020202020202020202020202062746E2E61747472282268726566222C20704C696E6B293B0D0A202020202020202020202020202020207D0D0A0D0A2020202020202020202020202020202069662028704F6E4D6F757365646F776E29207B0D0A';
wwv_flow_api.g_varchar2_table(136) := '202020202020202020202020202020202020202062746E2E6F6E28226D6F757365646F776E222C20704F6E4D6F757365646F776E293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020202020202072657475726E206274';
wwv_flow_api.g_varchar2_table(137) := '6E3B0D0A2020202020202020202020207D0D0A0D0A20202020202020202020202066756E6374696F6E207570646174654D6F64616C436F6E74656E74287052657365744C617374496E646578203D20747275652C2070536F7274203D207472756529207B';
wwv_flow_api.g_varchar2_table(138) := '0D0A202020202020202020202020202020206966202870536F727429207B0D0A20202020202020202020202020202020202020202F2F20736F727420617272617920646174612062792067726F757020616E64206C6162656C0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(139) := '202020202020202020202064617461203D20646174612E736F72742872616E6B6564536F7274282267726F7570222C20226C6162656C2229293B0D0A202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020696620';
wwv_flow_api.g_varchar2_table(140) := '287052657365744C617374496E64657829207B0D0A20202020202020202020202020202020202020206C617374496E646578203D20303B0D0A202020202020202020202020202020207D0D0A0D0A202020202020202020202020202020206C6574206C44';
wwv_flow_api.g_varchar2_table(141) := '617461203D2064617461207C7C205B5D3B0D0A202020202020202020202020202020206C657420696E70203D20696E7075744974656D2E76616C28292E746F4C6F63616C654C6F7765724361736528293B0D0A202020202020202020202020202020206C';
wwv_flow_api.g_varchar2_table(142) := '65742067726F75703B0D0A202020202020202020202020202020206C65742072617756616C75654172726179203D2067657452617756616C756528293B0D0A0D0A202020202020202020202020202020202F2F2067657420706F736974696F6E20616E64';
wwv_flow_api.g_varchar2_table(143) := '207769647468206F662074686520696E707574206669656C6420746F2073657420697420666F72207468652073656C656374696F6E206C6973740D0A202020202020202020202020202020206C657420636F6E7461696E6572203D20776F726B4974656D';
wwv_flow_api.g_varchar2_table(144) := '2E706172656E7428293B0D0A20202020202020202020202020202020696620286973446566696E6564416E644E6F744E756C6C2870436F6E6669672E6D696E4C69737457696474682929207B0D0A20202020202020202020202020202020202020206D6F';
wwv_flow_api.g_varchar2_table(145) := '64616C436F6E74656E742E63737328226D696E2D7769647468222C2070436F6E6669672E6D696E4C6973745769647468293B0D0A202020202020202020202020202020207D0D0A0D0A202020202020202020202020202020206D6F64616C436F6E74656E';
wwv_flow_api.g_varchar2_table(146) := '742E63737328227769647468222C20636F6E7461696E65722E77696474682829293B0D0A202020202020202020202020202020206D6F64616C436F6E74656E742E6373732822746F70222C2028636F6E7461696E65722E6F666673657428292E746F7020';
wwv_flow_api.g_varchar2_table(147) := '2B20636F6E7461696E65722E706172656E7428292E686569676874282929293B0D0A202020202020202020202020202020206D6F64616C436F6E74656E742E63737328226C656674222C20636F6E7461696E65722E6F666673657428292E6C656674293B';
wwv_flow_api.g_varchar2_table(148) := '0D0A0D0A202020202020202020202020202020202F2F2066696C74657220646174610D0A202020202020202020202020202020206C44617461203D20646174612E66696C7465722866756E6374696F6E2028656C29207B0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(149) := '202020202020202020696620286973446566696E6564416E644E6F744E756C6C28656C2929207B0D0A2020202020202020202020202020202020202020202020206C657420737472203D202222202B20656C2E6C6162656C202B20656C2E696E666F3B0D';
wwv_flow_api.g_varchar2_table(150) := '0A202020202020202020202020202020202020202020202020696620286D756C746953656C656374696F6E2026262072617756616C756541727261792E696E636C7564657328656C2E76616C75652929207B0D0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(151) := '20202020202020202020202072657475726E2066616C73653B0D0A2020202020202020202020202020202020202020202020207D0D0A202020202020202020202020202020202020202020202020696620286973446566696E6564416E644E6F744E756C';
wwv_flow_api.g_varchar2_table(152) := '6C28696E702929207B0D0A2020202020202020202020202020202020202020202020202020202072657475726E207374722E746F4C6F63616C654C6F7765724361736528292E696E636C7564657328696E70293B0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(153) := '202020202020202020207D20656C7365207B0D0A2020202020202020202020202020202020202020202020202020202072657475726E20747275653B0D0A2020202020202020202020202020202020202020202020207D0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(154) := '2020202020202020207D20656C7365207B0D0A20202020202020202020202020202020202020202020202072657475726E2066616C73653B0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D293B';
wwv_flow_api.g_varchar2_table(155) := '0D0A0D0A202020202020202020202020202020206C6574206D61784C656E677468203D204D6174682E6D696E282870436F6E6669672E6D6178526573756C7473207C7C2035292C206C446174612E6C656E677468293B0D0A0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(156) := '202020202020696620286C446174615B305D202626206C446174615B305D2E67726F757029207B0D0A202020202020202020202020202020202020202067726F7570203D206C446174615B305D2E67726F75703B0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(157) := '20207D0D0A0D0A202020202020202020202020202020206D6F64616C436F6E74656E742E656D70747928293B0D0A0D0A202020202020202020202020202020206C657420756C203D202428223C756C3E22293B0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(158) := '206C6574207461626C65203D202428223C7461626C653E22293B0D0A20202020202020202020202020202020636F6E73742069734C697374203D2070436F6E6669672E646973706C61795479706520213D3D20227461626C65223B0D0A0D0A2020202020';
wwv_flow_api.g_varchar2_table(159) := '20202020202020202020206966202869734C69737429207B0D0A2020202020202020202020202020202020202020756C2E616464436C6173732822617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D756C22293B0D0A202020';
wwv_flow_api.g_varchar2_table(160) := '20202020202020202020202020202020206D6F64616C436F6E74656E742E617070656E6428756C293B0D0A202020202020202020202020202020207D20656C7365207B0D0A20202020202020202020202020202020202020207461626C652E616464436C';
wwv_flow_api.g_varchar2_table(161) := '6173732822617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D7461626C6522293B0D0A20202020202020202020202020202020202020206D6F64616C436F6E74656E742E617070656E64287461626C65293B0D0A2020202020';
wwv_flow_api.g_varchar2_table(162) := '202020202020202020202020202020696620286C446174615B305D202626206C446174615B305D2E7461626C65436F6C756D6E7329207B0D0A2020202020202020202020202020202020202020202020206C6574207472203D202428223C74723E22293B';
wwv_flow_api.g_varchar2_table(163) := '0D0A2020202020202020202020202020202020202020202020207461626C652E617070656E64287472293B0D0A202020202020202020202020202020202020202020202020666F7220286C6574206920696E206C446174615B305D2E7461626C65436F6C';
wwv_flow_api.g_varchar2_table(164) := '756D6E7329207B0D0A202020202020202020202020202020202020202020202020202020206C6574207468203D202428223C74683E22293B0D0A2020202020202020202020202020202020202020202020202020202074682E68746D6C28657363617065';
wwv_flow_api.g_varchar2_table(165) := '48544D4C286C446174615B305D2E7461626C65436F6C756D6E735B695D2E6E616D6529293B0D0A2020202020202020202020202020202020202020202020202020202074722E617070656E64287468293B0D0A2020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(166) := '202020202020207D0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020666F7220286C65742069203D206C617374496E6465783B2069203C20286C';
wwv_flow_api.g_varchar2_table(167) := '617374496E646578202B206D61784C656E677468293B20692B2B29207B0D0A20202020202020202020202020202020202020206C657420726F77203D206C446174615B695D3B0D0A202020202020202020202020202020202020202069662028726F7729';
wwv_flow_api.g_varchar2_table(168) := '207B0D0A2020202020202020202020202020202020202020202020206966202869734C69737429207B0D0A20202020202020202020202020202020202020202020202020202020696620286973446566696E6564416E644E6F744E756C6C2867726F7570';
wwv_flow_api.g_varchar2_table(169) := '2929207B0D0A20202020202020202020202020202020202020202020202020202020202020206C65742070203D202428223C703E22293B0D0A2020202020202020202020202020202020202020202020202020202020202020702E616464436C61737328';
wwv_flow_api.g_varchar2_table(170) := '22617065786175746F636F6D706C6574652D67726F75707322293B0D0A2020202020202020202020202020202020202020202020202020202020202020702E68746D6C2865736361706548544D4C28726F772E67726F7570207C7C20222D2229293B0D0A';
wwv_flow_api.g_varchar2_table(171) := '20202020202020202020202020202020202020202020202020202020202020206966202867726F757020213D3D20726F772E67726F7570207C7C2069203D3D3D203029207B0D0A2020202020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(172) := '20202020202020756C2E617070656E642870293B0D0A20202020202020202020202020202020202020202020202020202020202020207D0D0A0D0A202020202020202020202020202020202020202020202020202020202020202067726F7570203D2072';
wwv_flow_api.g_varchar2_table(173) := '6F772E67726F75703B0D0A202020202020202020202020202020202020202020202020202020207D0D0A0D0A202020202020202020202020202020202020202020202020202020206C6574206C69203D202428223C6C693E22293B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(174) := '2020202020202020202020202020202020202020206C692E616464436C6173732822617065786175746F636F6D706C6574652D6C6922293B0D0A202020202020202020202020202020202020202020202020202020206C692E617474722822726F6C6522';
wwv_flow_api.g_varchar2_table(175) := '2C20226F7074696F6E22293B0D0A202020202020202020202020202020202020202020202020202020206C692E6174747228227261772D64617461222C20726F772E76616C7565293B0D0A20202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(176) := '2020206C692E636C69636B2866756E6374696F6E202829207B0D0A20202020202020202020202020202020202020202020202020202020202020206164644974656D56616C756528726F772E76616C7565293B0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(177) := '2020202020202020202020202020202020636C6F736553756767657374696F6E4C69737428293B0D0A202020202020202020202020202020202020202020202020202020207D293B0D0A0D0A202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(178) := '202020206C657420646976203D202428223C6469763E22293B0D0A202020202020202020202020202020202020202020202020202020206469762E616464436C6173732822617065786175746F636F6D706C6574652D6C692D7772617070657222293B0D';
wwv_flow_api.g_varchar2_table(179) := '0A0D0A20202020202020202020202020202020202020202020202020202020696620286973446566696E6564416E644E6F744E756C6C28726F772E69636F6E2929207B0D0A20202020202020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(180) := '206C65742069636F203D202428223C7370616E3E22293B0D0A202020202020202020202020202020202020202020202020202020202020202069636F2E617474722822617269612D68696464656E222C20227472756522293B0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(181) := '202020202020202020202020202020202020202020202069636F2E616464436C6173732822666122293B0D0A202020202020202020202020202020202020202020202020202020202020202069636F2E616464436C61737328726F772E69636F6E293B0D';
wwv_flow_api.g_varchar2_table(182) := '0A202020202020202020202020202020202020202020202020202020202020202069636F2E616464436C6173732822617065786175746F636F6D706C6574652D6C692D69636F6E22293B0D0A202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(183) := '20202020202020206469762E617070656E642869636F293B0D0A202020202020202020202020202020202020202020202020202020207D0D0A0D0A202020202020202020202020202020202020202020202020202020206C6574206D61746368203D2024';
wwv_flow_api.g_varchar2_table(184) := '28223C7370616E3E22293B0D0A202020202020202020202020202020202020202020202020202020206D617463682E68746D6C2865736361706548544D4C28726F772E6C6162656C29293B0D0A2020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(185) := '20202020206D617463682E616464436C6173732822617065786175746F636F6D706C6574652D6C692D7465787422293B0D0A202020202020202020202020202020202020202020202020202020206469762E617070656E64286D61746368293B0D0A0D0A';
wwv_flow_api.g_varchar2_table(186) := '20202020202020202020202020202020202020202020202020202020696620286973446566696E6564416E644E6F744E756C6C28726F772E696E666F2929207B0D0A20202020202020202020202020202020202020202020202020202020202020206469';
wwv_flow_api.g_varchar2_table(187) := '762E617070656E6428223C62723E22293B0D0A0D0A20202020202020202020202020202020202020202020202020202020202020206C657420696E666F203D202428223C7370616E3E22293B0D0A20202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(188) := '20202020202020202020696E666F2E68746D6C2865736361706548544D4C28726F772E696E666F29293B0D0A2020202020202020202020202020202020202020202020202020202020202020696E666F2E616464436C6173732822617065786175746F63';
wwv_flow_api.g_varchar2_table(189) := '6F6D706C6574652D6C692D696E666F22293B0D0A20202020202020202020202020202020202020202020202020202020202020206469762E617070656E6428696E666F293B0D0A202020202020202020202020202020202020202020202020202020207D';
wwv_flow_api.g_varchar2_table(190) := '0D0A0D0A202020202020202020202020202020202020202020202020202020206C692E617070656E6428646976293B0D0A20202020202020202020202020202020202020202020202020202020756C2E617070656E64286C69293B0D0A0D0A2020202020';
wwv_flow_api.g_varchar2_table(191) := '2020202020202020202020202020202020202020202020686967686C696768745465787428696E7075744974656D2E76616C28292C206D61746368293B0D0A0D0A2020202020202020202020202020202020202020202020202020202069662028697344';
wwv_flow_api.g_varchar2_table(192) := '6566696E6564416E644E6F744E756C6C28726F772E696E666F2929207B0D0A2020202020202020202020202020202020202020202020202020202020202020686967686C696768745465787428696E7075744974656D2E76616C28292C206D6174636829';
wwv_flow_api.g_varchar2_table(193) := '3B0D0A202020202020202020202020202020202020202020202020202020207D0D0A2020202020202020202020202020202020202020202020207D20656C7365207B0D0A2020202020202020202020202020202020202020202020202020202069662028';
wwv_flow_api.g_varchar2_table(194) := '726F772E7461626C65436F6C756D6E7329207B0D0A20202020202020202020202020202020202020202020202020202020202020206C6574207472203D202428223C74723E22293B0D0A0D0A202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(195) := '202020202020202074722E636C69636B2866756E6374696F6E202829207B0D0A2020202020202020202020202020202020202020202020202020202020202020202020206164644974656D56616C756528726F772E76616C7565293B0D0A202020202020';
wwv_flow_api.g_varchar2_table(196) := '202020202020202020202020202020202020202020202020202020202020636C6F736553756767657374696F6E4C69737428293B0D0A20202020202020202020202020202020202020202020202020202020202020207D293B0D0A0D0A20202020202020';
wwv_flow_api.g_varchar2_table(197) := '202020202020202020202020202020202020202020202020207461626C652E617070656E64287472293B0D0A2020202020202020202020202020202020202020202020202020202020202020666F7220286C6574206920696E20726F772E7461626C6543';
wwv_flow_api.g_varchar2_table(198) := '6F6C756D6E7329207B0D0A2020202020202020202020202020202020202020202020202020202020202020202020206C6574207464203D202428223C74643E22293B0D0A2020202020202020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(199) := '2020202074642E68746D6C2865736361706548544D4C28726F772E7461626C65436F6C756D6E735B695D2E76616C756529293B0D0A20202020202020202020202020202020202020202020202020202020202020202020202074722E617070656E642874';
wwv_flow_api.g_varchar2_table(200) := '64293B0D0A20202020202020202020202020202020202020202020202020202020202020207D0D0A202020202020202020202020202020202020202020202020202020207D0D0A2020202020202020202020202020202020202020202020207D0D0A2020';
wwv_flow_api.g_varchar2_table(201) := '2020202020202020202020202020202020207D0D0A202020202020202020202020202020207D0D0A0D0A202020202020202020202020202020206C65742062746E57726170203D202428223C6469763E22293B0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(202) := '2062746E577261702E616464436C6173732822617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D62746E2D7772617022293B0D0A202020202020202020202020202020206D6F64616C436F6E74656E742E617070656E642862';
wwv_flow_api.g_varchar2_table(203) := '746E57726170293B0D0A0D0A202020202020202020202020202020206C65742062746E57726170436F6C31203D202428223C6469763E22293B0D0A2020202020202020202020202020202062746E57726170436F6C312E616464436C6173732822617065';
wwv_flow_api.g_varchar2_table(204) := '782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D62746E2D777261702D636F6C2D6C65667422293B0D0A0D0A202020202020202020202020202020206C65742062746E57726170436F6C32203D202428223C6469763E22293B0D0A20';
wwv_flow_api.g_varchar2_table(205) := '20202020202020202020202020202062746E57726170436F6C322E616464436C6173732822617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D62746E2D777261702D636F6C2D63656E74657222293B0D0A0D0A202020202020';
wwv_flow_api.g_varchar2_table(206) := '202020202020202020206C65742062746E77726170636F6C33203D202428223C6469763E22293B0D0A2020202020202020202020202020202062746E77726170636F6C332E616464436C6173732822617065782D6175746F636F6D706C6574652D6D6F64';
wwv_flow_api.g_varchar2_table(207) := '616C2D6469616C6F672D62746E2D777261702D636F6C2D726967687422293B0D0A0D0A2020202020202020202020202020202062746E577261702E617070656E642862746E57726170436F6C31293B0D0A2020202020202020202020202020202062746E';
wwv_flow_api.g_varchar2_table(208) := '577261702E617070656E642862746E57726170436F6C32293B0D0A2020202020202020202020202020202062746E577261702E617070656E642862746E77726170636F6C33293B0D0A0D0A20202020202020202020202020202020696620286C61737449';
wwv_flow_api.g_varchar2_table(209) := '6E646578203E203029207B0D0A20202020202020202020202020202020202020206C65742062746E48544D4C203D20676574427574746F6E48544D4C280D0A20202020202020202020202020202020202020202020202060247B70436F6E6669672E7072';
wwv_flow_api.g_varchar2_table(210) := '6576696F757342746E4C6162656C7D2028247B6C617374496E6465787D29602C0D0A20202020202020202020202020202020202020202020202070436F6E6669672E70726576696F757342746E49636F6E2C0D0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(211) := '20202020202020206E756C6C2C0D0A20202020202020202020202020202020202020202020202066756E6374696F6E20286529207B0D0A20202020202020202020202020202020202020202020202020202020652E70726576656E7444656661756C7428';
wwv_flow_api.g_varchar2_table(212) := '293B0D0A202020202020202020202020202020202020202020202020202020206C617374496E646578203D206C617374496E646578202D2070436F6E6669672E6D6178526573756C74733B0D0A2020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(213) := '20202020207570646174654D6F64616C436F6E74656E742866616C7365293B0D0A2020202020202020202020202020202020202020202020207D2C0D0A202020202020202020202020202020202020202020202020226C222C0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(214) := '202020202020202020202020202020747275650D0A2020202020202020202020202020202020202020293B0D0A0D0A202020202020202020202020202020202020202062746E57726170436F6C312E617070656E642862746E48544D4C293B0D0A202020';
wwv_flow_api.g_varchar2_table(215) := '202020202020202020202020207D0D0A0D0A202020202020202020202020202020206966202870436F6E6669672E62746E53686F77203D3D3D2022592229207B0D0A20202020202020202020202020202020202020206C65742062746E48544D4C203D20';
wwv_flow_api.g_varchar2_table(216) := '676574427574746F6E48544D4C280D0A20202020202020202020202020202020202020202020202070436F6E6669672E62746E4C6162656C2C0D0A20202020202020202020202020202020202020202020202070436F6E6669672E62746E49636F6E2C0D';
wwv_flow_api.g_varchar2_table(217) := '0A20202020202020202020202020202020202020202020202070436F6E6669672E62746E416374696F6E0D0A2020202020202020202020202020202020202020293B0D0A0D0A202020202020202020202020202020202020202062746E57726170436F6C';
wwv_flow_api.g_varchar2_table(218) := '322E617070656E642862746E48544D4C293B0D0A202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020696620286C446174612E6C656E677468203E20286C617374496E646578202B206D61784C656E6774682929';
wwv_flow_api.g_varchar2_table(219) := '207B0D0A20202020202020202020202020202020202020206C65742062746E48544D4C203D20676574427574746F6E48544D4C280D0A20202020202020202020202020202020202020202020202060247B70436F6E6669672E6E65787442746E4C616265';
wwv_flow_api.g_varchar2_table(220) := '6C7D2028247B6C446174612E6C656E677468202D206C617374496E646578202D2070436F6E6669672E6D6178526573756C74737D29602C0D0A20202020202020202020202020202020202020202020202070436F6E6669672E6E65787442746E49636F6E';
wwv_flow_api.g_varchar2_table(221) := '2C0D0A2020202020202020202020202020202020202020202020206E756C6C2C0D0A20202020202020202020202020202020202020202020202066756E6374696F6E20286529207B0D0A2020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(222) := '2020652E70726576656E7444656661756C7428293B0D0A202020202020202020202020202020202020202020202020202020206C617374496E646578203D206C617374496E646578202B2070436F6E6669672E6D6178526573756C74733B0D0A20202020';
wwv_flow_api.g_varchar2_table(223) := '2020202020202020202020202020202020202020202020207570646174654D6F64616C436F6E74656E742866616C7365293B0D0A2020202020202020202020202020202020202020202020207D2C0D0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(224) := '202020202272222C0D0A202020202020202020202020202020202020202020202020747275650D0A2020202020202020202020202020202020202020293B0D0A0D0A202020202020202020202020202020202020202062746E77726170636F6C332E6170';
wwv_flow_api.g_varchar2_table(225) := '70656E642862746E48544D4C293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D0D0A0D0A20202020202020202020202066756E6374696F6E2072656E6465724974656D2829207B0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(226) := '202020202077726170706572203D202428223C6469763E22293B0D0A20202020202020202020202020202020777261707065722E6174747228226964222C20777261707065724944293B0D0A20202020202020202020202020202020777261707065722E';
wwv_flow_api.g_varchar2_table(227) := '617474722822726F6C65222C2022636F6D626F626F7822293B0D0A20202020202020202020202020202020777261707065722E616464436C6173732822617065786175746F636F6D706C6574652D7772617022293B0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(228) := '202020776F726B4974656D2E777261702877726170706572293B0D0A0D0A202020202020202020202020202020206D6F64616C436F6E74656E74203D202428223C6469763E22293B0D0A202020202020202020202020202020206D6F64616C436F6E7465';
wwv_flow_api.g_varchar2_table(229) := '6E742E61747472282269732D6F70656E222C202266616C736522293B0D0A202020202020202020202020202020206D6F64616C436F6E74656E742E617474722822726F6C65222C20226C697374626F7822293B0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(230) := '206D6F64616C436F6E74656E742E616464436C6173732822617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F6722293B0D0A202020202020202020202020202020206D6F64616C436F6E74656E742E6869646528293B0D0A0D0A20';
wwv_flow_api.g_varchar2_table(231) := '202020202020202020202020202020696E7075744974656D2E666F6375732866756E6374696F6E202829207B0D0A20202020202020202020202020202020202020206F70656E53756767657374696F6E4C69737428293B0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(232) := '202020202020202020696E7075744974656D2E616464436C6173732822666F637573656422293B0D0A202020202020202020202020202020207D293B0D0A0D0A2020202020202020202020202020202024287772617070657253656C292E636C69636B28';
wwv_flow_api.g_varchar2_table(233) := '66756E6374696F6E202829207B0D0A20202020202020202020202020202020202020206966202821696E7075744974656D2E686173436C6173732822666F6375736564222929207B0D0A202020202020202020202020202020202020202020202020696E';
wwv_flow_api.g_varchar2_table(234) := '7075744974656D2E666F63757328293B0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D293B0D0A0D0A202020202020202020202020202020202F2F207768656E20636C69636B206F6E20616E6F';
wwv_flow_api.g_varchar2_table(235) := '7468657220656C656D656E74207468656E20616C736F20636C6F736520746865206C6973740D0A202020202020202020202020202020202428646F63756D656E74292E6F6E2822746F75636820636C69636B222C2066756E6374696F6E20286529207B0D';
wwv_flow_api.g_varchar2_table(236) := '0A2020202020202020202020202020202020202020696620282428652E746172676574292E706172656E7473287772617070657253656C292E6C656E677468203D3D3D203029207B0D0A2020202020202020202020202020202020202020202020206966';
wwv_flow_api.g_varchar2_table(237) := '20282428652E746172676574292E706172656E7473286D6F64616C436F6E74656E74292E6C656E677468203D3D3D2030207C7C20212428652E746172676574292E636C6F7365737428222E617065782D6175746F636F6D706C6574652D6D6F64616C2D64';
wwv_flow_api.g_varchar2_table(238) := '69616C6F672D62746E2D7772617022292E6C656E67746829207B0D0A20202020202020202020202020202020202020202020202020202020636C6F736553756767657374696F6E4C69737428293B0D0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(239) := '202020207D0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D293B0D0A0D0A20202020202020202020202020202020696E7075744974656D2E6B657975702866756E6374696F6E20286576656E74';
wwv_flow_api.g_varchar2_table(240) := '29207B0D0A202020202020202020202020202020202020202069662028216D756C746953656C656374696F6E29207B0D0A202020202020202020202020202020202020202020202020696620286576656E742E6B6579203D3D3D2022456E746572222026';
wwv_flow_api.g_varchar2_table(241) := '26206D6F64616C436F6E74656E742E66696E6428226C693A666972737422292E6C656E677468203E3D203020262620696E7075744974656D2E76616C28292E6C656E677468203E3D203029207B0D0A202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(242) := '202020202020206576656E742E70726576656E7444656661756C7428293B0D0A202020202020202020202020202020202020202020202020202020206576656E742E73746F7050726F7061676174696F6E28293B0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(243) := '20202020202020202020202020206164644974656D56616C7565286D6F64616C436F6E74656E742E66696E6428226C693A666972737422292E6174747228227261772D646174612229293B0D0A2020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(244) := '207D0D0A20202020202020202020202020202020202020207D20656C7365207B0D0A202020202020202020202020202020202020202020202020696620286576656E742E6B6579203D3D3D2022456E7465722229207B0D0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(245) := '202020202020202020202020202020206576656E742E70726576656E7444656661756C7428293B0D0A202020202020202020202020202020202020202020202020202020206576656E742E73746F7050726F7061676174696F6E28293B0D0A2020202020';
wwv_flow_api.g_varchar2_table(246) := '20202020202020202020202020202020202020202020206164644974656D56616C756528696E7075744974656D2E76616C2829293B0D0A2020202020202020202020202020202020202020202020207D20656C736520696620286D756C746953656C6563';
wwv_flow_api.g_varchar2_table(247) := '74696F6E20262620696E7075744974656D2E76616C2829203D3D3D202222202626206576656E742E6B6579203D3D3D20224261636B73706163652229207B0D0A2020202020202020202020202020202020202020202020202020202072656D6F76654974';
wwv_flow_api.g_varchar2_table(248) := '656D56616C756528293B0D0A2020202020202020202020202020202020202020202020207D0D0A20202020202020202020202020202020202020207D0D0A20202020202020202020202020202020202020207570646174654D6F64616C436F6E74656E74';
wwv_flow_api.g_varchar2_table(249) := '28293B0D0A202020202020202020202020202020207D293B0D0A0D0A202020202020202020202020202020202F2F20617070656E6420746F20626F647920746F2067657420697420776F726B20746F2069670D0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(250) := '242822626F647922292E617070656E64286D6F64616C436F6E74656E74293B0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2F2063726561746520617065782E6974656D206170697320746861742073686F756C642062';
wwv_flow_api.g_varchar2_table(251) := '652068616E646C656420646966666572656E7420666F722074686973206974656D20706C75672D696E0D0A2020202020202020202020206C6574206974656D415049203D207B0D0A202020202020202020202020202020206974656D5F747970653A2022';
wwv_flow_api.g_varchar2_table(252) := '52572E415045582E4155544F2E434F4D504C455445222C0D0A2020202020202020202020202020202064697361626C653A2066756E6374696F6E202829207B0D0A2020202020202020202020202020202020202020696E7075744974656D2E70726F7028';
wwv_flow_api.g_varchar2_table(253) := '2264697361626C6564222C2074727565293B0D0A2020202020202020202020202020202020202020776F726B4974656D2E70726F70282264697361626C6564222C2074727565293B0D0A2020202020202020202020202020202020202020617065784974';
wwv_flow_api.g_varchar2_table(254) := '656D2E70726F70282264697361626C6564222C2074727565293B0D0A202020202020202020202020202020207D2C0D0A20202020202020202020202020202020646973706C617956616C7565466F723A2066756E6374696F6E202829207B0D0A20202020';
wwv_flow_api.g_varchar2_table(255) := '2020202020202020202020202020202072657475726E20617065784974656D2E76616C2829207C7C2022223B0D0A202020202020202020202020202020207D2C0D0A20202020202020202020202020202020656E61626C653A2066756E6374696F6E2028';
wwv_flow_api.g_varchar2_table(256) := '29207B0D0A2020202020202020202020202020202020202020696E7075744974656D2E70726F70282264697361626C6564222C2066616C7365293B0D0A2020202020202020202020202020202020202020776F726B4974656D2E70726F70282264697361';
wwv_flow_api.g_varchar2_table(257) := '626C6564222C2066616C7365293B0D0A2020202020202020202020202020202020202020617065784974656D2E70726F70282264697361626C6564222C2066616C7365293B0D0A202020202020202020202020202020207D2C0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(258) := '2020202020202067657456616C75653A2066756E6374696F6E202829207B0D0A202020202020202020202020202020202020202072657475726E2067657452617756616C75652829207C7C2022223B0D0A202020202020202020202020202020207D2C0D';
wwv_flow_api.g_varchar2_table(259) := '0A2020202020202020202020202020202069734368616E6765643A2066756E6374696F6E202829207B0D0A202020202020202020202020202020202020202072657475726E20696E697469616C56616C756520213D3D20746869732E67657456616C7565';
wwv_flow_api.g_varchar2_table(260) := '28292E6A6F696E2876616C756553706C6974293B0D0A202020202020202020202020202020207D2C0D0A20202020202020202020202020202020697344697361626C65643A2066756E6374696F6E202829207B0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(261) := '202020202072657475726E2028696E7075744974656D2E70726F70282264697361626C6564222929203F2074727565203A2066616C73653B0D0A202020202020202020202020202020207D2C0D0A202020202020202020202020202020206973456D7074';
wwv_flow_api.g_varchar2_table(262) := '793A2066756E6374696F6E202829207B0D0A202020202020202020202020202020202020202072657475726E20286973446566696E6564416E644E6F744E756C6C28617065784974656D2E617474722872617756616C756541747472292929203F206661';
wwv_flow_api.g_varchar2_table(263) := '6C7365203A20747275653B0D0A202020202020202020202020202020207D2C0D0A20202020202020202020202020202020697352656164793A2066756E6374696F6E202829207B0D0A202020202020202020202020202020202020202072657475726E20';
wwv_flow_api.g_varchar2_table(264) := '286973446566696E6564416E644E6F744E756C6C28646174612929203F2074727565203A2066616C73653B0D0A202020202020202020202020202020207D2C0D0A20202020202020202020202020202020726566726573683A2066756E6374696F6E2028';
wwv_flow_api.g_varchar2_table(265) := '29207B0D0A202020202020202020202020202020202020202067657444617461287570646174654D6F64616C436F6E74656E74293B0D0A202020202020202020202020202020207D2C0D0A20202020202020202020202020202020686173446973706C61';
wwv_flow_api.g_varchar2_table(266) := '7956616C75653A2066756E6374696F6E202829207B0D0A202020202020202020202020202020202020202072657475726E20286973446566696E6564416E644E6F744E756C6C28617065784974656D2E617474722872617756616C756541747472292929';
wwv_flow_api.g_varchar2_table(267) := '203F2074727565203A2066616C73653B0D0A202020202020202020202020202020207D2C0D0A20202020202020202020202020202020736574466F6375733A2066756E6374696F6E202829207B0D0A202020202020202020202020202020202020202069';
wwv_flow_api.g_varchar2_table(268) := '6E7075744974656D2E666F63757328293B0D0A202020202020202020202020202020207D2C0D0A2020202020202020202020202020202073657456616C75653A2066756E6374696F6E20287056616C75652C2070446973706C617956616C75652C207053';
wwv_flow_api.g_varchar2_table(269) := '757070726573734368616E67654576656E7429207B0D0A20202020202020202020202020202020202020206966202870436F6E6669672E7570646174654C4F566265666F726553657456616C7565203D3D3D2022592229207B0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(270) := '20202020202020202020202020202067657444617461287570646174654D6F64616C436F6E74656E742C20747275652C207056616C75652C2070446973706C617956616C75652C207053757070726573734368616E67654576656E74293B0D0A20202020';
wwv_flow_api.g_varchar2_table(271) := '202020202020202020202020202020207D20656C7365207B0D0A2020202020202020202020202020202020202020202020207365744974656D56616C7565287056616C75652C2070446973706C617956616C75652C207053757070726573734368616E67';
wwv_flow_api.g_varchar2_table(272) := '654576656E74293B0D0A20202020202020202020202020202020202020207D0D0A0D0A202020202020202020202020202020202020202069662028217053757070726573734368616E67654576656E7429207B0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(273) := '202020202020202020746869732E73757070726573734368616E67654576656E74203D20747275653B0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D2C0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(274) := '202075736552656D6F74653A2066756E6374696F6E202870494429207B0D0A20202020202020202020202020202020202020206C6574206C6F76446174613B0D0A2020202020202020202020202020202020202020696620286461746129207B0D0A2020';
wwv_flow_api.g_varchar2_table(275) := '202020202020202020202020202020202020202020206C6F7644617461203D207B20726F77733A2064617461207D3B0D0A20202020202020202020202020202020202020207D20656C7365207B0D0A202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(276) := '2020206C6F7644617461203D2070446174613B0D0A20202020202020202020202020202020202020207D0D0A20202020202020202020202020202020202020206C657420636F6E666967203D20242E657874656E64287B7D2C2070436F6E666967293B0D';
wwv_flow_api.g_varchar2_table(277) := '0A2020202020202020202020202020202020202020636F6E6669672E6974656D4E616D65203D207049443B0D0A2020202020202020202020202020202020202020617065784175746F436F6D706C6574654974656D28617065782C2024292E696E697469';
wwv_flow_api.g_varchar2_table(278) := '616C697A6528636F6E6669672C206C6F7644617461293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D3B0D0A0D0A2020202020202020202020202F2F20637265676973746572206974656D20666F722061706578';
wwv_flow_api.g_varchar2_table(279) := '2E6974656D206170690D0A202020202020202020202020617065782E6974656D2E6372656174652870436F6E6669672E6974656D4E616D652C206974656D415049293B0D0A20202020202020202020202072656E6465724974656D28293B0D0A20202020';
wwv_flow_api.g_varchar2_table(280) := '2020202020202020696620286973446566696E6564416E644E6F744E756C6C2870446174612929207B0D0A2020202020202020202020202020202064617461203D2070446174612E726F77733B0D0A20202020202020202020202020202020736574496E';
wwv_flow_api.g_varchar2_table(281) := '697469616C56616C756528293B0D0A202020202020202020202020202020207570646174654D6F64616C436F6E74656E7428293B0D0A2020202020202020202020207D20656C7365207B0D0A202020202020202020202020202020206765744461746128';
wwv_flow_api.g_varchar2_table(282) := '696E69744C697374293B0D0A2020202020202020202020207D0D0A0D0A202020202020202020202020696620286973446566696E6564416E644E6F744E756C6C2870436F6E6669672E63617363616465506172656E744974656D2929207B0D0A20202020';
wwv_flow_api.g_varchar2_table(283) := '2020202020202020202020206C657420617272203D2070436F6E6669672E63617363616465506172656E744974656D2E73706C697428222C22293B0D0A202020202020202020202020202020206172722E666F72456163682866756E6374696F6E202869';
wwv_flow_api.g_varchar2_table(284) := '74656D29207B0D0A202020202020202020202020202020202020202024286974656D292E6368616E67652866756E6374696F6E202829207B0D0A20202020202020202020202020202020202020202020202067657444617461287570646174654D6F6461';
wwv_flow_api.g_varchar2_table(285) := '6C436F6E74656E74293B0D0A20202020202020202020202020202020202020207D293B0D0A202020202020202020202020202020207D293B0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2F2061646420737570707265';
wwv_flow_api.g_varchar2_table(286) := '73734368616E67654576656E742066756E6374696F6E616C6974790D0A202020202020202020202020617065784974656D2E6368616E67652866756E6374696F6E20286576656E7429207B0D0A202020202020202020202020202020206C657420697465';
wwv_flow_api.g_varchar2_table(287) := '6D203D20617065782E6974656D2870436F6E6669672E6974656D4E616D65293B0D0A20202020202020202020202020202020696620286974656D2E73757070726573734368616E67654576656E7429207B0D0A2020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(288) := '2020206974656D2E73757070726573734368616E67654576656E74203D2066616C73653B0D0A20202020202020202020202020202020202020206576656E742E73746F70496D6D65646961746550726F7061676174696F6E28293B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(289) := '2020202020202020202020202072657475726E2066616C73653B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D293B0D0A20202020202020207D0D0A202020207D3B0D0A7D3B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(84012814206055370)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_file_name=>'script.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D62746E2D77726170207B0D0A20202020646973706C61793A20677269643B0D0A20202020677269642D74656D706C6174652D636F6C756D6E733A2072657065617428332C';
wwv_flow_api.g_varchar2_table(2) := '20316672293B0D0A7D0D0A0D0A2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D62746E2D777261702D636F6C2D63656E746572207B0D0A20202020746578742D616C69676E3A2063656E7465723B0D0A20202020706164';
wwv_flow_api.g_varchar2_table(3) := '64696E673A203670783B0D0A7D0D0A0D0A2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D62746E2D777261702D636F6C2D7269676874207B0D0A20202020746578742D616C69676E3A2072696768743B0D0A2020202070';
wwv_flow_api.g_varchar2_table(4) := '616464696E673A203670783B0D0A7D0D0A0D0A2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D62746E2D777261702D636F6C2D6C656674207B0D0A20202020746578742D616C69676E3A206C6566743B0D0A2020202070';
wwv_flow_api.g_varchar2_table(5) := '616464696E673A203670783B0D0A7D0D0A0D0A2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D62746E207B0D0A09637572736F723A20706F696E7465723B0D0A7D0D0A0D0A2E617065786175746F636F6D706C6574652D';
wwv_flow_api.g_varchar2_table(6) := '6C692D69636F6E2C0D0A2E617065786175746F636F6D706C6574652D6C692D74657874207B0D0A096C696E652D6865696768743A20696E68657269742021696D706F7274616E743B0D0A09666F6E742D73697A653A20696E68657269742021696D706F72';
wwv_flow_api.g_varchar2_table(7) := '74616E743B0D0A7D0D0A0D0A2E617065786175746F636F6D706C6574652D6C692D69636F6E207B0D0A096D617267696E2D72696768743A203570783B0D0A7D0D0A0D0A2E617065786175746F636F6D706C6574652D77726170207B0D0A0977696474683A';
wwv_flow_api.g_varchar2_table(8) := '20313030253B0D0A09646973706C61793A20666C65783B0D0A7D0D0A0D0A2E617065786175746F636F6D706C6574652D777261703E696E7075743A3A706C616365686F6C646572207B0D0A09636F6C6F723A2072676261283139302C203139302C203139';
wwv_flow_api.g_varchar2_table(9) := '302C20302E37293B0D0A097472616E736974696F6E3A20616C6C20302E337320656173653B0D0A7D0D0A0D0A2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F67207B0D0A096D696E2D77696474683A33303070783B0D0A0970';
wwv_flow_api.g_varchar2_table(10) := '6F736974696F6E3A206162736F6C7574653B0D0A096D61782D6865696768743A2034303070783B0D0A096F766572666C6F772D793A206175746F3B0D0A09746F703A20313030253B0D0A096C6566743A20303B0D0A0972696768743A20303B0D0A097061';
wwv_flow_api.g_varchar2_table(11) := '6464696E673A20303B0D0A096D617267696E3A20302E3572656D2030203020303B0D0A09626F726465722D7261646975733A203270783B0D0A096261636B67726F756E642D636F6C6F723A20766172282D2D75742D726567696F6E2D6261636B67726F75';
wwv_flow_api.g_varchar2_table(12) := '6E642D636F6C6F722C2023666666293B0D0A09626F726465723A2031707820736F6C69642072676261283139302C203139302C203139302C20302E32293B0D0A097A2D696E6465783A20313030303B0D0A096F75746C696E653A206E6F6E653B0D0A0962';
wwv_flow_api.g_varchar2_table(13) := '6F782D736861646F773A2030203020367078202E33327078207267626128302C302C302C302E3236293B0D0A7D0D0A0D0A2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D756C207B0D0A0970616464696E673A20303B0D';
wwv_flow_api.g_varchar2_table(14) := '0A096D617267696E3A20302E3572656D2030203020303B0D0A7D0D0A0D0A2E617065786175746F636F6D706C6574652D67726F757073207B0D0A096D617267696E3A2035707820313070783B0D0A09666F6E742D7765696768743A203630303B0D0A7D0D';
wwv_flow_api.g_varchar2_table(15) := '0A0D0A2E617065786175746F636F6D706C6574652D6C69207B0D0A097472616E736974696F6E3A20616C6C20302E327320656173653B0D0A0970616464696E673A2035707820313070783B0D0A096C6973742D7374796C653A206E6F6E653B0D0A097465';
wwv_flow_api.g_varchar2_table(16) := '78742D616C69676E3A206C6566743B0D0A20202020637572736F723A20706F696E7465723B0D0A7D0D0A0D0A2E617065786175746F636F6D706C6574652D6C692D77726170706572207B0D0A09666F6E742D7765696768743A206E6F726D616C3B0D0A09';
wwv_flow_api.g_varchar2_table(17) := '666F6E742D73697A653A20313470783B0D0A0977686974652D73706163653A206E6F777261703B0D0A096F766572666C6F773A2068696464656E3B0D0A09746578742D6F766572666C6F773A20656C6C69707369733B0D0A0970616464696E672D6C6566';
wwv_flow_api.g_varchar2_table(18) := '743A203270783B0D0A7D0D0A0D0A6C692E617065786175746F636F6D706C6574652D6C693A686F7665722C0D0A6C692E617065786175746F636F6D706C6574652D6C693A666F6375732C0D0A6C692E617065786175746F636F6D706C6574652D6C692D73';
wwv_flow_api.g_varchar2_table(19) := '656C207B0D0A09637572736F723A20706F696E7465723B0D0A096261636B67726F756E642D636F6C6F723A2072676261283139302C203139302C203139302C20302E32293B0D0A7D0D0A0D0A2E617065786175746F636F6D706C6574652D686967686C69';
wwv_flow_api.g_varchar2_table(20) := '676874207B0D0A096261636B67726F756E642D636F6C6F723A207472616E73706172656E743B0D0A09666F6E742D7765696768743A20626F6C643B0D0A7D0D0A0D0A2E617065786175746F636F6D706C6574652D6C695B617269612D73656C6563746564';
wwv_flow_api.g_varchar2_table(21) := '3D2274727565225D207B0D0A096261636B67726F756E642D636F6C6F723A2072676261283139302C203139302C203139302C20302E32293B0D0A7D0D0A0D0A2E617065786175746F636F6D706C6574652D6D732D77726170207B0D0A0970616464696E67';
wwv_flow_api.g_varchar2_table(22) := '2D626C6F636B2D656E643A2063616C6328766172282D2D612D6669656C642D696E7075742D70616464696E672D792C202E323572656D29202D20766172282D2D612D6669656C642D696E7075742D626F726465722D77696474682C2031707829202D202E';
wwv_flow_api.g_varchar2_table(23) := '31323572656D293B0D0A7D0D0A0D0A2E617065786175746F636F6D706C6574652D6D732D756C207B0D0A096F75746C696E653A206E6F6E653B0D0A0970616464696E673A20303B0D0A096D617267696E3A20303B0D0A7D0D0A0D0A2E617065786175746F';
wwv_flow_api.g_varchar2_table(24) := '636F6D706C6574652D6D732D6C69207B0D0A096C6973742D7374796C653A206E6F6E653B0D0A096C696E652D6865696768743A20696E68657269743B0D0A09646973706C61793A20666C65783B0D0A09616C69676E2D6974656D733A2063656E7465723B';
wwv_flow_api.g_varchar2_table(25) := '0D0A09637572736F723A2064656661756C743B0D0A09626F726465722D7261646975733A20766172282D2D612D6669656C642D696E7075742D626F726465722D7261646975732C20302E31323572656D293B0D0A09626F726465723A2031707820736F6C';
wwv_flow_api.g_varchar2_table(26) := '696420766172282D2D612D6669656C642D696E7075742D73746174652D626F726465722D636F6C6F722C20766172282D2D612D6669656C642D696E7075742D626F726465722D636F6C6F7229293B0D0A092F2A6261636B67726F756E643A207267622832';
wwv_flow_api.g_varchar2_table(27) := '35352C203235352C203235352C20302E37293B2A2F0D0A096261636B67726F756E642D636C69703A2070616464696E672D626F783B0D0A09666C6F61743A206C6566743B0D0A096D617267696E3A203170783B0D0A0970616464696E672D6C6566743A20';
wwv_flow_api.g_varchar2_table(28) := '3270783B0D0A0970616464696E672D72696768743A203270783B0D0A7D0D0A0D0A2E617065786175746F636F6D706C6574652D6D732D746578742C0D0A2E617065786175746F636F6D706C6574652D6D732D72656D6F7665207B0D0A09666F6E742D7369';
wwv_flow_api.g_varchar2_table(29) := '7A653A20766172282D2D612D706F7075706C6F762D636869702D666F6E742D73697A652C2031327078293B0D0A096C696E652D6865696768743A20766172282D2D612D706F7075706C6F762D636869702D6C696E652D6865696768742C2031367078293B';
wwv_flow_api.g_varchar2_table(30) := '0D0A096D61782D77696474683A20313030253B0D0A09646973706C61793A20626C6F636B3B0D0A096F766572666C6F773A2068696464656E3B0D0A09776F72642D777261703A20627265616B2D776F72643B0D0A0977686974652D73706163653A206E6F';
wwv_flow_api.g_varchar2_table(31) := '726D616C3B0D0A096F766572666C6F772D777261703A20627265616B2D776F72643B0D0A0968797068656E733A206175746F3B0D0A7D0D0A0D0A2E617065786175746F636F6D706C6574652D6D732D72656D6F7665207B0D0A09637572736F723A20706F';
wwv_flow_api.g_varchar2_table(32) := '696E7465723B0D0A096D617267696E2D6C6566743A203370783B0D0A09646973706C61793A20696E6C696E652D626C6F636B3B0D0A09766572746963616C2D616C69676E3A20746F703B0D0A0977696474683A20766172282D2D612D69636F6E2D73697A';
wwv_flow_api.g_varchar2_table(33) := '652C2031367078293B0D0A096865696768743A20766172282D2D612D69636F6E2D73697A652C2031367078293B0D0A096C696E652D6865696768743A20766172282D2D612D69636F6E2D73697A652C2031367078293B0D0A09666F6E742D73697A653A20';
wwv_flow_api.g_varchar2_table(34) := '766172282D2D612D706F7075706C6F762D636869702D72656D6F76652D666F6E742D73697A652C20766172282D2D612D69636F6E2D73697A652C203136707829293B0D0A7D0D0A0D0A2E617065786175746F636F6D706C6574652D6D732D7466207B0D0A';
wwv_flow_api.g_varchar2_table(35) := '09626F726465723A206E6F6E653B0D0A096261636B67726F756E643A207472616E73706172656E743B0D0A096865696768743A20312E323572656D3B0D0A096D617267696E2D746F703A203370783B0D0A7D0D0A0D0A2E617065786175746F636F6D706C';
wwv_flow_api.g_varchar2_table(36) := '6574652D6D732D74663A666F637573207B0D0A096F75746C696E653A206E6F6E653B0D0A096F75746C696E652D6F66667365743A20696E68657269743B0D0A7D0D0A0D0A2E617065786175746F636F6D706C6574652D6C692D696E666F207B0D0A09636F';
wwv_flow_api.g_varchar2_table(37) := '6C6F723A20233333333B0D0A09666F6E742D73697A653A20313370783B0D0A7D0D0A0D0A2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D7461626C652074642C0D0A2E617065782D6175746F636F6D706C6574652D6D6F';
wwv_flow_api.g_varchar2_table(38) := '64616C2D6469616C6F672D7461626C65207468207B0D0A2020626F726465723A2031707820736F6C69642072676261283139302C203139302C203139302C20302E32293B0D0A2020746578742D616C69676E3A206C6566743B0D0A202070616464696E67';
wwv_flow_api.g_varchar2_table(39) := '3A203870783B0D0A7D0D0A0D0A2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D7461626C65207464207B0D0A20202020637572736F723A20706F696E7465723B0D0A7D0D0A0D0A2E617065782D6175746F636F6D706C65';
wwv_flow_api.g_varchar2_table(40) := '74652D6D6F64616C2D6469616C6F672D7461626C652074723A6E74682D6368696C64286576656E29207B0D0A20206261636B67726F756E642D636F6C6F723A2072676261283139302C203139302C203139302C20302E32293B0D0A7D0D0A2E617065782D';
wwv_flow_api.g_varchar2_table(41) := '6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D7461626C65207B0D0A2020626F726465722D636F6C6C617073653A20636F6C6C617073653B0D0A202077696474683A20313030253B0D0A2020666F6E742D73697A653A20766172282D2D';
wwv_flow_api.g_varchar2_table(42) := '612D6D656E752D666F6E742D73697A652C203172656D293B0D0A7D0D0A0D0A2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D7461626C652074723A686F766572207B0D0A20206261636B67726F756E642D636F6C6F723A';
wwv_flow_api.g_varchar2_table(43) := '2072676261283139302C203139302C203139302C20302E34293B0D0A7D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(84013627282055371)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_file_name=>'style.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D62746E2D777261707B646973706C61793A677269643B677269642D74656D706C6174652D636F6C756D6E733A72657065617428332C316672297D2E617065782D6175746F';
wwv_flow_api.g_varchar2_table(2) := '636F6D706C6574652D6D6F64616C2D6469616C6F672D62746E2D777261702D636F6C2D63656E7465727B746578742D616C69676E3A63656E7465723B70616464696E673A3670787D2E617065782D6175746F636F6D706C6574652D6D6F64616C2D646961';
wwv_flow_api.g_varchar2_table(3) := '6C6F672D62746E2D777261702D636F6C2D72696768747B746578742D616C69676E3A72696768743B70616464696E673A3670787D2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D62746E2D777261702D636F6C2D6C6566';
wwv_flow_api.g_varchar2_table(4) := '747B746578742D616C69676E3A6C6566743B70616464696E673A3670787D2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D62746E7B637572736F723A706F696E7465727D2E617065786175746F636F6D706C6574652D6C';
wwv_flow_api.g_varchar2_table(5) := '692D69636F6E2C2E617065786175746F636F6D706C6574652D6C692D746578747B6C696E652D6865696768743A696E686572697421696D706F7274616E743B666F6E742D73697A653A696E686572697421696D706F7274616E747D2E617065786175746F';
wwv_flow_api.g_varchar2_table(6) := '636F6D706C6574652D6C692D69636F6E7B6D617267696E2D72696768743A3570787D2E617065786175746F636F6D706C6574652D777261707B77696474683A313030253B646973706C61793A666C65787D2E617065786175746F636F6D706C6574652D77';
wwv_flow_api.g_varchar2_table(7) := '7261703E696E7075743A3A706C616365686F6C6465727B636F6C6F723A72676261283139302C3139302C3139302C2E37293B7472616E736974696F6E3A616C6C202E337320656173657D2E617065782D6175746F636F6D706C6574652D6D6F64616C2D64';
wwv_flow_api.g_varchar2_table(8) := '69616C6F677B6D696E2D77696474683A33303070783B706F736974696F6E3A6162736F6C7574653B6D61782D6865696768743A34303070783B6F766572666C6F772D793A6175746F3B746F703A313030253B6C6566743A303B72696768743A303B706164';
wwv_flow_api.g_varchar2_table(9) := '64696E673A303B6D617267696E3A2E3572656D203020303B626F726465722D7261646975733A3270783B6261636B67726F756E642D636F6C6F723A766172282D2D75742D726567696F6E2D6261636B67726F756E642D636F6C6F722C2023666666293B62';
wwv_flow_api.g_varchar2_table(10) := '6F726465723A31707820736F6C69642072676261283139302C3139302C3139302C2E32293B7A2D696E6465783A313030303B6F75746C696E653A303B626F782D736861646F773A30203020367078202E33327078207267626128302C302C302C2E323629';
wwv_flow_api.g_varchar2_table(11) := '7D2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D756C7B70616464696E673A303B6D617267696E3A2E3572656D203020307D2E617065786175746F636F6D706C6574652D67726F7570737B6D617267696E3A3570782031';
wwv_flow_api.g_varchar2_table(12) := '3070783B666F6E742D7765696768743A3630307D2E617065786175746F636F6D706C6574652D6C697B7472616E736974696F6E3A616C6C202E327320656173653B70616464696E673A35707820313070783B6C6973742D7374796C653A6E6F6E653B7465';
wwv_flow_api.g_varchar2_table(13) := '78742D616C69676E3A6C6566743B637572736F723A706F696E7465727D2E617065786175746F636F6D706C6574652D6C692D777261707065727B666F6E742D7765696768743A3430303B666F6E742D73697A653A313470783B77686974652D7370616365';
wwv_flow_api.g_varchar2_table(14) := '3A6E6F777261703B6F766572666C6F773A68696464656E3B746578742D6F766572666C6F773A656C6C69707369733B70616464696E672D6C6566743A3270787D6C692E617065786175746F636F6D706C6574652D6C692D73656C2C6C692E617065786175';
wwv_flow_api.g_varchar2_table(15) := '746F636F6D706C6574652D6C693A666F6375732C6C692E617065786175746F636F6D706C6574652D6C693A686F7665727B637572736F723A706F696E7465723B6261636B67726F756E642D636F6C6F723A72676261283139302C3139302C3139302C2E32';
wwv_flow_api.g_varchar2_table(16) := '297D2E617065786175746F636F6D706C6574652D686967686C696768747B6261636B67726F756E642D636F6C6F723A7472616E73706172656E743B666F6E742D7765696768743A3730307D2E617065786175746F636F6D706C6574652D6C695B61726961';
wwv_flow_api.g_varchar2_table(17) := '2D73656C65637465643D747275655D7B6261636B67726F756E642D636F6C6F723A72676261283139302C3139302C3139302C2E32297D2E617065786175746F636F6D706C6574652D6D732D777261707B70616464696E672D626C6F636B2D656E643A6361';
wwv_flow_api.g_varchar2_table(18) := '6C6328766172282D2D612D6669656C642D696E7075742D70616464696E672D792C202E323572656D29202D20766172282D2D612D6669656C642D696E7075742D626F726465722D77696474682C2031707829202D202E31323572656D297D2E6170657861';
wwv_flow_api.g_varchar2_table(19) := '75746F636F6D706C6574652D6D732D756C7B6F75746C696E653A303B70616464696E673A303B6D617267696E3A307D2E617065786175746F636F6D706C6574652D6D732D6C697B6C6973742D7374796C653A6E6F6E653B6C696E652D6865696768743A69';
wwv_flow_api.g_varchar2_table(20) := '6E68657269743B646973706C61793A666C65783B616C69676E2D6974656D733A63656E7465723B637572736F723A64656661756C743B626F726465722D7261646975733A766172282D2D612D6669656C642D696E7075742D626F726465722D7261646975';
wwv_flow_api.g_varchar2_table(21) := '732C20302E31323572656D293B626F726465723A31707820736F6C696420766172282D2D612D6669656C642D696E7075742D73746174652D626F726465722D636F6C6F722C20766172282D2D612D6669656C642D696E7075742D626F726465722D636F6C';
wwv_flow_api.g_varchar2_table(22) := '6F7229293B6261636B67726F756E642D636C69703A70616464696E672D626F783B666C6F61743A6C6566743B6D617267696E3A3170783B70616464696E672D6C6566743A3270783B70616464696E672D72696768743A3270787D2E617065786175746F63';
wwv_flow_api.g_varchar2_table(23) := '6F6D706C6574652D6D732D72656D6F76652C2E617065786175746F636F6D706C6574652D6D732D746578747B666F6E742D73697A653A766172282D2D612D706F7075706C6F762D636869702D666F6E742D73697A652C2031327078293B6C696E652D6865';
wwv_flow_api.g_varchar2_table(24) := '696768743A766172282D2D612D706F7075706C6F762D636869702D6C696E652D6865696768742C2031367078293B6D61782D77696474683A313030253B646973706C61793A626C6F636B3B6F766572666C6F773A68696464656E3B776F72642D77726170';
wwv_flow_api.g_varchar2_table(25) := '3A627265616B2D776F72643B77686974652D73706163653A6E6F726D616C3B6F766572666C6F772D777261703A627265616B2D776F72643B68797068656E733A6175746F7D2E617065786175746F636F6D706C6574652D6D732D72656D6F76657B637572';
wwv_flow_api.g_varchar2_table(26) := '736F723A706F696E7465723B6D617267696E2D6C6566743A3370783B646973706C61793A696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A746F703B77696474683A766172282D2D612D69636F6E2D73697A652C2031367078293B68';
wwv_flow_api.g_varchar2_table(27) := '65696768743A766172282D2D612D69636F6E2D73697A652C2031367078293B6C696E652D6865696768743A766172282D2D612D69636F6E2D73697A652C2031367078293B666F6E742D73697A653A766172282D2D612D706F7075706C6F762D636869702D';
wwv_flow_api.g_varchar2_table(28) := '72656D6F76652D666F6E742D73697A652C20766172282D2D612D69636F6E2D73697A652C203136707829297D2E617065786175746F636F6D706C6574652D6D732D74667B626F726465723A303B6261636B67726F756E643A3020303B6865696768743A31';
wwv_flow_api.g_varchar2_table(29) := '2E323572656D3B6D617267696E2D746F703A3370787D2E617065786175746F636F6D706C6574652D6D732D74663A666F6375737B6F75746C696E653A303B6F75746C696E652D6F66667365743A696E68657269747D2E617065786175746F636F6D706C65';
wwv_flow_api.g_varchar2_table(30) := '74652D6C692D696E666F7B636F6C6F723A233333333B666F6E742D73697A653A313370787D2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D7461626C652074642C2E617065782D6175746F636F6D706C6574652D6D6F64';
wwv_flow_api.g_varchar2_table(31) := '616C2D6469616C6F672D7461626C652074687B626F726465723A31707820736F6C69642072676261283139302C3139302C3139302C2E32293B746578742D616C69676E3A6C6566743B70616464696E673A3870787D2E617065782D6175746F636F6D706C';
wwv_flow_api.g_varchar2_table(32) := '6574652D6D6F64616C2D6469616C6F672D7461626C652074647B637572736F723A706F696E7465727D2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D7461626C652074723A6E74682D6368696C64286576656E297B6261';
wwv_flow_api.g_varchar2_table(33) := '636B67726F756E642D636F6C6F723A72676261283139302C3139302C3139302C2E32297D2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D7461626C657B626F726465722D636F6C6C617073653A636F6C6C617073653B77';
wwv_flow_api.g_varchar2_table(34) := '696474683A313030253B666F6E742D73697A653A766172282D2D612D6D656E752D666F6E742D73697A652C203172656D297D2E617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D7461626C652074723A686F7665727B626163';
wwv_flow_api.g_varchar2_table(35) := '6B67726F756E642D636F6C6F723A72676261283139302C3139302C3139302C2E34297D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(84014060397055372)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_file_name=>'style.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '636F6E737420617065784175746F436F6D706C6574654974656D3D66756E6374696F6E28742C65297B2275736520737472696374223B636F6E737420613D7B6E616D653A22415045582E44332E47414E5454222C76657273696F6E3A22312E30227D3B66';
wwv_flow_api.g_varchar2_table(2) := '756E6374696F6E206C2874297B72657475726E206E756C6C213D7426262222213D3D747D72657475726E7B696E697469616C697A653A66756E6374696F6E286E2C6F297B742E64656275672E696E666F287B6663743A612E6E616D652B22202D20696E69';
wwv_flow_api.g_varchar2_table(3) := '7469616C697A65222C617267756D656E74733A6E2C6665617475726544657461696C733A617D293B636F6E737420693D6E2E6D756C746973656C656374696F6E2C733D2223222B6E2E6974656D4E616D652C703D732B28693F225F6D7363223A2222292C';
wwv_flow_api.g_varchar2_table(4) := '723D732B28693F225F6D73635F7466223A2222292C643D6E2E6974656D4E616D652B225F616377726170706572222C753D2223222B642C633D652873292C663D652870292C6D3D652872292C673D223A222C683D227261772D76616C7565222C783D632E';
wwv_flow_api.g_varchar2_table(5) := '617474722868293B6C657420432C622C762C773B66756E6374696F6E20792865297B72657475726E206E2E65736361706548544D4C3F742E7574696C2E65736361706548544D4C2822222B65293A657D66756E6374696F6E204128297B2274727565223D';
wwv_flow_api.g_varchar2_table(6) := '3D3D622E61747472282269732D6F70656E2229262628622E736C696465557028226661737422292C622E61747472282269732D6F70656E222C2266616C73652229297D66756E6374696F6E204928742C613D2130297B6C6574206C3B72657475726E2061';
wwv_flow_api.g_varchar2_table(7) := '2626286C3D74292C652E6561636828762C2866756E6374696F6E28652C61297B696628612E76616C75653D3D742972657475726E206C3D612E6C6162656C2C21317D29292C6C7D66756E6374696F6E204528297B72657475726E20632E61747472286829';
wwv_flow_api.g_varchar2_table(8) := '26262222213D3D632E617474722868293F632E617474722868292E73706C69742867293A5B5D7D66756E6374696F6E204428612C6F2C73297B6C657420703D5B5D2C723D5B5D3B6966286C286129262628703D41727261792E697341727261792861293F';
wwv_flow_api.g_varchar2_table(9) := '613A742E7574696C2E746F417272617928612C67292C6C286F293F723D41727261792E69734172726179286F293F6F3A742E7574696C2E746F4172726179286F2C67293A652E6561636828702C2866756E6374696F6E28742C65297B6C657420613D4928';
wwv_flow_api.g_varchar2_table(10) := '65293B722E707573682861297D2929292C6C286E2E6D617853656C656374696F6E7329262628703D702E736C69636528302C6E2E6D617853656C656374696F6E73292C723D722E736C69636528302C6E2E6D617853656C656374696F6E7329292C66756E';
wwv_flow_api.g_varchar2_table(11) := '6374696F6E2874297B41727261792E697341727261792874293F632E6174747228682C742E6A6F696E286729293A632E6174747228682C74297D2870292C69297B6C657420743D662E66696E642822756C2E617065786175746F636F6D706C6574652D6D';
wwv_flow_api.g_varchar2_table(12) := '732D756C22293B742E656D70747928292C632E76616C28722E6A6F696E286729292C652E6561636828722C2866756E6374696F6E28612C6C297B6C6574206E3D6528223C6C693E22293B6E2E616464436C6173732822617065786175746F636F6D706C65';
wwv_flow_api.g_varchar2_table(13) := '74652D6D732D6C6922293B6C6574206F3D6528223C7370616E3E22293B6F2E616464436C6173732822617065786175746F636F6D706C6574652D6D732D7465787422292C6F2E68746D6C2879286C29292C6E2E617070656E64286F293B6C657420693D65';
wwv_flow_api.g_varchar2_table(14) := '28223C7370616E3E22293B692E616464436C6173732822666122292C692E616464436C617373282266612D636C6F736522292C692E616464436C6173732822617065786175746F636F6D706C6574652D6D732D72656D6F766522292C692E636C69636B28';
wwv_flow_api.g_varchar2_table(15) := '2866756E6374696F6E28297B4C28705B615D297D29292C6E2E617070656E642869292C742E617070656E64286E297D29297D656C736520632E76616C28722E6A6F696E2867292E7265706C616365282F283C285B5E3E5D2B293E292F67692C222229293B';
wwv_flow_api.g_varchar2_table(16) := '737C7C632E7472696767657228226368616E676522297D66756E6374696F6E204C2874297B6C657420653D4528293B6966286C287429297B636F6E737420613D652E696E6465784F662874293B613E2D312626652E73706C69636528612C31297D656C73';
wwv_flow_api.g_varchar2_table(17) := '6520653D652E736C69636528302C2D31293B442865297D66756E6374696F6E20542874297B6C657420653D5B5D3B696628692626286D2E76616C282222292C2222213D3D632E61747472286829262628653D45282929292C6C286E2E6D617853656C6563';
wwv_flow_api.g_varchar2_table(18) := '74696F6E7329297B636F6E737420613D652E6C656E6774683B613C6E2E6D617853656C656374696F6E733F652E707573682874293A655B612D315D3D747D656C736520652E707573682874293B442865297D66756E6374696F6E206B286C2C6E297B636F';
wwv_flow_api.g_varchar2_table(19) := '6E7374206F3D6E657720526567457870286C2C22696722293B696628742E64656275672E696E666F287B6663743A612E6E616D652B22202D20686967686C6967687454657874222C705374723A6C2C66696C7465723A6F2C70456C656D656E743A6E2C66';
wwv_flow_api.g_varchar2_table(20) := '65617475726544657461696C733A617D292C6E2E74657874282926266E2E7465787428292E6D61746368286F29297B6C657420743D6528223C6469763E22292C613D6528223C7370616E3E22293B612E616464436C6173732822617065786175746F636F';
wwv_flow_api.g_varchar2_table(21) := '6D706C6574652D686967686C6967687422292C612E68746D6C286E2E7465787428292E6D61746368286F295B305D292C742E617070656E642861292C2222213D3D6C26266E2E68746D6C286E2E7465787428292E7265706C616365286F2C742E68746D6C';
wwv_flow_api.g_varchar2_table(22) := '282929297D7D66756E6374696F6E205028297B6C657420743D4528293B286E2E6C6F76446973706C617945787472617C7C6C284928742C213129292926264428742C6E756C6C2C2130297D66756E6374696F6E205328652C6F2C692C702C72297B6C6574';
wwv_flow_api.g_varchar2_table(23) := '20643D5B5D3B6966286C286E2E6974656D73546F5375626D697429297B6C657420743D6E2E6974656D73546F5375626D69742E73706C697428222C22293B643D642E636F6E6361742874297D6966286C286E2E63617363616465506172656E744974656D';
wwv_flow_api.g_varchar2_table(24) := '29297B6C657420743D6E2E63617363616465506172656E744974656D2E73706C697428222C22293B643D642E636F6E6361742874297D742E7365727665722E706C7567696E286E2E616A617849442C7B706167654974656D733A642E6A6F696E28222C22';
wwv_flow_api.g_varchar2_table(25) := '297D2C7B6C6F6164696E67496E64696361746F723A732C737563636573733A66756E6374696F6E2874297B763D742E726F77732C6528292C6F26264428692C702C72297D2C6572726F723A66756E6374696F6E2865297B763D5B5D2C742E64656275672E';
wwv_flow_api.g_varchar2_table(26) := '6572726F72287B6663743A612E6E616D652B22202D2067657444617461222C6D73673A224572726F72207768696C65206C6F6164696E6720414A41582064617461222C6572723A652C6665617475726544657461696C733A617D297D2C64617461547970';
wwv_flow_api.g_varchar2_table(27) := '653A226A736F6E227D297D66756E6374696F6E204228742C612C6C2C6E2C6F3D226C222C693D2131297B6C657420733D6528223C613E22293B696628732E61747472282274797065222C22627574746F6E22292C732E616464436C6173732822742D4275';
wwv_flow_api.g_varchar2_table(28) := '74746F6E22292C692626732E616464436C6173732822742D427574746F6E2D2D686F7422292C732E616464436C6173732822617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D62746E22292C612626226C223D3D3D6F297B6C';
wwv_flow_api.g_varchar2_table(29) := '657420743D6528223C7370616E3E22293B742E616464436C6173732822742D49636F6E22292C742E616464436C6173732822742D49636F6E2D2D6C65667422292C742E616464436C6173732822666122292C742E616464436C6173732861292C742E6373';
wwv_flow_api.g_varchar2_table(30) := '73282270616464696E672D7269676874222C2233707822292C732E617070656E642874297D69662874297B6C657420613D6528223C7370616E3E22293B612E616464436C6173732822742D427574746F6E2D6C6162656C22292C612E746578742874292C';
wwv_flow_api.g_varchar2_table(31) := '612E617474722822617269612D68696464656E222C227472756522292C732E617070656E642861297D696628612626226C22213D3D6F297B6C657420743D6528223C7370616E3E22293B742E616464436C6173732822742D49636F6E22292C742E616464';
wwv_flow_api.g_varchar2_table(32) := '436C6173732822742D49636F6E2D2D6C65667422292C742E616464436C6173732822666122292C742E616464436C6173732861292C742E637373282270616464696E672D6C656674222C2233707822292C732E617070656E642874297D72657475726E20';
wwv_flow_api.g_varchar2_table(33) := '6C2626732E61747472282268726566222C6C292C6E2626732E6F6E28226D6F757365646F776E222C6E292C737D66756E6374696F6E205228743D21302C613D2130297B766172206F2C733B61262628763D762E736F727428286F3D2267726F7570222C73';
wwv_flow_api.g_varchar2_table(34) := '3D226C6162656C222C66756E6374696F6E28742C65297B72657475726E20745B6F5D3C655B6F5D3F2D313A745B6F5D3E655B6F5D7C7C745B735D3E655B735D3F313A745B735D3C655B735D3F2D313A307D2929292C74262628773D30293B6C657420702C';
wwv_flow_api.g_varchar2_table(35) := '723D767C7C5B5D2C643D6D2E76616C28292E746F4C6F63616C654C6F7765724361736528292C753D4528292C633D662E706172656E7428293B6C286E2E6D696E4C6973745769647468292626622E63737328226D696E2D7769647468222C6E2E6D696E4C';
wwv_flow_api.g_varchar2_table(36) := '6973745769647468292C622E63737328227769647468222C632E77696474682829292C622E6373732822746F70222C632E6F666673657428292E746F702B632E706172656E7428292E6865696768742829292C622E63737328226C656674222C632E6F66';
wwv_flow_api.g_varchar2_table(37) := '6673657428292E6C656674292C723D762E66696C746572282866756E6374696F6E2874297B6966286C287429297B6C657420653D22222B742E6C6162656C2B742E696E666F3B72657475726E2821697C7C21752E696E636C7564657328742E76616C7565';
wwv_flow_api.g_varchar2_table(38) := '2929262628216C2864297C7C652E746F4C6F63616C654C6F7765724361736528292E696E636C75646573286429297D72657475726E21317D29293B6C657420673D4D6174682E6D696E286E2E6D6178526573756C74737C7C352C722E6C656E677468293B';
wwv_flow_api.g_varchar2_table(39) := '725B305D2626725B305D2E67726F7570262628703D725B305D2E67726F7570292C622E656D70747928293B6C657420683D6528223C756C3E22292C783D6528223C7461626C653E22293B636F6E737420433D227461626C6522213D3D6E2E646973706C61';
wwv_flow_api.g_varchar2_table(40) := '79547970653B6966284329682E616464436C6173732822617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D756C22292C622E617070656E642868293B656C736520696628782E616464436C6173732822617065782D6175746F';
wwv_flow_api.g_varchar2_table(41) := '636F6D706C6574652D6D6F64616C2D6469616C6F672D7461626C6522292C622E617070656E642878292C725B305D2626725B305D2E7461626C65436F6C756D6E73297B6C657420743D6528223C74723E22293B782E617070656E642874293B666F72286C';
wwv_flow_api.g_varchar2_table(42) := '6574206120696E20725B305D2E7461626C65436F6C756D6E73297B6C6574206C3D6528223C74683E22293B6C2E68746D6C287928725B305D2E7461626C65436F6C756D6E735B615D2E6E616D6529292C742E617070656E64286C297D7D666F72286C6574';
wwv_flow_api.g_varchar2_table(43) := '20743D773B743C772B673B742B2B297B6C657420613D725B745D3B696628612969662843297B6966286C287029297B6C6574206C3D6528223C703E22293B6C2E616464436C6173732822617065786175746F636F6D706C6574652D67726F75707322292C';
wwv_flow_api.g_varchar2_table(44) := '6C2E68746D6C287928612E67726F75707C7C222D2229292C703D3D3D612E67726F7570262630213D3D747C7C682E617070656E64286C292C703D612E67726F75707D6C6574206E3D6528223C6C693E22293B6E2E616464436C6173732822617065786175';
wwv_flow_api.g_varchar2_table(45) := '746F636F6D706C6574652D6C6922292C6E2E617474722822726F6C65222C226F7074696F6E22292C6E2E6174747228227261772D64617461222C612E76616C7565292C6E2E636C69636B282866756E6374696F6E28297B5428612E76616C7565292C4128';
wwv_flow_api.g_varchar2_table(46) := '297D29293B6C6574206F3D6528223C6469763E22293B6966286F2E616464436C6173732822617065786175746F636F6D706C6574652D6C692D7772617070657222292C6C28612E69636F6E29297B6C657420743D6528223C7370616E3E22293B742E6174';
wwv_flow_api.g_varchar2_table(47) := '74722822617269612D68696464656E222C227472756522292C742E616464436C6173732822666122292C742E616464436C61737328612E69636F6E292C742E616464436C6173732822617065786175746F636F6D706C6574652D6C692D69636F6E22292C';
wwv_flow_api.g_varchar2_table(48) := '6F2E617070656E642874297D6C657420693D6528223C7370616E3E22293B696628692E68746D6C287928612E6C6162656C29292C692E616464436C6173732822617065786175746F636F6D706C6574652D6C692D7465787422292C6F2E617070656E6428';
wwv_flow_api.g_varchar2_table(49) := '69292C6C28612E696E666F29297B6F2E617070656E6428223C62723E22293B6C657420743D6528223C7370616E3E22293B742E68746D6C287928612E696E666F29292C742E616464436C6173732822617065786175746F636F6D706C6574652D6C692D69';
wwv_flow_api.g_varchar2_table(50) := '6E666F22292C6F2E617070656E642874297D6E2E617070656E64286F292C682E617070656E64286E292C6B286D2E76616C28292C69292C6C28612E696E666F2926266B286D2E76616C28292C69297D656C736520696628612E7461626C65436F6C756D6E';
wwv_flow_api.g_varchar2_table(51) := '73297B6C657420743D6528223C74723E22293B742E636C69636B282866756E6374696F6E28297B5428612E76616C7565292C4128297D29292C782E617070656E642874293B666F72286C6574206C20696E20612E7461626C65436F6C756D6E73297B6C65';
wwv_flow_api.g_varchar2_table(52) := '74206E3D6528223C74643E22293B6E2E68746D6C287928612E7461626C65436F6C756D6E735B6C5D2E76616C756529292C742E617070656E64286E297D7D7D6C657420493D6528223C6469763E22293B492E616464436C6173732822617065782D617574';
wwv_flow_api.g_varchar2_table(53) := '6F636F6D706C6574652D6D6F64616C2D6469616C6F672D62746E2D7772617022292C622E617070656E642849293B6C657420443D6528223C6469763E22293B442E616464436C6173732822617065782D6175746F636F6D706C6574652D6D6F64616C2D64';
wwv_flow_api.g_varchar2_table(54) := '69616C6F672D62746E2D777261702D636F6C2D6C65667422293B6C6574204C3D6528223C6469763E22293B4C2E616464436C6173732822617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D62746E2D777261702D636F6C2D63';
wwv_flow_api.g_varchar2_table(55) := '656E74657222293B6C657420503D6528223C6469763E22293B696628502E616464436C6173732822617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D62746E2D777261702D636F6C2D726967687422292C492E617070656E64';
wwv_flow_api.g_varchar2_table(56) := '2844292C492E617070656E64284C292C492E617070656E642850292C773E30297B6C657420743D422860247B6E2E70726576696F757342746E4C6162656C7D2028247B777D29602C6E2E70726576696F757342746E49636F6E2C6E756C6C2C2866756E63';
wwv_flow_api.g_varchar2_table(57) := '74696F6E2874297B742E70726576656E7444656661756C7428292C772D3D6E2E6D6178526573756C74732C52282131297D292C226C222C2130293B442E617070656E642874297D6966282259223D3D3D6E2E62746E53686F77297B6C657420743D42286E';
wwv_flow_api.g_varchar2_table(58) := '2E62746E4C6162656C2C6E2E62746E49636F6E2C6E2E62746E416374696F6E293B4C2E617070656E642874297D696628722E6C656E6774683E772B67297B6C657420743D422860247B6E2E6E65787442746E4C6162656C7D2028247B722E6C656E677468';
wwv_flow_api.g_varchar2_table(59) := '2D772D6E2E6D6178526573756C74737D29602C6E2E6E65787442746E49636F6E2C6E756C6C2C2866756E6374696F6E2874297B742E70726576656E7444656661756C7428292C772B3D6E2E6D6178526573756C74732C52282131297D292C2272222C2130';
wwv_flow_api.g_varchar2_table(60) := '293B502E617070656E642874297D7D6C6574206A3D7B6974656D5F747970653A2252572E415045582E4155544F2E434F4D504C455445222C64697361626C653A66756E6374696F6E28297B6D2E70726F70282264697361626C6564222C2130292C662E70';
wwv_flow_api.g_varchar2_table(61) := '726F70282264697361626C6564222C2130292C632E70726F70282264697361626C6564222C2130297D2C646973706C617956616C7565466F723A66756E6374696F6E28297B72657475726E20632E76616C28297C7C22227D2C656E61626C653A66756E63';
wwv_flow_api.g_varchar2_table(62) := '74696F6E28297B6D2E70726F70282264697361626C6564222C2131292C662E70726F70282264697361626C6564222C2131292C632E70726F70282264697361626C6564222C2131297D2C67657456616C75653A66756E6374696F6E28297B72657475726E';
wwv_flow_api.g_varchar2_table(63) := '204528297C7C22227D2C69734368616E6765643A66756E6374696F6E28297B72657475726E2078213D3D746869732E67657456616C756528292E6A6F696E2867297D2C697344697361626C65643A66756E6374696F6E28297B72657475726E21216D2E70';
wwv_flow_api.g_varchar2_table(64) := '726F70282264697361626C656422297D2C6973456D7074793A66756E6374696F6E28297B72657475726E216C28632E61747472286829297D2C697352656164793A66756E6374696F6E28297B72657475726E21216C2876297D2C726566726573683A6675';
wwv_flow_api.g_varchar2_table(65) := '6E6374696F6E28297B532852297D2C686173446973706C617956616C75653A66756E6374696F6E28297B72657475726E21216C28632E61747472286829297D2C736574466F6375733A66756E6374696F6E28297B6D2E666F63757328297D2C7365745661';
wwv_flow_api.g_varchar2_table(66) := '6C75653A66756E6374696F6E28742C652C61297B2259223D3D3D6E2E7570646174654C4F566265666F726553657456616C75653F5328522C21302C742C652C61293A4428742C652C61292C617C7C28746869732E73757070726573734368616E67654576';
wwv_flow_api.g_varchar2_table(67) := '656E743D2130297D2C75736552656D6F74653A66756E6374696F6E2861297B6C6574206C3B6C3D763F7B726F77733A767D3A6F3B6C657420693D652E657874656E64287B7D2C6E293B692E6974656D4E616D653D612C617065784175746F436F6D706C65';
wwv_flow_api.g_varchar2_table(68) := '74654974656D28742C65292E696E697469616C697A6528692C6C297D7D3B696628742E6974656D2E637265617465286E2E6974656D4E616D652C6A292C433D6528223C6469763E22292C432E6174747228226964222C64292C432E617474722822726F6C';
wwv_flow_api.g_varchar2_table(69) := '65222C22636F6D626F626F7822292C432E616464436C6173732822617065786175746F636F6D706C6574652D7772617022292C662E777261702843292C623D6528223C6469763E22292C622E61747472282269732D6F70656E222C2266616C736522292C';
wwv_flow_api.g_varchar2_table(70) := '622E617474722822726F6C65222C226C697374626F7822292C622E616464436C6173732822617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F6722292C622E6869646528292C6D2E666F637573282866756E6374696F6E28297B22';
wwv_flow_api.g_varchar2_table(71) := '66616C7365223D3D3D622E61747472282269732D6F70656E222926262852282131292C622E736C696465446F776E28226661737422292C622E61747472282269732D6F70656E222C22747275652229292C6D2E616464436C6173732822666F6375736564';
wwv_flow_api.g_varchar2_table(72) := '22297D29292C652875292E636C69636B282866756E6374696F6E28297B6D2E686173436C6173732822666F637573656422297C7C6D2E666F63757328297D29292C6528646F63756D656E74292E6F6E2822746F75636820636C69636B222C2866756E6374';
wwv_flow_api.g_varchar2_table(73) := '696F6E2874297B303D3D3D6528742E746172676574292E706172656E74732875292E6C656E67746826262830213D3D6528742E746172676574292E706172656E74732862292E6C656E67746826266528742E746172676574292E636C6F7365737428222E';
wwv_flow_api.g_varchar2_table(74) := '617065782D6175746F636F6D706C6574652D6D6F64616C2D6469616C6F672D62746E2D7772617022292E6C656E6774687C7C412829297D29292C6D2E6B65797570282866756E6374696F6E2874297B693F22456E746572223D3D3D742E6B65793F28742E';
wwv_flow_api.g_varchar2_table(75) := '70726576656E7444656661756C7428292C742E73746F7050726F7061676174696F6E28292C54286D2E76616C282929293A69262622223D3D3D6D2E76616C28292626224261636B7370616365223D3D3D742E6B657926264C28293A22456E746572223D3D';
wwv_flow_api.g_varchar2_table(76) := '3D742E6B65792626622E66696E6428226C693A666972737422292E6C656E6774683E3D3026266D2E76616C28292E6C656E6774683E3D30262628742E70726576656E7444656661756C7428292C742E73746F7050726F7061676174696F6E28292C542862';
wwv_flow_api.g_varchar2_table(77) := '2E66696E6428226C693A666972737422292E6174747228227261772D64617461222929292C5228297D29292C652822626F647922292E617070656E642862292C6C286F293F28763D6F2E726F77732C5028292C522829293A53282866756E6374696F6E28';
wwv_flow_api.g_varchar2_table(78) := '297B5028292C5228297D29292C6C286E2E63617363616465506172656E744974656D29297B6E2E63617363616465506172656E744974656D2E73706C697428222C22292E666F7245616368282866756E6374696F6E2874297B652874292E6368616E6765';
wwv_flow_api.g_varchar2_table(79) := '282866756E6374696F6E28297B532852297D29297D29297D632E6368616E6765282866756E6374696F6E2865297B6C657420613D742E6974656D286E2E6974656D4E616D65293B696628612E73757070726573734368616E67654576656E742972657475';
wwv_flow_api.g_varchar2_table(80) := '726E20612E73757070726573734368616E67654576656E743D21312C652E73746F70496D6D65646961746550726F7061676174696F6E28292C21317D29297D7D7D3B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(84016862566102560)
,p_plugin_id=>wwv_flow_api.id(84003609119055356)
,p_file_name=>'script.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
