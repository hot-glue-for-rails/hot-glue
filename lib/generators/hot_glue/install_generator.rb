require 'rails/generators/erb/scaffold/scaffold_generator'
require 'ffaker'

module HotGlue
  class InstallGenerator < Rails::Generators::Base
    hook_for :form_builder, :as => :scaffold
    class_option :markup, type: :string, default: "erb"

    source_root File.expand_path('templates', __dir__)


    def initialize(*args) #:nodoc:
      super
      @markup = options['markup']
      if @markup == "haml"
        copy_file "haml/_flash_notices.haml", "#{'spec/dummy/' if Rails.env.test?}app/views/layouts/_flash_notices.haml"
      elsif @markup == "erb"
        copy_file "erb/_flash_notices.erb", "#{'spec/dummy/' if Rails.env.test?}app/views/layouts/_flash_notices.erb"

      end

      if Rails.version.split(".")[0].to_i >= 7
        copy_file "confirmable.js", "#{'spec/dummy/' if Rails.env.test?}app/javascript/controllers/confirmable.js"
      end

      if Rails.version.split(".")[0].to_i == 6
        app_js_contents = File.read("app/javascript/packs/application.js")
        if app_js_contents.include?("import Turbolinks from \"turbolinks\"")
          app_js_contents.gsub!("import Turbolinks from \"turbolinks\"", "import { Turbo } from \"@hotwired/turbo-rails\"")
          puts "  HOTGLUE --> fixed packs/application.js: swapping old Turbolinks syntas for new Turbo-Rails syntax [ import { Turbo } from \"@hotwired/turbo-rails\" ] "
        end

        if app_js_contents.include?("Turbolinks.start()")
          app_js_contents.gsub!("Turbolinks.start()", "Turbo.start()")
          puts "  HOTGLUE --> fixed packs/application.js: swapping old Turbolinks syntas for new Turbo-Rails syntax[ Turbolinks.start() ] "
        end
        File.write("app/javascript/packs/application.js", app_js_contents)

      end

      rails_helper_contents = File.read("spec/rails_helper.rb")
      if !rails_helper_contents.include?("include FactoryBot::Syntax::Methods")
        rails_helper_contents.gsub!("RSpec.configure do |config|", "RSpec.configure do |config| \n
  config.include FactoryBot::Syntax::Methods
")
        puts "  HOTGLUE --> added to spec/rails_helper.rb: `config.include FactoryBot::Syntax::Methods`  "
      end

      if ! rails_helper_contents.include?("require 'support/capybara_login.rb'")
        rails_helper_contents.gsub!("require 'rspec/rails'","require 'rspec/rails' \nrequire 'support/capybara_login.rb'")
        puts "  HOTGLUE --> added to spec/rails_helper.rb: `require 'support/capybara_login.rb'`  "
      end
      File.write("spec/rails_helper.rb", rails_helper_contents)


      application_layout_contents = File.read("app/views/layouts/application.html.erb")

      if !application_layout_contents.include?("render partial: 'layouts/flash_notices'")
        application_layout_contents.gsub!("<body>", "<body>\n
<%= render partial: 'layouts/flash_notices' %>
")
        File.write("app/views/layouts/application.html.erb", application_layout_contents)
        puts "  HOTGLUE --> added to app/views/layouts/application.html.erb: `<%= render partial: 'layouts/flash_notices' %>`  "
      end


      if !File.exists?("spec/support/capybara_login.rb")
        copy_file "capybara_login.rb", "#{'spec/dummy/' if Rails.env.test?}spec/support/capybara_login.rb"
      end
    end
  end
end



