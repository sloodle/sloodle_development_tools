#!/bin/sed -e

/sloodle_get_record/! s/get_record(/sloodle_get_record(/g
/sloodle_get_records/! s/get_records(/sloodle_get_records(/g
/sloodle_get_records_select/! s/get_records_select(/sloodle_get_records_select(/g
/sloodle_get_records_sql/! s/get_records_sql(/sloodle_get_records_sql(/g
/sloodle_get_record_sql/! s/get_record_sql(/sloodle_get_record_sql(/g
/sloodle_get_record_select/! s/get_record_select(/sloodle_get_record_select(/g
/sloodle_get_recordset_select/! s/get_recordset_select(/sloodle_get_recordset_select(/g
/sloodle_get_field/! s/get_field(/sloodle_get_field(/g
/sloodle_get_field_sql/! s/get_field_sql(/sloodle_get_field_sql(/g
/sloodle_count_records_select/! s/count_records_select(/sloodle_count_records_select(/g
/sloodle_count_records/! s/count_records(/sloodle_count_records(/
/sloodle_insert_record/! s/insert_record(/sloodle_insert_record(/g
/sloodle_update_record/! s/update_record(/sloodle_update_record(/g
/sloodle_delete_records/! s/delete_records(/sloodle_delete_records(/g
/sloodle_has_capability/! s/has_capability(/sloodle_has_capability(/g
