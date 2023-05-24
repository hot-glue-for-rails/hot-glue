class EnumField < Field
  def spec_setup_and_change_act(which_partial = nil)
    "      list_of_#{name.to_s} = #{singular_class}.defined_enums['#{name.to_s}'].keys \n" +
    "      " + "new_#{name.to_s} = list_of_#{name.to_s}[rand(list_of_#{name.to_s}.length)].to_s \n" +
    '      find("select[name=\'' + singular + '[' + name.to_s + ']\']  option[value=\'#{new_' + name.to_s + '}\']").select_option'
  end

  def spec_make_assertion
    if(eval("#{class_name}.respond_to?(:#{name}_labels)"))
      "expect(page).to have_content(#{class_name}.#{name}_labels[new_#{name}])"
    else
      "expect(page).to have_content(new_#{name})"
    end
  end

  def spec_setup_let_args
    super
  end

  def spec_list_view_assertion
    if(eval("#{class_name}.respond_to?(:#{name}_labels)"))
      "expect(page).to have_content(#{class_name}.#{name}_labels[#{singular}#{1}.#{name}])"
    else
      "expect(page).to have_content(#{singular}1.#{name})"
    end
  end

  def form_field_output
    enum_type = eval("#{class_name}.columns.select{|x| x.name == '#{name}'}[0].sql_type")

    if eval("defined? #{class_name}.#{enum_type}_labels") == "method"
      enum_definer = "#{class_name}.#{enum_type}_labels"
    else
      enum_definer = "#{class_name}.defined_enums['#{enum_type}']"
    end
    return "<%= f.collection_select(:#{name},  enum_to_collection_select(#{enum_definer}), :key, :value, {selected: #{singular}.#{name} }, class: 'form-control') %>"
  end

  def line_field_output
    enum_type = eval("#{class_name}.columns.select{|x| x.name == '#{name}'}[0].sql_type")

    if eval("defined? #{class_name}.#{enum_type}_labels") == "method"
      enum_definer = "#{class_name}.#{enum_type}_labels"
    else
      enum_definer = "#{class_name}.defined_enums['#{enum_type}']"
    end
    "
    <% if #{singular}.#{name}.nil? %>
        <span class='alert-danger'>MISSING</span>
    <% else %>
      <%=  #{enum_definer}[#{singular}.#{name}.to_sym] %>
    <% end %>
"
  end
end
