module HotGlue
  module ControllerHelper
    def timezonize(tz)
      tz = tz.to_i
      (tz >= 0 ? "+" : "-") + sprintf('%02d',tz.abs) + ":00"
    end

    def datetime_field_localized(form_object, field_name, value, **args )
      current_timezone

      args = args.merge({class: 'form-control',
                         type: 'datetime-local' })

      if !value.nil?
        args[:value] = date_to_current_timezone(value, current_timezone) + timezonize(current_timezone)
      end

      form_object.text_field(field_name, args)

    end


    def date_field_localized(form_object, field_name, value, **args)

      form_object.text_field(field_name,  args.merge({class: 'form-control',
                                                      type: 'date',
                                                      value: value }))
    end

    def time_field_localized(form_object, field_name, value, **args )
      current_timezone

      form_object.text_field(field_name,  args.merge({class: 'form-control',
                                                      type: 'time',
                                                      value: value }))

    end






    def current_timezone
      # returns a TimeZone (https://apidock.com/rails/TimeZone) object
      if defined?(current_user)
        if current_user.try(:timezone)
          current_user.timezone

          # Time.now.in_time_zone(current_user.timezone.to_i).zone
        else
          Rails.application.config.time_zone
          # Time.zone.name
        end
      else
        Rails.application.config.time_zone
        # Time.zone.name
      end
    end

    def date_to_current_timezone(date, timezone = nil)
      # used for displaying when in EDIT  mode
      # (this format is how the browser expectes to receive the value='' of the input field)
      if date.nil?
        return nil
      else
        return date.in_time_zone(timezone).strftime("%Y-%m-%dT%H:%M")
      end
    end

    def is_dst_now?
      ActiveSupport::TimeZone['Eastern Time (US & Canada)'].now.dst?
    end

    def format_timezone_offset(hour, minute)
      sign = hour < 0 ? "-" : "+"
      hour_abs = hour.abs.to_s.rjust(2, '0')
      minute_str = minute.to_s.rjust(2, '0')
      "#{sign}#{hour_abs}#{minute_str}"
    end

    def modify_date_inputs_on_params(modified_params, current_user_object = nil, field_list = {})

      use_timezone = if current_user_object.try(:timezone)
                       (ActiveSupport::TimeZone[current_user_object.timezone])
                     else
                       Time.zone
                     end


      uses_dst = (current_user_object.try(:locale_uses_dst)) || false

      modified_params = modified_params.tap do |params|
        params.keys.each{|k|
          if field_list.is_a?(Hash)
            include_me = field_list[k.to_sym].present?
          elsif field_list.is_a?(Array)
            field_list.include?(k.to_sym)
          end

          parsables =  {
            datetime: "%Y-%m-%d %H:%M %z",
            time: "%H:%M %z"
          }


          if include_me && params[k].present?
            if use_timezone
              natural_offset = use_timezone.formatted_offset
              hour = natural_offset.split(":").first.to_i
              min  = natural_offset.split(":").last.to_i

              hour = hour + 1 if uses_dst && is_dst_now?

              use_offset = format_timezone_offset(hour, min)
              parse_date = "#{params[k].gsub("T", " ")} #{use_offset}"


              Rails.logger.info("use_offset: #{use_offset}")

              Rails.logger.info("parse_date: #{parse_date}")

              # note: as according to https://stackoverflow.com/questions/20111413/html5-datetime-local-control-how-to-hide-seconds
              # there is no way to set the seconds to 00 in the datetime-local input field
              # as I have implemented a "seconds don't matter" solution,
              # the only solution is to avoid setting any non-00 datetime values into the database
              # if they already exist in your database, you should zero them out
              # or apply .change(sec: 0) when displaying them as output in the form
              # this will prevent seconds from being added by the browser
              if  field_list.is_a?(Array)
                parsed_time = Time.strptime(parse_date, "%Y-%m-%d %H:%M %z")
              else
                parsed_time = Time.strptime(parse_date, parsables[field_list[k.to_sym]])
              end
              Rails.logger.info "parsed_time #{parsed_time}"
              Rails.logger.info "Timezone: #{use_timezone.name}"
              Rails.logger.info "Offset: #{use_timezone.formatted_offset}"
              Rails.logger.info "DST? #{uses_dst} | is_dst_now? => #{is_dst_now?}"
              Rails.logger.info "Final offset used: #{use_offset}"

              params[k] = parsed_time
            end
          end
        }
      end
      modified_params
    end

    def hawk_params(hawk_schema, modified_params)
      @hawk_alarm = ""
      hawk_schema.each do |hawk_key,hawk_definition|
        hawk_root = hawk_definition[0]
        # hawk_scope = hawk_definition[1]

        unless modified_params[hawk_key.to_s].blank?
          begin
            eval("hawk_root").find(modified_params[hawk_key.to_s])
          rescue ActiveRecord::RecordNotFound => e
            @hawk_alarm << "You aren't allowed to set #{hawk_key.to_s} to #{modified_params[hawk_key.to_s]}. "
            modified_params.tap { |hs| hs.delete(hawk_key.to_s) }
          end
        end
      end
      modified_params
    end

    def string_query_constructor(match, search)
      if match.blank? || search.blank?
        nil
      else
        case match
        when 'contains'
          "%#{search}%"
        when 'is_exactly'
          "#{search}"
        when 'starts_with'
          "#{search}%"
        when 'ends_with'
          "%#{search}"
        else
          nil
        end
      end
    end

    def integer_query_constructor(match, search)
      if match.blank? || search.blank?
        nil
      else
        case match
        when '='
          "= #{search.to_i}"
        when '≥'
          ">= #{search.to_i}"
        when '>'
          "> #{search.to_i}"
        when '≤'
          "<= #{search.to_i}"
        when '<'
          "< #{search.to_i}"
        else
          nil
        end
      end
    end

    def enum_constructor(field_name, value, **args)
      return nil if value.blank?
      ["#{field_name} = ?", value]
    end


    def date_query_constructor(field, match, search_start, search_end)
      if match.blank?
        nil
      elsif ['is_on', 'not_on'].include?(match) && search_start.blank?
        nil
      elsif ['is_on_or_after','is_between'].include?(match) && (search_start.blank? )
        nil
      elsif ['is_before_or_on'].include?(match) && (search_end.blank? )
        nil
      elsif ['is_between'].include?(match) && (search_start.blank? || search_end.blank? )
        nil
      else
        case match
        when 'is_on'
          ["#{field} = ?", search_start]
        when 'is_on_or_after'
          ["#{field} = ? OR #{field} > ?", search_start, search_start]
        when "is_before_or_on"
          ["#{field} = ? OR #{field} < ?", search_end, search_end]
        when "is_between"
          ["#{field} BETWEEN ? AND ?", search_start, search_end]
        when "not_on"
          ["#{field} != ?", search_start]
        end
      end
    end

    def time_query_constructor(field, match, search_start, search_end)
      if match.blank?
        nil
      elsif ['is_at'].include?(match) && search_start.blank?
        nil
      elsif ['is_ar_or_after', 'is_before_or_at', 'is_between'].include?(match) && (search_start.blank? || search_end.blank?)
        nil
      else
        case match
        when 'is_at_exactly'
          ["EXTRACT(HOUR FROM #{field}) = ?
          AND EXTRACT(MINUTE FROM #{field}) = ? ", search_start.split(":")[0], search_start.split(":")[1]]
          # when 'is_at_or_after'
          #   ["#{field} = ? OR #{field} > ?", search_start, search_start]
          # when "is_before_or_at"
          #   ["#{field} = ? OR #{field} < ?", search_end, search_end]
          # when "is_between"
          #   ["#{field} BETWEEN ? AND ?", search_start, search_end]
        end
      end
    end

    def association_constructor(field, search)
      unless search.blank?
        ["#{field} = ?", search]
      else
        nil
      end
    end

    def boolean_query_constructor(field, search)
      unless search == "-1"
        ["#{field} IS #{search ? 'TRUE' : 'FALSE'}"]
      else
        nil
      end
    end

    def boolean_modified_datetime_constructor(field,search)
      unless search == '-1'
        ["#{field} #{search == '0' ? 'IS NULL' : 'IS NOT NULL'}"]
      else
        nil
      end
    end

    private

  end
end
