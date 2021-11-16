module  HotGlue
  class ErbTemplate < TemplateBase

    # include GeneratorHelper
    attr_accessor :singular

    def field_output(col, type = nil, width, col_identifier )
      "<div class='col form-group <%='alert-danger' if @#{singular}.errors.details.keys.include?(:#{col.to_s})%>' > \n" +
      "  <%= f.text_field :#{col.to_s}, value: @#{@singular}.#{col.to_s}, size: #{width}, class: 'form-control', type: '#{type}' %>\n "+
      "  <label class='form-text' >#{col.to_s.humanize}</label>\n" +
      "</div>"
    end


    def magic_button_output(*args)
      path_helper_singular = args[0][:path_helper_singular]
      path_helper_args = args[0][:path_helper_args]
      singular = args[0][:singular]
      magic_buttons = args[0][:magic_buttons]

      magic_buttons.collect{ |button_name|
        "<%= form_with model: #{singular}, url: #{path_helper_singular}(#{path_helper_args}) do |f| %>
      <%= f.hidden_field :#{button_name}, value: \"#{button_name}\" %>
    <%= f.submit '#{button_name.titleize}'.html_safe, data: {confirm: 'Are you sure you want to #{button_name} this #{singular}?'}, class: '#{singular}-button btn btn-primary ' %>
    <% end %>"
      }.join("\n")
    end

    def text_area_output(col, field_length, col_identifier )
      lines = field_length % 40
      if lines > 5
        lines = 5
      end

      "<div class=\"#{col_identifier} form-group \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\">" +
      "<%= f.text_area :#{col.to_s}, class: 'form-control', cols: 40, rows: '#{lines}' %>" +
        "<label class='form-text'>#{col.to_s.humanize}</label>"+
        "</div>"

    end

    def list_column_headings(*args)
      columns = args[0][:columns]

      columns.map(&:to_s).map{|col_name| "<div class='col'>#{col_name.humanize}</div>"}.join("\n")
    end


    def all_form_fields(*args)
      columns = args[0][:columns]
      show_only = args[0][:show_only]
      singular_class = args[0][:singular_class]

      # TODO: CLEAN ME
      @singular = args[0][:singular]
      singular = @singular


      col_identifier = "col"
      col_spaces_prepend = "    "

      res = columns.map { |col|

        if show_only.include?(col)

          "<div class=\"#{col_identifier} form-group <%= 'alert-danger' if #{singular}.errors.details.keys.include?(:#{col}) %>\">" +
          "<%= @#{singular}.#{col.to_s} %>" +
            "<label class='form-text'>#{col.to_s.humanize}</label>" +
          "</div>"

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
                exit_message= "*** Oops. on the #{singular_class} object, there doesn't seem to be an association called '#{assoc_name}'"
                exit
              end
              display_column = HotGlue.derrive_reference_name(assoc.class_name)

              "<div class='#{col_identifier} form-group <%= 'alert-danger' if #{singular}.errors.details.keys.include?(:#{assoc_name.to_s}) %>' >
<%= f.collection_select(:#{col.to_s}, #{assoc.class_name}.all, :id, :#{display_column}, {prompt: true, selected: @#{singular}.#{col.to_s} }, class: 'form-control') %>
<label class='small form-text text-muted'>#{col.to_s.humanize}</label></div>"

            else
              "<div class=\"#{col_identifier} form-group <%= 'alert-danger' if #{singular}.errors.details.keys.include?(:#{col}) %> \" >
<%= f.text_field :#{col.to_s}, value: #{singular}.#{col.to_s}, class: 'form-control', size: 4, type: 'number' %>
<label class='small form-text text-muted'>#{col.to_s.humanize}</label></div>"

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
            limit ||= 256
            field_output(col, nil, limit, col_identifier)


          when :datetime


            "<div class='col form-group <%='alert-danger' if @#{singular}.errors.details.keys.include?(:#{col.to_s})%>' > \n" +
"<%= datetime_field_localized(f, :#{col.to_s}, #{singular}.#{col.to_s}, '#{ col.to_s.humanize }', #{@auth ? @auth+'.timezone' : 'nil'}) %>" +
              "</div>"
          when :date
            "<div class='col form-group <%='alert-danger' if @#{singular}.errors.details.keys.include?(:#{col.to_s})%>' > \n" +
              "<%= date_field_localized(f, :#{col.to_s}, #{singular}.#{col.to_s}, '#{ col.to_s.humanize  }', #{@auth ? @auth+'.timezone' : 'nil'}) %>" +
              "</div>"
          when :time
            "<div class='col form-group <%='alert-danger' if @#{singular}.errors.details.keys.include?(:#{col.to_s})%>' > \n" +
              "<%= time_field_localized(f, :#{col.to_s}, #{singular}.#{col.to_s},  '#{ col.to_s.humanize  }', #{@auth ? @auth+'.timezone' : 'nil'}) %>" +
              "</div>"

          when :boolean
            "<div class='col form-group <%='alert-danger' if @#{singular}.errors.details.keys.include?(:#{col.to_s})%>' > \n" +
              "  <span>#{col.to_s.humanize}</span>" +
              "  <%= f.radio_button(:#{col.to_s},  '0', checked: #{singular}.#{col.to_s}  ? '' : 'checked') %>\n" +
              "  <%= f.label(:#{col.to_s}, value: 'No', for: '#{singular}_#{col.to_s}_0') %>\n" +
              "  <%= f.radio_button(:#{col.to_s}, '1',  checked: #{singular}.#{col.to_s}  ? 'checked' : '') %>\n" +
              "  <%= f.label(:#{col.to_s}, value: 'Yes', for: '#{singular}_#{col.to_s}_1') %>\n" +
            "</div>"
          when :enum
            enum_name ="enum_name"
            "<div class='#{col_identifier} form-group <%= 'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s}) %>' >
<%= f.collection_select(:#{col.to_s},  enum_to_collection_select( #{singular_class}.defined_enums['#{col.to_s}']), :key, :value, {prompt: true, selected: @#{singular}.#{col.to_s} }, class: 'form-control') %>
<label class='small form-text text-muted'>#{col.to_s.humanize}</label></div>"

          end

        end
      }.join("\n")
      return res
    end



    def paginate(*args)
      plural = args[0][:plural]

      "<% if #{plural}.respond_to?(:total_pages) %><%= paginate(#{plural}) %> <% end %>"
    end

    def all_line_fields(*args)
      columns = args[0][:columns]
      show_only = args[0][:show_only]
      singular_class = args[0][:singular_class]
      singular = args[0][:singular]

      columns_count = columns.count + 1
      perc_width = (100/columns_count).floor

      col_identifer = "col"
      columns.map { |col|
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
              exit_message =  "*** Oops. on the #{singular_class} object, there doesn't seem to be an association called '#{assoc_name}'"
              raise(HotGlue::Error,exit_message)
            end

            display_column =  HotGlue.derrive_reference_name(assoc.class_name)

            "<div class='#{col_identifer}'>
  <%= #{singular}.#{assoc.name.to_s}.try(:#{display_column}) || '<span class=\"content alert-danger\">MISSING</span>'.html_safe %>
</div>"

          else
            "<div class='#{col_identifer}'>
  <%= #{singular}.#{col}%></div>"
          end
        when :float
          width = (limit && limit < 40) ? limit : (40)
          "<div class='#{col_identifer}'>
<%= #{singular}.#{col}%></div>"
        when :string
          width = (limit && limit < 40) ? limit : (40)
          "<div class='#{col_identifer}'>
  <%= #{singular}.#{col} %>
</div>"
        when :text
          "<div class='#{col_identifer}'>
  <%= #{singular}.#{col} %>
</div>"
        when :datetime

          "<div class='#{col_identifer}'>
  <% unless #{singular}.#{col}.nil? %>
<%= #{singular}.#{col}.in_time_zone(current_timezone).strftime('%m/%d/%Y @ %l:%M %p ') + timezonize(current_timezone) %>
<% else %>
<span class='alert-danger'>MISSING</span>
<% end %>
</div>"
        when :date
          "<div class='#{col_identifer}'>
  <% unless #{singular}.#{col}.nil? %>
    <%= #{singular}.#{col} %>
  <% else %>
  <span class='alert-danger'>MISSING</span>
  <% end %>
</div>"
        when :time
          "<div class='#{col_identifer}'>
  <% unless #{singular}.#{col}.nil? %>
    <%= #{singular}.#{col}.in_time_zone(current_timezone).strftime('%l:%M %p ') + timezonize(current_timezone) %>
   <% else %>
  <span class='alert-danger'>MISSING</span>
  <% end %>
</div>
"
        when :boolean
          "<div class='#{col_identifer}'>
  <% if #{singular}.#{col}.nil? %>
      <span class='alert-danger'>MISSING</span>
  <% elsif #{singular}.#{col} %>
    YES
  <% else %>
    NO
  <% end %>
</div>
"        when :enum
                                                                                                         "<div class='#{col_identifer}'>
  <% if #{singular}.#{col}.nil? %>
      <span class='alert-danger'>MISSING</span>
  <% else %>
    <%=  #{singular}.#{col} %>
  <% end %>
</div>
"
        end #end of switch
      }.join("\n")
    end
  end




end