module HotGlue
  module ControllerHelper

    def timezonize(tz)
      tz = tz.to_i
      (tz >= 0 ? "+" : "-") + sprintf('%02d',tz.abs) + ":00"
    end


    def datetime_field_localized(form_object, field_name, value, label, timezone = nil )
        form_object.text_field(field_name, class: 'form-control',
                                    type: 'datetime-local',
                                    value: date_to_current_timezone(value, timezone))
        + timezonize(timezone)
    end


    def date_field_localized(form_object, field_name, value, label, timezone = nil )
      form_object.text_field(field_name, class: 'form-control',
                                    type: 'date',
                                    value: value )
    end

    def time_field_localized(form_object, field_name, value, label, timezone = nil )
      form_object.text_field(field_name, class: 'form-control',
                                    type: 'time',
                                    value: date_to_current_timezone(value, timezone))
      + timezonize(timezone)

    end

    def current_timezone
      if defined?(current_user)
        if current_user.try(:timezone)
          Time.now.in_time_zone(current_user.timezone.to_i).strftime("%z").to_i/100
        else
          server_timezone
        end
      elsif true
        server_timezone
      # elsif defined?(controller) == "method"
      #   # controller.try(:current_timezone)
      # elsif self.class.ancestors.include?(ApplicationController)
      #   self.try(:current_timezone)
      else
        puts "no method current_user is available; please implement/override the method current_timezone IN YOUR CONTROLLER"
        exit
      end
    end

    def server_timezone
      Time.now.strftime("%z").to_i/100
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
  end
end