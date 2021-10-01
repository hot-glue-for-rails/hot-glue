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
    end
  end
end



