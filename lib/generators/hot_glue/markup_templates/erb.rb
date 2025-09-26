module  HotGlue
  class ErbTemplate < TemplateBase

    attr_accessor :path, :singular, :singular_class,
                  :magic_buttons, :small_buttons,
                  :show_only, :layout_strategy, :perc_width,
                  :ownership_field, :form_labels_position,
                  :inline_list_labels, :layout_object,
                  :columns,  :col_identifier, :singular,
                  :form_placeholder_labels, :hawk_keys, :update_show_only,
                  :attachments, :show_only, :columns_map, :pundit, :related_sets,
                  :search, :search_fields, :search_query_fields, :search_position,
                  :form_path, :layout_object, :search_clear_button, :search_autosearch,
                  :stimmify, :stimmify_camel, :hidden_create, :hidden_update, :invisible_create,
                  :invisible_update, :plural, :phantom_search


    def initialize(singular:, singular_class: ,
                 layout_strategy: , magic_buttons: ,
                 small_buttons: , show_only: ,
                 ownership_field: , form_labels_position: ,
                 inline_list_labels: ,
                 form_placeholder_labels:, hawk_keys: ,
                 update_show_only:, attachments: , columns_map:, pundit:, related_sets:,
                 search:, search_fields:, search_query_fields: , search_position:,
                 search_clear_button:, search_autosearch:, layout_object:,
                 form_path: , stimmify: , stimmify_camel:, hidden_create:, hidden_update: ,
                 invisible_create:, invisible_update: , plural: , phantom_search:)


      @form_path = form_path
      @search = search
      @search_fields = search_fields
      @search_by_query = search_query_fields
      @search_position = search_position
      @layout_object = layout_object
      @stimmify = stimmify
      @stimmify_camel = stimmify_camel
      @hidden_create = hidden_create
      @hidden_update = hidden_update
      @invisible_create = invisible_create
      @invisible_update = invisible_update
      @plural = plural

      @singular = singular
      @singular_class = singular_class
      @search_clear_button = search_clear_button
      @search_autosearch = search_autosearch

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
      @related_sets = related_sets
      @phantom_search = phantom_search
    end

    def add_spaces_each_line(text, num_spaces)
      add_spaces = " " * num_spaces
      text.lines.collect{|line| add_spaces + line}.join("")
    end

    def magic_button_output(path:,
                            singular:,
                            big_edit: ,
                            magic_buttons:, small_buttons: )
      magic_buttons.collect{ |button_name|
        "<%= form_with model: #{singular}, url: #{path}, html: {style: 'display: inline', data: {\"turbo-confirm\": 'Are you sure you want to #{button_name} this #{singular}?'  " +
          (big_edit ? ", \"turbo\": false" : "") +
           "}} do |f| %>" +
          "<%= f.hidden_field :__#{button_name}, value: \"__#{button_name}\" %>" +
          "<%= f.submit '#{button_name.titleize}'.html_safe, disabled: (#{singular}.respond_to?(:#{button_name}_able?) && ! #{singular}.#{button_name}_able? ), class: '#{singular}-button #{@layout_strategy.button_applied_classes} #{@layout_strategy.magic_button_classes}' %>" +
        "<% end %>"
      }.join("\n")
    end

    def list_column_headings(column_width:, singular: )
      col_style = @layout_strategy.column_headings_col_style

      columns = layout_object[:columns][:container]
      result = columns.map.with_index{ |column,i|

        size = layout_object[:columns][:bootstrap_column_width][i]
        "<div class='#{layout_strategy.column_classes_for_column_headings(size)} hg-heading-row heading--#{singular}--#{column.join("-")}' " + col_style + ">" +
          column.map(&:to_s).map{|col_name|
            the_output = "#{col_name.humanize}"
            if invisible_update.include?(col_name.to_sym)
              if_statements = []
              if_statements << "false" if invisible_update.include?(col_name.to_sym)
              # if_statements << "@action == 'new'" if invisible_create.include?(col_name.to_sym)
              the_output = "<% if ( " +  if_statements.join(" || ") + " || policy(#{@plural}).#{col_name}_able? ) %>" +
                +  the_output + "<% end %>"

            end
            the_output
          }.join("<br />")  + "</div>"
      }.join("\n")
      return result
    end


    ################################################################
    # THE FORM
    ################################################################

    def search_input_area
      columns = layout_object[:columns][:container]

      res =+ "<\%= form_with url: #{form_path}, method: :get, html: {'data-turbo-action': 'advance', 'data-controller': 'search-form'} do |f| %>"
      res << "<div class=\"#{@layout_strategy.row_classes} search--#{@plural}\">"

      res << columns.map{ |column|
        cols_result = column.map { |col|
          if @search_fields.collect(&:to_sym).include?(col)
            label_class = columns_map[col].label_class
            label_for = columns_map[col].label_for
            the_label = "\n<label class='#{label_class}' for='search-#{label_for}'>#{col.to_s.humanize}</label>"
            search_field_result =  columns_map[col].search_field_output

            add_spaces_each_line( "\n  <span class='' >\n" +
                                add_spaces_each_line( (form_labels_position == 'before' ? the_label || "" : "") +
                                  +  " <br />\n" + search_field_result +
                                  (form_labels_position == 'after' ? the_label : "")   , 4) +
                                    "\n  </span>\n  <br />", 2)
          end
        }.compact.join("\n")



        size = layout_object[:columns][:bootstrap_column_width][columns.index(column)]
        "  <div class='#{layout_strategy.column_classes_for_form_fields(size)} search-cell--#{singular}--#{column.join("-")}' >" +
          cols_result + "</div>"

      }.join("\n")

      # phantom searches
      @phantom_search.each_key do |search_field|
        data = @phantom_search[search_field]
        res << "<div>"
        res << "<label>#{data[:name]}</label><br />"

        data[:choices].each do |choice|
          dom_label = choice[:label].downcase.gsub(" ","_")
          if data[:type] == "radio"
            res << "\n<input type='radio'
                            id='#{search_field}_search__#{dom_label}}'
                            name='q[0][#{search_field}_search]' value='#{dom_label}'
           <%= 'checked' if  @q['0'][:#{search_field}_search] == \"#{dom_label}\" %> />"
          elsif data[:type] == "checkboxes"
            res << "\n<input type='checkbox'
                            id='#{search_field}_search__#{dom_label}'
                            name='q[0][#{search_field}_search__#{dom_label}]'
                            value='1'
           <%= 'checked' if  @q['0'][:#{search_field}_search__#{dom_label}]  %> />"

          end
          res << "\n<label for='#{search_field}_search__#{dom_label}'>#{choice[:label]}</label> <br/>"
        end

        res << "</div>"

      end


      res << "</div>"
      res << "<div class='#{layout_strategy.column_classes_for_form_fields(nil)}'>"
      if @search_clear_button
        res << "<\%= f.button \"Clear\", name: nil, 'data-search-form-target': 'clearButton', class: 'btn btn-sm btn-secondary' %>"
      end
      res << "<\%= submit_tag \"Search\", name: nil, class: 'btn btn-sm btn-primary' %>"
      res << "</div><\% end %>"
      res
    end


    def all_form_fields(layout_strategy:)
      columns = layout_object[:columns][:container]

      result = columns.map{ |column|
        size  = layout_object[:columns][:bootstrap_column_width][columns.index(column)]

        "  <div class='#{layout_strategy.column_classes_for_form_fields(size)} cell--#{singular}--#{column.join("-")}' >" +
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
              elsif update_show_only.include?(col)
                "<% if @action == 'edit' %>" + columns_map[col].form_show_only_output + "<% else %>" + columns_map[col].form_field_output + "<% end %>"
              else
                columns_map[col].form_field_output
              end


            @tinymce_stimulus_controller = (columns_map[col].modify_as == {tinymce: 1} ?  "data-controller='tiny-mce' " : "")

            if @stimmify
              col_target = HotGlue.to_camel_case(col.to_s.gsub("_", " "))
              data_attr = " data-#{@stimmify}-target='#{col_target}Wrapper'"
            end


            the_output =   add_spaces_each_line( "\n  <div #{@tinymce_stimulus_controller}class='<%= \"alert alert-danger\" if #{singular}.errors.details.keys.include?(:#{field_error_name}) %>' #{data_attr} >\n" +
                                                             add_spaces_each_line( (form_labels_position == 'before' ? (the_label || "") + "<br />\n"  : "") +
                                                                                     +  field_result +
                                                                                     (form_labels_position == 'after' ? (  columns_map[col].newline_after_field? ? "<br />\n" : "") + (the_label || "") : "")  , 4) +
                                                             "\n  </div>\n ", 2)


            if hidden_create.include?(col.to_sym) || hidden_update.include?(col.to_sym)
              if_statements = []
              if_statements << "@action == 'edit'" if hidden_update.include?(col.to_sym)
              if_statements << "@action == 'new'" if hidden_create.include?(col.to_sym)

              the_output = "<% if " + if_statements.join(" || ") + " %>" +
                columns_map[col].hidden_output + "<% else %>" +  the_output + "<% end %>"
            end

            if invisible_create.include?(col) || invisible_update.include?(col)
              if_statements = []
              if_statements << "@action == 'edit'" if invisible_update.include?(col.to_sym)
              if_statements << "@action == 'new'" if invisible_create.include?(col.to_sym)

              the_output = "<% if !(" + if_statements.join(" || ") + ") || policy(@#{singular}).#{col}_able? %>" +
                +  the_output + "<% end %>"
            end



            the_output
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
                        perc_width:)

      inline_list_labels = @inline_list_labels  || 'omit'
      columns = layout_object[:columns][:container]

      columns_count = columns.count + 1
      perc_width = (perc_width).floor

      style_with_flex_basis = layout_strategy.style_with_flex_basis(perc_width)

      result = columns.map.with_index{ |column,i|

        size = layout_object[:columns][:bootstrap_column_width][i]

        "<div class='hg-col #{layout_strategy.column_classes_for_line_fields(size)} #{singular}--#{column.join("-")}'#{style_with_flex_basis}> " +
        column.map { |col|
          if eval("#{singular_class}.columns_hash['#{col}']").nil? && !attachments.keys.include?(col) && !related_sets.include?(col)
            raise "Can't find column '#{col}' on #{singular_class}, are you sure that is the column name?"
          end

          field_output = columns_map[col].line_field_output
          
          label = "<label class='small form-text text-muted'>#{col.to_s.humanize}</label>"

          the_output = "#{inline_list_labels == 'before' ? label + "<br/>" : ''}#{field_output}#{inline_list_labels == 'after' ? "<br/>" + label : ''}"
          if invisible_create.include?(col) || invisible_update.include?(col)
            if_statements = []
            if invisible_update.include?(col.to_sym) && invisible_create.include?(col.to_sym)
            # elsif invisible_create.include?(col.to_sym)
            #   if_statements << "!(@action == 'new')"
            else
              if_statements << "@action == 'edit'"
            end

            if_statements << " policy(#{singular}).#{col}_able?"
            the_output = "<% if  " +  if_statements.join(" || ") + " %>" +
              +  the_output + "<% end %>"
          end
          the_output
        }.join(  "<br />") + "</div>"
      }.join("\n")
      return result

    end
  end
end
