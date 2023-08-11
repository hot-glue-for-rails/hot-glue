module HotGlue
  class FlashNoticesInstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def filepath_prefix
      # todo: inject the context
      'spec/dummy/' if $INTERNAL_SPECS
    end


    def initialize(*args) #:nodoc:
      super
      copy_file "erb/_flash_notices.erb", "#{'spec/dummy/' if Rails.env.test?}app/views/layouts/_flash_notices.erb"

    end
  end
end



