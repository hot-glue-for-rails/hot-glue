module  HotGlue
  class HamlTemplate < TemplateBase

    def text_area_output(col, field_length, col_identifier )
      lines = field_length % 40
      if lines > 5
        lines = 5
      end

      "#{col_identifier}{class: \"form-group \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
    = f.text_area :#{col.to_s}, class: 'form-control', cols: 40, rows: '#{lines}'
    %label.form-text
      #{col.to_s.humanize}\n"
    end


    attr_accessor :singular

    def field_output(col, type = nil, width, col_identifier )

      "#{col_identifier}{class: \"form-group \#{'alert-danger' if @#{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
    = f.text_field :#{col.to_s}, value: @#{@singular}.#{col.to_s}, size: #{width}, class: 'form-control', type: '#{type}'
    %label.form-text
      #{col.to_s.humanize}\n"
    end


    def all_form_fields(*args)

      columns = args[0][:columns]
      show_only = args[0][:show_only]
      singular_class = args[0][:singular_class]

      # TODO: CLEAN ME
      @singular = args[0][:singular]
      singular = @singular


      col_identifier = "  .col"
      col_spaces_prepend = "    "

      res = columns.map { |col|

        if show_only.include?(col)

          "#{col_identifier}{class: \"form-group \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
    = @#{singular}.#{col.to_s}
    %label.form-text
      #{col.to_s.humanize}\n"
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


              "#{col_identifier}{class: \"form-group \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{assoc_name.to_s})}\"}
#{col_spaces_prepend}= f.collection_select(:#{col.to_s}, #{assoc.class_name}.all, :id, :#{display_column}, {prompt: true, selected: @#{singular}.#{col.to_s} }, class: 'form-control')
#{col_spaces_prepend}%label.small.form-text.text-muted
#{col_spaces_prepend}  #{col.to_s.humanize}"

            else
              "#{col_identifier}{class: \"form-group \#{'alert-danger' if @#{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
#{col_spaces_prepend}= f.text_field :#{col.to_s}, value: #{singular}.#{col.to_s}, class: 'form-control', size: 4, type: 'number'
#{col_spaces_prepend}%label.form-text
#{col_spaces_prepend}  #{col.to_s.humanize}\n"
            end
          when :string
            limit ||= 256
            if limit <= 256
              field_output(col, nil, limit, col_identifier)
            else
              text_area_output(col, limit, col_identifier)
            end

          when :text
            limit ||= 256
            if limit <= 256
              field_output(col, nil, limit, col_identifier)
            else
              text_area_output(col, limit, col_identifier)
            end
          when :float
            limit ||= 256
            field_output(col, nil, limit, col_identifier)


          when :datetime
            "#{col_identifier}{class: \"form-group \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
#{col_spaces_prepend}= datetime_field_localized(f, :#{col.to_s}, #{singular}.#{col.to_s}, '#{col.to_s.humanize}', #{@auth ? @auth+'.timezone' : 'nil'})"
          when :date
            "#{col_identifier}{class: \"form-group \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
#{col_spaces_prepend}= date_field_localized(f, :#{col.to_s}, #{singular}.#{col.to_s}, '#{col.to_s.humanize}', #{@auth ? @auth+'.timezone' : 'nil'})"
          when :time
            "#{col_identifier}{class: \"form-group  \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
#{col_spaces_prepend}= time_field_localized(f, :#{col.to_s}, #{singular}.#{col.to_s}, '#{col.to_s.humanize}', #{@auth ? @auth+'.timezone' : 'nil'})"
          when :boolean
            "#{col_identifier}{class: \"form-group  \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
#{col_spaces_prepend}%span
#{col_spaces_prepend}  #{col.to_s.humanize}
#{col_spaces_prepend}= f.radio_button(:#{col.to_s},  '0', checked: #{singular}.#{col.to_s}  ? '' : 'checked')
#{col_spaces_prepend}= f.label(:#{col.to_s}, value: 'No', for: '#{singular}_#{col.to_s}_0')

#{col_spaces_prepend}= f.radio_button(:#{col.to_s}, '1',  checked: #{singular}.#{col.to_s}  ? 'checked' : '')
#{col_spaces_prepend}= f.label(:#{col.to_s}, value: 'Yes', for: '#{singular}_#{col.to_s}_1')
      "
          end
        end
      }.join("\n")
      return res
    end



    def paginate(*args)
      plural = args[0][:plural]

      "- if #{plural}.respond_to?(:total_pages)
      = paginate #{plural}"
    end

    def all_line_fields(*args)
    columns = args[0][:columns]
    show_only = args[0][:show_only]
    singular_class = args[0][:singular_class]
    singular = args[0][:singular]

    columns_count = columns.count + 1
    perc_width = (100/columns_count).floor

    col_identifer = ".col"
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


          "#{col_identifer}
  = #{singular}.#{assoc.name.to_s}.try(:#{display_column}) || '<span class=\"content alert-danger\">MISSING</span>'.html_safe"

        else
          "#{col_identifer}
  = #{singular}.#{col}"
        end
      when :float
        width = (limit && limit < 40) ? limit : (40)
        "#{col_identifer}
  = #{singular}.#{col}"

      when :string
        width = (limit && limit < 40) ? limit : (40)
        "#{col_identifer}
  = #{singular}.#{col}"
      when :text
        "#{col_identifer}
  = #{singular}.#{col}"
      when :datetime
        "#{col_identifer}
  - unless #{singular}.#{col}.nil?
    = #{singular}.#{col}.in_time_zone(current_timezone).strftime('%m/%d/%Y @ %l:%M %p ') + timezonize(current_timezone)
  - else
    %span.alert-danger
      MISSING
"
      when :date
        "#{col_identifer}
  - unless #{singular}.#{col}.nil?
    = #{singular}.#{col}
  - else
    %span.alert-danger
      MISSING
"
      when :time
        "#{col_identifer}
  - unless #{singular}.#{col}.nil?
    = #{singular}.#{col}.in_time_zone(current_timezone).strftime('%l:%M %p ') + timezonize(current_timezone)
  - else
    %span.alert-danger
      MISSING
"
      when :boolean
        "#{col_identifer}
  - if #{singular}.#{col}.nil?
    %span.alert-danger
      MISSING
  - elsif #{singular}.#{col}
    YES
  - else
    NO
"
      end #end of switch
    }.join("\n")
  end

    def list_column_headings(*args)
      columns = args[0][:columns]

      columns.map(&:to_s).map{|col_name| '      .col ' + col_name.humanize}.join("\n")
    end

  end




end