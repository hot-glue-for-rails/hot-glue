module HotGlue
  class NavTemplateGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)
    class_option :namespace, type: :string, default: nil

    def filepath_prefix
      # todo: inject the context
      'spec/dummy/' if $INTERNAL_SPECS
    end


    def initialize(*args) #:nodoc:
      super
      @namespace = options['namespace']
      copy_file "erb/_nav.html.erb", "#{'spec/dummy/' if $INTERNAL_SPECS}app/views/#{@namespace ? @namespace + "/" : ""}_nav.html.erb"

    end
  end
end



