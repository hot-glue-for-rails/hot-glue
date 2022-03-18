module HotGlue
  module ControllerHelper
    def timezonize(tz)
      tz = tz.to_i
      (tz >= 0 ? "+" : "-") + sprintf('%02d',tz.abs) + ":00"
    end

    def datetime_field_localized(form_object, field_name, value, label, timezone = nil )
      form_object.text_field(field_name, class: 'form-control',
                                    type: 'datetime-local',
                                    value: date_to_current_timezone(value, timezone))  + timezonize(timezone)
    end


    def date_field_localized(form_object, field_name, value, label, timezone = nil )
      form_object.text_field(field_name, class: 'form-control',
                                    type: 'date',
                                    value: value )
    end

    def time_field_localized(form_object, field_name, value, label, timezone = nil )
      form_object.text_field(field_name, class: 'form-control',
                                    type: 'time',
                                    value: date_to_current_timezone(value, timezone)) + timezonize(timezone)

    end

    def current_timezone
      if defined?(current_user)
        if current_user.try(:timezone)
          Time.now.in_time_zone(current_user.timezone.to_i).strftime("%z").to_i/100
        else
          server_timezone
        end
      else
        server_timezone
      end
    end

    def date_to_current_timezone(date, timezone = nil)
      # if the timezone is nil, use the server date'

      if timezone.nil?
        timezone = Time.now.strftime("%z").to_i/100
      end

      return nil if date.nil?

      return date.in_time_zone(timezone).strftime("%Y-%m-%dT%H:%M")
      # begin
      #
      # rescue
      #   return nil
      # end
    end

    def modify_date_inputs_on_params(modified_params, current_user_object = nil)

      use_timezone = (current_user_object.try(:timezone)) || Time.now.strftime("%z")

      modified_params = modified_params.tap do |params|
        params.keys.each{|k|
          if k.ends_with?("_at") || k.ends_with?("_date")

            begin
              params[k] = DateTime.strptime("#{params[k]} #{use_timezone}", '%Y-%m-%dT%H:%M %z')
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
        hawk_scope = hawk_definition[1]
        begin
          eval("hawk_root.#{hawk_scope}").find(modified_params[hawk_key.to_s])
        rescue ActiveRecord::RecordNotFound => e
          @hawk_alarm << "You aren't allowed to set #{hawk_key.to_s} to #{modified_params[hawk_key.to_s]}. "
          modified_params.tap { |hs| hs.delete(hawk_key.to_s) }
        end
      end
      modified_params
    end

    private

    def server_timezone
      Time.now.strftime("%z").to_i/100
    end
  end
end