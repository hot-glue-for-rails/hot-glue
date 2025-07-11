class TimeField < Field

  def spec_setup_let_arg
    "#{name}: Time.current + rand(5000).seconds"
  end

  def form_field_output


    "<%= time_field_localized(f, :#{name}, #{singular}.#{name}&.in_time_zone(current_user.timezone)&.strftime('%H:%M'), label: '#{ name.to_s.humanize  }') %>"
  end

  def line_field_output
    "<% unless #{singular}.#{name}.nil? %>
      <%= #{singular}.#{name}.in_time_zone(current_timezone).strftime('%l:%M %p %Z') %>
     <% else %>
    <span class=''>MISSING</span>
    <% end %>"
  end

  def spec_setup_and_change_act(which_partial = nil)
    "      new_#{name} = Time.current + 5.seconds \n" +
    '      ' + "find(\"[name='#{testing_name}[#{ name.to_s }]']\").fill_in(with: new_#{name.to_s})"

  end

  def spec_make_assertion
    "expect(page).to have_content(new_#{name}.strftime('%l:%M %p').strip)"
  end

  def spec_list_view_assertion
    # "expect(page).to have_content(#{singular}#{1}.#{name})"
  end

  def search_field_output
    "      <div data-controller='time-range-picker' >"+
      "\n        <%= f.select 'q[0][#{name}_match]', options_for_select([['', ''], ['is at exactly', 'is_at_exactly']], @q[\'0\']['#{name}_match']), {} ," +
      "\n         { class: 'form-control match', 'data-action': 'change->time-range-picker#matchSelection' } %>"+
      "\n        <%= time_field_localized f, 'q[0][#{name}_search_start]',  @q[\'0\'][:#{name}_search_start], autocomplete: 'off', size: 40, class: 'form-control', type: 'text', placeholder: 'start', 'data-time-range-picker-target': 'start' %>" +
      "\n        <%= time_field_localized f, 'q[0][#{name}_search_end]',  @q[\'0\'][:#{name}_search_end], autocomplete: 'off', size: 40, class: 'form-control', type: 'text', placeholder: 'end' , 'data-time-range-picker-target': 'end' %>" +
      "\n      </div>"
  end


  def where_query_statement
    ".where(*#{name}_query)"
  end

  def load_all_query_statement
    "#{name}_query = time_query_constructor(:#{name}, @q['0'][:#{name}_match], @q['0'][:#{name}_search_start], @q['0'][:#{name}_search_end])"
  end
end
