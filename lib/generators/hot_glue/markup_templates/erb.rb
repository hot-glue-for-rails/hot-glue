module  HotGlue
  class ErbTemplate < TemplateBase

    attr_accessor :path, :singular, :singular_class,
                  :magic_buttons, :small_buttons,
                  :show_only, :layout_strategy, :perc_width,
                  :ownership_field, :form_labels_position,
                  :inline_list_labels, :layout_object,
                  :columns,  :col_identifier, :singular,
                  :form_placeholder_labels, :hawk_keys, :update_show_only,
                  :attachments, :show_only, :columns_map, :pundit


      def initialize(singular:, singular_class: ,
                   layout_strategy: , magic_buttons: ,
                   small_buttons: , show_only: ,
                   ownership_field: , form_labels_position: ,
                   inline_list_labels: ,
                   form_placeholder_labels:, hawk_keys: ,
                   update_show_only:, attachments: , columns_map:, pundit: )

      @singular = singular
      @singular_class = singular_class

      @columns_map = columns_map

      @magic_buttons = magic_buttons
      @small_buttons = small_buttons
      @layout_strategy = layout_strategy
      @show_only = show_only
      @pundit = pundit
      @ownership_field = ownership_field

      @form_labels_position = form_labels_position

      @inline_list_labels = inline_list_labels
      @singular = singular
      @form_placeholder_labels = form_placeholder_labels
      @hawk_keys = hawk_keys
      @update_show_only = update_show_only
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

            field_error_name = columns_map[col].field_error_name

            label_class = columns_map[col].label_class
            label_for = columns_map[col].label_for

            the_label = "\n<label class='#{label_class}' for='#{label_for}'>#{col.to_s.humanize}</label>"


            field_result =
              if show_only.include?(col)
                columns_map[col].form_show_only_output
              elsif update_show_only.include?(col) && !@pundit
                "<% if @action == 'edit' %>" + columns_map[col].form_show_only_output + "<% else %>" + columns_map[col].form_field_output + "<% end %>"
              elsif update_show_only.include?(col) && @pundit && eval("defined? #{singular_class}Policy") && eval("#{singular_class}Policy").instance_methods.include?("#{col}_able?".to_sym)
                "<% if @action == 'new' && policy(@#{singular}).#{col}_able? %>" + columns_map[col].form_field_output + "<% else %>" + columns_map[col].form_show_only_output + "<% end %>"

                             # show only on the update action overrides any pundit policy
            elsif @pundit && eval("defined? #{singular_class}Policy") && eval("#{singular_class}Policy").instance_methods.include?("#{col}_able?".to_sym)
              "<% if policy(@#{singular}).#{col}_able? %>" + columns_map[col].form_field_output + "<% else %>" + columns_map[col].form_show_only_output  + "<% end %>"
            else
              columns_map[col].form_field_output
            end
            # byebug
            @tinymce_stimulus_controller = (columns_map[col].modify_as == {tinymce: 1} ?  "data-controller='tiny-mce' " : "")

            add_spaces_each_line( "\n  <span #{@tinymce_stimulus_controller}class='<%= \"alert alert-danger\" if #{singular}.errors.details.keys.include?(:#{field_error_name}) %>'  #{'style="display: inherit;"'}  >\n" +
                                    add_spaces_each_line( (form_labels_position == 'before' ? the_label || "" : "") +
                                                        +  " <br />\n" + field_result +
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
          field_output = columns_map[col].line_field_output
          
          label = "<label class='small form-text text-muted'>#{col.to_s.humanize}</label>"

          "#{inline_list_labels == 'before' ? label + "<br/>" : ''}#{field_output}#{inline_list_labels == 'after' ? "<br/>" + label : ''}"
        }.join(  "<br />") + "</div>"
      }.join("\n")
    end
  end
end
