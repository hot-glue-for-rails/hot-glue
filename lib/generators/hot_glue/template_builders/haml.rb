module  HotGlue
module TemplateBuilders
  class Haml

  def all_line_fields
    columns = @columns.count + 1
    perc_width = (100/columns).floor

    col_identifer = ".col"

    @columns.map { |col|
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

          display_column =  derrive_reference_name(assoc.class_name)


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
        ".cell
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
      end
    }.join("\n")
  end
  end

end