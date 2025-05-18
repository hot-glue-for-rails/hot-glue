class IntegerField < Field
  def spec_random_data
    rand(1...1000)
  end

  def spec_setup_and_change_act(which_partial = nil)
    if name.to_s.ends_with?("_id")
      capybara_block_for_association(name_name: name, which_partial: which_partial)
    else
      "      new_#{name} = rand(10) \n" +
      "      find(\"[name='#{testing_name}[#{ name.to_s }]']\").fill_in(with: new_#{name.to_s})"
    end
  end

  def spec_make_assertion
    "expect(page).to have_content(new_#{name})"
  end

  def spec_setup_let_arg
    "#{name}: rand(100)"
  end

  def spec_list_view_assertion
    "expect(page).to have_content(#{singular}#{1}.#{name})"
  end

  def form_field_output
    "  <%= f.text_field :#{name}, value: #{singular}.#{name}, autocomplete: 'off', size: 4, class: 'form-control', type: 'number'"  + (form_placeholder_labels ? ", placeholder: '#{name.to_s.humanize}'" : "")  +  " %>\n " + "\n"
  end

  def search_field_output
    "      <div>" +
    "\n        <%= f.select 'q[0][#{name}_match]', options_for_select([['', ''], ['=', '='], " +
    "\n         ['≥', '≥'], ['>', '>'], " +
    "\n         ['≤', '≤'], ['<', '<']], @q[\'0\']['#{name}_match'] ), {} ," +
    "\n         { class: 'form-control match' } %>"+
    "\n        <%= f.text_field  'q[0][#{name}_search]',  {value: @q[\'0\'][:#{name}_search], autocomplete: 'off', size: 4, class: 'form-control', type: 'number'} %>" +
    "\n      </div>"
  end


  def where_query_statement
    ".where(\"#{name} \#{#{name}_query }\")"
  end

  def load_all_query_statement
    "#{name}_query = integer_query_constructor(@q['0'][:#{name}_match], @q['0'][:#{name}_search])"
  end

  def code_to_reset_match_if_search_is_blank
    "    @q['0'][:#{name}_match] = '' if @q['0'][:#{name}_search] == ''"
  end

end
