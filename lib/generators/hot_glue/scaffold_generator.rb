require 'rails/generators/erb/scaffold/scaffold_generator'
require 'ffaker'

require_relative './markup_templates/base'
require_relative './markup_templates/erb'
# require_relative './markup_templates/haml'
# require_relative './markup_templates/slim'

require_relative './layout/builder'
require_relative './layout_strategy/base'
require_relative './layout_strategy/bootstrap'
require_relative './layout_strategy/hot_glue'
require_relative './layout_strategy/tailwind'


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

  def self.optionalized_ternary(namespace: nil,
                                target:,
                                nested_set:,
                                modifier: "",
                                with_params: false,
                                top_level: false,
                                put_form: false)
    instance_sym = top_level ? "@" : ""
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

      is_present_path = HotGlue.optionalized_ternary(
        namespace: namespace,
         target: target,
         modifier: modifier,
         top_level: top_level,
         with_params: with_params,
         put_form: put_form,
         nested_set: [nonoptional, *rest_of_nest])

      is_missing_path = HotGlue.optionalized_ternary(
        namespace: namespace,
        target: target,
        modifier: modifier,
        top_level: top_level,
        with_params: with_params,
        put_form: put_form,
        nested_set: rest_of_nest  )
      return "defined?(#{instance_sym + nested_set[0][:singular]}2) ? #{is_present_path} : #{is_missing_path}"
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
    end
    display_column
  end

  class ScaffoldGenerator < Erb::Generators::ScaffoldGenerator
    hook_for :form_builder, :as => :scaffold

    source_root File.expand_path('templates', __dir__)
    attr_accessor :path, :singular, :plural, :singular_class, :nest_with
    attr_accessor :columns, :downnest_children, :layout_object

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
    class_option :update_show_only, type: :string, default: ""

    class_option :ujs_syntax, type: :boolean, default: nil
    class_option :downnest, type: :string, default: nil
    class_option :magic_buttons, type: :string, default: nil
    class_option :small_buttons, type: :boolean, default: nil
    class_option :display_list_after_update, type: :boolean, default: false
    class_option :smart_layout, type: :boolean, default: false
    class_option :markup, type: :string, default: nil # deprecated -- use in app config instead
    class_option :layout, type: :string, default: nil # if used here it will override what is in the config
    class_option :hawk, type: :string, default: nil
    class_option :with_turbo_streams, type: :boolean, default: false

    class_option :label, default: nil
    class_option :list_label_heading, default: nil
    class_option :new_button_label, default: nil
    class_option :new_form_heading, default: nil

    class_option :no_list_label, type: :boolean, default: false
    class_option :no_list_heading, type: :boolean, default: false

    # determines if the labels show up BEFORE or AFTER on the NEW/EDIT (form)
    class_option :form_labels_position, type: :string, default: 'after' #  choices are before, after, omit
    class_option :form_placeholder_labels, type: :boolean,  default: false # puts the field names into the placeholder labels

    # determines if labels appear within the rows of the VIEWABLE list (does NOT affect the list heading)
    class_option :inline_list_labels, default: 'omit' # choices are before, after, omit
    class_option :factory_creation, default: ''
    class_option :alt_foreign_key_lookup, default: '' #
    class_option :attachments, default: ''
    class_option :stacked_downnesting, default: false

    def initialize(*meta_args)
      super

      begin
        @the_object = eval(class_name)
      rescue StandardError => e
        message = "*** Oops: It looks like there is no object for #{class_name}. Please define the object + database table first."
        puts message
        raise(HotGlue::Error, message)
      end

      @meta_args = meta_args

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

      if options['layout']
        layout = options['layout']
      else
        layout = yaml_from_config[:layout]

        if !['hotglue', 'bootstrap', 'tailwind'].include? layout
          raise "Invalid option #{layout} in Hot glue config (config/hot_glue.yml). You must either use --layout= when generating or have a file config/hotglue.yml; specify layout as either 'hotglue' or 'bootstrap'"
        end
      end

      @layout_strategy =
        case layout
        when 'bootstrap'
          LayoutStrategy::Bootstrap.new(self)
        when 'tailwind'
          LayoutStrategy::Tailwind.new(self)
        when 'hotglue'
          LayoutStrategy::HotGlue.new(self)
        end

      args = meta_args[0]
      @singular = args.first.tableize.singularize # should be in form hello_world

      if @singular.include?("/")
        @singular = @singular.split("/").last
      end

      @plural = options['plural'] || @singular.pluralize # respects what you set in inflections.rb, to override, use plural option
      @namespace = options['namespace'] || nil
      use_controller_name =  plural.titleize.gsub(" ", "")
      @controller_build_name = (( @namespace.titleize.gsub(" ","") + "::" if @namespace) || "") + use_controller_name + "Controller"
      @controller_build_folder = use_controller_name.underscore
      @controller_build_folder_singular = singular

      @auth = options['auth'] || "current_user"
      @auth_identifier = options['auth_identifier'] || (! @god && @auth.gsub("current_", "")) || nil

      if options['nest']
        raise HotGlue::Error, "STOP: the flag --nest has been replaced with --nested; please re-run using the --nested flag"
      end
      @nested = (!options['nested'].empty? && options['nested']) || nil
      @singular_class = args.first # note this is the full class name with a model namespace

      setup_attachments

      @exclude_fields = []
      @exclude_fields += options['exclude'].split(",").collect(&:to_sym)

      if !options['include'].empty?
        @include_fields = []

        # semicolon to denote layout columns; commas separate fields
        @include_fields += options['include'].split(":").collect{|x|x.split(",")}.flatten.collect(&:to_sym)
      end

      @show_only = []
      if !options['show_only'].empty?
        @show_only += options['show_only'].split(",").collect(&:to_sym)
      end

      @update_show_only = []
      if !options['update_show_only'].empty?
        @update_show_only += options['update_show_only'].split(",").collect(&:to_sym)
      end


      # syntax should be xyz_id{xyz_email},abc_id{abc_email}
      # instead of a drop-down for the foreign entity, a text field will be presented
      # You must ALSO use a factory that contains a parameter of the same name as the 'value' (for example, `xyz_email`)

      alt_lookups_entry = options['alt_foreign_key_lookup'].split(",")
      @alt_lookups = {}
      @alt_foreign_key_lookup = alt_lookups_entry.each do |setting|
        setting =~ /(.*){(.*)}/
        key, lookup_as = $1, $2
        assoc = eval("#{class_name}.reflect_on_association(:#{key.to_s.gsub("_id","")}).class_name")

        data = {lookup_as: lookup_as.gsub("+",""),
                assoc: assoc,
                with_create: lookup_as.include?("+")}
        @alt_lookups[key] = data
      end

      puts "------ ALT LOOKUPS for #{@alt_lookups}"

      @update_alt_lookups = @alt_lookups.collect{|key, value|
        @update_show_only.include?(key) ?
          {  key: value }
          : nil}.compact

      @label = options['label'] || ( eval("#{class_name}.class_variable_defined?(:@@table_label_singular)") ? eval("#{class_name}.class_variable_get(:@@table_label_singular)") :  singular.gsub("_", " ").titleize )
      @list_label_heading =  options['list_label_heading'] || ( eval("#{class_name}.class_variable_defined?(:@@table_label_plural)") ? eval("#{class_name}.class_variable_get(:@@table_label_plural)") : plural.gsub("_", " ").upcase )

      @new_button_label = options['new_button_label'] || ( eval("#{class_name}.class_variable_defined?(:@@table_label_singular)") ? "New " + eval("#{class_name}.class_variable_get(:@@table_label_singular)") : "New " + singular.gsub("_", " ").titleize )
      @new_form_heading = options['new_form_heading'] || "New #{@label}"


      identify_object_owner
      setup_hawk_keys
      @form_placeholder_labels = options['form_placeholder_labels'] # true or false
      @inline_list_labels = options['inline_list_labels']  || 'omit' # 'before','after','omit'


      @form_labels_position = options['form_labels_position']
      if !['before','after','omit'].include?(@form_labels_position)
        raise HotGlue::Error, "You passed '#{@form_labels_position}' as the setting for --form-labels-position but the only allowed options are before, after (default), and omit"
      end

      if !['before','after','omit'].include?(@inline_list_labels)
        raise HotGlue::Error, "You passed '#{@inline_list_labels}' as the setting for --inline-list-labels but the only allowed options are before, after, and omit (default)"
      end



      if  @markup == "erb"
        @template_builder = HotGlue::ErbTemplate.new(
          layout_strategy: @layout_strategy,
          magic_buttons: @magic_buttons,
          small_buttons: @small_buttons,
          inline_list_labels: @inline_list_labels,
          show_only: @show_only,
          update_show_only: @update_show_only,
          singular_class: singular_class,
          singular: singular,
          hawk_keys: @hawk_keys,
          ownership_field: @ownership_field,
          form_labels_position: @form_labels_position,
          form_placeholder_labels: @form_placeholder_labels,
          alt_lookups: @alt_lookups,
          attachments: @attachments,
        )
      elsif  @markup == "slim"
        raise(HotGlue::Error,  "SLIM IS NOT IMPLEMENTED")
      elsif  @markup == "haml"
        raise(HotGlue::Error,  "HAML IS NOT IMPLEMENTED")
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
      @stacked_downnesting = options['stacked_downnesting']




      @display_list_after_update = options['display_list_after_update'] || false
      @smart_layout = options['smart_layout']

      if options['include'].include?(":") && @smart_layout
        raise HotGlue::Error, "You specified both --smart-layout and also specified grouping mode (there is a : character in your field include list); you must remove the colon(s) from your --include tag or remove the --smart-layout option"
      end

      @container_name = @layout_strategy.container_name
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
        @object_owner_sym = @auth.gsub("current_", "").to_sym
        @object_owner_eval = @auth
        @object_owner_optional = false
        @object_owner_name = @auth.gsub("current_", "").to_s


      elsif @auth && ! @self_auth && @nested_set.none? && !@auth.include?(".")
        @object_owner_sym = @auth.gsub("current_", "").to_sym
        @object_owner_eval = @auth
        @object_owner_optional = false
        @object_owner_name = @auth.gsub("current_", "").to_s

      elsif @auth && @auth.include?(".")
        @object_owner_sym = nil
        @object_owner_eval = @auth
      else
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


      @factory_creation = options['factory_creation'].gsub(";", "\n")




      # SETUP FIELDS & LAYOUT
      setup_fields
      if  (@columns - @show_only - (@ownership_field ?  [@ownership_field.to_sym] : [])).empty?
        @no_field_form = true
      end

      buttons_width = ((!@no_edit && 1) || 0) + ((!@no_delete && 1) || 0) + @magic_buttons.count

      builder = HotGlue::Layout::Builder.new(include_setting: options['include'],
                                              downnest_object: @downnest_object,
                                              buttons_width: buttons_width,
                                              columns: @columns,
                                              smart_layout: @smart_layout,
                                              stacked_downnesting: @stacked_downnesting)
      @layout_object = builder.construct



      @menu_file_exists = true if @nested_set.none? && File.exist?("#{Rails.root}/app/views/#{namespace_with_trailing_dash}_menu.#{@markup}")

      @turbo_streams = !!options['with_turbo_streams']






    end


    def fields_filtered_for_email_lookups
      @columns.reject{|c| @alt_lookups.keys.include?(c) } + @alt_lookups.values.map{|v| ("__lookup_#{v[:lookup_as]}").to_sym}
    end


    def creation_syntax

      merge_with = @alt_lookups.collect{ |key, data|
        "#{data[:assoc].downcase}: #{data[:assoc].downcase}_factory.#{data[:assoc].downcase}"
      }.join(", ")

      if @factory_creation == ''
        "@#{singular_name } = #{ class_name }.create(modified_params)"
      else
        "#{@factory_creation}\n" +
        "    @#{singular_name } = #{ class_name }.create(modified_params#{'.merge(' + merge_with + ')' if !merge_with.empty?})"
      end
    end
    
    def setup_hawk_keys
      @hawk_keys = {}

      if options["hawk"]
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
          optional = eval(singular_class + ".reflect_on_association(:#{key.gsub('_id','')})").options[:optional]

          @hawk_keys[key.to_sym] = {bind_to: [hawk_to], optional: optional}
          use_shorthand = !options["hawk"].include?("{")

          if use_shorthand # only include the hawk scope if using the shorthand
            @hawk_keys[key.to_sym][:bind_to] << hawk_scope
          end

        end

        puts "HAWKING: #{@hawk_keys}"
      end
    end


    def setup_attachments
      @attachments = {}

      if options["attachments"]

        options['attachments'].split(",").each do |attachment_entry|
          # format is: avatar{thumbnail|field_for_original_filename}

          if attachment_entry.include?("{")
            num_params = attachment_entry.split("|").count
            if num_params == 1
              attachment_entry =~ /(.*){(.*)}/
              key, thumbnail = $1, $2
            elsif num_params == 2
              attachment_entry =~ /(.*){(.*)\|(.*)}/
              key, thumbnail, field_for_original_filename = $1, $2, $3
            elsif num_params > 2
              if num_params == 3
                attachment_entry =~ /(.*){(.*)\|(.*)\|(.*)}/
                key, thumbnail, field_for_original_filename, direct_upload = $1, $2, $3, $4
              elsif num_params > 3
                attachment_entry =~ /(.*){(.*)\|(.*)\|(.*)\|(.*)}/
                key, thumbnail, field_for_original_filename, direct_upload, dropzone = $1, $2, $3, $4, $5
              end

              field_for_original_filename = nil if field_for_original_filename == ""

              if thumbnail == ''
                thumbnail = nil
              end

              if !direct_upload.nil? && direct_upload != "direct"
                raise HotGlue::Error, "received 3rd parameter in attachment long form specification that was not 'direct'; for direct uploads, just use 'direct' or leave off to disable"
              end

              if !dropzone.nil? && dropzone != "dropzone"
                raise HotGlue::Error, "received 4th parameter in attachme long form specification that was not 'dropzone'; for dropzone, just use 'dropzone' or leave off to disable"
              end

              if dropzone && !direct_upload
                raise HotGlue::Error, "dropzone requires direct_upload"
              end

              if field_for_original_filename && direct_upload
                raise HotGlue::Error, "Unfortunately orig filename extraction doesn't work with direct upload; please set 2nd parameter to empty string to disable"
              end

              direct_upload = !!direct_upload
              dropzone = !!dropzone
            end
          else
            key = attachment_entry

            if !(eval("#{singular_class}.reflect_on_attachment(:#{attachment_entry})"))
              raise HotGlue::Error, "Could not find #{attachment_entry} attachment on #{singular_class}"
            end
            if eval("#{singular_class}.reflect_on_attachment(:#{attachment_entry}).variants.include?(:thumb)")
              thumbnail = "thumb"
            else
              thumbnail = nil
            end

            direct_upload = nil
            field_for_original_filename = nil
            dropzone  = nil
          end

          if thumbnail && !eval("#{singular_class}.reflect_on_attachment(:#{key}).variants.include?(:#{thumbnail})")
            raise HotGlue::Error, "you specified to use #{thumbnail} as the thumbnail but could not find any such variant on the #{key} attachment; add to your #{singular}.rb file:
  has_one_attached :#{key} do |attachable|
    attachable.variant :#{thumbnail}, resize_to_limit: [100, 100]
  end
"
          end


          @attachments[key.to_sym] = {thumbnail: thumbnail,
                                      field_for_original_filename: field_for_original_filename,
                                      direct_upload: direct_upload,
                                      dropzone: dropzone}
        end

        puts "ATTACHMENTS: #{@attachments}"
      end
    end

    def identify_object_owner
      auth_assoc = @auth && @auth.gsub("current_","")

      if @object_owner_sym && ! @self_auth
        auth_assoc_field = auth_assoc + "_id" unless @god
        assoc = eval("#{singular_class}.reflect_on_association(:#{@object_owner_sym})")
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

      if @attachments.any?
        puts "adding attachments-as-columns: #{@attachments}"
        @attachments.keys.each do |attachment|
          @columns << attachment if !@columns.include?(attachment)
        end
      end



      @associations = []

      @columns.each do |col|
        if col.to_s.starts_with?("_")
          @show_only << col
        end

        if @the_object.columns_hash.keys.include?(col.to_s)
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
                assoc_class.respond_to?(field.to_s) ||  assoc_class.instance_methods.include?(field)
              }.any?
                # do nothing here
              else
                exit_message = "Oops: Missing a label for `#{assoc_class}`. Can't find any column to use as the display label for the #{assoc_name} association on the #{singular_class} model. TODO: Please implement just one of: 1) name, 2) to_label, 3) full_name, 4) display_name 5) email. You can implement any of these directly on your`#{assoc_class}` model (can be database fields or model methods) or alias them to field you want to use as your display label. Then RERUN THIS GENERATOR. (Field used will be chosen based on rank here.)"
                raise(HotGlue::Error,exit_message)
              end
            end
          end
        elsif @attachments.keys.include?(col)

        else
          raise "couldn't find #{col} in either field list or attachments list"
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
        dest_file = File.join("#{'spec/dummy/' if Rails.env.test?}spec/features#{namespace_with_dash}", "#{plural}_behavior_spec.rb")

        if  File.exist?(dest_file)
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

    def spec_foreign_association_merge_hash
      ", #{testing_name}: #{testing_name}1"
    end

    def spec_related_column_lets
      (@columns - @show_only - @attachments.keys).map { |col|
        type = eval("#{singular_class}.columns_hash['#{col}']").type
        if (type == :integer && col.to_s.ends_with?("_id") || type == :uuid)
          assoc = "#{col.to_s.gsub('_id','')}"
          the_foreign_class = eval(@singular_class + ".reflect_on_association(:" + assoc + ")").class_name.split("::").last.underscore
          hawk_keys_on_lets = (@hawk_keys["#{assoc}_id".to_sym] ? ", #{@auth.gsub('current_', '')}: #{@auth}": "")

          "  let!(:#{assoc}1) {create(:#{the_foreign_class}" +  hawk_keys_on_lets + ")}"
        end
      }.compact.join("\n")
    end

    def list_column_headings
      @template_builder.list_column_headings(
        layout_object: @layout_object,
        col_identifier: @layout_strategy.column_classes_for_column_headings,
        column_width: @layout_strategy.column_width,
        singular: @singular
      )
    end

    def columns_spec_with_sample_data
      (@columns - @attachments.keys).map { |c|
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


    def regenerate_me_code
      "rails generate hot_glue:scaffold #{ @meta_args[0][0] } #{@meta_args[1].collect{|x| x.gsub(/\s*=\s*([\S\s]+)/, '=\'\1\'')}.join(" ")}"
    end

    def object_parent_mapping_as_argument_for_specs

      if @self_auth
        ""
      elsif @nested_set.any? && ! @nested_set.last[:optional]
        ", " + @nested_set.last[:singular] + ": " + @nested_set.last[:singular]
      elsif @auth && !@god
        ", #{@auth_identifier}: #{@auth}"
      end
    end

    def objest_nest_factory_setup
      # TODO: figure out what this is for
      res = ""
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
      singular_class_name.gsub("::","_").underscore
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

    def test_capybara_block(which_partial = :create)
      ((@columns - @attachments.keys) - (which_partial == :create ? @show_only : (@update_show_only+@show_only))).map { |col|
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
            capybara_block_for_association(col_name: col, which_partial: which_partial)
          else
            "      new_#{col} = rand(10) \n" +
            "      find(\"[name='#{testing_name}[#{ col.to_s }]']\").fill_in(with: new_#{col.to_s})"
          end
        when :float
          "      " + "new_#{col} = rand(10) \n" +
            "      find(\"[name='#{testing_name}[#{ col.to_s }]']\").fill_in(with: new_#{col.to_s})"
        when :uuid
          capybara_block_for_association(col_name: col, which_partial: which_partial)

        when :enum
          "      list_of_#{col.to_s} = #{singular_class}.defined_enums['#{col.to_s}'].keys \n" +
            "      " + "new_#{col.to_s} = list_of_#{col.to_s}[rand(list_of_#{col.to_s}.length)].to_s \n" +
            '      find("select[name=\'' + singular + '[' + col.to_s + ']\']  option[value=\'#{new_' + col.to_s + '}\']").select_option'

        when :boolean
          "      new_#{col} = 1 \n" +
            "      find(\"[name='#{testing_name}[#{col}]'][value='\#{new_" + col.to_s + "}']\").choose"
        when :string
          faker_string =
            if col.to_s.include?('email')
              "FFaker::Internet.email"
            elsif  col.to_s.include?('domain')
              "FFaker::Internet.domain_name"
            elsif col.to_s.include?('ip_address') || col.to_s.ends_with?('_ip')
              "FFaker::Internet.ip_v4_address"
            else
              "FFaker::Movie.title"
            end
            "      " + "new_#{col} = #{faker_string} \n" +
            "      find(\"[name='#{testing_name}[#{ col.to_s }]']\").fill_in(with: new_#{col.to_s})"
        when :text
          "      " + "new_#{col} = FFaker::Lorem.paragraphs(1).join("") \n" +
            "      find(\"[name='#{testing_name}[#{ col.to_s }]']\").fill_in(with: new_#{col.to_s})"
        end

      }.join("\n")
    end


    def capybara_block_for_association(col_name: nil , which_partial: nil )
      assoc = col_name.to_s.gsub('_id','')
      if which_partial == :update && @update_show_only.include?(col_name)
        # do not update tests
      elsif @alt_lookups.keys.include?(col_name.to_s)
        lookup = @alt_lookups[col_name.to_s][:lookup_as]
        "      find(\"[name='#{singular}[__lookup_#{lookup}]']\").fill_in( with: #{assoc}1.#{lookup} )"
      else
        "      #{col_name}_selector = find(\"[name='#{singular}[#{col_name}]']\").click \n" +
          "      #{col_name}_selector.first('option', text: #{assoc}1.name).select_option"
      end
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

    def nav_template
      "#{namespace_with_trailing_dash}nav"
    end


    def include_nav_template
      File.exist?("#{Rails.root}/app/views/#{namespace_with_trailing_dash}_nav.html.#{@markup}")
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
      # if File.exist?(menu_file)
      #   # TODO: can I insert the new menu item into the menu programatically here?
      #   # not sure how i would achieve this without nokogiri
      #
      # end

    end

    def append_model_callbacks
      # somehow the generator invokes this

      if options['with_turbo_streams'] == true
        dest_filename = cc_filename_with_extensions("#{singular_class.underscore}", "rb")
        dest_filepath = File.join("#{'spec/dummy/' if Rails.env.test?}app/models", dest_filename)


        puts "appending turbo callbacks to #{dest_filepath}"

        text = File.read(dest_filepath)

        append_text = "class #{singular_class} < ApplicationRecord\n"
        if !text.include?("include ActionView::RecordIdentifier")
          append_text << "  include ActionView::RecordIdentifier\n"
        end
        append_text << "  after_update_commit lambda { broadcast_replace_to self, target: \"#{@namespace}__\#{dom_id(self)}\", partial: \"#{@namespace}/#{@plural}/line\" }\n  after_destroy_commit lambda { broadcast_remove_to self, target: \"#{@namespace}__\#{dom_id(self)}\"}\n"

        replace = text.gsub(/class #{singular_class} < ApplicationRecord/, append_text)
        File.open(dest_filepath, "w") {|file| file.puts replace}
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

    def all_views
      res =  %w(index  _line _list _show _errors)

      unless @no_create
        res += %w(new _new_form _new_button)
      end

      unless @no_edit
        res << 'edit'
      end

      if !( @no_edit && @no_create)
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

    def form_fields_html
      @template_builder.all_form_fields(layout_strategy: @layout_strategy,
                                        layout_object: @layout_object)
    end

    def list_label
      @list_label_heading
    end

    def new_thing_label
      @new_thing_label
    end

    def all_line_fields
      @template_builder.all_line_fields(
        col_identifier: @layout_strategy.column_classes_for_line_fields,
        perc_width: @layout_strategy.each_col,     #undefined method `each_col'
        layout_strategy: @layout_strategy,
        layout_object: @layout_object
        # columns:  @layout_object[:columns][:container],
        # show_only: @show_only,
        # singular_class: singular_class,
        # singular: singular,
        # attachments: @attachments
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
        ".tap{ |ary| ary.delete('__#{magic_button}') }"
      }.join("")
    end

    def controller_update_params_tap_away_alt_lookups
      @alt_lookups.collect{ |key, data|
        ".tap{ |ary| ary.delete('__lookup_#{data[:lookup_as]}') }"
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
      if @associations.any? || @attachments.any?
        ".includes(" + (@associations.map{|x| x} + @attachments.collect{|k,v| "#{k}_attachment"}).map{|x| ":#{x.to_s}"}.join(", ") + ")"
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
      res = @hawk_keys.collect{ |k,v|
        "#{k.to_s}: [#{v[:bind_to].join(".")}]"
      }.join(", ")
      res
    end

    def controller_attachment_orig_filename_pickup_syntax
      @attachments.collect{ |key, attachment|  "\n" + "    modified_params[:#{ attachment[:field_for_original_filename] }] = #{singular_name}_params['#{ key }'].original_filename" if attachment[:field_for_original_filename] }.compact.join("\n")
    end

    def any_datetime_fields?
      (@columns - @attachments.keys.collect(&:to_sym)).collect{|col| eval("#{singular_class}.columns_hash['#{col}']").type}.include?(:datetime)
    end
  end
end
