module HotGlue
  module ControllerHelper
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