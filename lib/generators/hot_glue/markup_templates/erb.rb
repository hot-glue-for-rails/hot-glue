module  HotGlue
  class ErbTemplate < TemplateBase

    attr_accessor :path, :singular, :singular_class,
                  :magic_buttons, :small_buttons,
                  :show_only, :layout_strategy, :perc_width,
                  :ownership_field, :form_labels_position,
                  :inline_list_labels, :layout_object,
                  :columns,  :col_identifier, :singular,
                  :form_placeholder_labels, :hawk_keys, :update_show_only,
                  :alt_lookups, :attachments, :show_only, :columns_map


      def initialize(singular:, singular_class: ,
                   layout_strategy: , magic_buttons: ,
                   small_buttons: , show_only: ,
                   ownership_field: , form_labels_position: ,
                   inline_list_labels: ,
                   form_placeholder_labels:, hawk_keys:,
                   update_show_only:, alt_lookups: , attachments: , columns_map: )

      @singular = singular
      @singular_class = singular_class

      @columns_map = columns_map

      @magic_buttons = magic_buttons
      @small_buttons = small_buttons
      @layout_strategy = layout_strategy
      @show_only = show_only
      @ownership_field = ownership_field

      @form_labels_position = form_labels_position

      @inline_list_labels = inline_list_labels
      @singular = singular
      @form_placeholder_labels = form_placeholder_labels
      @hawk_keys = hawk_keys
      @update_show_only = update_show_only
      @alt_lookups = alt_lookups
      @attachments = attachments
    end

    def add_spaces_each_line(text, num_spaces)
      add_spaces = " " * num_spaces
      text.lines.collect{|line| add_spaces + line}.join("")
    end

    def magic_button_output(path:, singular:, magic_buttons:, small_buttons: )
      magic_buttons.collect{ |button_name|
        "<%= form_with model: #{singular}, url: #{path}, html: {style: 'display: inline', data: {\"turbo-confirm\": 'Are you sure you want to #{button_name} this #{singular}?'}} do |f| %>" +
          "<%= f.hidden_field :__#{button_name}, value: \"__#{button_name}\" %>" +
          "<%= f.submit '#{button_name.titleize}'.html_safe, disabled: (#{singular}.respond_to?(:#{button_name}able?) && ! #{singular}.#{button_name}able? ), class: '#{singular}-button #{@layout_strategy.button_applied_classes} #{@layout_strategy.magic_button_classes}' %>" +
        "<% end %>"
      }.join("\n")
    end

    def list_column_headings(layout_object: ,
                             col_identifier: ,
                             column_width:, singular: )
      col_style = @layout_strategy.column_headings_col_style

      columns = layout_object[:columns][:container]
      result = columns.map{ |column|
        "<div class='#{col_identifier} heading--#{singular}--#{column.join("-")}' " + col_style + ">" +
          column.map(&:to_s).map{|col_name| "#{col_name.humanize}"}.join("<br />")  + "</div>"
      }.join("\n")
      return result
    end


    ################################################################
    # THE FORM
    ################################################################


    def all_form_fields(layout_strategy:, layout_object: )
      column_classes = layout_strategy.column_classes_for_form_fields
      columns = layout_object[:columns][:container]

      result = columns.map{ |column|
        "  <div class='#{column_classes} cell--#{singular}--#{column.join("-")}' >" +
          column.map { |col|

            # field_result = show_only.include?(col.to_sym) ?
            #                  columns_map[col].form_show_only_output :
            #                  columns_map[col].form_field_output

            if attachments.keys.include?(col)
              field_result = columns_map[col].form_field_output
            else
              type = eval("#{singular_class}.columns_hash['#{col}']").type
              limit = eval("#{singular_class}.columns_hash['#{col}']").limit
              sql_type = eval("#{singular_class}.columns_hash['#{col}']").sql_type

              field_result =
                if show_only.include?(col.to_sym)

                  # field_result = columns_map[col].form_show_only_output
                  #
                  show_only_result(type: type, col: col, singular: singular)
                else
                  case type
                  when :integer
                    columns_map[col].form_field_output
                  when :uuid
                    association_result(col)
                  when :string
                    string_result(col, sql_type, limit)
                  when :text
                    text_result(col, sql_type, limit)
                  when :float
                    field_output(col, nil, 5, column_classes)
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
            end

            field_error_name = columns_map[col].field_error_name
            the_label = "\n<label class='small form-text text-muted'>#{col.to_s.humanize}</label>"
            show_only_open = ""
            show_only_close = ""

            byebug if columns_map[col].nil?

            if update_show_only.include?(col)
              show_only_open = "<% if action_name == 'edit' %>" +
                show_only_result(type: type, col: col, singular: singular) + "<% else %>"
              show_only_close = "<% end %>"
            end


            add_spaces_each_line( "\n  <span class='<%= \"alert-danger\" if #{singular}.errors.details.keys.include?(:#{field_error_name}) %>'  #{'style="display: inherit;"'}  >\n" +
                                    add_spaces_each_line( (form_labels_position == 'before' ? the_label : "") +
                                                            show_only_open + field_result + show_only_close +
                                                            (form_labels_position == 'after' ? the_label : "")   , 4) +
                                    "\n  </span>\n  <br />", 2)

          }.join("") + "\n  </div>"
      }.join("\n")
      return result
    end


    def show_only_result(type:, col: , singular: )
      if type == :uuid || (type == :integer && col.ends_with?("_id"))
        association_read_only_result(col)
      else
        "<%= #{singular}.#{col} %>"
      end
    end



    def association_read_only_result(col)
      assoc_name = col.to_s.gsub("_id","")
      assoc = eval("#{singular_class}.reflect_on_association(:#{assoc_name})")
      if assoc.nil?
        exit_message = "*** Oops. on the #{singular_class} object, there doesn't seem to be an association called '#{assoc_name}'"
        exit
      end

      is_owner = col == ownership_field
      assoc_class_name = assoc.class_name.to_s
      display_column = HotGlue.derrive_reference_name(assoc_class_name)

      if @hawk_keys[assoc.foreign_key.to_sym]
        hawk_definition = @hawk_keys[assoc.foreign_key.to_sym]
        hawked_association = hawk_definition.join(".")
      else
        hawked_association = "#{assoc.class_name}.all"
      end
      "<%= #{@singular}.#{assoc_name}.#{display_column} %>"
    end

    def association_result(col)

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
      (form_labels_position == 'before' ?  " <br />"  : "") +
        "  <%= f.radio_button(:#{col},  '0', checked: #{singular}.#{col}  ? '' : 'checked') %>\n" +
        "  <%= f.label(:#{col}, value: 'No', for: '#{singular}_#{col}_0') %>\n" +
        "  <%= f.radio_button(:#{col}, '1',  checked: #{singular}.#{col}  ? 'checked' : '') %>\n" +
        "  <%= f.label(:#{col}, value: 'Yes', for: '#{singular}_#{col}_1') %>\n" +
      (form_labels_position == 'after' ?  " <br />"  : "")

    end

    def enum_result(col)
      enum_type = eval("#{singular_class}.columns.select{|x| x.name == '#{col}'}[0].sql_type")

      if eval("defined? #{singular_class}.#{enum_type}_labels") == "method"
        enum_definer = "#{singular_class}.#{enum_type}_labels"
      else
        enum_definer = "#{singular_class}.defined_enums['#{enum_type}']"
      end

      "<%= f.collection_select(:#{col},  enum_to_collection_select(#{enum_definer}), :key, :value, {selected: @#{singular}.#{col} }, class: 'form-control') %>"
    end

    ################################################################

    def paginate(*args)
      plural = args[0][:plural]

      "<% if #{plural}.respond_to?(:total_pages) %><%= paginate(#{plural}) %> <% end %>"
    end




    ################################################################


    def all_line_fields(layout_strategy:,
                        layout_object: ,
                        perc_width:,
                        col_identifier: nil)

      @col_identifier =  layout_strategy.column_classes_for_line_fields

      inline_list_labels = @inline_list_labels  || 'omit'
      columns = layout_object[:columns][:container]

      columns_count = columns.count + 1
      perc_width = (perc_width).floor

      style_with_flex_basis = layout_strategy.style_with_flex_basis(perc_width)

      result = columns.map{ |column|

        "<div class='#{col_identifier} #{singular}--#{column.join("-")}'#{style_with_flex_basis}> " +
        column.map { |col|
          if eval("#{singular_class}.columns_hash['#{col}']").nil? && !attachments.keys.include?(col)
            raise "Can't find column '#{col}' on #{singular_class}, are you sure that is the column name?"
          end

          if attachments.keys.include?(col)
            this_attachment  = attachments[col]
            thumbnail = this_attachment[:thumbnail]

            field_output =  (this_attachment[:thumbnail] ? "<%= #{singular}.#{col}.attached? ? image_tag(#{singular}.#{col}.variant(:#{thumbnail})) : '' %>" : "")

          else
            type = eval("#{singular_class}.columns_hash['#{col}']").type
            limit = eval("#{singular_class}.columns_hash['#{col}']").limit
            sql_type = eval("#{singular_class}.columns_hash['#{col}']").sql_type

            field_output =
              case type
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
                  assoc_class_name = assoc.class_name

                  display_column =  HotGlue.derrive_reference_name(assoc_class_name)
                  "<%= #{singular}.#{assoc.name.to_s}.try(:#{display_column}) || '<span class=\"content alert-danger\">MISSING</span>'.html_safe %>"

                else
                  "<%= #{singular}.#{col}%>"
                end

              when :uuid
                assoc_name = col.to_s.gsub("_id","")
                assoc = eval("#{singular_class}.reflect_on_association(:#{assoc_name})")

                if assoc.nil?
                  exit_message =  "*** Oops. on the #{singular_class} object, there doesn't seem to be an association called '#{assoc_name}'"
                  puts exit_message
                  exit
                  # raise(HotGlue::Error,exit_message)
                end

                display_column =  HotGlue.derrive_reference_name(assoc.class_name.to_s)
                "<%= #{singular}.#{assoc.name.to_s}.try(:#{display_column}) || '<span class=\"content alert-danger\">MISSING</span>'.html_safe %>"

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

  "
              when :enum
                enum_type = eval("#{singular_class}.columns.select{|x| x.name == '#{col}'}[0].sql_type")

                if eval("defined? #{singular_class}.#{enum_type}_labels") == "method"
                  enum_definer = "#{singular_class}.#{enum_type}_labels"
                else
                  enum_definer = "#{singular_class}.defined_enums['#{enum_type}']"
                end
                "
    <% if #{singular}.#{col}.nil? %>
        <span class='alert-danger'>MISSING</span>
    <% else %>
      <%=  #{enum_definer}[#{singular}.#{col}.to_sym] %>
    <% end %>

"
              end #end of switch
          end

          label = "<br/><label class='small form-text text-muted'>#{col.to_s.humanize}</label>"

          (inline_list_labels == 'before' ? label : "") + field_output +
            (inline_list_labels == 'after' ? label : "")
        }.join(  "<br />") + "</div>"
      }.join("\n")
    end
  end
end
