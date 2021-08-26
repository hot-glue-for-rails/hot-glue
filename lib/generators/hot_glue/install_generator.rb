require 'rails/generators/erb/scaffold/scaffold_generator'
require 'ffaker'

module HotGlue
  class InstallGenerator < Rails::Generators::Base
    hook_for :form_builder, :as => :scaffold

    source_root File.expand_path('templates', __dir__)


    def initialize(*args) #:nodoc:
      super
      copy_file "_flash_notices.haml", "#{'spec/dummy/' if Rails.env.test?}app/views/layouts/_flash_notices.haml"
    end
  end
end



