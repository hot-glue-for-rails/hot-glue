require 'rails/generators/erb/scaffold/scaffold_generator'
require 'ffaker'

module HotGlue
  class InstallGenerator < Rails::Generators::Base
    hook_for :form_builder, :as => :scaffold

    source_root File.expand_path('templates', __dir__)


    def initialize(*args) #:nodoc:
      super
      # copy_file "common_core.js", "app/javascript/common_core.js"
      # copy_file "common_core.scss", "app/assets/stylesheets/common_core.scss"
      copy_file "_flash_notices.haml", "app/views/layouts/_flash_notices.haml"
    end
  end
end



