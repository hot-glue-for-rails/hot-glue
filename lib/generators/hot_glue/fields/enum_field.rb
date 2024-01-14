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

    res = "<%= f.collection_select(:#{name},  enum_to_collection_select(#{enum_definer}), :key, :value, {selected: #{singular}.#{name} }, class: 'form-control') %>"


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
    "<% if #{singular}.#{name} %><%=  render partial: #{singular}.#{name}, locals: { #{singular}: #{singular} } %><% end %>"
  end


  def form_show_only_output
    viewable_output
  end


  def search_field_output

    # assoc_name = name.to_s.gsub("_id","")
    # assoc = eval("#{class_name}.reflect_on_association(:#{assoc_name})")
    # if modify_as && modify_as[:typeahead]
    #   search_url  = "#{namespace ? namespace + "_" : ""}#{assoc.class_name.downcase.pluralize}_typeahead_index_url"
    #   "<div class='typeahead typeahead--#{assoc.name}_id'
    #   data-controller='typeahead'
    #   data-typeahead-url-value='<%= #{search_url} %>'
    #   data-typeahead-typeahead-results-outlet='#search-results'>
    #   <%= text_field_tag :#{assoc.plural_name}_query, '', placeholder: 'Search #{assoc.plural_name}', class: 'search__input',
    #                  data: { action: 'keyup->typeahead#fetchResults keydown->typeahead#navigateResults', typeahead_target: 'query' },
    #                  autofocus: true,
    #                  autocomplete: 'off',
    #                  value: #{singular}.try(:#{assoc.name}).try(:name) %>
    #   <%= f.hidden_field :#{assoc.name}_id, value: #{singular}.try(:#{assoc.name}).try(:id), 'data-typeahead-target': 'hiddenFormValue' %>
    #   <div data-typeahead-target='results'></div>
    #   <div data-typeahead-target='classIdentifier' data-id=\"typeahead--#{assoc_name}_id\"></div>
    #   </div>"
    # else
    #   if assoc.nil?
    #     exit_message = "*** Oops. on the #{class_name} object, there doesn't seem to be an association called '#{assoc_name}'"
    #     exit
    #   end
    #
    #   is_owner = name == ownership_field
    #   assoc_class_name = assoc.class_name.to_s
    #   display_column = HotGlue.derrive_reference_name(assoc_class_name)
    #
    #   if hawk_keys[assoc.foreign_key.to_sym]
    #     hawk_definition = hawk_keys[assoc.foreign_key.to_sym]
    #     hawked_association = hawk_definition[:bind_to].join(".")
    #   else
    #     hawked_association = "#{assoc.class_name}.all"
    #   end
    #
    #   (is_owner ? "<% unless @#{assoc_name} %>\n" : "") +
    #     "  <%= f.collection_select(\"q[0][#{name}_search]\", #{hawked_association}, :id, :#{display_column}, {include_blank: true, selected: @q['0']['#{name}_search'] }, class: 'form-control') %>\n" +
    #     (is_owner ? "<% else %>\n <%= @#{assoc_name}.#{display_column} %>" : "") +
    #     (is_owner ? "\n<% end %>" : "")
    # end


    # "      "+
    #   "\n        <%= f.select 'q[0][#{name}_match]', options_for_select([['', ''], ['is on', 'is_on'], " +
    #   "\n         ['is between', 'is_between'], ['is on or after', 'is_on_or_after'], " +
    #   "\n         ['is before or on', 'is_before_or_on'], ['not on', 'not_on']], @q[\'0\']['#{name}_match'] ), {} ," +
    #   "\n         { class: 'form-control match', 'data-action': 'change->date-range-picker#matchSelection' } %>"+
    #   "\n        <%= date_field_localized f, 'q[0][#{name}_search_start]',  @q[\'0\'][:#{name}_search_start], autocomplete: 'off', size: 40, class: 'form-control', type: 'text', placeholder: 'start', 'data-date-range-picker-target': 'start' %>" +
    #   "\n        <%= date_field_localized f, 'q[0][#{name}_search_end]',  @q[\'0\'][:#{name}_search_end], autocomplete: 'off', size: 40, class: 'form-control', type: 'text', placeholder: 'end' , 'data-date-range-picker-target': 'end'%>" +
    #   "\n     "

    enum_type = eval("#{class_name}.columns.select{|x| x.name == '#{name}'}[0].sql_type")
    if eval("defined? #{class_name}.#{enum_type}_labels") == "method"
      enum_definer = "#{class_name}.#{enum_type}_labels"
    else
      enum_definer = "#{class_name}.defined_enums['#{name}']"
    end

    "<%= f.collection_select(\'q[0][#{name}_search]\', enum_to_collection_select(#{enum_definer}), :key, :value, {selected: @q['0']['#{name}_search'] }, class: 'form-control') %>"
  end


  def where_query_statement
    ".where(*#{name}_query)"
  end

  def load_all_query_statement
    "#{name}_query = enum_constructor(:#{name}, @q['0'][:#{name}_search])"
  end
end
