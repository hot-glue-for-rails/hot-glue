class FloatField < Field
  def spec_setup_and_change_act(which_partial = nil)
    "      " + "new_#{name} = rand(10) \n" +
    "      find(\"[name='#{testing_name}[#{ name.to_s }]']\").fill_in(with: new_#{name.to_s})"

  end


  def spec_setup_let_arg
    "#{name}: rand(1)*10000"
  end

  def form_field_output
    field_output(nil, 5)
  end

  # def line_field_output
  #   width = (limit && limit < 40) ? limit : (40)
  #
  #   "<%= #{singular}.#{name} %>"
  # end

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
end
