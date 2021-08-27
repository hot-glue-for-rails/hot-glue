require 'rails/generators/erb/scaffold/scaffold_generator'
require 'ffaker'

require_relative './markup_templates/base'
require_relative './markup_templates/erb'
require_relative './markup_templates/haml'
require_relative './markup_templates/slim'

module HotGlue
  class Error < StandardError
  end

  module GeneratorHelper
    def derrive_reference_name thing_as_string
      assoc_class = eval(thing_as_string)

      if assoc_class.respond_to?("name")
        display_column = "name"
      elsif assoc_class.respond_to?("to_label")
        display_column = "to_label"
      elsif assoc_class.respond_to?("full_name")
        display_column = "full_name"
      elsif assoc_class.respond_to?("display_name")
        display_column = "display_name"
      elsif assoc_class.respond_to?("email")
        display_column = "email"
      else
        raise("this should have been caught by the checker in the initializer")
        # puts "*** Oops: Can't find any column to use as the display label for the #{assoc.name.to_s} association on the #{singular_class} model . TODO: Please implement just one of: 1) name, 2) to_label, 3) full_name, 4) display_name, or 5) email directly on your #{assoc.class_name} model (either as database field or model methods), then RERUN THIS GENERATOR. (If more than one is implemented, the field to use will be chosen based on the rank here, e.g., if name is present it will be used; if not, I will look for a to_label, etc)"
      end
      display_column
    end


    def text_area_output(col, field_length, col_identifier )
      lines = field_length % 40
      if lines > 5
        lines = 5
      end

      "#{col_identifier}{class: \"form-group \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
    = f.text_area :#{col.to_s}, class: 'form-control', cols: 40, rows: '#{lines}'
    %label.form-text
      #{col.to_s.humanize}\n"
    end




  end


  class ScaffoldGenerator < Erb::Generators::ScaffoldGenerator
    hook_for :form_builder, :as => :scaffold

    source_root File.expand_path('templates', __dir__)
    attr_accessor :path, :singular, :plural, :singular_class, :nest_with


    include GeneratorHelper


    class_option :singular, type: :string, default: nil
    class_option :plural, type: :string, default: nil
    class_option :singular_class, type: :string, default: nil
    class_option :nest, type: :string, default: ""
    class_option :namespace, type: :string, default: nil
    class_option :auth, type: :string, default: nil
    class_option :auth_identifier, type: :string, default: nil
    class_option :exclude, type: :string, default: ""
    class_option :include, type: :string, default: ""
    class_option :god, type: :boolean, default: false
    class_option :gd, type: :boolean, default: false # alias for god
    class_option :specs_only, type: :boolean, default: false
    class_option :no_specs, type: :boolean, default: false
    class_option :no_delete, type: :boolean, default: false
    class_option :no_create, type: :boolean, default: false
    class_option :no_paginate, type: :boolean, default: false
    class_option :big_edit, type: :boolean, default: false
    class_option :show_only, type: :string, default: ""
    class_option :markup, type: :string, default: "erb"

    def initialize(*meta_args) #:nodoc:
      super

      begin
        @the_object = eval(class_name)
      rescue StandardError => e
        message = "*** Oops: It looks like there is no object for #{class_name}. Please define the object + database table first."
        raise(HotGlue::Error, message)
      end

      if @specs_only && @no_specs
        raise(HotGlue::Error, "*** Oops: You seem to have specified both the --specs-only flag and --no-specs flags. this doesn't make any sense, so I am aborting. sorry.")
      end

      if options['markup'] == "erb"
        @template_builder = HotGlue::ErbTemplate.new
      elsif options['markup'] == "slim"
        puts "SLIM IS NOT IMPLEMENTED"
        abort
        @template_builder = HotGlue::SlimTemplate.new

      elsif options['markup'] == "haml"
        @template_builder = HotGlue::HamlTemplate.new
      end


      args = meta_args[0]
      @singular = args.first.tableize.singularize # should be in form hello_world
      @plural = options['plural'] || @singular + "s" # supply to override; leave blank to use default
      @auth = options['auth'] || "current_user"
      @auth_identifier = options['auth_identifier'] || (!@auth.nil? && @auth.gsub("current_", "")) || nil


      @nest = (!options['nest'].empty? && options['nest']) || nil
      @namespace = options['namespace'] || nil

      @singular_class = @singular.titleize.gsub(" ", "")
      @exclude_fields = []
      @exclude_fields += options['exclude'].split(",").collect(&:to_sym)

      if !options['include'].empty?
        @include_fields = []
        @include_fields += options['include'].split(",").collect(&:to_sym)
      end


      @show_only = []
      if !options['show_only'].empty?
        @show_only += options['show_only'].split(",").collect(&:to_sym)
      end


      @god = options['god'] || options['gd'] || false
      @specs_only = options['specs_only'] || false

      @no_specs = options['no_specs'] || false
      @no_delete = options['no_delete'] || false

      @no_create = options['no_create'] || false
      @no_paginate = options['no_paginate'] || false
      @big_edit = options['big_edit']

      if @god
        @auth = nil
      end

      # when in self auth, the object is the same as the authenticated object
      if @auth && auth_identifier == @singular
        @self_auth = true
      end

      @nested_args = []
      if !@nest.nil?
        @nested_args = @nest.split("/")
        @nested_args_plural = {}
        @nested_args.each do |a|
          @nested_args_plural[a] = a + "s"
        end
      end

                                 # the @object_owner will always be object that will 'own' the object
                                 # for new and create

      if @auth && ! @self_auth && @nested_args.none?
        @object_owner_sym = @auth.gsub("current_", "").to_sym
        @object_owner_eval = @auth
      else

        if @nested_args.any?
          @object_owner_sym = @nested_args.last.to_sym
          @object_owner_eval = "@#{@nested_args.last}"
        else
          @object_owner_sym = ""
          @object_owner_eval = ""
        end
      end

      identify_object_owner
      setup_fields
    end

    def identify_object_owner
      auth_assoc = @auth && @auth.gsub("current_","")

      if !@object_owner_sym.empty?
        auth_assoc_field = auth_assoc + "_id"
        assoc = eval("#{singular_class}.reflect_on_association(:#{@object_owner_sym})")

        if assoc
          @ownership_field = assoc.name.to_s + "_id"
        elsif !@nest
          exit_message = "*** Oops: It looks like is no association from current_#{@object_owner_sym} to a class called #{@singular_class}. If your user is called something else, pass with flag auth=current_X where X is the model for your users as lowercase. Also, be sure to implement current_X as a method on your controller. (If you really don't want to implement a current_X on your controller and want me to check some other method for your current user, see the section in the docs for auth_identifier.) To make a controller that can read all records, specify with --god."

        else
          if @god

            exit_message= "*** Oops:  god mode could not find the association(?). something is wrong."
          else
            @auth_check = "current_user"
            @nested_args.each do |arg|

              if !@auth_check.method("#{arg}s")
                exit_message= "*** Oops:  your nesting chain does not have a assocation for #{arg}s on #{@auth_check}  something is wrong."
              end
              byebug
              puts ""
            end
          end

          raise(HotGlue::Error, exit_message)
        end
      end
    end


    def setup_fields
      auth_assoc = @auth && @auth.gsub("current_","")

      if !@include_fields
        @exclude_fields.push :id, :created_at, :updated_at, :encrypted_password,
                             :reset_password_token,
                             :reset_password_sent_at, :remember_created_at,
                             :confirmation_token, :confirmed_at,
                             :confirmation_sent_at, :unconfirmed_email

        @exclude_fields.push( (auth_assoc + "_id").to_sym) if ! auth_assoc.nil?
        @exclude_fields.push( @ownership_field.to_sym ) if ! @ownership_field.nil?


        @columns = @the_object.columns.map(&:name).map(&:to_sym).reject{|field| @exclude_fields.include?(field) }

      else
        @columns = @the_object.columns.map(&:name).map(&:to_sym).reject{|field| !@include_fields.include?(field) }
      end

      @columns.each do |col|
        if col.to_s.starts_with?("_")
          @show_only << col
        end

        if @the_object.columns_hash[col.to_s].type == :integer
          if col.to_s.ends_with?("_id")
            # guess the association name label
            assoc_name = col.to_s.gsub("_id","")
            assoc = eval("#{singular_class}.reflect_on_association(:#{assoc_name})")


            begin
              eval(assoc.class_name)
            rescue NameError => e
              exit_message = "*** Oops: The model #{singular_class} is missing an association for #{assoc_name} or the model doesn't exist. TODO: Please implement a model for #{assoc_name.titlecase}; your model #{singular_class.titlecase} should have_many :#{assoc_name}s.  To make a controller that can read all records, specify with --god."
              raise(HotGlue::Error, exit_message)

            end


            if assoc.nil?
              exit_message= "*** Oops. on the #{singular_class} object, there doesn't seem to be an association called '#{assoc_name}'"
              raise(HotGlue::Error,exit_message)
            end

            assoc_class = eval(assoc.class_name)

            name_list = [:name, :to_label, :full_name, :display_name, :email]


            if name_list.collect{ |field|
              assoc_class.column_names.include?(field.to_s) ||  assoc_class.instance_methods.include?(field)
            }.any?
              # do nothing here
            else
              exit_message= "*** Oops: Missing a label for #{assoc.class_name.upcase}. Can't find any column to use as the display label for the #{assoc.name.to_s} association on the #{singular_class} model . TODO: Please implement just one of: 1) name, 2) to_label, 3) full_name, 4) display_name, or 5) email directly on your #{assoc.class_name.upcase} model (either as database field or model methods), then RERUN THIS GENERATOR. (If more than one is implemented, the field to use will be chosen based on the rank here, e.g., if name is present it will be used; if not, I will look for a to_label, etc)"
              raise(HotGlue::Error,exit_message)
            end
          end
        end
      end
    end

    #
    def formats
      [format]
    end

    def format
      nil
    end

    def copy_controller_and_spec_files
      @default_colspan = @columns.size

      unless @specs_only
        template "controller.rb.erb", File.join("#{'spec/dummy/' if Rails.env.test?}app/controllers#{namespace_with_dash}", "#{plural}_controller.rb")
        if @namespace
          begin
            eval(controller_descends_from)
            puts "   skipping   base controller #{controller_descends_from}"
          rescue NameError => e
            template "base_controller.rb.erb", File.join("#{'spec/dummy/' if Rails.env.test?}app/controllers#{namespace_with_dash}", "base_controller.rb")
          end
        end
      end

      unless @no_specs
        template "system_spec.rb.erb", File.join("#{'spec/dummy/' if Rails.env.test?}spec/system#{namespace_with_dash}", "#{plural}_behavior_spec.rb")
      end

      template "_errors.haml", File.join("#{'spec/dummy/' if Rails.env.test?}app/views#{namespace_with_dash}", "_errors.haml")
    end

    def list_column_headings
      @columns.map(&:to_s).map{|col_name| '      .col ' + col_name.humanize}.join("\n")
    end

    def columns_spec_with_sample_data
      @columns.map { |c|
        if eval("#{singular_class}.columns_hash['#{c}']").nil?
          byebug
        end
        type = eval("#{singular_class}.columns_hash['#{c}']").type
        random_data = case type
                      when :integer
                        rand(1...1000)
                      when :string
                        FFaker::AnimalUS.common_name
                      when :text
                        FFaker::AnimalUS.common_name
                      when :datetime
                        Time.now + rand(1..5).days
                      end
        c.to_s + ": '" + random_data.to_s + "'"
      }.join(", ")
    end

    def object_parent_mapping_as_argument_for_specs
      if @nested_args.any?
        ", " + @nested_args.last + ": " + @nested_args.last
      elsif @auth
        ", #{@auth_identifier}: #{@auth}"
      end
    end

    def objest_nest_factory_setup
      res = ""
      if @auth
        last_parent = ", #{@auth_identifier}: #{@auth}"
      end

      @nested_args.each do |arg|
        res << "  let(:#{arg}) {create(:#{arg} #{last_parent} )}\n"
        last_parent = ", #{arg}: #{arg}"
      end
      res
    end


    def objest_nest_params_by_id_for_specs
      @nested_args.map{|arg|
        "#{arg}_id: #{arg}.id"
      }.join(",\n          ")
    end


    def controller_class_name
      res = ""
      res << @namespace.titleize + "::" if @namespace
      res << plural.titleize.gsub(" ", "") + "Controller"
      res
    end

    def singular_name
      @singular
    end

    def plural_name
      plural
    end

    def auth_identifier
      @auth_identifier
    end

    def path_helper_args
      if @nested_args.any?
        [(@nested_args).collect{|a| "@#{a}"} , singular].join(",")
      else
        singular
      end
    end

    def path_helper_singular
      "#{@namespace+"_" if @namespace}#{(@nested_args.join("_") + "_" if @nested_args.any?)}#{singular}_path"
    end

    def path_helper_plural
      "#{@namespace+"_" if @namespace}#{(@nested_args.join("_") + "_" if @nested_args.any?)}#{plural}_path"
    end

    def path_arity
      res = ""
      if @nested_args.any?
        res << nested_objects_arity + ", "
      end
      res << "@" + singular
    end

    def line_path_partial
      "#{@namespace+"/" if @namespace}#{plural}/line"
    end

    def show_path_partial
      "#{@namespace+"/" if @namespace}#{plural}/show"
    end

    def list_path_partial
      "#{@namespace+"/" if @namespace}#{plural}/list"
    end

    def new_path_name
      "new_#{@namespace+"_" if @namespace}#{singular}_path"
    end

    def nested_assignments
      @nested_args.map{|a| "#{a}: @#{a}"}.join(", ") #metaprgramming into Ruby hash
    end

    def nested_assignments_with_leading_comma
      if @nested_args.any?
        ", #{nested_assignments}"
      else
        ""
      end
    end

    def nested_objects_arity
      @nested_args.map{|a| "@#{a}"}.join(", ")
    end

    def nested_arity_for_path
      [@nested_args[0..-1].collect{|a| "@#{a}"}].join(", ") #metaprgramming into arity for the Rails path helper
    end

    def object_scope
      if @auth
        if @nested_args.none?
          @auth + ".#{plural}"
        else
          "@" + @nested_args.last + ".#{plural}"
        end
      else
        @singular_class
      end
    end


    def all_objects_root
      if @auth
        if @self_auth
          @singular_class + ".where(id: #{@auth}.id)"
        elsif @nested_args.none?
          @auth + ".#{plural}"
        else
          "@" + @nested_args.last + ".#{plural}"
        end
      else
        @singular_class + ".all"
      end
    end

    def any_nested?
      @nested_args.any?
    end

    def all_objects_variable
      all_objects_root + ".page(params[:page])"
    end

    def auth_object
      @auth
    end

    def no_devise_installed
      !Gem::Specification.sort_by{ |g| [g.name.downcase, g.version] }.group_by{ |g| g.name }['devise']
    end





    def copy_view_files
      return if @specs_only
      haml_views.each do |view|
        formats.each do |format|
          filename = cc_filename_with_extensions(view, "haml")
          template filename, File.join("#{'spec/dummy/' if Rails.env.test?}app/views#{namespace_with_dash}", controller_file_path, filename)
        end
      end

      turbo_stream_views.each do |view|
        formats.each do |format|
          filename = cc_filename_with_extensions(view, 'turbo_stream.haml')
          template filename, File.join("#{'spec/dummy/' if Rails.env.test?}app/views#{namespace_with_dash}", controller_file_path, filename)
        end
      end
    end

    def namespace_with_dash
      if @namespace
        "/#{@namespace}"
      else
        ""
      end
    end

    def namespace_with_trailing_dash
      if @namespace
        "#{@namespace}/"
      else
        ""
      end
    end

    def haml_views
      res =  %w(index edit _form _line _list _show _errors)

      unless @no_create
        res += %w(new _new_form _new_button)
      end

      res
    end

    def turbo_stream_views
      res = %w(create  edit update)
      unless @no_delete
        res << 'destroy'
      end
      res
    end

    def handler
      :erb
    end

    def model_has_strings?
      false
    end


    def model_search_fields # an array of fields we can search on
      []
    end

    def all_form_fields
      @template_builder.all_form_fields(
        columns: @columns,
        show_only: @show_only,
        singular_class: singular_class,
        singular: singular
      )
    end

    def all_line_fields
      @template_builder.all_line_fields(
        columns: @columns,
        show_only: @show_only,
        singular_class: singular_class,
        singular: singular
      )
    end

    def controller_descends_from
      if defined?(@namespace.titlecase + "::BaseController")
        @namespace.titlecase + "::BaseController"
      else
        "ApplicationController"
      end
    end



    def display_class
      me = eval(singular_class)

      @display_class ||=
        if me.column_names.include?("name") || me.instance_methods(false).include?(:name)
          # note that all class object respond_to?(:name) with the name of their own class
          # this one is unique
          "name"
        elsif me.column_names.include?("to_label") || me.instance_methods(false).include?(:to_label)
          "to_label"
        elsif me.column_names.include?("full_name") || me.instance_methods(false).include?(:full_name)
          "full_name"
        elsif me.column_names.include?("display_name") || me.instance_methods(false).include?(:display_name)
          "display_name"
        elsif me.column_names.include?("email") || me.instance_methods(false).include?(:email)
          "email"
        elsif me.column_names.include?("number") || me.instance_methods(false).include?(:number)
          "number"
        else
          exit_message = "*** Oops: Can't find any column to use as the display label on #{singular_class} model . TODO: Please implement just one of: 1) name, 2) to_label, 3) full_name, 4) display_name, 5) email, or 6) number directly on your #{singular_class} model (either as database field or model methods), then RERUN THIS GENERATOR. (If more than one is implemented, the field to use will be chosen based on the rank here, e.g., if name is present it will be used; if not, I will look for a to_label, etc)"
          raise(HotGlue::Error, exit_message)
        end
    end

    def destroy_action
      return false if @self_auth
      return !@no_delete
    end

    def create_action
      return false if @self_auth
      return !@no_create
    end

    def namespace_with_slash
      if @namespace
        "#{@namespace}/"
     else
       ""
     end
   end

    def paginate
      @template_builder.paginate(plural: plural)
    end
  private # thor does something fancy like sending the class all of its own methods during some strange run sequence
    # does not like public methods

    def cc_filename_with_extensions(name, file_format = format)
      [name, file_format].compact.join(".")
    end
  end

end



