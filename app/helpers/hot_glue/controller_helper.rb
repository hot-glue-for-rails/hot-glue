module HotGlue
  module ControllerHelper
    def timezonize(tz)
      tz = tz.to_i
      (tz >= 0 ? "+" : "-") + sprintf('%02d',tz.abs) + ":00"
    end

    def datetime_field_localized(form_object, field_name, value, **args )
      current_timezone

      args = args[:options].merge({class: 'form-control',
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

      form_object.text_field(field_name,  args[:options].merge({class: 'form-control',
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

    def modify_date_inputs_on_params(modified_params, current_user_object = nil, field_list = nil)
      use_offset = (current_user_object.try(:timezone)) || server_timezone_offset

      modified_params = modified_params.tap do |params|
        params.keys.each{|k|

          if field_list.nil? # legacy pre v0.5.18 behavior
            include_me = k.ends_with?("_at") || k.ends_with?("_date")
          else
            include_me = field_list.include?(k.to_sym)
          end
          if include_me
            if use_offset != 0
              puts "changing #{params[k]}"

              if use_offset.is_a? String
                puts "parsing #{use_offset}"
                zone = DateTime.now.in_time_zone(use_offset).zone
                params[k] = DateTime.parse(params[k].gsub("T", " ") + " #{zone}")
              else
                puts "parsing #{use_offset}"
                params[k] = DateTime.strptime("#{params[k]} #{use_offset}", '%Y-%m-%dT%H:%M %z').new_offset(0)
              end
              puts "changed #{params[k]}"

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

    private

    def server_timezone_offset # returns integer of hours to add/subtract from UTC
      Time.now.in_time_zone(Rails.application.config.time_zone).strftime("%z").to_i/100
    end
  end
end
