require 'rails/generators/erb/scaffold/scaffold_generator'
require 'ffaker'


module HotGlue


  class Error < StandardError
  end


  module GeneratorHelper
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



    def field_output(col, type = nil, width, col_identifier )

      "#{col_identifier}{class: \"form-group \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
    = f.text_field :#{col.to_s}, value: @#{singular}.#{col.to_s}, size: #{width}, class: 'form-control', type: '#{type}'
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
    class_option :god, type: :boolean, default: false
    class_option :spacs_only, type: :boolean, default: false
    class_option :no_specs, type: :boolean, default: false
    class_option :no_delete, type: :boolean, default: false
    class_option :no_create, type: :boolean, default: false
    class_option :no_paginate, type: :boolean, default: false

    def initialize(*meta_args) #:nodoc:
      super

      begin
        object = eval(class_name)
      rescue StandardError => e
        message = "*** Oops: It looks like there is no object for #{class_name}. Please define the object + database table first."
        raise(HotGlue::Error, message)
      end

      if @specs_only && @no_specs
        raise(HotGlue::Error, "*** Oops: You seem to have specified both the --specs-only flag and --no-specs flags. this doesn't make any sense, so I am aborting. sorry.")
      end


      args = meta_args[0]
      @singular = args.first.tableize.singularize # should be in form hello_world
      @plural = options['plural'] || @singular + "s" # supply to override; leave blank to use default
      @auth = options['auth'] || "current_user"
      @auth_identifier = options['auth'] || (!@auth.nil? && @auth.gsub("current_", "")) || nil
      @nest = options['auth'] || nil
      @namespace = options['namespace'] || nil
      @singular_class = @singular.titleize.gsub(" ", "")
      @exclude_fields = []
      @exclude_fields += options['exclude'].split(",").collect(&:to_sym)
      auth_assoc = @auth.gsub("current_","")
      @god = options['god'] || options['gd'] || false
      @specs_only = options['specs-only'] || false
      @no_specs = options['no-specs'] || false
      @no_delete = options['no-delete'] || false
      @no_create = options['no-create'] || false
      @no_paginate = options['no-paginate'] || false

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


      if !@object_owner_sym.empty?
        auth_assoc_field = auth_assoc + "_id"
        assoc = eval("#{singular_class}.reflect_on_association(:#{@object_owner_sym})")
        if assoc
          ownership_field = assoc.name.to_s + "_id"
        else
          if @auth
            exit_message= "*** Oops: It looks like is no association from current_#{@object_owner_sym} to a class called #{singular_class}. If your user is called something else, pass with flag auth=current_X where X is the model for your users as lowercase. Also, be sure to implement current_X as a method on your controller. (If you really don't want to implement a current_X on your controller and want me to check some other method for your current user, see the section in the docs for auth_identifier.) To make a controller that can read all records, specify with --god."
          else
            exit_message= "*** Oops:  god mode could not find the association(?). something is wrong."
          end
          raise(HotGlue::Error, exit_message)
        end
      end

      @exclude_fields.push :id, :created_at, :updated_at, :encrypted_password,
                         :reset_password_token,
                         :reset_password_sent_at, :remember_created_at,
                         :confirmation_token, :confirmed_at,
                         :confirmation_sent_at, :unconfirmed_email

      @exclude_fields.push(auth_assoc_field.to_sym) if !auth_assoc_field.nil?
      @exclude_fields.push(ownership_field.to_sym) if !ownership_field.nil?

      begin
        @columns = object.columns.map(&:name).map(&:to_sym).reject{|field| @exclude_fields.include?(field) }
      rescue StandardError => e
        puts "Ooops... #{e} it looks like is no object for #{class_name}. Please create the database table with fields first. "
        exit
      end
    end

    def formats
      [format]
    end

    def format
      nil
    end

    def copy_controller_and_spec_files
      @default_colspan = @columns.size

      unless @specs_only
        template "controller.rb", File.join("app/controllers#{namespace_with_dash}", "#{plural}_controller.rb")
        if @namespace &&  defined?(controller_descends_from) == nil
          template "base_controller.rb", File.join("app/controllers#{namespace_with_dash}", "base_controller.rb")
        end
      end

      unless @no_specs
        template "controller_spec.rb", File.join("spec/controllers#{namespace_with_dash}", "#{plural}_controller_spec.rb")
      end

      template "_errors.haml", File.join("app/views#{namespace_with_dash}", "_errors.haml")
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


    def path_helper_full
      "#{@namespace+"_" if @namespace}#{(@nested_args.join("_") + "_" if @nested_args.any?)}#{singular}_path"
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

      # needs the authenticated root user
      # "#{@auth}.#{ @nested_args.map{|a| "#{@nested_args_plural[a]}.find(@#{a})"}.join('.') + "." if @nested_args.any?}#{plural}"

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
          template filename, File.join("app/views#{namespace_with_dash}", controller_file_path, filename)
        end
      end

      turbo_stream_views.each do |view|
        formats.each do |format|
          filename = cc_filename_with_extensions(view, 'turbo_stream.haml')
          template filename, File.join("app/views#{namespace_with_dash}", controller_file_path, filename)
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
      res =  %w(index edit new _form _new_form _line _list _new_button _show _errors)

      res
    end

    def turbo_stream_views
      res = %w(create destroy edit update)
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
      col_identifier = "  .col"
      col_spaces_prepend = "    "

      res = @columns.map { |col|
        type = eval("#{singular_class}.columns_hash['#{col}']").type
        limit = eval("#{singular_class}.columns_hash['#{col}']").limit
        sql_type = eval("#{singular_class}.columns_hash['#{col}']").sql_type

        case type
        when :integer
          # look for a belongs_to on this object
          if col.to_s.ends_with?("_id")
            # guess the association name label


            assoc_name = col.to_s.gsub("_id","")
            assoc = eval("#{singular_class}.reflect_on_association(:#{assoc_name})")
            if assoc.nil?
              puts "*** Oops. on the #{singular_class} object, there doesn't seem to be an association called '#{assoc_name}'"
              exit
            end


            assoc_class = eval(assoc.class_name)

            if assoc_class.column_names.include?("name")
              display_column = "name"
            elsif assoc_class.column_names.include?("to_label")
              display_column = "to_label"
            elsif assoc_class.column_names.include?("full_name")
              display_column = "full_name"
            elsif assoc_class.column_names.include?("display_name")
              display_column = "display_name"
            elsif assoc_class.column_names.include?("email")
              display_column = "email"
            else
              puts "*** Oops: Can't find any column to use as the display label for the #{assoc.name.to_s} association on the #{singular_class} model . TODO: Please implement just one of: 1) name, 2) to_label, 3) full_name, 4) display_name, or 5) email directly on your #{assoc.class_name} model (either as database field or model methods), then RERUN THIS GENERATOR. (If more than one is implemented, the field to use will be chosen based on the rank here, e.g., if name is present it will be used; if not, I will look for a to_label, etc)"
            end

            "#{col_identifier}{class: \"form-group \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{assoc_name.to_s})}\"}
#{col_spaces_prepend}= f.collection_select(:#{col.to_s}, #{assoc_class}.all, :id, :#{display_column}, {prompt: true, selected: @#{singular}.#{col.to_s} }, class: 'form-control')
#{col_spaces_prepend}%label.small.form-text.text-muted
#{col_spaces_prepend}  #{col.to_s.humanize}"

          else
            "#{col_identifier}{class: \"form-group \#{'alert-danger' if @#{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
#{col_spaces_prepend}= f.text_field :#{col.to_s}, value: #{singular}.#{col.to_s}, class: 'form-control', size: 4, type: 'number'
#{col_spaces_prepend}%label.form-text
#{col_spaces_prepend}  #{col.to_s.humanize}\n"
          end
        when :string
          limit ||= 256
          if limit <= 256
            field_output(col, nil, limit, col_identifier)
          else
            text_area_output(col, limit, col_identifier)
          end

        when :text
          limit ||= 256
          if limit <= 256
            field_output(col, nil, limit, col_identifier)
          else
            text_area_output(col, limit, col_identifier)
          end
        when :float
          limit ||= 256
          field_output(col, nil, limit, col_identifier)


        when :datetime
          "#{col_identifier}{class: \"form-group \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
#{col_spaces_prepend}= datetime_field_localized(f, :#{col.to_s}, #{singular}.#{col.to_s}, '#{col.to_s.humanize}', #{@auth ? @auth+'.timezone' : 'nil'})"
        when :date
          "#{col_identifier}{class: \"form-group \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
#{col_spaces_prepend}= date_field_localized(f, :#{col.to_s}, #{singular}.#{col.to_s}, '#{col.to_s.humanize}', #{@auth ? @auth+'.timezone' : 'nil'})"
        when :time
          "#{col_identifier}{class: \"form-group  \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
#{col_spaces_prepend}= time_field_localized(f, :#{col.to_s}, #{singular}.#{col.to_s}, '#{col.to_s.humanize}', #{@auth ? @auth+'.timezone' : 'nil'})"
        when :boolean
          "#{col_identifier}{class: \"form-group  \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
#{col_spaces_prepend}%span
#{col_spaces_prepend}  #{col.to_s.humanize}
#{col_spaces_prepend}= f.radio_button(:#{col.to_s},  '0', checked: #{singular}.#{col.to_s}  ? '' : 'checked')
#{col_spaces_prepend}= f.label(:#{col.to_s}, value: 'No', for: '#{singular}_#{col.to_s}_0')

#{col_spaces_prepend}= f.radio_button(:#{col.to_s}, '1',  checked: #{singular}.#{col.to_s}  ? 'checked' : '')
#{col_spaces_prepend}= f.label(:#{col.to_s}, value: 'Yes', for: '#{singular}_#{col.to_s}_1')
      "
        end

      }.join("\n")
      return res
    end


    def all_line_fields
      columns = @columns.count + 1
      perc_width = (100/columns).floor

      col_identifer = ".col"
      @columns.map { |col|
        type = eval("#{singular_class}.columns_hash['#{col}']").type
        limit = eval("#{singular_class}.columns_hash['#{col}']").limit
        sql_type = eval("#{singular_class}.columns_hash['#{col}']").sql_type

        case type
        when :integer
          # look for a belongs_to on this object
          if col.to_s.ends_with?("_id")

            assoc_name = col.to_s.gsub("_id","")


            assoc = eval("#{singular_class}.reflect_on_association(:#{assoc_name})")

            if assoc.nil?
              puts "*** Oops. on the #{singular_class} object, there doesn't seem to be an association called '#{assoc_name}'"
              exit
            end
            
            assoc_class = eval(assoc.class_name)

            if assoc_class.column_names.include?("name")
              display_column = "name"
            elsif assoc_class.column_names.include?("to_label")
              display_column = "to_label"
            elsif assoc_class.column_names.include?("full_name")
              display_column = "full_name"
            elsif assoc_class.column_names.include?("display_name")
              display_column = "display_name"
            elsif assoc_class.column_names.include?("email")
              display_column = "email"
            elsif assoc_class.column_names.include?("number")
              display_column = "number"

            else
              puts "*** Oops: Can't find any column to use as the display label for the #{assoc.name.to_s} association on the #{singular_class} model . TODO: Please implement just one of: 1) name, 2) to_label, 3) full_name, 4) display_name, 5) email, or 6) number directly on your #{assoc.class_name} model (either as database field or model methods), then RERUN THIS GENERATOR. (If more than one is implemented, the field to use will be chosen based on the rank here, e.g., if name is present it will be used; if not, I will look for a to_label, etc)"
            end

            "#{col_identifer}
  = #{singular}.#{assoc.name.to_s}.try(:#{display_column}) || '<span class=\"content alert-danger\">MISSING</span>'.html_safe"

          else
            "#{col_identifer}
  = #{singular}.#{col}"
          end
        when :float
          width = (limit && limit < 40) ? limit : (40)
          "#{col_identifer}
  = #{singular}.#{col}"

        when :string
          width = (limit && limit < 40) ? limit : (40)
          "#{col_identifer}
  = #{singular}.#{col}"
        when :text
          "#{col_identifer}
  = #{singular}.#{col}"
        when :datetime
          "#{col_identifer}
  - unless #{singular}.#{col}.nil?
    = #{singular}.#{col}.in_time_zone(current_timezone).strftime('%m/%d/%Y @ %l:%M %p ') + timezonize(current_timezone)
  - else
    %span.alert-danger
      MISSING
"
        when :date
          ".cell
  - unless #{singular}.#{col}.nil?
    = #{singular}.#{col}
  - else
    %span.alert-danger
      MISSING
"
        when :time
          "#{col_identifer}
  - unless #{singular}.#{col}.nil?
    = #{singular}.#{col}.in_time_zone(current_timezone).strftime('%l:%M %p ') + timezonize(current_timezone)
  - else
    %span.alert-danger
      MISSING
"
        when :boolean
          "#{col_identifer}
  - if #{singular}.#{col}.nil?
    %span.alert-danger
      MISSING
  - elsif #{singular}.#{col}
    YES
  - else
    NO
"
        end
      }.join("\n")
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
        if me.column_names.include?("name")
          "name"
        elsif me.column_names.include?("to_label")
          "to_label"
        elsif me.column_names.include?("full_name")
          "full_name"
        elsif me.column_names.include?("display_name")
          "display_name"
        elsif me.column_names.include?("email")
          "email"
        elsif me.column_names.include?("number")
          display_column = "number"

        else
          raise "*** Oops: Can't find any column to use as the display label on #{singular_class} model . TODO: Please implement just one of: 1) name, 2) to_label, 3) full_name, 4) display_name, 5) email, or 6) number directly on your #{singular_class} model (either as database field or model methods), then RERUN THIS GENERATOR. (If more than one is implemented, the field to use will be chosen based on the rank here, e.g., if name is present it will be used; if not, I will look for a to_label, etc)"
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
    "= paginate #{plural}"
  end

  private # thor does something fancy like sending the class all of its own methods during some strange run sequence
    # does not like public methods

    def cc_filename_with_extensions(name, file_format = format)
      [name, file_format].compact.join(".")
    end
  end

end



