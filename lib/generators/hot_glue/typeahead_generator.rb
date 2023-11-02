module HotGlue
  class TypeaheadGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)
    class_option :namespace, type: :string, default: nil
    class_option :search_by, type: :string, default: nil

    def filepath_prefix
      # todo: inject the context
      'spec/dummy/' if $INTERNAL_SPECS
    end


    def initialize(*meta_args)
      super

      @singular = args.first.tableize.singularize

      @plural = args.first.tableize.pluralize
      @namespace = options['namespace']

      if options['search_by']
        @search_by = options['search_by'].split(",")
      else
        # todo: read the fields off the table


        raise "no search_by specified"
      end

      dest_file = "#{'spec/dummy/' if $INTERNAL_SPECS}app/controllers/#{@namespace ? @namespace + "/" : ""}#{@plural }_typeahead_controller.rb"
      template "typeahead_controller.rb.erb", dest_file


    end


    def controller_descends_from
      if defined?(@namespace.titlecase.gsub(" ", "") + "::BaseController")
        @namespace.titlecase.gsub(" ", "") + "::BaseController"
      else
        "ApplicationController"
      end
    end
  end


end
