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

      rails_helper_contents = File.read("spec/rails_helper.rb")
      if !rails_helper_contents.include?("include FactoryBot::Syntax::Methods")
        rails_helper_contents.gsub!("RSpec.configure do |config|", "RSpec.configure do |config| \n
  config.include FactoryBot::Syntax::Methods
")
        File.write("spec/rails_helper.rb", rails_helper_contents)
        puts "  HOTGLUE --> add to spec/rails_helper.rb: `config.include FactoryBot::Syntax::Methods`  "
      end

      application_layout_contents = File.read("app/views/layouts/application.html.erb")

      if !application_layout_contents.include?("render partial: 'layouts/flash_notices'")
        application_layout_contents.gsub!("<body>", "<body>\n
<%= render partial: 'flash_notices' %>
")
        File.write("app/views/layouts/application.html.erb", application_layout_contents)
        puts "  HOTGLUE --> add to app/views/layouts/application.html.erb: `<%= render partial: 'layouts/flash_notices' %>`  "
      end

      #

      # TODO>: look for   config.include FactoryBot::Syntax::Methods
      # inside of spec/rails_Helper.rb and inject it if it is not there
      # rspec_file = File.read("spec/rails_helper.rb")
      #
      # "RSpec.configure do |config|"

    end
  end
end



