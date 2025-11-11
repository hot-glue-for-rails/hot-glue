class TextField < Field
  def spec_random_data
    FFaker::AnimalUS.common_name
  end

  def spec_setup_and_change_act(which_partial = nil)
    "      " + "new_#{name} = FFaker::Lorem.paragraphs(1).join("") \n" +
    "      find(\"[name='#{testing_name}[#{ name.to_s }]']\").fill_in(with: new_#{name.to_s})"
  end

  def spec_setup_let_arg
    "#{name}:  FFaker::Lorem.paragraphs(10).join("  ")"
  end

  def form_field_output
    if sql_type == "varchar" || sql_type == "character varying"
      field_output( nil, limit || 40)
    else
      text_area_output( 65536, extra_classes: (modify_as == {tinymce: 1} ? " tinymce" : "" ))
    end
  end

  # TODO: dry with string_field.rb
  def text_result( sql_type, limit)
    if sql_type == "varchar"
      field_output( nil, limit)
    else
      text_area_output( 65536)
    end
  end


  def search_field_output
    "<%= f.select 'q[0][#{name}_match]', options_for_select([['', ''], ['contains', 'contains'], ['is exactly', 'is_exactly'], ['starts with', 'starts_with'], ['ends with', 'ends_with']], @q[\'0\']['#{name}_match'] ), {} , { class: 'form-control match', 'data-search-form-target': \"textMatch\" } %>"+
      "<%= f.text_field 'q[0][#{name}_search]', value: @q[\'0\'][:#{name}_search], autocomplete: 'off', size: 40, class: 'form-control', type: 'text', 'data-search-form-target': \"textSearch\" %>"
  end


  def where_query_statement
    ".where('#{name} ILIKE ?', #{name}_query)"
  end

  def load_all_query_statement
    "#{name}_query = string_query_constructor(@q['0'][:#{name}_match], @q['0'][:#{name}_search])"
  end

  def code_to_reset_match_if_search_is_blank
    # "    @q['0'][:#{name}_match] = '' if @q['0'][:#{name}_search] == ''"
  end

end
