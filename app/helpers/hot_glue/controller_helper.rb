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
          ActiveSupport::TimeZone[current_user.timezone]
        else
          Rails.application.config.time_zone
          # Time.zone.name
        end
      else
        Rails.application.config.time_zone
        # Time.zone.name
      end
    end

    def formatted_time_display(object, method, current_user)
      tz = ActiveSupport::TimeZone[current_user.timezone]

      t = object.public_send(method)

      # Build UTC datetime for today + stored time
      utc_datetime = Time.utc(
        Time.now.year,
        Time.now.month,
        Time.now.day,
        t.hour,
        t.min,
        t.sec
      )

      # Convert to user's timezone (DST-aware)
      local_time = utc_datetime.in_time_zone(tz)

      local_time.strftime('%-l:%M %p %Z')
    end

    def formatted_time_field(object, method, current_user)
      tz = ActiveSupport::TimeZone[current_user.timezone]

      t = object.public_send(method)

      # Build UTC datetime from the stored time
      utc_datetime = Time.utc(
        Time.now.year,
        Time.now.month,
        Time.now.day,
        t.hour,
        t.min,
        t.sec
      )

      # Convert to user's timezone (DST-aware)
      local_time = utc_datetime.in_time_zone(tz)

      # Format for HTML5 <input type="time"> (24h clock, HH:MM)
      local_time.strftime('%H:%M')
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

    # def modify_date_inputs_on_params(modified_params, current_user_object = nil, field_list = {})
    #
    #   use_timezone = if current_user_object.try(:timezone)
    #                    (ActiveSupport::TimeZone[current_user_object.timezone])
    #                  else
    #                    Time.zone
    #                  end
    #
    #
    #   uses_dst = (current_user_object.try(:locale_uses_dst)) || false
    #
    #   modified_params = modified_params.tap do |params|
    #     params.keys.each{|k|
    #       if field_list.is_a?(Hash)
    #         include_me = field_list[k.to_sym].present?
    #       elsif field_list.is_a?(Array)
    #         field_list.include?(k.to_sym)
    #       end
    #
    #       parsables =  {
    #         datetime: "%Y-%m-%d %H:%M %z",
    #         time: "%H:%M %z"
    #       }
    #
    #
    #       if include_me && params[k].present?
    #         input_value = params[k].gsub("T", " ") # e.g. "2025-09-24 14:00" or "14:00"
    #
    #         if field_list.is_a?(Array)
    #           # Datetime inputs (e.g. datetime-local)
    #           parsed_time = Time.strptime(input_value, "%Y-%m-%d %H:%M")
    #           parsed_time = parsed_time.utc.change(sec: 0)
    #         else
    #           case field_list[k.to_sym]
    #           when :datetime
    #             parsed_time = Time.strptime(input_value, "%Y-%m-%d %H:%M")
    #             parsed_time = parsed_time.utc.change(sec: 0)
    #           when :time
    #
    #             Rails.logger.info("input_value: #{input_value}")
    #             # Parse as hour/minute only, no zone
    #             t = Time.strptime(input_value, "%H:%M")
    #
    #             # Build a UTC time with today's date
    #             parsed_time = Time.utc(Time.now.year, Time.now.month, Time.now.day, t.hour, t.min, 0)
    #             # Convert back to a plain "time of day" (for DB `time` column)
    #             parsed_time = parsed_time.to_time.change(sec: 0)
    #             Rails.logger.info("parsed_time: #{parsed_time}")
    #
    #           else
    #             raise "Unsupported field type: #{field_list[k.to_sym]}"
    #           end
    #         end
    #
    #         Rails.logger.info "parsed_time #{parsed_time}"
    #         params[k] = parsed_time
    #       end
    #     }
    #   end
    #   modified_params
    # end

    def modify_date_inputs_on_params(modified_params, current_user_object = nil, field_list = {})
      use_timezone =
        if current_user_object.try(:timezone)
          ActiveSupport::TimeZone[current_user_object.timezone]
        else
          Time.zone
        end

      modified_params.tap do |params|
        params.keys.each do |k|
          include_me =
            if field_list.is_a?(Hash)
              field_list[k.to_sym].present?
            elsif field_list.is_a?(Array)
              field_list.include?(k.to_sym)
            end

          next unless include_me && params[k].present?

          input_value = params[k].gsub("T", " ") # "13:00" or "2025-09-24 13:00"

          case field_list[k.to_sym]
          when :datetime
            # Interpret input as in user's local time zone
            local_time = use_timezone.strptime(input_value, "%Y-%m-%d %H:%M")
            # Convert to UTC for storage
            parsed_time = local_time.utc.change(sec: 0)
          when :time
            # Parse as HH:MM (local wall clock time)
            t = Time.strptime(input_value, "%H:%M")
            # Interpret in user's timezone, with today's date
            local_time = use_timezone.local(Time.now.year, Time.now.month, Time.now.day, t.hour, t.min, 0)
            # Convert to UTC for storage
            parsed_time = local_time.utc
          else
            next
          end

          Rails.logger.info "input_value: #{input_value}"
          Rails.logger.info "parsed_time: #{parsed_time} (#{parsed_time.zone})"

          params[k] = parsed_time
        end
      end
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
