module  HotGlue
  class ErbTemplate < TemplateBase



    def add_spaces_each_line(text, num_spaces)
      add_spaces = " " * num_spaces
      text.lines.collect{|line| add_spaces + line}.join("")
    end


    # include GeneratorHelper
    attr_accessor :singular

    def field_output(col, type = nil, width, col_identifier )
      "  <%= f.text_field :#{col}, value: @#{@singular}.#{col}, autocomplete: 'off', size: #{width}, class: 'form-control', type: '#{type}' %>\n "+
      "\n"
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

    def text_area_output(col, field_length, col_identifier )
      lines = field_length % 40
      if lines > 5
        lines = 5
      end

      "<%= f.text_area :#{col}, class: 'form-control', autocomplete: 'off', cols: 40, rows: '#{lines}' %>"
    end

    def list_column_headings(*args)
      layout_columns = args[0][:columns]
      column_width = args[0][:column_width]
      col_identifier = args[0][:col_identifier]
      layout = args[0][:layout]

      if layout == "hotglue"
        col_style = " style='flex-basis: #{column_width}%'"
      else
        col_style = ""
      end

      result = layout_columns.map{ |column|
        "<div class='#{col_identifier}'" + col_style + ">" +  column.map(&:to_s).map{|col_name| "#{col_name.humanize}"}.join("<br />")  + "</div>"
      }.join("\n")
      return result
    end


    def all_form_fields(*args)
      layout_columns = args[0][:columns]
      show_only = args[0][:show_only]
      singular_class = args[0][:singular_class]
      col_identifier = args[0][:col_identifier]
      ownership_field  = args[0][:ownership_field]

      @singular = args[0][:singular]
      singular = @singular
      result = layout_columns.map{ |column|
        "  <div class='#{col_identifier}' >" +
          column.map { |col|
            field_result =
              if show_only.include?(col.to_sym)
                "<%= @#{singular}.#{col} %>"
              else
                type = eval("#{singular_class}.columns_hash['#{col}']").type
                limit = eval("#{singular_class}.columns_hash['#{col}']").limit
                sql_type = eval("#{singular_class}.columns_hash['#{col}']").sql_type

                case type
                when :integer
                  # look for a belongs_to on this object
                  if col.to_s.ends_with?("_id")
                    assoc_name = col.to_s.gsub("_id","")
                    assoc = eval("#{singular_class}.reflect_on_association(:#{assoc_name})")
                    if assoc.nil?
                      exit_message = "*** Oops. on the #{singular_class} object, there doesn't seem to be an association called '#{assoc_name}'"
                      exit
                    end

                    is_owner = col == ownership_field
                    display_column = HotGlue.derrive_reference_name(assoc.class_name)

                    # TODO: add is_owner && check if this nested arg is optional
                    (is_owner ? "<% unless @#{assoc_name} %>\n" : "") +
                      "  <%= f.collection_select(:#{col}, #{assoc.class_name}.all, :id, :#{display_column}, {prompt: true, selected: @#{singular}.#{col} }, class: 'form-control') %>\n" +
                      (is_owner ? "<% else %>\n <%= @#{assoc_name}.#{display_column} %>" : "") +
                      (is_owner ? "\n<% end %>" : "")

                  else
                    "<%= f.text_field :#{col}, value: #{singular}.#{col}, class: 'form-control', size: 4, type: 'number' %>"

                  end
                when :string
                  if sql_type == "varchar" || sql_type == "character varying"
                    field_output(col, nil, limit || 40, col_identifier)
                  else
                    text_area_output(col, 65536, col_identifier)
                  end

                when :text
                  if sql_type == "varchar"
                    field_output(col, nil, limit, col_identifier)
                  else
                    text_area_output(col, 65536, col_identifier)
                  end
                when :float
                  field_output(col, nil, 5, col_identifier)
                when :datetime
                  "<%= datetime_field_localized(f, :#{col}, #{singular}.#{col}, '#{ col.to_s.humanize }', #{@auth ? @auth+'.timezone' : 'nil'}) %>"
                when :date
                  "<%= date_field_localized(f, :#{col}, #{singular}.#{col}, '#{ col.to_s.humanize  }', #{@auth ? @auth+'.timezone' : 'nil'}) %>"
                when :time
                  "<%= time_field_localized(f, :#{col}, #{singular}.#{col},  '#{ col.to_s.humanize  }', #{@auth ? @auth+'.timezone' : 'nil'}) %>"
                when :boolean
                  " " +
                    "  <span>#{col.to_s.humanize}</span>" +
                    "  <%= f.radio_button(:#{col},  '0', checked: #{singular}.#{col}  ? '' : 'checked') %>\n" +
                    "  <%= f.label(:#{col}, value: 'No', for: '#{singular}_#{col}_0') %>\n" +
                    "  <%= f.radio_button(:#{col}, '1',  checked: #{singular}.#{col}  ? 'checked' : '') %>\n" +
                    "  <%= f.label(:#{col}, value: 'Yes', for: '#{singular}_#{col}_1') %>\n" +
                    ""
                when :enum
                  enum_type = eval("#{singular_class}.columns.select{|x| x.name == '#{col}'}[0].sql_type")
                  "<%= f.collection_select(:#{col},  enum_to_collection_select( #{singular_class}.defined_enums['#{enum_type}']), :key, :value, {selected: @#{singular}.#{col} }, class: 'form-control') %>"
                end

              end

            if (type == :integer) && col.to_s.ends_with?("_id")
              field_error_name = col.to_s.gsub("_id","")
            else
              field_error_name = col
            end

            add_spaces_each_line( "\n  <span class='<%= \"alert-danger\" if #{singular}.errors.details.keys.include?(:#{field_error_name}) %>'  #{ 'style="display: inherit;"'}  >\n" +
                                    add_spaces_each_line(field_result + "\n<label class='small form-text text-muted'>#{col.to_s.humanize}</label>", 4) +
                                    "\n  </span>\n  <br />", 2)

          }.join("") + "\n  </div>"
      }.join("\n")
      return result
    end



    def paginate(*args)
      plural = args[0][:plural]

      "<% if #{plural}.respond_to?(:total_pages) %><%= paginate(#{plural}) %> <% end %>"
    end

    def all_line_fields(*args)
      layout_columns = args[0][:columns]
      show_only = args[0][:show_only]
      singular_class = args[0][:singular_class]
      singular = args[0][:singular]
      perc_width = args[0][:perc_width]
      layout = args[0][:layout]
      col_identifier =   args[0][:col_identifier]  || (layout == "bootstrap" ? "col-md-2" :  "scaffold-cell")


      columns_count = layout_columns.count + 1
      perc_width = (perc_width).floor

      if layout == "bootstrap"
        style_with_flex_basis = ""
      else
        style_with_flex_basis = " style='flex-basis: #{perc_width}%'"
      end

      result = layout_columns.map{ |column|
        "<div class='#{col_identifier}'#{style_with_flex_basis}>" +


        column.map { |col|
          type = eval("#{singular_class}.columns_hash['#{col}']").type
          limit = eval("#{singular_class}.columns_hash['#{col}']").limit
          sql_type = eval("#{singular_class}.columns_hash['#{col}']").sql_type

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

              display_column =  HotGlue.derrive_reference_name(assoc.class_name)

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
        }.join("<br />") + "</div>"
      }.join("\n")
    end
  end
end