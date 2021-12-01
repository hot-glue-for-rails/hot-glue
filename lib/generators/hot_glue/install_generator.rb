require 'rails/generators/erb/scaffold/scaffold_generator'
require 'ffaker'

module HotGlue
  class InstallGenerator < Rails::Generators::Base
    hook_for :form_builder, :as => :scaffold
    class_option :markup, type: :string, default: "erb"
    class_option :theme, type: :string, default: nil
    class_option :layout, type: :string, default: "hotglue"

    source_root File.expand_path('templates', __dir__)

    def initialize(*args) #:nodoc:
      super
      @layout = options['layout'] || "hotglue"
      @theme =  options['theme']

      if @layout == "hotglue" && options['theme'].nil?
        raise "You have selected to install Hot Glue without a theme. You can either use the --layout=bootstrap to install NO HOT GLUE THEME, or to use a Hot Glue theme please choose: like_boostrap, like_menlo_park, like_cupertino, like_mountain_view, dark_knight"
      end

      if @layout == 'boostrap'
        puts "IMPORTANT: You have selected to install Hot Glue with Bootstrap layout (legacy). Be sure to always use ``--layout=bootstrap` when building your scaffold. No Hot Glue theme will be installed at this time.` "
      end

      ### INTERACTIVE LICENSING
      #


      print "(To purchase a license, please see https://heliosdev.shop/hot-glue-license) \n Please enter your license key: "
      resp1 = STDIN.gets

      print "Please enter the EMAIL you used to purchase this license: "
      resp2 = STDIN.gets

      app_name = Rails.application.class.module_parent_name

      license_should_be = Digest::SHA1.hexdigest("HotGlueLicense--#{app_name}--#{resp1}")


      if (license_should_be != resp1)
        puts "Ooops... it seems that Hot Glue license is not valid. Please check 1) the email address you used for this license, 2) The app name you used to purchase this license, and 3) the activation key itself."
        exit
      end

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
      if !rails_helper_contents.include?("Capybara.default_driver =")
        rails_helper_contents << "\nCapybara.default_driver = :selenium_chrome_headless "
        puts "  HOTGLUE --> added to spec/rails_helper.rb: `Capybara.default_driver = :selenium_chrome_headless`  "
      end

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


      if @layout == "hotglue"
        theme_location = "themes/hotglue_scaffold_#{@theme}.scss"
        theme_file = "hotglue_scaffold_#{@theme}.scss"

        copy_file theme_location, "#{'spec/dummy/' if Rails.env.test?}app/assets/stylesheets/#{theme_file}"

        application_scss = File.read("app/assets/stylesheets/application.scss")

        if !application_scss.include?("@import '#{theme_file}';")
        application_scss << ( "\n @import '#{theme_file}'; ")
          File.write("app/assets/stylesheets/application.scss", application_scss)
          puts "  HOTGLUE --> added to app/assets/stylesheets/application.scss: @import '#{theme_file}' "
        else
          puts "  HOTGLUE --> already found theme in app/assets/stylesheets/application.scss: @import '#{theme_file}' "
        end
      end



      if !File.exists?("config/hot_glue.yml")

        yaml = {layout: @layout, markup: @markup}.to_yaml
        File.write("#{'spec/dummy/' if Rails.env.test?}config/hot_glue.yml", yaml)

      end


      if !File.exists?("spec/support/capybara_login.rb")
        copy_file "capybara_login.rb", "#{'spec/dummy/' if Rails.env.test?}spec/support/capybara_login.rb"
      end
    end
  end
end



