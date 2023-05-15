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
                   form_placeholder_labels:, hawk_keys: ,
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
            field_result = show_only.include?(col.to_sym) ?
                             columns_map[col].form_show_only_output :
                             columns_map[col].form_field_output

            field_error_name = columns_map[col].field_error_name

            the_label = "\n<label class='small form-text text-muted'>#{col.to_s.humanize}</label>"
            show_only_open = ""
            show_only_close = ""

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

    ################################################################

    def paginate(*args)
      plural = args[0][:plural]

      "<% if #{plural}.respond_to?(:total_pages) %><%= paginate(#{plural}) %> <% end %>"
    end


    ################################################################
    # THE SHOW ACTION
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

                  columns_map[col].line_field_output

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

                columns_map[col].line_field_output

              when :float
                columns_map[col].line_field_output

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
    <% end %>"
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

          label = "<label class='small form-text text-muted'>#{col.to_s.humanize}</label>"

          "#{inline_list_labels == 'before' ? label + "<br/>" : ''}#{field_output}#{inline_list_labels == 'after' ? "<br/>" + label : ''}"
        }.join(  "<br />") + "</div>"
      }.join("\n")
    end
  end
end
