class Field
  attr_accessor :assoc_model, :assoc_name, :assoc_class, :associations, :alt_lookup, :auth,
                :assoc_label,  :class_name, :default_boolean_display, :display_as, :form_placeholder_labels,
                :form_labels_position,
                :hawk_keys,   :layout_strategy, :limit, :modify_as, :name, :object, :sample_file_path,
                :self_auth,
                :singular_class,  :singular, :sql_type, :ownership_field,
                :update_show_only, :namespace, :pundit, :plural,
                :stimmify, :hidden, :attachment_data


  def initialize(
    scaffold:, name:

  )
    @name = name
    @layout_strategy = scaffold.layout_strategy
    @alt_lookup = scaffold.alt_lookups
    @singular = scaffold.singular
    @class_name = scaffold.singular_class
    @update_show_only = scaffold.update_show_only
    @hawk_keys = scaffold.hawk_keys
    @auth = scaffold.auth
    @sample_file_path = scaffold.sample_file_path
    @form_placeholder_labels = scaffold.form_placeholder_labels
    @ownership_field = scaffold.ownership_field
    @form_labels_position = scaffold.form_labels_position
    @modify_as = scaffold.modify_as
    @display_as = scaffold.display_as
    @pundit = scaffold.pundit
    @plural = scaffold.plural
    @self_auth = scaffold.self_auth
    @default_boolean_display = scaffold.default_boolean_display
    @namespace = scaffold.namespace_value
    @stimmify = scaffold.stimmify
    @hidden = scaffold.hidden
    @attachment_data = scaffold.attachments[name.to_sym]


    # TODO: remove knowledge of subclasses from Field
    unless self.class == AttachmentField || self.class == RelatedSetField
      @sql_type = eval("#{class_name}.columns_hash['#{name}']").sql_type
      @limit = eval("#{class_name}.columns_hash['#{name}']").limit
    end
  end

  def getName
    @name
  end

  def form_field_output
    raise "superclass must implement"
  end

  def field_error_name
    name
  end

  def spec_random_data

  end

  def testing_name
    class_name.to_s.gsub("::","_").underscore
  end

  def spec_setup_and_change_act(which_partial = nil)
    ""
  end


  def spec_make_assertion
    if !modify_binary?
      "expect(page).to have_content(new_#{name})"
    else
      "expect(page).to have_content('#{modify_as[:binary][:truthy]}'"
    end
  end


  def spec_setup_let_arg

  end

  def spec_list_view_natural_assertion
    if !self_auth
      "expect(page).to have_content(#{singular}#{1}.#{name})"
    else
      "expect(page).to have_content(current_#{singular}.#{name})"
    end
  end

  def spec_list_view_assertion
    if modify_binary?
      "expect(page).to have_content('#{modify_as[:binary][:truthy]}'"
    else
      spec_list_view_natural_assertion
    end
  end


  def spec_related_column_lets
    ""
  end

  def line_field_output
    viewable_output
  end

  def form_show_only_output
    viewable_output
  end

  def viewable_output
    if modify_as[:modify]
      modified_display_output(show_only: true)
    else
      field_view_output
    end
  end

  def field_view_output
    if modify_as && modify_as[:none]
      "<span class='badge #{modify_as[:badges]}'>" + field_view_output + "</span>"
    else
      "<%= #{singular}.#{name} %>"
    end
  end


  def modified_display_output(show_only: false)
    res = +''

    if modify_as[:cast] && modify_as[:cast] == "$"
      if name.ends_with?("_cents")
        res += "<%= number_to_currency(#{singular}.#{name} / 100) %>"
      else
        res += "<%= number_to_currency(#{singular}.#{name}) %>"
      end
    elsif modify_as[:binary]
      res += "<%= #{singular}.#{name} ? '#{modify_as[:binary][:truthy]}' : '#{modify_as[:binary][:falsy]}' %>"
    elsif modify_as[:tinymce]

    elsif modify_as[:timezone]
      res += "<%= #{singular}.#{name} %>"
    elsif modify_as[:enum]
    elsif modify_as[:none]
        field_view_output
      # res += "<%= render partial: #{singular}.#{name}, locals: {#{singular}: #{singular}} %>"
    end


    # if modify_as[:badges]
    #   badge_code = if modify_as[:binary]
    #                  "#{singular}.#{name} ? '#{modify_as[:badges].split("|")[0]}' : '#{modify_as[:badges].split("|")[1]}'"
    #                else
    #                  modify_as[:badges].split("|").to_s + "[#{singular}.#{name}]"
    #                end
    #   res = "<span class='badge <%= #{badge_code} %>'>" + res + "</span>"
    # end
    # byebug
    res
  end

  def field_output(type = nil, width )
    if modify_as && modify_as[:timezone]
      "<%= f.time_zone_select :#{name}, ActiveSupport::TimeZone.all, {}, {class: 'form-control'} %>"
    else
      parts = name.split('_')
      camelcase_name = parts.first + parts[1..].map(&:capitalize).join
      "  <%= f.text_field :#{name}, value: #{singular}.#{name}, autocomplete: 'off', size: #{width}, class: 'form-control', type: '#{type}'"  + (form_placeholder_labels ? ", placeholder: '#{name.to_s.humanize}'" : "")  + (stimmify ? ", 'data-#{@stimmify}-target': '#{camelcase_name}' " : "")  +  " %>\n " + "\n"
    end
  end

  def hidden_output
    parts = name.split('_')
    camelcase_name = parts.first + parts[1..].map(&:capitalize).join
    "<%= f.hidden_field :#{name}, value: #{singular}.#{name} " +
      (@stimmify ? ", 'data-#{@stimmify}-target': '#{camelcase_name}' " : "") +
       " %>"
  end

  def text_area_output(field_length, extra_classes: "")
    lines = field_length % 40
    if lines > 5
      lines = 5
    end

    parts = name.split('_')
    camelcase_name = parts.first + parts[1..].map(&:capitalize).join
    "<%= f.text_area :#{name}, class: 'form-control#{extra_classes}', autocomplete: 'off', cols: 40, rows: '#{lines}'"  + ( form_placeholder_labels ? ", placeholder: '#{name.to_s.humanize}'" : "") +
      (@stimmify ? ", 'data-#{@stimmify}-target': '#{camelcase_name}' " : "") + " %>"
  end

  def modify_binary?
    !!(modify_as && modify_as[name.to_sym] && modify_as[name.to_sym][:binary])
  end

  def display_boolean_as

    if ! @default_boolean_display
      @default_boolean_display = "radio"
    end

    if  display_as[name.to_sym]
      return display_as[name.to_sym][:boolean] || "radio"
    else
      return @default_boolean_display
    end
  end

  def label_class
    "text-muted small form-text"
  end

  def label_for

  end

  def code_to_reset_match_if_search_is_blank
    nil
  end

  def newline_after_field?
    false
  end

end
