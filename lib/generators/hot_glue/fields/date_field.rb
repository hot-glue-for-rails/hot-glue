class DateField < Field
  def spec_setup_and_change_act(which_partial = nil)
    "      " + "new_#{name} = Date.current + (rand(100).days) \n" +
    '      ' + "find(\"[name='#{testing_name}[#{ name.to_s }]']\").fill_in(with: new_#{name.to_s})"
  end

  def spec_setup_let_arg
    "#{name}: Date.current + rand(50).days"
  end


  def form_field_output
    "<%= date_field_localized(f, :#{name}, #{singular}.#{name}, label:  '#{ name.to_s.humanize  }') %>"
  end

  def line_field_output
    "<% unless #{singular}.#{name}.nil? %>
      <%= #{singular}.#{name} %>
    <% else %>
      <span class=''>MISSING</span>
    <% end %>"
  end

  def search_field_output
    "      <div data-controller='date-range-picker' >"+
    "\n        <%= f.select 'q[0][#{name}_match]', options_for_select([['', ''], ['is on', 'is_on'], " +
    "\n         ['is between', 'is_between'], ['is on or after', 'is_on_or_after'], " +
    "\n         ['is before or on', 'is_before_or_on'], ['not on', 'not_on']], @q[\'0\']['#{name}_match'] ), {} ," +
    "\n         { class: 'form-control match', 'data-action': 'change->date-range-picker#matchSelection' } %>"+
    "\n        <%= date_field_localized f, 'q[0][#{name}_search_start]',  @q[\'0\'][:#{name}_search_start], autocomplete: 'off', size: 40, class: 'form-control', type: 'text', placeholder: 'start', 'data-date-range-picker-target': 'start' %>" +
    "\n        <%= date_field_localized f, 'q[0][#{name}_search_end]',  @q[\'0\'][:#{name}_search_end], autocomplete: 'off', size: 40, class: 'form-control', type: 'text', placeholder: 'end' , 'data-date-range-picker-target': 'end'%>" +
    "\n      </div>"
  end


  def where_query_statement
    ".where(*#{name}_query)"
  end

  def load_all_query_statement
    "#{name}_query = date_query_constructor(:#{name}, @q['0'][:#{name}_match], @q['0'][:#{name}_search_start], @q['0'][:#{name}_search_end])"
  end
end
