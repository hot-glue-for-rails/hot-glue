module HotGlue
  module ControllerHelper

    def timezonize(tz)
      tz = tz.to_i
      (tz >= 0 ? "+" : "-") + sprintf('%02d',tz.abs) + ":00"
    end


    def datetime_field_localized(form_object, field_name, value, label, timezone = nil )
      res = form_object.label(label,
                              field_name,
                              class: 'small form-text text-muted')

      res << form_object.text_field(field_name, class: 'form-control',
                                    type: 'datetime-local',
                                    value: date_to_current_timezone(value, timezone))

      res << timezonize(timezone)
      res
    end


    def date_field_localized(form_object, field_name, value, label, timezone = nil )

      res = form_object.label(label,
                              field_name,
                              class: 'small form-text text-muted')

      res << form_object.text_field(field_name, class: 'form-control',
                                    type: 'date',
                                    value: value )

      res
    end

    def time_field_localized(form_object, field_name, value, label, timezone = nil )
      res = form_object.label(label,
                              field_name,
                              class: 'small form-text text-muted')

      res << form_object.text_field(field_name, class: 'form-control',
                                    type: 'time',
                                    value: date_to_current_timezone(value, timezone))

      res << timezonize(tz)
      res
    end

    def current_timezone
      if controller.try(:current_timezone)
        controller.current_timezone
      elsif defined?(current_user)
        if current_user.try(:timezone)
          Time.now.in_time_zone(current_user.timezone.to_i).strftime("%z").to_i/100
        else
          Time.now.strftime("%z").to_i/100
        end
      else
        raise "no method current_user is available or it does not implement timezone; please implement/override the method current_timezone IN YOUR CONTROLLER"
      end
    end


    def date_to_current_timezone(date, timezone = nil)
      # if the timezone is nil, use the server date'
      if timezone.nil?
        timezone = Time.now.strftime("%z").to_i/100
      end

      return nil if date.nil?

      begin
        return date.in_time_zone(timezone).strftime("%Y-%m-%dT%H:%M")
      rescue
        return nil
      end
    end



    def modify_date_inputs_on_params(modified_params)
      use_timezone = current_account.timezone || Time.now.strftime("%z")

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
  end
end