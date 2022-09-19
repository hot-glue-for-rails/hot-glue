require 'rails/generators/erb/scaffold/scaffold_generator'
require 'ffaker'

require_relative './markup_templates/base'
require_relative './markup_templates/erb'
# require_relative './markup_templates/haml'
# require_relative './markup_templates/slim'

require_relative './layout/builder'

module HotGlue
  class Error < StandardError
  end

  def self.construct_downnest_object(input)
    res = input.split(",").map { |child|
      child_name = child.gsub("+","")
      extra_size = child.count("+")
      {child_name => 4+extra_size}
    }
    Hash[*res.collect{|hash| hash.collect{|key,value| [key,value].flatten}.flatten}.flatten]
  end

  def self.optionalized_ternary(params)
    namespace = params[:namespace] || nil
    target = params[:target]
    nested_set = params[:nested_set]
    modifier = params[:modifier] || ""
    with_params = params[:with_params] || false
    top_level = params[:top_level] || false

    instance_sym = top_level ? "@" : ""

    put_form =  params[:put_form] || false

    if nested_set.nil? || nested_set.empty?
      return modifier + "#{(namespace + '_') if namespace}#{target}_path" + (("(#{instance_sym}#{target})" if put_form) || "")
    elsif nested_set[0][:optional] == false
      return modifier + ((namespace + "_" if namespace) || "") + nested_set.collect{|x|
        x[:singular] + "_"
      }.join() + target + "_path" + (("(#{nested_set.collect{
        |x| instance_sym + x[:singular] }.join(",")
      }#{ put_form ? ',' + instance_sym + target : '' })" if with_params) || "")

    else
      # copy the first item, make a ternery in this cycle, and recursively move to both the
      # is present path and the is optional path

      nonoptional = nested_set[0].dup
      nonoptional[:optional] = false
      rest_of_nest = nested_set[1..-1]

      all_params = {namespace: namespace,
                    target: target,
                    modifier: modifier,
                    top_level: top_level,
                    with_params: with_params,
                    put_form: put_form}
      is_present_path = HotGlue.optionalized_ternary(all_params.merge({  nested_set: [nonoptional, *rest_of_nest]})       )

      is_missing_path = HotGlue.optionalized_ternary(all_params.merge({  nested_set: rest_of_nest})       )


      return "defined?(#{instance_sym + nested_set[0][:singular]}) ? #{is_present_path} : #{is_missing_path}"
    end
  end

  def self.derrive_reference_name(thing_as_string)
    assoc_class = eval(thing_as_string)

    if assoc_class.new.respond_to?("name")
      display_column = "name"
    elsif assoc_class.new.respond_to?("to_label")
      display_column = "to_label"
    elsif assoc_class.new.respond_to?("full_name")
      display_column = "full_name"
    elsif assoc_class.new.respond_to?("display_name")
      display_column = "display_name"
    elsif assoc_class.new.respond_to?("email")
      display_column = "email"
    # else # SHOULD BE UNREACHABLE
    #   raise("this should have been caught by the checker in the initializer")
    end
    display_column
  end

  class ScaffoldGenerator < Erb::Generators::ScaffoldGenerator
    hook_for :form_builder, :as => :scaffold

    source_root File.expand_path('templates', __dir__)
    attr_accessor :path, :singular, :plural, :singular_class, :nest_with

    class_option :singular, type: :string, default: nil
    class_option :plural, type: :string, default: nil
    class_option :singular_class, type: :string, default: nil
    class_option :nest, type: :string, default: nil # DEPRECATED —— DO NOT USE
    class_option :nested, type: :string, default: ""

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
    class_option :no_edit, type: :boolean, default: false
    class_option :no_list, type: :boolean, default: false
    class_option :no_paginate, type: :boolean, default: false
    class_option :big_edit, type: :boolean, default: false
    class_option :show_only, type: :string, default: ""

    class_option :ujs_syntax, type: :boolean, default: nil
    class_option :downnest, type: :string, default: nil
    class_option :magic_buttons, type: :string, default: nil
    class_option :small_buttons, type: :boolean, default: nil
    class_option :display_list_after_update, type: :boolean, default: false
    class_option :smart_layout, type: :boolean, default: false
    class_option :markup, type: :string, default: nil # deprecated -- use in app config instead
    class_option :layout, type: :string, default: nil # if used here it will override what is in the config
    class_option :hawk, type: :string, default: nil #

    class_option :no_list_label, type: :boolean, default: false

    class_option :no_list_heading, type: :boolean, default: false


    # determines if the labels show up BEFORE or AFTER on the NEW/EDIT (form)
    class_option :form_labels_position, type: :string, default: 'after' #  choices are before, after, omit
    class_option :form_placeholder_labels, type: :boolean,  default: false # puts the field names into the placeholder labels


    # NOT YET IMPLEMENTED
    # determines if labels appear within the rows of the VIEWABLE list (does NOT affect the list heading)
    class_option :inline_list_labels, default: 'omit' # choices are before, after, omit

    def initialize(*meta_args)
      super

      begin
        @the_object = eval(class_name)
      rescue StandardError => e
        message = "*** Oops: It looks like there is no object for #{class_name}. Please define the object + database table first."
        puts message
        raise(HotGlue::Error, message)
      end


      if options['specs_only'] && options['no_specs']
        raise(HotGlue::Error,  "*** Oops: You seem to have specified both the --specs-only flag and --no-specs flags. this doesn't make any sense, so I am aborting. Aborting.")
      end

      if !options['exclude'].empty? && !options['include'].empty?
        exit_message =  "*** Oops: You seem to have specified both --include and --exclude. Please use one or the other. Aborting."
        puts exit_message

        raise(HotGlue::Error, exit_message)
      end


      if @stimulus_syntax.nil?
        @stimulus_syntax = true

        # if Rails.version.split(".")[0].to_i >= 7
        #   @stimulus_syntax = true
        # else
        # end
      end

      if !options['markup'].nil?
        message = "Using --markup flag in the generator is deprecated; instead, use a file at config/hot_glue.yml with a key markup set to `erb` or `haml`"
        raise(HotGlue::Error, message)
      end

      yaml_from_config = YAML.load(File.read("config/hot_glue.yml"))
      @markup =  yaml_from_config[:markup]

      if  @markup == "erb"
        @template_builder = HotGlue::ErbTemplate.new
      elsif  @markup == "slim"
        raise(HotGlue::Error,  "SLIM IS NOT IMPLEMENTED")
      elsif  @markup == "haml"
        raise(HotGlue::Error,  "HAML IS NOT IMPLEMENTED")

      end


      if !options['layout']
        @layout = yaml_from_config[:layout]

        if !['hotglue', 'bootstrap'].include? @layout
          raise "Invalid option #{@layout} in Hot glue config (config/hot_glue.yml). You must either use --layout= when generating or have a file config/hotglue.yml; specify layout as either 'hotglue' or 'bootstrap'"
        end
      else
        @layout = options['layout']
      end

      args = meta_args[0]


      @singular = args.first.tableize.singularize # should be in form hello_world


      if @singular.include?("/")
        @singular = @singular.split("/").last
      end

      @plural = options['plural'] || @singular + "s" # supply to override; leave blank to use default
      @namespace = options['namespace'] || nil


      use_controller_name =  plural.titleize.gsub(" ", "")

      @controller_build_name = (( @namespace.titleize.gsub(" ","") + "::" if @namespace) || "") + use_controller_name + "Controller"
      @controller_build_folder = use_controller_name.underscore
      @controller_build_folder_singular = singular

      if ! @controller_build_folder.ends_with?("s")
        raise HotGlue::Error, "can't build with controller name #{@controller_build_folder} because it doesn't end with an 's'"
      end

      @auth = options['auth'] || "current_user"
      @auth_identifier = options['auth_identifier'] || (! @god && @auth.gsub("current_", "")) || nil



      if options['nest']
        raise HotGlue::Error, "STOP: the flag --nest has been replaced with --nested; please re-run using the --nested flag"

      end

      @nested = (!options['nested'].empty? && options['nested']) || nil

      @singular_class = args.first # note this is the full class name with a model namespace


      @exclude_fields = []
      @exclude_fields += options['exclude'].split(",").collect(&:to_sym)

      if !options['include'].empty?
        @include_fields = []
        # semicolon to denote layout columns; commas separate fields
        @include_fields += options['include'].gsub(":","").split(",").collect(&:to_sym)
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

      @no_edit = options['no_edit'] || false
      @no_list = options['no_list'] || false
      @no_list_label = options['no_list_label'] || false
      @no_list_heading = options['no_list_heading'] || false

      @form_labels_position = options['form_labels_position']
      if !['before','after','omit'].include?(@form_labels_position)

        raise HotGlue::Error, "You passed '#{@form_labels_position}' as the setting for --form-labels-position but the only allowed options are before, after (default), and omit"
      end

      @form_placeholder_labels = options['form_placeholder_labels'] # true or false
      @inline_list_labels = options['inline_list_labels']  || 'omit' # 'before','after','omit'


      if !['before','after','omit'].include?(@inline_list_labels)
        raise HotGlue::Error, "You passed '#{@inline_list_labels}' as the setting for --inline-list-labels but the only allowed options are before, after, and omit (default)"
      end



      @display_list_after_update = options['display_list_after_update'] || false
      @smart_layout = options['smart_layout']

      if options['include'].include?(":") && @smart_layout
        raise HotGlue::Error, "You specified both --smart-layout and also specified grouping mode (there is a : character in your field include list); you must remove the colon(s) from your --include tag or remove the --smart-layout option"
      end


      @container_name = @layout == "hotglue" ? "scaffold-container" : "container-fluid"
      @downnest = options['downnest'] || false

      @downnest_children = [] # TODO: defactor @downnest_children in favor of downnest_object
      @downnest_object = {}
      if @downnest
        @downnest_children = @downnest.split(",").map{|child| child.gsub("+","")}
        @downnest_object = HotGlue.construct_downnest_object(@downnest)
      end

      if @god
        @auth = nil
      end

      # when in self auth, the object is the same as the authenticated object

      if @auth && auth_identifier == @singular
        @self_auth = true
      end

      if @self_auth && !@no_create
        raise "This controller appears to be the same as the authentication object but in this context you cannot build a new/create action; please re-run with --no-create flag"
      end

      @magic_buttons = []
      if options['magic_buttons']
        @magic_buttons = options['magic_buttons'].split(',')
      end


      @small_buttons = options['small_buttons'] || false

      @build_update_action = !@no_edit || !@magic_buttons.empty?
      # if the magic buttons are present, build the update action anyway

      @ujs_syntax = options['ujs_syntax']
      if !@ujs_syntax
        @ujs_syntax = !defined?(Turbo::Engine)
      end


      # NEST CHAIN
      # new syntax
      # @nested_set = [
      # {
      #    singular: ...,
      #    plural: ...,
      #    optional: false
      # }]
      @nested_set = []

      if ! @nested.nil?
        @nested_set = @nested.split("/").collect { |arg|
          is_optional = arg.start_with?("~")
          arg.gsub!("~","")
          {
            singular: arg,
            plural: arg.pluralize,
            optional: is_optional
          }

        }
        puts "NESTING: #{@nested_set}"
      end

      # OBJECT OWNERSHIP & NESTING
      @reference_name = HotGlue.derrive_reference_name(singular_class)
      if @auth && @self_auth
        # byebug
        @object_owner_sym = @auth.gsub("current_", "").to_sym
        @object_owner_eval = @auth
        @object_owner_optional = false
        @object_owner_name = @auth.gsub("current_", "").to_s


      elsif @auth && ! @self_auth && @nested_set.none? && !@auth.include?(".")
        # byebug
        @object_owner_sym = @auth.gsub("current_", "").to_sym
        @object_owner_eval = @auth
        @object_owner_optional = false
        @object_owner_name = @auth.gsub("current_", "").to_s

      elsif @auth && @auth.include?(".")
        # byebug
        @object_owner_sym = nil
        @object_owner_eval = @auth
      else
        # byebug
        if @nested_set.any?
          @object_owner_sym = @nested_set.last[:singular].to_sym
          @object_owner_eval = "@#{@nested_set.last[:singular]}"
          @object_owner_name = @nested_set.last[:singular]
          @object_owner_optional = @nested_set.last[:optional]
        else
          @object_owner_sym = nil
          @object_owner_eval = ""
        end
      end

      identify_object_owner
      setup_hawk_keys



      # SETUP FIELDS & LAYOUT
      setup_fields
      if  (@columns - @show_only - (@ownership_field ?  [@ownership_field.to_sym] : [])).empty?
        @no_field_form = true
      end

      buttons_width = ((!@no_edit && 1) || 0) + ((!@no_delete && 1) || 0) + @magic_buttons.count

      builder = HotGlue::Layout::Builder.new({
                                              include_setting: options['include'],
                                              downnest_object: @downnest_object,
                                              buttons_width: buttons_width,
                                              columns: @columns,
                                              smart_layout: @smart_layout
                                            })
      @layout_object = builder.construct

      @menu_file_exists = true if @nested_set.none? && File.exists?("#{Rails.root}/app/views/#{namespace_with_trailing_dash}_menu.#{@markup}")


    end

    def setup_hawk_keys
      @hawk_keys = {}

      if options['hawk']
        options['hawk'].split(",").each do |hawk_entry|
          # format is: abc_id[thing]

          if hawk_entry.include?("{")
            hawk_entry =~ /(.*){(.*)}/
            key, hawk_to = $1, $2
          else
            key = hawk_entry
            hawk_to = @auth
          end
          hawk_scope = key.gsub("_id", "").pluralize
          @hawk_keys[key.to_sym] = [hawk_to, hawk_scope]
        end

        puts "HAWKING: #{@hawk_keys}"
      end
    end

    def identify_object_owner
      auth_assoc = @auth && @auth.gsub("current_","")

      if @object_owner_sym && ! @self_auth
        auth_assoc_field = auth_assoc + "_id" unless @god
        assoc = eval("#{singular_class}.reflect_on_association(:#{@object_owner_sym})")
        # byebug
        if assoc
          @ownership_field = assoc.name.to_s + "_id"
        elsif ! @nested_set.any?
          exit_message = "*** Oops: It looks like is no association `#{@object_owner_sym}` from the object #{@singular_class}. If your user is called something else, pass with flag auth=current_X where X is the model for your users as lowercase. Also, be sure to implement current_X as a method on your controller. (If you really don't want to implement a current_X on your controller and want me to check some other method for your current user, see the section in the docs for auth_identifier.) To make a controller that can read all records, specify with --god."
          raise(HotGlue::Error, exit_message)

        else
          if eval(singular_class + ".reflect_on_association(:#{@object_owner_sym.to_s})").nil? && !eval(singular_class + ".reflect_on_association(:#{@object_owner_sym.to_s.singularize})").nil?
            exit_message = "*** Oops: you tried to nest #{singular_class} within a route for `#{@object_owner_sym}` but I can't find an association for this relationship. Did you mean `#{@object_owner_sym.to_s.singularize}` (singular) instead?"
          # else  # NOTE: not reachable
          #   exit_message = "*** Oops: Missing relationship from class #{singular_class} to :#{@object_owner_sym}  maybe add `belongs_to :#{@object_owner_sym}` to #{singular_class}\n (If your user is called something else, pass with flag auth=current_X where X is the model for your auth object as lowercase.  Also, be sure to implement current_X as a method on your controller. If you really don't want to implement a current_X on your controller and want me to check some other method for your current user, see the section in the docs for --auth-identifier flag). To make a controller that can read all records, specify with --god."
          end

          raise(HotGlue::Error, exit_message)
        end
      elsif  @object_owner_sym && ! @object_owner_eval.include?(".")
        @ownership_field = @object_owner_name + "_id"
      end
    end

    def setup_fields

      if !@include_fields
        @exclude_fields.push :id, :created_at, :updated_at, :encrypted_password,
                             :reset_password_token,
                             :reset_password_sent_at, :remember_created_at,
                             :confirmation_token, :confirmed_at,
                             :confirmation_sent_at, :unconfirmed_email

        @exclude_fields.push( @ownership_field.to_sym ) if ! @ownership_field.nil?


        @columns = @the_object.columns.map(&:name).map(&:to_sym).reject{|field| @exclude_fields.include?(field) }

      else
        @columns = @the_object.columns.map(&:name).map(&:to_sym).reject{|field| !@include_fields.include?(field) }
      end

      @associations = []
      @columns.each do |col|
        if col.to_s.starts_with?("_")
          @show_only << col
        end

        if @the_object.columns_hash[col.to_s].type == :integer
          if col.to_s.ends_with?("_id")
            # guess the association name label
            assoc_name = col.to_s.gsub("_id","")


            assoc_model = eval("#{singular_class}.reflect_on_association(:#{assoc_name})")

            if assoc_model.nil?
              exit_message = "*** Oops: The model #{singular_class} is missing an association for :#{assoc_name} or the model #{assoc_name.titlecase} doesn't exist. TODO: Please implement a model for #{assoc_name.titlecase}; or add to #{singular_class} `belongs_to :#{assoc_name}`.  To make a controller that can read all records, specify with --god."
              puts exit_message
              raise(HotGlue::Error, exit_message)
            end

            begin
              assoc_class = eval(assoc_model.try(:class_name))
              @associations << assoc_name.to_sym
              name_list = [:name, :to_label, :full_name, :display_name, :email]

            rescue
              # unreachable(?)
              # if eval("#{singular_class}.reflect_on_association(:#{assoc_name.singularize})")
              #   raise(HotGlue::Error,"*** Oops: #{singular_class} has no association for #{assoc_name.singularize}")
              # else
              #   raise(HotGlue::Error,"*** Oops: Missing relationship from class #{singular_class} to :#{@object_owner_sym}  maybe add `belongs_to :#{@object_owner_sym}` to #{singular_class}\n (If your user is called something else, pass with flag auth=current_X where X is the model for your auth object as lowercase.  Also, be sure to implement current_X as a method on your controller. If you really don't want to implement a current_X on your controller and want me to check some other method for your current user, see the section in the docs for --auth-identifier flag). To make a controller that can read all records, specify with --god.")
              # end
            end

            if assoc_class && name_list.collect{ |field|
              assoc_class.column_names.include?(field.to_s) ||  assoc_class.instance_methods.include?(field)
            }.any?
              # do nothing here
            else
              exit_message = "Oops: Missing a label for `#{assoc_class}`. Can't find any column to use as the display label for the #{assoc_name} association on the #{singular_class} model. TODO: Please implement just one of: 1) name, 2) to_label, 3) full_name, 4) display_name 5) email. You can implement any of these directly on your`#{assoc_class}` model (can be database fields or model methods) or alias them to field you want to use as your display label. Then RERUN THIS GENERATOR. (Field used will be chosen based on rank here.)"
              raise(HotGlue::Error,exit_message)
            end
          end
        end
      end
    end


    def auth_root
      "authenticate_" + @auth_identifier.split(".")[0] + "!"
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
        template "controller.rb.erb", File.join("#{'spec/dummy/' if Rails.env.test?}app/controllers#{namespace_with_dash}", "#{@controller_build_folder}_controller.rb")
        if @namespace
          begin
            eval(controller_descends_from)
            # puts "   skipping   base controller #{controller_descends_from}"
          rescue NameError => e
            template "base_controller.rb.erb", File.join("#{'spec/dummy/' if Rails.env.test?}app/controllers#{namespace_with_dash}", "base_controller.rb")
          end
        end
      end

      unless @no_specs
        dest_file = File.join("#{'spec/dummy/' if Rails.env.test?}spec/system#{namespace_with_dash}", "#{plural}_behavior_spec.rb")

        if  File.exists?(dest_file)
          existing_file = File.open(dest_file)
          existing_content = existing_file.read
          if existing_content =~ /\#HOTGLUE-SAVESTART/
            if  existing_content !~ /\#HOTGLUE-END/
              raise "Your file at #{dest_file} contains a #HOTGLUE-SAVESTART marker without #HOTGLUE-END"
            end
            @existing_content =  existing_content[(existing_content =~ /\#HOTGLUE-SAVESTART/) .. (existing_content =~ /\#HOTGLUE-END/)-1]
            @existing_content << "#HOTGLUE-END"

          end
          existing_file.rewind
        else
          @existing_content = "  #HOTGLUE-SAVESTART\n  #HOTGLUE-END"
        end

        template "system_spec.rb.erb", dest_file
      end

      template "#{@markup}/_errors.#{@markup}", File.join("#{'spec/dummy/' if Rails.env.test?}app/views#{namespace_with_dash}", "_errors.#{@markup}")
    end

    def list_column_headings
      if @layout == "bootstrap"
        column_width = @layout_object[:columns][:size_each]
        col_identifier = "col-md-#{column_width}"
      elsif @layout == "hotglue"
        column_width = each_col * @columns.count
        col_identifier = "scaffold-cell"
      end

      @template_builder.list_column_headings(
        columns: @layout_object[:columns][:container],
        col_identifier: col_identifier,
        layout: @layout,
        column_width: column_width
      )
    end

    def columns_spec_with_sample_data
      @columns.map { |c|
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
      if @nested_set.any?
        ", " + @nested_set.last[:singular] + ": " + @nested_set.last[:singular]
      elsif @auth
        ", #{@auth_identifier}: #{@auth}"
      end
    end

    def objest_nest_factory_setup
      res = "  "
      if @auth
        last_parent = ", #{@auth_identifier}: #{@auth}"
      end

      @nested_set.each do |arg|
        res << "  let(:#{arg[:singular]}) {create(:#{arg[:singular]} #{last_parent} )}\n"
        last_parent = ", #{arg[:singular]}: #{arg[:singular]}"
      end
      res
    end

    def objest_nest_params_by_id_for_specs
      @nested_set.map{|arg|
        "#{arg[:singular]}_id: #{arg[:singular]}.id"
      }.join(",\n          ")
    end

    def controller_class_name
      @controller_build_name
    end

    def singular_name
      @singular
    end

    def testing_name
      singular_class_name.gsub("::","_").downcase
    end

    def singular_class_name
      @singular_class
    end

    def plural_name
      plural
    end

    def auth_identifier
      @auth_identifier
    end

    def test_capybara_block
      (@columns - @show_only).map { |col|
        type = eval("#{singular_class}.columns_hash['#{col}']").type
        case type
        when :date
          "      " + "new_#{col} = Date.current + (rand(100).days) \n" +
            '      ' + "find(\"[name='#{testing_name}[#{ col.to_s }]']\").fill_in(with: new_#{col.to_s})"
        when :time
          # "      " + "new_#{col} = DateTime.current + (rand(100).days) \n" +
          # '      ' + "find(\"[name='#{singular}[#{ col.to_s }]']\").fill_in(with: new_#{col.to_s})"

        when :datetime
          "      " + "new_#{col} = DateTime.current + (rand(100).days) \n" +
            '      ' + "find(\"[name='#{testing_name}[#{ col.to_s }]']\").fill_in(with: new_#{col.to_s})"

        when :integer

          if col.to_s.ends_with?("_id")
            assoc = col.to_s.gsub('_id','')
            "      #{col}_selector = find(\"[name='#{singular}[#{col}]']\").click \n" +
              "      #{col}_selector.first('option', text: #{assoc}1.name).select_option"
          else
            "      new_#{col} = rand(10) \n" +
              "      find(\"[name='#{testing_name}[#{ col.to_s }]']\").fill_in(with: new_#{col.to_s})"

          end

        when :enum
          "      list_of_#{col.to_s} = #{singular_class}.defined_enums['#{col.to_s}'].keys \n" +
            "      " + "new_#{col.to_s} = list_of_#{col.to_s}[rand(list_of_#{col.to_s}.length)].to_s \n" +
            '      find("select[name=\'' + singular + '[' + col.to_s + ']\']  option[value=\'#{new_' + col.to_s + '}\']").select_option'

        when :boolean
          "     new_#{col} = rand(2).floor \n" +
            "     find(\"[name='#{testing_name}[#{col}]'][value='\#{new_" + col.to_s + "}']\").choose"
        when :string
          if col.to_s.include?("email")
            "      " + "new_#{col} = 'new_test-email@nowhere.com' \n" +
              "      find(\"[name='#{testing_name}[#{ col.to_s }]']\").fill_in(with: new_#{col.to_s})"

          else
            "      " + "new_#{col} = 'new_test-email@nowhere.com' \n" +
              "      find(\"[name='#{testing_name}[#{ col.to_s }]']\").fill_in(with: new_#{col.to_s})"
          end
        when :text
          "      " + "new_#{col} = FFaker::Lorem.paragraphs(1).join("") \n" +
            "      find(\"[name='#{testing_name}[#{ col.to_s }]']\").fill_in(with: new_#{col.to_s})"
        end

      }.join("\n")
    end


    def path_helper_args
      if @nested_set.any? && @nested
        [(@nested_set).collect{|a| "#{a[:singular]}"} , singular].join(",")
      else
        singular
      end
    end

    def path_helper_singular
      if @nested
        "#{@namespace+"_" if @namespace}#{(@nested_set.collect{|x| x[:singular]}.join("_") + "_" if @nested_set.any?)}#{@controller_build_folder_singular}_path"
      else
        "#{@namespace+"_" if @namespace}#{@controller_build_folder_singular}_path"
      end
    end

    def path_helper_plural
      HotGlue.optionalized_ternary(namespace: @namespace,
                                   target: @controller_build_folder,
                                   nested_set: @nested_set)
    end

    def form_path_new_helper
      HotGlue.optionalized_ternary(namespace: @namespace,
                                   target: @controller_build_folder,
                                   nested_set: @nested_set,
                                   with_params: true,
                                   top_level: false)
    end

    def form_path_edit_helper
      HotGlue.optionalized_ternary(namespace: @namespace,
                                   target: @singular,
                                   nested_set: @nested_set,
                                   with_params: true,
                                   put_form: true,
                                   top_level: true)
    end


    def delete_path_helper
      HotGlue.optionalized_ternary(namespace: @namespace,
                                   target: @singular,
                                   nested_set: @nested_set,
                                   with_params: true,
                                   put_form: true)
    end

    def edit_path_helper
      HotGlue.optionalized_ternary(namespace: @namespace,
                                   target: @singular,
                                   nested_set: @nested_set,
                                   modifier: "edit_",
                                   with_params: true,
                                   put_form: true)
    end

    def path_arity
      res = ""
      if @nested_set.any? && @nested
        res << nested_objects_arity + ", "
      end
      res << "@" + singular
    end

    def line_path_partial
      "#{@namespace+"/" if @namespace}#{@controller_build_folder}/line"
    end

    def show_path_partial
      "#{@namespace+"/" if @namespace}#{@controller_build_folder}/show"
    end

    def list_path_partial
      "#{@namespace+"/" if @namespace}#{@controller_build_folder}/list"
    end

    def new_path_name
      HotGlue.optionalized_ternary(namespace: @namespace,
                                   target: singular,
                                   nested_set: @nested_set,
                                   modifier: "new_",
                                   with_params: true)
    end

    def nested_assignments
      return "" if @nested_set.none?
      @nested_set.map{|a| "#{a}: #{a}"}.join(", ") #metaprgramming into Ruby hash
    end

    def nested_assignments_top_level # this is by accessing the instance variable-- only use at top level
      @nested_set.map{|a| "#{a[:singular]}"}.join(", ") #metaprgramming into Ruby hash
    end

    def nest_assignments_operator(top_level = false, leading_comma = false)
      if @nested_set.any?
        "#{", " if leading_comma}#{top_level ? nested_assignments_top_level : nested_assignments }"
      else
        ""
      end
    end

    def nested_assignments_with_leading_comma
      nest_assignments_operator(false, true)
    end

    def nested_objects_arity
      @nested_set.map{|a| "@#{a[:singular]}"}.join(", ")
    end

    def nested_arity_for_path
      [@nested_set[0..-1].collect{|a| "@#{a[:singular]}"}].join(", ") #metaprgramming into arity for the Rails path helper
    end

    def object_scope
      if @auth
        if @nested_set.none?
          @auth + ".#{plural}"
        else
          "@" + @nested_set.last[:singular] + ".#{plural}"
        end
      else
        if @nested_set.none?
          @singular_class
        else
          "@" + @nested_set.last[:singular] + ".#{plural}"
        end

      end
    end


    def all_objects_root
      if @auth
        if @self_auth
          @singular_class + ".where(id: #{@auth}.id)"
        elsif @nested_set.none?
          @auth + ".#{plural}"
        else
          "@" + @nested_set.last[:singular] + ".#{plural}"
        end
      else
        @singular_class + ".all"
      end
    end

    def any_nested?
      @nested_set.any?
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


    def magic_button_output
      @template_builder.magic_button_output(
        path: HotGlue.optionalized_ternary(namespace: @namespace,
                                           target: @singular,
                                           nested_set: @nested_set,
                                           with_params: true,
                                           put_form: true),
        singular: singular,
        magic_buttons: @magic_buttons,
        small_buttons: @small_buttons
      )
    end

    def copy_view_files
      return if @specs_only
      all_views.each do |view|
        formats.each do |format|
          source_filename = cc_filename_with_extensions("#{@markup}/#{view}", "#{@markup}")
          dest_filename = cc_filename_with_extensions("#{view}", "#{@markup}")


          dest_filepath = File.join("#{'spec/dummy/' if Rails.env.test?}app/views#{namespace_with_dash}",
                                    @controller_build_folder, dest_filename)


          template source_filename, dest_filepath
          gsub_file dest_filepath,  '\%', '%'

        end
      end

      turbo_stream_views.each do |view|
        formats.each do |format|
          source_filename = cc_filename_with_extensions( "#{@markup}/#{view}.turbo_stream.#{@markup}")
          dest_filename = cc_filename_with_extensions("#{view}", "turbo_stream.#{@markup}")
          dest_filepath = File.join("#{'spec/dummy/' if Rails.env.test?}app/views#{namespace_with_dash}",
                                    @controller_build_folder, dest_filename)


          template source_filename, dest_filepath
          gsub_file dest_filepath,  '\%', '%'

        end
      end

      # menu_file = "app/views#{namespace_with_dash}/menu.erb"
      #
      # if File.exists?(menu_file)
      #   # TODO: can I insert the new menu item into the menu programatically here?
      #   # not sure how i would achieve this without nokogiri
      #
      # end

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

    def all_views
      res =  %w(index  _line _list _show _errors)

      unless @no_create
        res += %w(new _new_form _new_button)
      end

      unless @no_edit
        res << 'edit'
        res << '_form'
      end

      res
    end

    def turbo_stream_views
      res = []
      unless @no_delete
        res << 'destroy'
      end

      unless @no_create
        res << 'create'
      end

      unless @no_edit
        res << 'edit'
        res << 'update'
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
      col_identifier = (@layout == "hotglue") ? "scaffold-cell" : "col-md-#{@layout_object[:columns][:size_each]}"

      @template_builder.all_form_fields(
        columns: @layout_object[:columns][:container],
        show_only: @show_only,
        singular_class: singular_class,
        singular: singular,
        hawk_keys: @hawk_keys,
        col_identifier:  col_identifier,
        ownership_field: @ownership_field,
        form_labels_position: @form_labels_position,
        form_placeholder_labels: @form_placeholder_labels
      )
    end

    def column_width
      @each_col ||= each_col
    end

    def list_label
      if(eval("#{class_name}.class_variable_defined?(:@@table_label_plural)"))
        eval("#{class_name}.class_variable_get(:@@table_label_plural)")
      else
        plural.gsub("_", " ").upcase
      end
    end

    def thing_label
      if(eval("#{class_name}.class_variable_defined?(:@@table_label_singular)"))
        eval("#{class_name}.class_variable_get(:@@table_label_singular)")
      else
        singular.gsub("_", " ").upcase
      end
    end

    def each_col
      return col_width if @columns.count == 0
      (col_width/(@columns.count)).to_i
    end

    def col_width
      downnest_size = case (@downnest_children.count)

                      when 0
                        downnest_size = 0
                      when 1
                        downnest_size = 40

                      else
                        downnest_size = 60

                      end
      100 - downnest_size - 5
    end

    def all_line_fields
      col_identifier = (@layout == "hotglue") ? "scaffold-cell" : "col-md-#{@layout_object[:columns][:size_each]}"

      @template_builder.all_line_fields(
        perc_width: column_width,
        columns:  @layout_object[:columns][:container],
        show_only: @show_only,
        singular_class: singular_class,
        singular: singular,
        layout: @layout,
        col_identifier: col_identifier,
        inline_list_labels: @inline_list_labels

      )
    end

    def controller_descends_from
      if defined?(@namespace.titlecase.gsub(" ", "") + "::BaseController")
        @namespace.titlecase.gsub(" ", "") + "::BaseController"
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
        else
          # NOT UNREACHABLE BUT UNTESTED
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

    # def delete_confirmation_syntax
    #   if !@stimulus_syntax
    #    "{confirm: 'Are you sure?'}"
    #   else
    #    "{controller: 'confirmable', 'confirm-message': \"Are you sure you want to delete \#{ #{@singular}.#{ display_class } } \", 'action': 'confirmation#confirm'}"
    #   end
    # end


    def controller_magic_button_update_actions
      @magic_buttons.collect{ |magic_button|
        "    if #{singular}_params[:#{magic_button}]
      begin
        res = @#{singular}.#{magic_button}!
        res = \"#{magic_button.titleize}ed.\" if res === true
        flash[:notice] = (flash[:notice] || \"\") <<  (res ? res + \" \" : \"\")
      rescue ActiveRecord::RecordInvalid => e
        @#{singular}.errors.add(:base, e.message)
        flash[:alert] = (flash[:alert] || \"\") << 'There was ane error #{magic_button}ing your #{@singular}: '
      end
    end"

     }.join("\n") + "\n"
    end

    def controller_update_params_tap_away_magic_buttons
      @magic_buttons.collect{ |magic_button|
        ".tap{ |ary| ary.delete('#{magic_button}') }"
      }.join("")
    end


    def nested_for_turbo_id_list_constructor
      if @nested_set.any?
        '+ (((\'__\' + nested_for) if defined?(nested_for)) || "")'
      else
        ""
      end
    end


    def n_plus_one_includes
      if @associations.any?
        ".includes(" + @associations.map{|x| ":#{x.to_s}"}.join(", ") + ")"
      else
        ""
      end
    end

    def nested_for_turbo_nested_constructor(top_level = true)
      instance_symbol = "@" if top_level
      instance_symbol = "" if !top_level
      if @nested_set.none?
        "\"\""
      else
        @nested_set.collect{|arg|
          "(((\"__#{arg[:singular]}-\#{" + "@" + arg[:singular] + ".id}\") if @" + arg[:singular] + ") || \"\")"
        }.join(" + ")
      end
    end

    def nested_for_assignments_constructor(top_level = true)
      instance_symbol = "@" if top_level
      instance_symbol = "" if !top_level
      if @nested_set.none?
        ""
      else
        ", \n    nested_for: \"" + @nested_set.collect{|a| "#{a[:singular]}-" + '#{' + instance_symbol + a[:singular] + ".id}"}.join("__") + "\""
      end
    end

    private # thor does something fancy like sending the class all of its own methods during some strange run sequence
    # does not like public methods
    def cc_filename_with_extensions(name, file_format = format)
      [name, file_format].compact.join(".")
    end

    def hawk_to_ruby
      @hawk_keys.collect{ |k,v|
        "#{k}: [#{v[0]}, \"#{v[1]}\"] "
      }.join(", ")
    end
  end
end



