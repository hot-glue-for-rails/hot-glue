module HotGlue
  module ControllerHelper
    def timezonize(tz)
      tz = tz.to_i
      (tz >= 0 ? "+" : "-") + sprintf('%02d',tz.abs) + ":00"
    end

    def datetime_field_localized(form_object, field_name, value, label )
      current_timezone
      form_object.text_field(field_name, class: 'form-control',
                                    type: 'datetime-local',
                                    value: date_to_current_timezone(value, current_timezone))  + timezonize(current_timezone)
    end


    def date_field_localized(form_object, field_name, value, label, timezone = nil )
      form_object.text_field(field_name, class: 'form-control',
                                    type: 'date',
                                    value: value )
    end

    def time_field_localized(form_object, field_name, value, label )
      current_timezone
      form_object.text_field(field_name, class: 'form-control',
                                    type: 'time',
                                    value: value && value.strftime("%H:%M"))

    end

    def current_timezone
      # returns a TimeZone (https://apidock.com/rails/TimeZone) object
      if defined?(current_user)
        if current_user.try(:timezone)
          Time.now.in_time_zone(current_user.timezone.to_i).zone
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
            begin
              params[k] = DateTime.strptime("#{params[k]} #{use_offset}", '%Y-%m-%dT%H:%M %z').new_offset(0)
            rescue StandardError

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

    private

    def server_timezone_offset # returns integer of hours to add/subtract from UTC
      Time.now.strftime("%z").to_i/100
    end
  end
end
