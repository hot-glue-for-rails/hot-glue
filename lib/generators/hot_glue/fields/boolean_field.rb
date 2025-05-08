
class BooleanField < Field
  def spec_setup_and_change_act(which_partial = nil)
    "      new_#{name} = 1 \n" +
    "      find(\"[name='#{testing_name}[#{name}]'][value='\#{new_" + name.to_s + "}']\").choose"
  end

  def spec_make_assertion
    ["expect(page).to have_content(#{singular}#{1}.#{name} ? 'YES' : 'NO')"].join("\n      ")
  end

  def spec_setup_let_arg
    "#{name}: !!rand(2).floor"
  end

  def spec_list_view_assertion
    ["expect(page).to have_content(#{singular}#{1}.#{name} ? 'YES' : 'NO')"].join("\n      ")
  end

  def label_for
    "#{singular}_#{name}"
  end

  def radio_button_display
    "  <%= f.radio_button(:#{name}, '0', checked: #{singular}.#{name}  ? '' : 'checked', class: '#{@layout_strategy.form_checkbox_input_class}') %>\n" +
      "  <%= f.label(:#{name}, value: '#{modify_binary? && modify_as[:binary][:falsy] || 'No'}', for: '#{singular}_#{name}_0') %>\n" +
      " <br /> <%= f.radio_button(:#{name}, '1',  checked: #{singular}.#{name}  ? 'checked' : '' , class: '#{@layout_strategy.form_checkbox_input_class}') %>\n" +
      "  <%= f.label(:#{name}, value: '#{modify_binary? && modify_as[:binary][:truthy] || 'Yes'}', for: '#{singular}_#{name}_1') %>\n"
  end

  def checkbox_display
    "<%= f.check_box(:#{name}, class: '#{@layout_strategy.form_checkbox_input_class}', id: '#{singular}_#{name}', checked: #{singular}.#{name}) %>\n"
  end

  def switch_display
    "<%= f.check_box(:#{name}, class: '#{@layout_strategy.form_checkbox_input_class}', role: 'switch', id: '#{singular}_#{name}', checked: #{singular}.#{name}) %>\n"
  end

  def form_field_display
    if display_boolean_as.nil?
      ""
    end
    "<span class='#{@layout_strategy.form_checkbox_wrapper_class} #{'form-switch' if display_boolean_as == 'switch'}'>\n" +
      (if display_boolean_as == 'radio'
         radio_button_display
       elsif display_boolean_as == 'checkbox'
         checkbox_display
       elsif display_boolean_as == 'switch'
         switch_display
       end) + "</span> \n"
  end

  def form_field_output
    form_field_display
  end

  def line_field_output
    if modify_binary?
      "<% if #{singular}.#{name}.nil? %>
        <span class=''>MISSING</span>
    <% elsif #{singular}.#{name} %>
      #{modify_as[:binary][:truthy]}
    <% else %>
      #{modify_as[:binary][:falsy]}
    <% end %>"
    else
      "<% if #{singular}.#{name}.nil? %>
        <span class=''>MISSING</span>
    <% elsif #{singular}.#{name} %>
      YES
    <% else %>
      NO
    <% end %>"
    end
  end

  def truthy_value
    modify_as[:binary][:truthy] || 'Yes'
  end

  def falsy_value
    modify_as[:binary][:falsy] || 'No'
  end

  def label_class
    super + " form-check-label"
  end



  def search_field_output
    "  <%= f.radio_button('q[0][#{name}_match]', '-1', checked: @q[\'0\'][:#{name}_match]=='-1'  ? 'checked' : '', class: '#{@layout_strategy.form_checkbox_input_class}') %>\n" +
      "  <%= f.label('All', value: '-1', for: 'q[0][#{name}_match]_-1'  ) %>\n" +
      "  <%= f.radio_button('q[0][#{name}_match]', '0', checked: @q[\'0\'][:#{name}_match]=='0' ? 'checked' : '', class: '#{@layout_strategy.form_checkbox_input_class}') %>\n" +
      "  <%= f.label('#{falsy_value}', value: '0', for: 'q[0][#{name}_match]_0') %>\n" +
      " <br /> <%= f.radio_button('q[0][#{name}_match]', '1',  checked: @q[\'0\'][:#{name}_match]=='1'  ? 'checked' : '' , class: '#{@layout_strategy.form_checkbox_input_class}') %>\n" +
      "  <%= f.label('#{truthy_value}', value: '1', for: 'q[0][#{name}_match]_1') %>\n"
  end


  def where_query_statement
    ".where(#{name}_query)"
  end

  def load_all_query_statement
    "#{name}_query = boolean_query_constructor(:#{name}, @q['0'][:#{name}_match])"
  end

  # def code_to_reset_match_if_search_is_blank
  #   "    @q['0'][:#{name}_match] = '' if @q['0'][:#{name}_search] == ''"
  # end

end
