
require_relative './field.rb'

class AssociationField < Field

  attr_accessor :assoc_name, :assoc_class, :assoc, :alt_lookup

  def initialize(scaffold: , name: )
    super
    @assoc_model = eval("#{class_name}.reflect_on_association(:#{assoc})")

    if assoc_model.nil?
      exit_message = "*** Oops: The model #{class_name} is missing an association for :#{assoc_name} or the model #{assoc_name.titlecase} doesn't exist. TODO: Please implement a model for #{assoc_name.titlecase}; or add to #{class_name} `belongs_to :#{assoc_name}`.  To make a controller that can read all records, specify with --god."
      puts exit_message
      raise(HotGlue::Error, exit_message)
    end

    if ! eval("#{class_name}.reflect_on_association(:#{assoc}).polymorphic?")
      @assoc_class = eval(assoc_model.try(:class_name))

      name_list = [:name, :to_label, :full_name, :display_name, :email]

      if assoc_class && name_list.collect{ |field|
        assoc_class.respond_to?(field.to_s) || assoc_class.instance_methods.include?(field)
      }.none?
        exit_message = "Oops: Missing a label for `#{assoc_class}`. Can't find any column to use as the display label for the #{@assoc_name} association on the #{class_name} model. TODO: Please implement just one of: 1) name, 2) to_label, 3) full_name, 4) display_name 5) email. You can implement any of these directly on your`#{assoc_class}` model (can be database fields or model methods) or alias them to field you want to use as your display label. Then RERUN THIS GENERATOR. (Field used will be chosen based on rank here.)"
        raise(HotGlue::Error, exit_message)
      end
    end
  end

  def assoc_label

  end

  def assoc_name
    assoc
  end

  def assoc
    name.to_s.gsub('_id','')
  end

  def spec_setup_and_change_act(which_partial)
    if which_partial == :update_show_only && update_show_only.include?(name)

    else
      "      #{name}_selector = find(\"[name='#{singular}[#{name}]']\").click \n" +
      "      #{name}_selector.first('option', text: #{assoc}1.name).select_option"
    end
  end

  def spec_make_assertion
    " expect(page).to have_content(#{assoc}1.name)"
  end

  def spec_setup_let_arg
    "#{name.to_s.gsub('_id','')}: #{name.to_s.gsub('_id','')}1"
  end

  def spec_list_view_assertion

  end

  def spec_related_column_lets
    the_foreign_class = eval(class_name + ".reflect_on_association(:" + assoc + ")").class_name.split("::").last.underscore

    hawk_keys_on_lets = (hawk_keys["#{assoc}_id".to_sym] ? ", #{auth.gsub('current_', '')}: #{auth}": "")

    "  let!(:#{assoc}1) {create(:#{the_foreign_class}" +  hawk_keys_on_lets + ")}"
  end

  def raw_view_field
    assoc_name = name.to_s.gsub("_id","")
    assoc = eval("#{class_name}.reflect_on_association(:#{assoc_name})")
    if assoc.nil?
      exit_message = "*** Oops. on the #{singular_class} object, there doesn't seem to be an association called '#{assoc_name}'"
      exit
    end
    is_owner = name == ownership_field
    assoc_class_name = assoc.class_name.to_s
    display_column = HotGlue.derrive_reference_name(assoc_class_name)


    "<%= #{singular}.#{assoc_name}&.#{display_column} %>"
  end

  def form_field_output
    assoc_name = name.to_s.gsub("_id","")


    assoc = eval("#{class_name}.reflect_on_association(:#{assoc_name})")

    if alt_lookup.keys.include?(name)
      assoc_name = name.to_s.gsub("_id","")
      assoc = eval("#{class_name}.reflect_on_association(:#{assoc_name})")

      lookup_field = alt_lookup[name][:lookup_as]
      assoc = alt_lookup[name][:assoc].downcase
      parts = name.split('_')
      "<%= f.text_field :__lookup_#{assoc}_#{lookup_field}, value: @#{singular}.#{assoc_name}&.#{lookup_field}, placeholder: \"#{lookup_field}\" " + (stimmify ? ", 'data-#{@stimmify}-target': '#{camelcase_name}' " : "")  + "%>"
    elsif modify_as && modify_as[:typeahead]
      search_url  = "#{namespace ? namespace + "_" : ""}" +
        modify_as[:nested].join("_") + ( modify_as[:nested].any? ? "_" : "") +
        + "#{assoc.class_name.downcase.pluralize}_typeahead_index_url"


      if @modify_as[:nested].any?
        search_url  << "(" + modify_as[:nested].collect{|x| "#{x}"}.join(",") + ")"
      end

      "<div class='typeahead typeahead--#{assoc.name}_id'
      data-controller='typeahead'
      data-typeahead-url-value='<%= #{search_url} %>'
      data-typeahead-typeahead-results-outlet='#search-results'>
      <%= text_field_tag :#{assoc.plural_name}_query, '', placeholder: 'Search #{assoc.plural_name}', class: 'search__input',
                     data: { action: 'keyup->typeahead#fetchResults keydown->typeahead#navigateResults', typeahead_target: 'query' },
                     autofocus: true,
                     autocomplete: 'off',
                     value: #{singular}.try(:#{assoc.name}).try(:name) %>
      <%= f.hidden_field :#{assoc.name}_id, value: #{singular}.try(:#{assoc.name}).try(:id), 'data-typeahead-target': 'hiddenFormValue' %>
      <div data-typeahead-target='results'></div>
      <div data-typeahead-target='classIdentifier' data-id=\"typeahead--#{assoc_name}_id\"></div>
      </div>"
    else
      if assoc.nil?
        exit_message = "*** Oops. on the #{class_name} object, there doesn't seem to be an association called '#{assoc_name}'"
        exit
      end

      is_owner = name == ownership_field
      assoc_class_name = assoc.class_name.to_s
      if assoc_class
        display_column = HotGlue.derrive_reference_name(assoc_class_name)
      else
        # polymorphic
        display_column = "name"
      end

      if hawk_keys[assoc.foreign_key.to_sym]
        hawk_definition = hawk_keys[assoc.foreign_key.to_sym]
        hawked_association = hawk_definition[:bind_to].join(".")
      else
        hawked_association = "#{assoc.class_name}.all"
      end


      if @stimmify
        col_target = HotGlue.to_camel_case(name.to_s.gsub("_", " "))
        data_attr = ", data: {'#{@stimmify}-target': '#{col_target}'} "
      els
        data_attr = ""
      end



      (is_owner ? "<% unless @#{assoc_name} %>\n" : "") +
        "  <%= f.collection_select(:#{name}, #{hawked_association}, :id, :#{display_column}, { prompt: true, selected: #{singular}.#{name} }, class: 'form-control'#{data_attr}) %>\n" +
        (is_owner ? "<% else %>\n <%= @#{assoc_name}.#{display_column} %>" : "") +
        (is_owner ? "\n<% end %>" : "")
    end
  end

  def field_error_name
    assoc_name
  end

  def form_show_only_output


    # if hawk_keys[assoc.foreign_key.to_sym]
    #   hawk_definition = hawk_keys[assoc.foreign_key.to_sym]
    #   hawked_association = hawk_definition.join(".")
    # else
    #   hawked_association = "#{assoc.class_name}.all"
    # end
    if modify_as && modify_as[:none]
      "<span class='badge #{modify_as[:badges]}'>" + raw_view_field + "</span>"
    else
      raw_view_field
    end
  end

  def line_field_output


    if assoc_class
      display_column =  HotGlue.derrive_reference_name(assoc_class.to_s)
      "<%= #{singular}.#{assoc}.try(:#{display_column}) || '<span class=\"content \">MISSING</span>'.html_safe %>"
    else
      "<%= #{singular}.#{assoc}.try(:to_label) || '<span class=\"content \">MISSING</span>'.html_safe %>"
    end

  end


  def search_field_output

    assoc_name = name.to_s.gsub("_id","")
    assoc = eval("#{class_name}.reflect_on_association(:#{assoc_name})")
    if modify_as && modify_as[:typeahead]
      search_url  = "#{namespace ? namespace + "_" : ""}#{assoc.class_name.downcase.pluralize}_typeahead_index_url"

      # \"q[0][#{name}_search]\"
      # @q['0']['#{name}_search']
      "<div class='typeahead typeahead--q_0_#{name}_search'
      data-controller='typeahead'
      data-typeahead-url-value='<%= #{search_url} %>'
      data-typeahead-typeahead-results-outlet='#search-results'>
      <%= text_field_tag \'q[0][#{name}_search]_query\', '', placeholder: 'Search #{assoc.plural_name}', class: 'search__input',
                     data: { action: 'keyup->typeahead#fetchResults keydown->typeahead#navigateResults', typeahead_target: 'query' },
                     autofocus: true,
                     autocomplete: 'off',
                     value: @q['0']['#{name}'].present? ? #{assoc.class_name}.find(@q['0']['#{name}']).try(:name) : \"\"  %>
      <%= f.hidden_field \'q[0][#{name}]\', value: @q['0']['#{name}_search'].try(:id), 'data-typeahead-target': 'hiddenFormValue' %>
      <div data-typeahead-target='results'></div>
      <div data-typeahead-target='classIdentifier' data-id=\"typeahead--q_0_#{name}_search\"></div>
      </div>"
    else
      if assoc.nil?
        exit_message = "*** Oops. on the #{class_name} object, there doesn't seem to be an association called '#{assoc_name}'"
        exit
      end

      is_owner = name == ownership_field
      assoc_class_name = assoc.class_name.to_s
      display_column = HotGlue.derrive_reference_name(assoc_class_name)

      if hawk_keys[assoc.foreign_key.to_sym]
        hawk_definition = hawk_keys[assoc.foreign_key.to_sym]
        hawked_association = hawk_definition[:bind_to].join(".")
      else
        hawked_association = "#{assoc.class_name}.all"
      end

      (is_owner ? "<% unless @#{assoc_name} %>\n" : "") +
        "  <%= f.collection_select(\"q[0][#{name}_search]\", #{hawked_association}, :id, :#{display_column}, {include_blank: true, selected: @q['0']['#{name}_search'] }, class: 'form-control') %>\n" +
        (is_owner ? "<% else %>\n <%= @#{assoc_name}.#{display_column} %>" : "") +
        (is_owner ? "\n<% end %>" : "")
    end


    # "      "+
    #   "\n        <%= f.select 'q[0][#{name}_match]', options_for_select([['', ''], ['is on', 'is_on'], " +
    #   "\n         ['is between', 'is_between'], ['is on or after', 'is_on_or_after'], " +
    #   "\n         ['is before or on', 'is_before_or_on'], ['not on', 'not_on']], @q[\'0\']['#{name}_match'] ), {} ," +
    #   "\n         { class: 'form-control match', 'data-action': 'change->date-range-picker#matchSelection' } %>"+
    #   "\n        <%= date_field_localized f, 'q[0][#{name}_search_start]',  @q[\'0\'][:#{name}_search_start], autocomplete: 'off', size: 40, class: 'form-control', type: 'text', placeholder: 'start', 'data-date-range-picker-target': 'start' %>" +
    #   "\n        <%= date_field_localized f, 'q[0][#{name}_search_end]',  @q[\'0\'][:#{name}_search_end], autocomplete: 'off', size: 40, class: 'form-control', type: 'text', placeholder: 'end' , 'data-date-range-picker-target': 'end'%>" +
    #   "\n     "
  end

  def newline_after_field?
    if modify_as && modify_as[:typeahead]
      false
    else
      true
    end
  end

  def where_query_statement
    ".where(*#{name}_query)"
  end

  def load_all_query_statement
    if modify_as && modify_as[:typeahead]
      "#{name}_query = association_constructor(:#{name}, @q['0'][:#{name}])"
    else
      "#{name}_query = association_constructor(:#{name}, @q['0'][:#{name}_search])"
    end
  end

  def prelookup_syntax
    field =  @alt_lookup[name.to_s]
    if field[:with_create]

      method_name = "find_or_create_by"

    else
      method_name = "find_by"
    end
    field_name = field[:assoc].downcase.gsub("_id","")
    assoc_class = field[:assoc].classify

    assoc = plural

    ## TODO: add the hawk here
    res = +""
    if @hawk_keys[name.to_sym]
      res << "#{field_name} = #{@hawk_keys[name.to_sym][:bind_to].first}.#{assoc_name.pluralize}.#{method_name}(#{field[:lookup_as]}: #{singular}_params[:__lookup_#{field[:assoc].downcase}_#{field[:lookup_as]}] )"
    elsif @god
      assoc_name = field[:assoc]
      res << "#{field_name} = #{assoc_class}.#{method_name}(#{field[:lookup_as]}: #{singular}_params[:__lookup_#{field[:assoc].downcase}_#{field[:lookup_as]}] )"
    else
      raise "Field #{field_name} is an alt lookup in a non-Gd context which is a security vulnerability"
    end

    res << "\n    modified_params.tap { |hs| hs.delete(:__lookup_#{field[:assoc].downcase}_#{field[:lookup_as]})}"
    return res

  end
end
