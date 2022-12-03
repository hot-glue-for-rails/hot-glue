module  HotGlue
  class ErbTemplate < TemplateBase

    attr_accessor :path, :singular, :singular_class,
                  :magic_buttons, :small_buttons,
                  :show_only, :column_width, :layout_strategy, :perc_width,
                  :ownership_field, :form_labels_position,
                  :inline_list_labels,
                  :columns, :column_width, :col_identifier, :singular,
                  :form_placeholder_labels, :hawk_keys



    def add_spaces_each_line(text, num_spaces)
      add_spaces = " " * num_spaces
      text.lines.collect{|line| add_spaces + line}.join("")
    end

    def magic_button_output(*args)
      path = args[0][:path]
      # path_helper_singular = args[0][:path_helper_singular]
      # path_helper_args = args[0][:path_helper_args]
      singular = args[0][:singular]
      magic_buttons = args[0][:magic_buttons]
      small_buttons = args[0][:small_buttons]

      magic_buttons.collect{ |button_name|
        "<%= form_with model: #{singular}, url: #{path}, html: {style: 'display: inline', data: {\"turbo-confirm\": 'Are you sure you want to #{button_name} this #{singular}?'}} do |f| %>
      <%= f.hidden_field :#{button_name}, value: \"#{button_name}\" %>
    <%= f.submit '#{button_name.titleize}'.html_safe, disabled: (#{singular}.respond_to?(:#{button_name}able?) && ! #{singular}.#{button_name}able? ), class: '#{singular}-button btn btn-primary #{"btn-sm" if small_buttons}' %>
    <% end %>"
      }.join("\n")
    end

    def list_column_headings(*args)
      @columns = args[0][:columns]
      @column_width = args[0][:column_width]
      @col_identifier = args[0][:col_identifier]

      col_style = @layout_strategy.column_headings_col_style

      result = columns.map{ |column|
        "<div class='#{col_identifier}'" + col_style + ">" +  column.map(&:to_s).map{|col_name| "#{col_name.humanize}"}.join("<br />")  + "</div>"
      }.join("\n")
      return result
    end


    ################################################################

    # THE FORM

    def all_form_fields(*args)
      @columns = args[0][:columns]
      @show_only = args[0][:show_only]
      @singular_class = args[0][:singular_class]
      @col_identifier = args[0][:col_identifier]
      @ownership_field  = args[0][:ownership_field]
      @form_labels_position = args[0][:form_labels_position]
      @form_placeholder_labels = args[0][:form_placeholder_labels]
      @hawk_keys = args[0][:hawk_keys]

      @singular = args[0][:singular]
      singular = @singular
      result = columns.map{ |column|
        "  <div class='#{col_identifier}' >" +
          column.map { |col|
            field_result =
              if show_only.include?(col.to_sym)
                "<%= #{singular}.#{col} %>"
              else
                type = eval("#{singular_class}.columns_hash['#{col}']").type
                limit = eval("#{singular_class}.columns_hash['#{col}']").limit
                sql_type = eval("#{singular_class}.columns_hash['#{col}']").sql_type

                case type
                when :integer
                  integer_result(col)
                when :string
                  string_result(col, sql_type, limit)
                when :text
                  text_result(col, sql_type, limit)
                when :float
                  field_output(col, nil, 5, col_identifier)
                when :datetime
                  "<%= datetime_field_localized(f, :#{col}, #{singular}.#{col}, '#{ col.to_s.humanize }', #{@auth ? @auth+'.timezone' : 'nil'}) %>"
                when :date
                  "<%= date_field_localized(f, :#{col}, #{singular}.#{col}, '#{ col.to_s.humanize  }', #{@auth ? @auth+'.timezone' : 'nil'}) %>"
                when :time
                  "<%= time_field_localized(f, :#{col}, #{singular}.#{col},  '#{ col.to_s.humanize  }', #{@auth ? @auth+'.timezone' : 'nil'}) %>"
                when :boolean
                  boolean_result(col)
                when :enum
                  enum_result(col)
                end
              end

            if (type == :integer) && col.to_s.ends_with?("_id")
              field_error_name = col.to_s.gsub("_id","")
            else
              field_error_name = col
            end

            the_label = "\n<label class='small form-text text-muted'>#{col.to_s.humanize}</label>"
            add_spaces_each_line( "\n  <span class='<%= \"alert-danger\" if #{singular}.errors.details.keys.include?(:#{field_error_name}) %>'  #{'style="display: inherit;"'}  >\n" +
                                    add_spaces_each_line( (@form_labels_position == 'before' ? the_label : "") +
                                      field_result + (@form_labels_position == 'after' ? the_label : "")   , 4) +
                                    "\n  </span>\n  <br />", 2)


          }.join("") + "\n  </div>"
      }.join("\n")
      return result
    end


    def integer_result(col)
      # look for a belongs_to on this object
      if col.to_s.ends_with?("_id")
        assoc_name = col.to_s.gsub("_id","")
        assoc = eval("#{singular_class}.reflect_on_association(:#{assoc_name})")
        if assoc.nil?
          exit_message = "*** Oops. on the #{singular_class} object, there doesn't seem to be an association called '#{assoc_name}'"
          exit
        end

        is_owner = col == ownership_field
        assoc_class_name = assoc.active_record.name
        display_column = HotGlue.derrive_reference_name(assoc_class_name)

        if @hawk_keys[assoc.foreign_key.to_sym]
          hawk_definition = @hawk_keys[assoc.foreign_key.to_sym]
          hawk_root = hawk_definition[0]
          hawk_scope = hawk_definition[1]
          hawked_association = "#{hawk_root}.#{hawk_scope}"
        else
          hawked_association = "#{assoc.class_name}.all"
        end

        (is_owner ? "<% unless @#{assoc_name} %>\n" : "") +
          "  <%= f.collection_select(:#{col}, #{hawked_association}, :id, :#{display_column}, {prompt: true, selected: @#{singular}.#{col} }, class: 'form-control') %>\n" +
          (is_owner ? "<% else %>\n <%= @#{assoc_name}.#{display_column} %>" : "") +
          (is_owner ? "\n<% end %>" : "")

      else
        "  <%= f.text_field :#{col}, value: #{@singular}.#{col}, autocomplete: 'off', size: 4, class: 'form-control', type: 'number'"  + (@form_placeholder_labels ? ", placeholder: '#{col.to_s.humanize}'" : "")  +  " %>\n " + "\n"
      end
    end

    def string_result(col, sql_type, limit)
      if sql_type == "varchar" || sql_type == "character varying"
        field_output(col, nil, limit || 40, col_identifier)
      else
        text_area_output(col, 65536, col_identifier)
      end
    end


    def text_result(col, sql_type, limit)
      if sql_type == "varchar"
        field_output(col, nil, limit, col_identifier)
      else
        text_area_output(col, 65536, col_identifier)
      end
    end

    def field_output(col, type = nil, width, col_identifier )
      "  <%= f.text_field :#{col}, value: #{@singular}.#{col}, autocomplete: 'off', size: #{width}, class: 'form-control', type: '#{type}'"  + (@form_placeholder_labels ? ", placeholder: '#{col.to_s.humanize}'" : "")  +  " %>\n " + "\n"
    end

    def text_area_output(col, field_length, col_identifier )
      lines = field_length % 40
      if lines > 5
        lines = 5
      end

      "<%= f.text_area :#{col}, class: 'form-control', autocomplete: 'off', cols: 40, rows: '#{lines}'"  + ( @form_placeholder_labels ? ", placeholder: '#{col.to_s.humanize}'" : "") + " %>"
    end

    def boolean_result(col)
      " <br />"  +
        "  <%= f.radio_button(:#{col},  '0', checked: #{singular}.#{col}  ? '' : 'checked') %>\n" +
        "  <%= f.label(:#{col}, value: 'No', for: '#{singular}_#{col}_0') %>\n" +
        "  <%= f.radio_button(:#{col}, '1',  checked: #{singular}.#{col}  ? 'checked' : '') %>\n" +
        "  <%= f.label(:#{col}, value: 'Yes', for: '#{singular}_#{col}_1') %>\n" +
        ""
    end

    def enum_result(col)
      enum_type = eval("#{singular_class}.columns.select{|x| x.name == '#{col}'}[0].sql_type")
      "<%= f.collection_select(:#{col},  enum_to_collection_select( #{singular_class}.defined_enums['#{enum_type}']), :key, :value, {selected: @#{singular}.#{col} }, class: 'form-control') %>"
    end

    ################################################################

    def paginate(*args)
      plural = args[0][:plural]

      "<% if #{plural}.respond_to?(:total_pages) %><%= paginate(#{plural}) %> <% end %>"
    end




    ################################################################


    def all_line_fields(*args)
      @columns = args[0][:columns]
      @show_only = args[0][:show_only]
      @singular_class = args[0][:singular_class]
      @singular = args[0][:singular]
      @perc_width = args[0][:perc_width]
      @col_identifier =  @layout_strategy.col_identifier_line_fields

      @inline_list_labels = args[0][:inline_list_labels] || 'omit'

      columns_count = columns.count + 1
      perc_width = (@perc_width).floor

      style_with_flex_basis = @layout_strategy.style_with_flex_basis(perc_width)

      result = columns.map{ |column|
        "<div class='#{col_identifier}'#{style_with_flex_basis}>" +


        column.map { |col|
          type = eval("#{singular_class}.columns_hash['#{col}']").type
          limit = eval("#{singular_class}.columns_hash['#{col}']").limit
          sql_type = eval("#{singular_class}.columns_hash['#{col}']").sql_type

          field_output = case type
          when :integer
            # look for a belongs_to on this object
            if col.ends_with?("_id")

              assoc_name = col.to_s.gsub("_id","")


              assoc = eval("#{singular_class}.reflect_on_association(:#{assoc_name})")

              if assoc.nil?
                exit_message =  "*** Oops. on the #{singular_class} object, there doesn't seem to be an association called '#{assoc_name}'"
                puts exit_message
                exit
                # raise(HotGlue::Error,exit_message)
              end
              assoc_class_name = assoc.active_record.name
              display_column =  HotGlue.derrive_reference_name(assoc_class_name)
              "<%= #{singular}.#{assoc.name.to_s}.try(:#{display_column}) || '<span class=\"content alert-danger\">MISSING</span>'.html_safe %>"

            else
              "<%= #{singular}.#{col}%>"
            end
          when :float
            width = (limit && limit < 40) ? limit : (40)
            "<%= #{singular}.#{col}%>"
          when :string
            width = (limit && limit < 40) ? limit : (40)
            "<%= #{singular}.#{col} %>"
          when :text
            "<%= #{singular}.#{col} %>"
          when :datetime
            "<% unless #{singular}.#{col}.nil? %>
  <%= #{singular}.#{col}.in_time_zone(current_timezone).strftime('%m/%d/%Y @ %l:%M %p ') + timezonize(current_timezone) %>
  <% else %>
  <span class='alert-danger'>MISSING</span>
  <% end %>"
          when :date
            "<% unless #{singular}.#{col}.nil? %>
      <%= #{singular}.#{col} %>
    <% else %>
    <span class='alert-danger'>MISSING</span>
    <% end %>"
          when :time
            "<% unless #{singular}.#{col}.nil? %>
      <%= #{singular}.#{col}.in_time_zone(current_timezone).strftime('%l:%M %p ') + timezonize(current_timezone) %>
     <% else %>
    <span class='alert-danger'>MISSING</span>
    <% end %>"
          when :boolean
            "
    <% if #{singular}.#{col}.nil? %>
        <span class='alert-danger'>MISSING</span>
    <% elsif #{singular}.#{col} %>
      YES
    <% else %>
      NO
    <% end %>

  "        when :enum
             enum_type = eval("#{singular_class}.columns.select{|x| x.name == '#{col}'}[0].sql_type")

                       "
    <% if #{singular}.#{col}.nil? %>
        <span class='alert-danger'>MISSING</span>
    <% else %>
      <%=  #{singular_class}.defined_enums['#{enum_type}'][#{singular}.#{col}] %>
    <% end %>

"
                         end #end of switch


          label = "<br/><label class='small form-text text-muted'>#{col.to_s.humanize}</label>"

          (inline_list_labels == 'before' ? label : "") + field_output +
            (inline_list_labels == 'after' ? label : "")
        }.join(  "<br />") + "</div>"
      }.join("\n")
    end
  end
end
