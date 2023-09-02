
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
      "  <%= f.label(:#{name}, value: '#{modify_binary? && modify[:binary][:falsy] || 'No'}', for: '#{singular}_#{name}_0') %>\n" +
      " <br /> <%= f.radio_button(:#{name}, '1',  checked: #{singular}.#{name}  ? 'checked' : '' , class: '#{@layout_strategy.form_checkbox_input_class}') %>\n" +
      "  <%= f.label(:#{name}, value: '#{modify_binary? && modify[:binary][:truthy] || 'Yes'}', for: '#{singular}_#{name}_1') %>\n"
  end

  def checkbox_display
    "<%= f.check_box(:#{name}, class: '#{@layout_strategy.form_checkbox_input_class}', id: '#{singular}_#{name}', checked: #{singular}.#{name}) %>\n"
  end

  def switch_display
    "<%= f.check_box(:#{name}, class: '#{@layout_strategy.form_checkbox_input_class}', role: 'switch', id: '#{singular}_#{name}', checked: #{singular}.#{name}) %>\n"
  end

  def form_field_display
    "<div class='#{@layout_strategy.form_checkbox_wrapper_class} #{'form-switch' if display_boolean_as == 'switch'}'>\n" +
      (if display_boolean_as == 'radio'
      radio_button_display
    elsif display_boolean_as == 'checkbox'
      checkbox_display
    elsif display_boolean_as == 'switch'
      switch_display
   end) + "</div> \n"
  end

  def form_field_output
    (form_labels_position == 'before' ?  " <br />"  : "") +
      form_field_display + (form_labels_position == 'after' ?  " <br />"  : "")
  end

  def line_field_output
    if modify_binary?
      "<% if #{singular}.#{name}.nil? %>
        <span class='alert-danger'>MISSING</span>
    <% elsif #{singular}.#{name} %>
      #{modify[:binary][:truthy]}
    <% else %>
      #{modify[:binary][:falsy]}
    <% end %>"
    else
      "<% if #{singular}.#{name}.nil? %>
        <span class='alert-danger'>MISSING</span>
    <% elsif #{singular}.#{name} %>
      YES
    <% else %>
      NO
    <% end %>"
    end
  end

  def label_class
    super + " form-check-label"
  end
end
