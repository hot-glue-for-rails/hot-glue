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
  
  
  def form_field_output
    (form_labels_position == 'before' ?  " <br />"  : "") +
      "  <%= f.radio_button(:#{name},  '0', checked: #{singular}.#{name}  ? '' : 'checked') %>\n" +
      "  <%= f.label(:#{name}, value: '#{modify_binary? && modify[:binary][:falsy] || 'No'}', for: '#{singular}_#{name}_0') %>\n" +
      " <br /> <%= f.radio_button(:#{name}, '1',  checked: #{singular}.#{name}  ? 'checked' : '') %>\n" +
      "  <%= f.label(:#{name}, value: '#{modify_binary? && modify[:binary][:truthy] || 'Yes'}', for: '#{singular}_#{name}_1') %>\n" +
      (form_labels_position == 'after' ?  " <br />"  : "")
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
end
