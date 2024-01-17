class DateTimeField < Field
  def spec_random_data
    Time.now + rand(1..5).days
  end

  def spec_setup_and_change_act(which_partial = nil)
    "      " + "new_#{name} = DateTime.current + 1.year \n" +
    '      ' + "find(\"[name='#{testing_name}[#{ name.to_s }]']\").fill_in(with: new_#{name.to_s})"

  end

  def spec_make_assertion
    if !modify_binary?
      "expect(page).to have_content(new_#{name}.in_time_zone(testing_timezone).strftime('%m/%d/%Y @ %l:%M %p %Z').gsub('  ', ' '))"
    else
      "expect(page).to have_content('#{modify_as[:binary][:truthy]}'"
    end
  end

  def spec_setup_let_arg
    "#{name}: DateTime.current + 1.day"
  end

  def spec_list_view_assertion
    if modify_binary?
      "expect(page).to have_content('#{modify_as[:binary][:truthy]}')"
    else
      spec_list_view_natural_assertion
    end
  end

  def spec_list_view_natural_assertion
    "expect(page).to have_content(#{singular}#{1}.#{name}.in_time_zone(testing_timezone).strftime('%m/%d/%Y @ %l:%M %p %Z').gsub('  ', ' '))"
  end

  def form_field_output
    "<%= datetime_field_localized(f, :#{name}, #{singular}.#{name}, label: '#{ name.to_s.humanize }' ) %>"
  end

  def viewable_output
    if modify_binary?
      modified_display_output
    else
      "<% unless #{singular}.#{name}.nil? %>
  <%= #{singular}.#{name}.in_time_zone(current_timezone).strftime('%m/%d/%Y @ %l:%M %p %Z') %>
  <% else %>
  <span class=''>MISSING</span>
  <% end %>"
    end
  end

  def search_field_output
    if !modify_binary?

      "      <div data-controller='date-range-picker' >"+
      "\n        <%= f.select 'q[0][#{name}_match]', options_for_select([['', ''], ['is on', 'is_on'], " +
      "\n         ['is between', 'is_between'], ['is on or after', 'is_on_or_after'], " +
      "\n         ['is before or on', 'is_before_or_on'], ['not on', 'not_on']], @q[\'0\']['#{name}_match'] ), {} ," +
      "\n         { class: 'form-control match', 'data-action': 'change->date-range-picker#matchSelection' } %>"+
      "\n        <%= datetime_local_field 'q[0]', '#{name}_search_start', {value: @q[\'0\'][:#{name}_search_start], autocomplete: 'off', size: 40, class: 'form-control', placeholder: 'start', 'data-date-range-picker-target': 'start' } %>" +
      "\n        <%= datetime_local_field 'q[0]', '#{name}_search_end', {value: @q[\'0\'][:#{name}_search_end], autocomplete: 'off', size: 40, class: 'form-control', placeholder: 'end' , 'data-date-range-picker-target': 'end' } %>" +
      "\n      </div>"
    else
      "  <%= f.radio_button('q[0][#{name}_match]', '-1', checked: @q[\'0\']['#{name}_match']=='-1'  ? 'checked' : '', class: '#{@layout_strategy.form_checkbox_input_class}') %>\n" +
      "  <%= f.label('All', value: '-1', for: 'q[0][#{name}_match]_-1'  ) %>\n" +
      "  <br /><%= f.radio_button('q[0][#{name}_match]', '0', checked: @q[\'0\']['#{name}_match']=='0' ? 'checked' : '', class: '#{@layout_strategy.form_checkbox_input_class}') %>\n" +
      "  <%= f.label('#{modify_as[:binary][:falsy]}', value: '0', for: 'q[0][#{name}_match]_0') %>\n" +
      "  <br /><%= f.radio_button('q[0][#{name}_match]', '1',  checked: @q[\'0\']['#{name}_match']=='1'  ? 'checked' : '' , class: '#{@layout_strategy.form_checkbox_input_class}') %>\n" +
      "  <%= f.label('#{modify_as[:binary][:truthy]}', value: '1', for: 'q[0][#{name}_match]_1') %>\n" +
        "<br />"
    end
  end


  def where_query_statement
    ".where(#{name}_query)"
  end

  def load_all_query_statement
    if !modify_binary?
      "#{name}_query = date_query_constructor(:#{name}, @q['0'][:#{name}_match], @q['0'][:#{name}_search_start], @q['0'][:#{name}_search_end])"
    else
      "#{name}_query = boolean_modified_datetime_constructor(:#{name}, @q['0'][:#{name}_match])"
    end
  end
end
