require_relative './default_config_loader'

module HotGlue
  class TypeaheadGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)
    class_option :namespace, type: :string, default: nil
    class_option :search_by, type: :string, default: nil
    class_option :nested, type: :string, default: nil
    class_option :auth_identifier, type: :string, default: nil
    class_option :auth, type: :string, default: nil



    include DefaultConfigLoader
    def filepath_prefix
      # todo: inject the context
      'spec/dummy/' if $INTERNAL_SPECS
    end


    def initialize(*meta_args)
      super
      begin
        @the_object = eval(meta_args[0][0])
      rescue StandardError => e
        message = "*** Oops: It looks like there is no object for #{meta_args[0][0]}. Please define the object + database table first."
        puts message
        raise(HotGlue::Error, message)
      end
      @pundit = get_default_from_config(key: :pundit_default)

      @singular = args.first.tableize.singularize
      @class_name = args.first
      @plural = args.first.tableize.pluralize
      @namespace = options['namespace']
      @auth_identifier = options['auth_identifier']
      @auth = options['auth']

      @nested = options['nested']


      @nested_set = []

      if !@nested.nil?
        @nested_set = @nested.split("/").collect { |arg|
          {
            singular: arg,
            plural: arg.pluralize,
          }
        }
        puts "NESTING: #{@nested_set}"
      end

      if options['search_by']
        @search_by = options['search_by'].split(",")
      else
        # todo: read the fields off the table

        eligible_columns = @the_object.columns.filter{ |column|
          column.sql_type == "character varying"
        }
        columns = eligible_columns.map(&:name).map(&:to_sym).reject { |field| [:id, :created_at, :updated_at].include?(field) }
        @search_by = columns.collect(&:to_s)

      end
      @meta_args = meta_args
      dest_file = "#{'spec/dummy/' if $INTERNAL_SPECS}app/controllers/#{@namespace ? @namespace + "/" : ""}#{@plural }_typeahead_controller.rb"
      template "typeahead_controller.rb.erb", dest_file


      dirname =  "app/views/#{@namespace ? @namespace + "/" : ""}#{@plural}_typeahead"

      if !Dir.exist?(dirname)
        Dir.mkdir dirname
      end
      {"typeahead_views/_thing.html.erb" => "_#{@singular}.html.erb",
       "typeahead_views/index.html.erb" => "index.html.erb"}.each do |source_filename, dest_filename|

        dest_filepath = File.join("#{'spec/dummy/' if $INTERNAL_SPECS}app/views#{namespace_with_dash}",
                                  "#{@plural}_typeahead", dest_filename)

        template source_filename, dest_filepath
        text = File.read(dest_filepath)
        text.gsub!('<\\%=', '<%=' )
        text.gsub!('<\\%', '<%' )
        File.open(dest_filepath, "w") { |f| f.write text }
      end


      puts ""
      puts "be sure to add this your config/routes.rb file:"
      puts ""
      if @namespace
        puts "namespace :#{@namespace} do"
      end
      if @nested_set.length > 0
        space = "  "
        @nested_set.each do |nested|
          space += "  "
          puts "  resources :#{nested[:plural]} do"
        end
      end
      puts "#{space}  resources :#{@plural}_typeahead, only: [:index]"


      if @nested_set.length > 0
        @nested_set.each do |nested|
          space = space[0..-3]
          puts "#{space}end"
        end
      end


      if @namespace
        puts "end"
      end
      puts ""

    end


    def namespace_with_dash
      if @namespace
        "/#{@namespace}"
      else
        ""
      end
    end

    def filepath_prefix
      'spec/dummy/' if $INTERNAL_SPECS
    end

    def controller_descends_from
      if defined?(@namespace.titlecase.gsub(" ", "") + "::BaseController")
        @namespace.titlecase.gsub(" ", "") + "::BaseController"
      else
        "ApplicationController"
      end
    end

    def regenerate_me_code
      "bin/rails generate hot_glue:typeahead #{ @meta_args[0][0] } #{@meta_args[1].collect { |x| x.gsub(/\s*=\s*([\S\s]+)/, '=\'\1\'') }.join(" ")}"
    end
  end


end
