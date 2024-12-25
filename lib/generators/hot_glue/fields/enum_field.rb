class EnumField < Field
  def spec_setup_and_change_act(which_partial = nil)
    # what is the enum name
    "      list_of_#{enum_type} = #{class_name}.defined_enums['#{name}'].keys \n" +
      "      " + "new_#{name} = list_of_#{enum_type}[rand(list_of_#{enum_type}.length)].to_s \n" +
      '      find("select[name=\'' + singular + '[' + name + ']\']  option[value=\'#{new_' + name + '}\']").select_option'
  end

  def enum_type
    eval("#{class_name}.columns.select{|x| x.name == '#{name}'}[0].sql_type")
  end

  def spec_make_assertion
    if(eval("#{class_name}.respond_to?(:#{name}_labels)"))
      "expect(page).to have_content(#{singular_class}.#{name}_labels[new_#{name}])"
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
      enum_definer = "#{class_name}.defined_enums['#{name}']"
    end

    res = "<%= f.collection_select(:#{name},  enum_to_collection_select(#{enum_definer}), :key, :value, {include_blank: true, selected: #{singular}.#{name} }, class: 'form-control') %>"


    if modify_as && modify_as[:enum] == :partials
      res << partial_render
    end
    res
  end

  def line_field_output
    enum_type = eval("#{class_name}.columns.select{|x| x.name == '#{name}'}[0].sql_type")

    if eval("defined? #{class_name}.#{enum_type}_labels") == "method"
      enum_definer = "#{class_name}.#{enum_type}_labels"
    else
      enum_definer = "#{class_name}.defined_enums['#{name}']"
    end

    res = "
    <% if #{singular}.#{name}.nil? %>
        <span class='alert-danger'>Missing #{name}</span>
    <% else %>"

    if modify_as && modify_as[:enum] == :partials
      res << partial_render
    else
      res << "<%=  #{enum_definer}[#{singular}.#{name}.to_sym] %>"
    end

    res << "<% end %>"
    res
  end

  def partial_render
    "<% if #{singular}.#{name} %><%=  render partial: \"#{namespace + "/" if namespace}#{plural}/\#{#{singular}.#{name}}\", locals: { #{singular}: #{singular} } %><% end %>"
  end


  def form_show_only_output
    viewable_output
  end


  def search_field_output
    enum_type = eval("#{class_name}.columns.select{|x| x.name == '#{name}'}[0].sql_type")
    if eval("defined? #{class_name}.#{enum_type}_labels") == "method"
      enum_definer = "#{class_name}.#{enum_type}_labels"
    else
      enum_definer = "#{class_name}.defined_enums['#{name}']"
    end

    "<%= f.collection_select(\'q[0][#{name}_search]\', enum_to_collection_select(#{enum_definer}), :key, :value, {include_blank: true, selected: @q['0']['#{name}_search'] }, class: 'form-control') %>"
  end


  def where_query_statement
    ".where(*#{name}_query)"
  end

  def load_all_query_statement
    "#{name}_query = enum_constructor(:#{name}, @q['0'][:#{name}_search])"
  end
end
