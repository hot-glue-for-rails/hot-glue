require 'rails/generators/erb/scaffold/scaffold_generator'
require_relative './default_config_loader'
require 'ffaker'
require_relative './fields/field'
require_relative './field_factory'
require_relative './markup_templates/base'
require_relative './markup_templates/erb'
require_relative './layout/builder'
require_relative './layout_strategy/base'
require_relative './layout_strategy/bootstrap'
require_relative './layout_strategy/hot_glue'
require_relative './layout_strategy/tailwind'

class HotGlue::ScaffoldGenerator < Erb::Generators::ScaffoldGenerator
  include DefaultConfigLoader
  hook_for :form_builder, :as => :scaffold

  source_root File.expand_path('templates', __dir__)
  attr_accessor :alt_lookups, :attachments, :auth,
                :big_edit, :button_icons, :bootstrap_column_width,
                :columns,
                :default_boolean_display,
                :display_as, :downnest_children, :downnest_object, :god,  :hawk_keys, :layout_object,
                :modify_as,
                :nest_with, :path, :plural, :sample_file_path, :show_only_data, :singular,
                :singular_class, :smart_layout, :stacked_downnesting,
                :update_show_only, :ownership_field,
                :layout_strategy, :form_placeholder_labels,
                :form_labels_position, :no_nav_menu, :pundit,
                :self_auth, :namespace_value, :record_scope, :related_sets,
                :search_clear_button, :search_autosearch, :include_object_names,
                :stimmify, :stimmify_camel, :hidden_create, :hidden_update,
                :invisible_create, :invisible_update, :phantom_create_params,
                :phantom_update_params, :lazy
  # important: using an attr_accessor called :namespace indirectly causes a conflict with Rails class_name method
  # so we use namespace_value instead

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
  class_option :no_controller, type: :boolean, default: false
  class_option :no_paginate, type: :boolean, default: false
  class_option :paginate_per_page_selector, type: :boolean, default: false
  class_option :big_edit, type: :boolean, default: false
  class_option :show_only, type: :string, default: ""
  class_option :update_show_only, type: :string, default: ""
  class_option :hidden, type: :string, default: ""
  class_option :hidden_create, type: :string, default: ""
  class_option :hidden_update, type: :string, default: ""
  class_option :invisible, type: :string, default: ""
  class_option :invisible_create, type: :string, default: ""
  class_option :invisible_update, type: :string, default: ""

  class_option :ujs_syntax, type: :boolean, default: nil
  class_option :downnest, type: :string, default: nil
  class_option :magic_buttons, type: :string, default: nil
  class_option :small_buttons, type: :boolean, default: nil
  class_option :display_list_after_update, type: :boolean, default: false
  class_option :display_edit_after_create, type: :boolean, default: false
  class_option :new_in_modal, type: :boolean, default: false
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
  class_option :form_labels_position, type: :string #  choices are before, after, omit
  class_option :form_placeholder_labels, type: :boolean, default: false # puts the field names into the placeholder labels

  # determines if labels appear within the rows of the VIEWABLE list (does NOT affect the list heading)
  class_option :inline_list_labels, default: nil # default is set below
  class_option :factory_creation, default: nil
  class_option :alt_foreign_key_lookup, default: '' #
  class_option :attachments, default: ''
  class_option :stacked_downnesting, default: false
  class_option :bootstrap_column_width, default: nil # must be nil to detect if user has not passed
  class_option :button_icons, default: nil
  class_option :modify, default: {}
  class_option :display_as, default: {}
  class_option :pundit, default: nil
  class_option :pundit_policy_override, default: nil
  class_option :related_sets, default: ''
  class_option :code_before_create, default: nil
  class_option :code_after_create, default: nil
  class_option :code_before_update, default: nil
  class_option :code_after_update, default: nil
  class_option :code_after_new, default: nil
  class_option :record_scope, default: nil
  class_option :no_nav_menu, type: :boolean, default: false # suppress writing to _nav template
  class_option :include_object_names, type: :boolean, default: false
  class_option :new_button_position, type: :string, default: 'above'
  class_option :downnest_shows_headings, type: :boolean, default: nil
  class_option :stimmify, type: :string, default: nil
  class_option :phantom_create_params, type: :string, default: nil
  class_option :phantom_update_params, type: :string, default: nil
  class_option :controller_prefix, type: :string, default: nil

  # SEARCH OPTIONS
  class_option :search, default: nil # set or predicate

  # FOR THE SET SEARCH
  class_option :search_fields, default: nil # comma separated list of all fields to search

  # for the single-entry search box, they will be removed from the list specified above.
  class_option :search_query_fields, default: '' # comma separated list of fields to search by single-entry search term
  class_option :search_position, default: 'vertical' # choices are vertical or horizontal
  class_option :search_clear_button, default: false
  class_option :search_autosearch, default: false

  # FOR THE PREDICATE SEARCH
  # TDB


  class_option :phantom_search, default: nil



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
      raise(HotGlue::Error, "*** Oops: You seem to have specified both the --specs-only flag and --no-specs flags. this doesn't make any sense, so I am aborting. Aborting.")
    end

    if !options['exclude'].empty? && !options['include'].empty?
      exit_message = "*** Oops: You seem to have specified both --include and --exclude. Please use one or the other. Aborting."
      puts exit_message

      raise(HotGlue::Error, exit_message)
    end

    if @stimulus_syntax.nil?
      @stimulus_syntax = true
    end


    if Gem::Specification.find_all_by_name('pagy').any?
      @pagination_style = 'pagy'
    elsif Gem::Specification.find_all_by_name('will_paginate').any?
      @pagination_style = 'will_paginate'
    elsif Gem::Specification.find_all_by_name('kaminari').any?
      @pagination_style = 'kaminari'
    end

    if !options['markup'].nil?
      message = "Using --markup flag in the generator is deprecated; instead, use a file at config/hot_glue.yml with a key markup set to `erb` or `haml`"
      raise(HotGlue::Error, message)
    end

    @markup = get_default_from_config(key: :markup)
    @sample_file_path = get_default_from_config(key: :sample_file_path)
    @bootstrap_column_width ||= options['bootstrap_column_width'] ||
      get_default_from_config(key: :bootstrap_column_width) || 2


    @controller_prefix = options['controller_prefix']
    @default_boolean_display = get_default_from_config(key: :default_boolean_display)
    if options['layout']
      layout = options['layout']
    else
      layout = get_default_from_config(key: :layout)

      if !['hotglue', 'bootstrap', 'tailwind'].include? layout
        raise "Invalid option #{layout} in Hot glue config (config/hot_glue.yml). You must either use --layout= when generating or have a file config/hotglue.yml; specify layout as either 'hotglue' or 'bootstrap'"
      end
    end

    @button_icons = get_default_from_config(key: :button_icons) || 'none'

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


    @singular =   args.first.tableize.singularize # should be in form hello_world

    if @singular.include?("/")
      @singular = @singular.split("/").last
    end

    @plural = (options['plural'] || args.first.tableize.singularize.pluralize)
    if @plural.include?("/")
      @plural = @plural.split("/").last
    end
    # respects what you set in inflections.rb, to override, use plural option
    puts "SINGULAR: #{@singular}"
    puts "PLURAL: #{@plural}"

    @namespace = options['namespace'] || nil
    @namespace_value = @namespace
    use_controller_name =  plural.titleize.gsub(" ", "")


    @controller_build_name =  ((@namespace.titleize.gsub(" ", "") + "::" if @namespace) || "") + (@controller_prefix ? @controller_prefix.titleize : "") + use_controller_name + "Controller"
    @controller_build_folder = (@controller_prefix ? @controller_prefix.downcase + "_" : "") + use_controller_name.underscore
    @controller_build_folder_singular = singular

    @auth = options['auth'] || "current_user"

    @god = options['god'] || options['gd'] || false
    @auth_identifier = options['auth_identifier'] || (!@god && @auth.gsub("current_", "")) || nil

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
      @include_fields += options['include'].split(":").collect { |x| x.split(",") }.flatten.collect(&:to_sym)
    end



    @show_only = options['show_only'].split(",").collect(&:to_sym)
    if @show_only.any?
      puts "show only field #{@show_only}}"
    end

    @hidden_all = options['hidden'].split(",").collect(&:to_sym)
    @hidden_create = options['hidden_create'].split(",").collect(&:to_sym)
    @hidden_update = options['hidden_update'].split(",").collect(&:to_sym)
    @hidden_update.concat(@hidden_all) if @hidden_all.any?
    @hidden_create.concat(@hidden_all) if @hidden_all.any?
    @hidden_create.uniq!
    @hidden_update.uniq!

    if @hidden_create.any? || @hidden_update.any? || @hidden_all.any?
      puts "hidden update fields #{@hidden_update}}"
      puts "hidden create fields #{@hidden_create}}"
    end


    @invisible_all = options['invisible'].split(",").collect(&:to_sym)
    @invisible_create = options['invisible_create'].split(",").collect(&:to_sym)
    @invisible_update = options['invisible_update'].split(",").collect(&:to_sym)
    @invisible_update.concat(@invisible_all) if @invisible_all.any?
    @invisible_update.uniq!
    @invisible_create.concat(@invisible_all) if @invisible_all.any?
    @invisible_create.uniq!


    @modify_as = {}
    if !options['modify'].empty?
      modify_input = options['modify'].split(",")
      modify_input.each do |setting|
        if setting.include?("[")
          setting =~ /(.*){(.*)}\[(.*)\]/
          key, lookup_as = $1, $2, $3
        else
          setting =~ /(.*){(.*)}/
          key, lookup_as = $1, $2
        end
        if ["$"].include?($2)
          @modify_as[key.to_sym] =  {cast: $2, badges: $3}
        elsif $2.include?("|")
          binary = $2.split("|")
          @modify_as[key.to_sym] =  {binary: {truthy: binary[0],
                                              falsy: binary[1]},
                                              badges: $3}
        elsif $2 == "partial"
          @modify_as[key.to_sym] =  {enum: :partials, badges: $3 }
        elsif $2 == "tinymce"
          @modify_as[key.to_sym] =  {tinymce: 1, badges: $3}
        elsif $2 == "typeahead"
          if !$3.nil?
            nested = $3.split("/")
          else
            nested = []
          end
          @modify_as[key.to_sym] =  {typeahead: 1, nested: nested}
        elsif $2 == "timezone"
          @modify_as[key.to_sym] =  {timezone: 1, badges: $3}
        elsif $2 == "include_blank"
          @modify_as[key.to_sym] =  {include_blank: true}
        elsif $2 == "none"
          @modify_as[key.to_sym] =  {none: 1, badges: $3}
        else
          raise "unknown modification direction #{$2}"
        end
      end
    end

    @display_as = {}
    if !options['display_as'].empty?
      display_input = options['display_as'].split(",")

      display_input.each do |setting|
        setting =~ /(.*){(.*)}/
        key, lookup_as = $1, $2
        @display_as[key.to_sym] =  {boolean: $2}
      end
    end


    @update_show_only = []
    if !options['update_show_only'].empty?
      @update_show_only += options['update_show_only'].split(",").collect(&:to_sym)
    end

    # syntax should be xyz_id{xyz_email},abc_id{abc_email}
    # instead of a drop-down for the foreign entity, a text field will be presented
    # You must ALSO use a factory that contains a parameter of the same name as the 'value' (for example, `xyz_email`)

    @label = options['label'] || (eval("#{class_name}.class_variable_defined?(:@@table_label_singular)") ? eval("#{class_name}.class_variable_get(:@@table_label_singular)") : singular.gsub("_", " ").titleize)
    @list_label_heading = options['list_label_heading'] || (eval("#{class_name}.class_variable_defined?(:@@table_label_plural)") ? eval("#{class_name}.class_variable_get(:@@table_label_plural)") : plural.gsub("_", " ").upcase)

    @new_button_label = options['new_button_label'] || (eval("#{class_name}.class_variable_defined?(:@@table_label_singular)") ? "New " + eval("#{class_name}.class_variable_get(:@@table_label_singular)") : "New " + singular.gsub("_", " ").titleize)
    @new_form_heading = options['new_form_heading'] || "New #{@label}"

    # @table_display_name_singular = (eval("#{class_name}.class_variable_defined?(:@@table_label_singular)") ? eval("#{class_name}.class_variable_get(:@@table_label_singular)") : singular.gsub("_", " ").titleize)
    @table_display_name_plural = (eval("#{class_name}.class_variable_defined?(:@@table_label_plural)") ? eval("#{class_name}.class_variable_get(:@@table_label_plural)") : plural.gsub("_", " ").titleize)

    setup_hawk_keys
    @form_placeholder_labels = options['form_placeholder_labels'] # true or false
    @inline_list_labels = options['inline_list_labels'] || get_default_from_config(key: :inline_list_labels) || 'omit' # 'before','after','omit'

    @form_labels_position = options['form_labels_position']
    if @form_labels_position.nil?
      @form_labels_position = get_default_from_config(key: :form_labels_position)
      if @form_labels_position.nil?
        @form_labels_position = 'after'
      end
    else
      if !['before', 'after', 'omit'].include?(@form_labels_position)
        raise HotGlue::Error, "You passed '#{@form_labels_position}' as the setting for --form-labels-position but the only allowed options are before, after (default), and omit"
      end
    end


    if !['before', 'after', 'omit'].include?(@inline_list_labels)
      raise HotGlue::Error, "You passed '#{@inline_list_labels}' as the setting for --inline-list-labels but the only allowed options are before, after, and omit (default)"
    end

    @specs_only = options['specs_only'] || false

    @no_specs = options['no_specs'] || false
    @no_delete = options['no_delete'] || false

    @no_create = options['no_create'] || false
    @no_paginate = options['no_paginate'] || false
    @paginate_per_page_selector = options['paginate_per_page_selector']

    @big_edit = options['big_edit']

    @no_edit = options['no_edit'] || false
    @no_list = options['no_list'] || false

    @no_controller = options['no_controller'] || false
    @no_list = options['no_list'] || false
    @no_list_label = options['no_list_label'] || false
    @no_list_heading = options['no_list_heading'] || false
    @stacked_downnesting = options['stacked_downnesting']

    @display_list_after_update = options['display_list_after_update'] || false
    @display_edit_after_create = options['display_edit_after_create'] || false
    @new_in_modal = options['new_in_modal'] || false

    @smart_layout = options['smart_layout']
    @record_scope = options['record_scope']
    @downnest_shows_headings = options['downnest_shows_headings']
    @new_button_position = options['new_button_position']


    @pundit = options['pundit']
    @pundit_policy_override = options['pundit_policy_override']

    @no_nav_menu = options['no_nav_menu']

    @phantom_create_params = options['phantom_create_params'] || ""
    @phantom_update_params = options['phantom_update_params'] || ""

    if get_default_from_config(key: :pundit_default)
      raise "please note the config setting `pundit_default` has been renamed `pundit`. please update your hot_glue.yml file"
    end

    if @pundit.nil?
      @pundit = get_default_from_config(key: :pundit)
    end


    if (@invisible_create + @invisible_update).any? && !@pundit
      raise "you specified invisible fields without using Pundit. please remove the invisible fields or use --pundit"
    end

    if options['include'].include?(":") && @smart_layout
      raise HotGlue::Error, "You specified both --smart-layout and also specified grouping mode (there is a : character in your field include list); you must remove the colon(s) from your --include tag or remove the --smart-layout option"
    end

    @container_name = @layout_strategy.container_name
    @downnest = options['downnest'] || false

    @downnest_children = [] # TODO: defactor @downnest_children in favor of downnest_object
    @downnest_object = {}

    if @downnest
      @downnest_children = @downnest.split(",")

      @downnest_children.each do |child|
        if child.include?("(")
          child =~ /(.*)\((.*)\)/
          child_name, polymorph_as = $1, $2
        else
          child_name = child
        end
        extra_size = child_name.count("+")

        child_name.gsub!("+","")


        @downnest_object[child] = {
          name: child_name,
          extra_size: extra_size,
          polymorph_as: polymorph_as
        }
      end
    end




    @include_object_names = options['include_object_names'] || get_default_from_config(key: :include_object_names)



    if @god
      # @auth = nil
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

    if !@nested.nil?
      @nested_set = @nested.split("/").collect { |arg|
        if arg.include?("(")
          arg =~ /(.*)\((.*)\)/
          singular, polymorph_as = $1, $2
        else
          singular = arg
        end

        {
          singular: singular,
          plural: singular.pluralize,
          polymorph_as: polymorph_as
        }
      }
      puts "NESTING: #{@nested_set}"
    end

    if @nested_set.any?
      @lazy = true
    end

    # related_sets
    related_set_input = options['related_sets'].split(",")
    @related_sets = {}
    related_set_input.each do |setting|

      if setting.include?("{") && setting.include?("[")
        setting =~ /(.*){(.*)}\[(.*)\]/
        key, label, hawk = $1, $2 , $3
      elsif setting.include?("{") && !setting.include?("[")
        setting =~ /(.*){(.*)}/
        key, label = $1, $2 , $3
      elsif setting.include?("[") && !setting.include?("{")
        setting =~ /(.*)\[(.*)\]/
        key, hawk = $1, $2
      else

        key = setting
        label = "label"
      end

      association_ids_method = eval("#{singular_class}.reflect_on_association(:#{key.to_sym})").class_name.underscore + "_ids"
      class_name = eval("#{singular_class}.reflect_on_association(:#{key.to_sym})").class_name

      @related_sets[key.to_sym] =   { name: key.to_sym,
                          association_ids_method: association_ids_method,
                          class_name: class_name,
                          label_field: label,
                          hawk: hawk }
    end

    if @related_sets.any?
      puts "RELATED SETS: #{@related_sets}"

    end

    # OBJECT OWNERSHIP & NESTING
    @reference_name = HotGlue.derrive_reference_name(singular_class)


    if @auth && @self_auth
      @object_owner_sym = @auth.gsub("current_", "").to_sym
      @object_owner_eval = @auth
      @object_owner_optional = false
      @object_owner_name = @auth.gsub("current_", "").to_s

    elsif @auth && !@self_auth && @nested_set.none? && !@auth.include?(".")
      @object_owner_sym = @auth.gsub("current_", "").to_sym
      @object_owner_eval = @auth
      @object_owner_optional = false
      @object_owner_name = @auth.gsub("current_", "").to_s

    elsif @auth && @auth.include?(".")
      @object_owner_sym = nil
      @object_owner_eval = @auth
    else
      if @nested_set.any?

        @object_owner_sym = (@nested_set.last[:polymorph_as] || @nested_set.last[:singular]).to_sym

        @object_owner_eval = "#{( @nested_set.last[:singular])}"
        @object_owner_name = (@nested_set.last[:polymorph_as] || @nested_set.last[:singular])
      else
        @object_owner_sym = nil
        @object_owner_eval = ""
      end
    end

    unless options['factory_creation'].nil?
      @factory_creation = options['factory_creation'].gsub(";", "\n")
    end

    identify_object_owner
    setup_fields


    if (@columns - @show_only - (@ownership_field ? [@ownership_field.to_sym] : [])).empty?
      @no_field_form = true
    end

    @code_before_create = options['code_before_create']
    @code_after_create = options['code_after_create']
    @code_before_update = options['code_before_update']
    @code_after_update = options['code_after_update']
    @code_after_new = options['code_after_new']

    buttons_width = ((!@no_edit && 1) || 0) + ((!@no_delete && 1) || 0) + (@magic_buttons.any? ? 1 : 0)


    # alt_lookups_entry =


    @alt_lookups = {}

    options['alt_foreign_key_lookup'].split(",").each do |setting|
      setting =~ /(.*){(.*)}/
      key, lookup_as = $1, $2



      if !eval("#{class_name}.reflect_on_association(:#{key.to_s.gsub("_id","")})")
        raise "couldn't find association for #{key} in the object #{class_name}"
      end
      assoc = eval("#{class_name}.reflect_on_association(:#{key.to_s.gsub("_id","")}).class_name")

      data = {lookup_as: lookup_as.gsub("+",""),
              assoc: assoc,
              with_create: lookup_as.include?("+")}
      @alt_lookups[key] = data
    end



    # @update_alt_lookups = @alt_lookups.collect{|key, value|
    #   @update_show_only.include?(key) ?
    #     {  key: value }
    #     : nil}.compact

    @stimmify = options['stimmify']
    if @stimmify === "stimmify"
      @stimmify = @singular.gsub("_", "-") + "-form"
      @stimify_camel = @stimmify.camelize
    end

    # build a new polymorphic object
    @associations = []
    @columns_map = {}
    @columns.each do |col|
      # if !(@the_object.columns_hash.keys.include?(col.to_s) || @attachments.keys.include?(col))
      #   raise "couldn't find #{col} in either field list or attachments list"
      # end

      if col.to_s.starts_with?("_")
        @show_only << col
      end

      if @the_object.columns_hash.keys.include?(col.to_s)
        type = @the_object.columns_hash[col.to_s].type
      elsif @attachments.keys.include?(col)
        type = :attachment
      elsif @related_sets.keys.include?(col)
        type = :related_set
      else
        raise "couldn't find #{col} in either field list, attachments, or related sets"
      end
      this_column_object = FieldFactory.new(name: col.to_s,
                                            generator: self,
                                            type: type)
      field = this_column_object.field
      if field.is_a?(AssociationField)
        @associations << field.assoc_name.to_sym
      end
      @columns_map[col] = this_column_object.field
    end


    @columns_map.each do |key, field|
      if field.is_a?(AssociationField)
        if @modify_as && @modify_as[key] && @modify_as[key][:typeahead]
          assoc_name = field.assoc_name
          file_path = "app/controllers/#{@namespace ? @namespace + "/" : ""}#{assoc_name.pluralize}_typeahead_controller.rb"

          if ! File.exist?(file_path)

            assoc_model = eval("#{class_name}.reflect_on_association(:#{field.assoc_name})")
            assoc_class = assoc_model.class_name
            puts "##############################################"
            puts "WARNING: you specified --modify=#{key}{typeahead} but there is no file at `#{file_path}`; please create one with:"
            puts "bin/rails generate hot_glue:typeahead #{assoc_class} #{namespace ? " --namespace=\#{namespace}" : ""}"
            puts "##############################################"
          end
        end
      end
    end


    puts "------ ALT LOOKUPS for #{@alt_lookups}"
    @alt_lookups.each do |key, value|
      if !@columns_map[key.to_sym].is_a?(AssociationField)
        raise "You specified an alt-lookup for #{key} but that field is not an association field"
      elsif !@columns_map[key.to_sym]
        raise "You specified an alt-lookup for #{key} but that field does not exist in the list of columns"
      elsif !@god && !@hawk_keys.include?(key.to_sym)
        raise "You specified an alt-lookup for #{key} in non-Gd mode but this would leave the lookup unprotected. To fix, use with --hawk or with --factory-creation "
      end
    end


    if options['phantom_search']
      ps_input = options['phantom_search']

      ps_input =~ /(.*)\[(.*)\]/
      type_and_label, settings = $1, $2


      type = type_and_label.split("_")[0]
      label = type_and_label.split("_")[1]

      @phantom_search = {}
      choices = settings.split("|")


      @phantom_search[label.to_sym] = {
        type: type,
        name: label.humanize,
        choices: []
      }

      choices.each do |choice|
        if type == "radio"
          choice_label = choice.split(":")[0]
          choice_scope = choice.split(":")[1]
        elsif type == "checkboxes"
          choice_label = choice.split(":")[0]
          choice_scope_negative = choice.split(":")[1]
          choice_scope  = choice.split(":")[2]
        end

        if choice_scope.nil? || choice_scope.strip.empty?
          choice_scope = "all"
        end

        if choice_scope_negative.nil? || choice_scope_negative.strip.empty?
          choice_scope_negative = "all"
        end

        choice_scope = ".#{choice_scope}" if !choice_scope.start_with?(".")
        choice_scope_negative = ".#{choice_scope_negative}" if !choice_scope_negative.start_with?(".")

        @phantom_search[label.to_sym][:choices] << {
          label: choice_label,
          scope: choice_scope,
          scope_negative: choice_scope_negative,
        }
      end
      puts "phantom search #{@phantom_search}"
    else
      @phantom_search = {}
    end

    # search
    @search = options['search']

    if @search == 'set'
      if options['search_fields'].nil?
        if  !@phantom_search
          puts "Since you did not specify search fields or phantom search fields I am including all columns in search"
          @search_fields = @columns
        else
          @search_fields = []
        end
      else
        @search_fields = options['search_fields'].split(',')
      end

      # within the set search we will take out any fields on the query list
      # or the field
      @search_query_fields = options['search_query_fields'].split(',') || []
      @search_position = options['search_position'] || 'vertical'

      @search_fields = @search_fields - @search_query_fields

      @search_clear_button = !!options['search_clear_button']
      @search_autosearch = !!options['search_autosearch']

    elsif @search == 'predicate'

    end

    if @search_fields
      @search_fields.each do |field|
        if !@columns.include?(field.to_sym) && !@phantom_search.include?(field.to_sym)
          raise "You specified a search field for #{field} but that field is not in the list of columns"
        end
      end
    end

    builder = HotGlue::Layout::Builder.new(generator: self,
                                           include_setting: options['include'],
                                           buttons_width: buttons_width)

    @layout_object = builder.construct

    # syntax should be xyz_id{xyz_email},abc_id{abc_email}
    # instead of a drop-down for the foreign entity, a text field will be presented
    # You must ALSO use a factory that contains a parameter of the same name as the 'value' (for example, `xyz_email`)

    # create the template object


    if @markup == "erb"
      @template_builder = HotGlue::ErbTemplate.new(
        layout_object: @layout_object,
        layout_strategy: @layout_strategy,
        magic_buttons: @magic_buttons,
        small_buttons: @small_buttons,
        inline_list_labels: @inline_list_labels,
        show_only: @show_only,
        update_show_only: @update_show_only,
        singular_class: singular_class,
        singular: singular,
        plural: @plural,
        hawk_keys: @hawk_keys,
        ownership_field: @ownership_field,
        form_labels_position: @form_labels_position,
        form_placeholder_labels: @form_placeholder_labels,
        attachments: @attachments,
        columns_map: @columns_map,
        pundit: @pundit,
        related_sets: @related_sets,
        search: @search,
        search_fields: @search_fields,
        search_query_fields: @search_query_fields,
        search_position: @search_position,
        search_clear_button: @search_clear_button,
        search_autosearch: @search_autosearch,
        form_path: form_path_new_helper,
        stimmify: @stimmify,
        stimmify_camel: @stimmify_camel,
        hidden_create: @hidden_create,
        hidden_update: @hidden_update,
        invisible_create: @invisible_create,
        invisible_update: @invisible_update,
        phantom_search: @phantom_search,
        pagination_style: @pagination_style
      )
    elsif @markup == "slim"
      raise(HotGlue::Error, "SLIM IS NOT IMPLEMENTED")
    elsif @markup == "haml"
      raise(HotGlue::Error, "HAML IS NOT IMPLEMENTED")
    end


    @menu_file_exists = true if @nested_set.none? && File.exist?("#{Rails.root}/app/views/#{namespace_with_trailing_dash}_menu.#{@markup}")

    @turbo_streams = !!options['with_turbo_streams']

    puts "show only #{@show_only}"
    puts "update show only #{@update_show_only}"

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

        if eval(singular_class + ".reflect_on_association(:#{key.gsub('_id', '')})").nil?
          raise "Could not find `#{key.gsub('_id', '')}` association; add this to the #{singular_class} class: \nbelongs_to :#{key.gsub('_id', '')} "
        end

        optional = eval(singular_class + ".reflect_on_association(:#{key.gsub('_id', '')})").options[:optional]

        @hawk_keys[key.to_sym] = { bind_to: [hawk_to], optional: optional }
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

          if Rails.version.to_f >= 7.1
            thumb = eval("#{singular_class}.reflect_on_attachment(:#{attachment_entry}).named_variants.include?(:thumb)")
          else
            thumb = eval("#{singular_class}.reflect_on_attachment(:#{attachment_entry}).variants.include?(:thumb)")
          end

          if thumb
            thumbnail = "thumb"
          else
            thumbnail = nil
          end

          direct_upload = nil
          field_for_original_filename = nil
          dropzone = nil
        end

        if thumbnail
          if Rails.version.to_f >= 7.1
            check_for_missing_variant = !eval("#{singular_class}.reflect_on_attachment(:#{key}).named_variants.include?(:#{thumbnail})")
          else
            check_for_missing_variant = !eval("#{singular_class}.reflect_on_attachment(:#{key}).variants.include?(:#{thumbnail})")
          end
          if  check_for_missing_variant
          raise HotGlue::Error, "you specified to use #{thumbnail} as the thumbnail but could not find any such variant on the #{key} attachment; add to your #{singular}.rb file:
  has_one_attached :#{key} do |attachable|
    attachable.variant :#{thumbnail}, resize_to_limit: [100, 100]
  end
"
          end
        end

        @attachments[key.to_sym] = { thumbnail: thumbnail,
                                     field_for_original_filename: field_for_original_filename,
                                     direct_upload: direct_upload,
                                     dropzone: dropzone }
      end

      puts "ATTACHMENTS: #{@attachments}"
    end
  end

  def identify_object_owner
    return if @god
    auth_assoc = @auth && @auth.gsub("current_", "")

    if @object_owner_sym && !@self_auth
      auth_assoc_field = auth_assoc + "_id" unless @god
      assoc = eval("#{singular_class}.reflect_on_association(:#{@object_owner_sym})")

      if assoc
        @ownership_field = assoc.name.to_s + "_id"
      elsif !@nested_set.any?
        exit_message = "*** Oops: It looks like is no association `#{@object_owner_sym}` from the object #{@singular_class}. If your user is called something else, pass with flag auth=current_X where X is the model for your users as lowercase. Also, be sure to implement current_X as a method on your controller. (If you really don't want to implement a current_X on your controller and want me to check some other method for your current user, see the section in the docs for auth_identifier.) To make a controller that can read all records, specify with --god."
        raise(HotGlue::Error, exit_message)

      else
        exit_message = "When trying to nest #{singular_class} within #{@nested_set.last[:plural]}, check the #{singular_class} model for the #{@object_owner_sym} association: \n belongs_to :#{@object_owner_sym}"
        raise(HotGlue::Error, exit_message)
      end
    elsif @object_owner_sym && !@object_owner_eval.include?(".")
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


      # TODO: this should exclude any nested parents
      @exclude_fields.push(@ownership_field.to_sym) if !@ownership_field.nil?

      @columns = @the_object.columns.map(&:name).map(&:to_sym).reject { |field| @exclude_fields.include?(field) }

    else
      @columns = @the_object.columns.map(&:name).map(&:to_sym).reject { |field| !@include_fields.include?(field) }
    end

    @columns = @columns - @nested_set.collect { |set| (set[:singular] + "_id").to_sym  }

    if @attachments.any?
      puts "Adding attachments-as-columns: #{@attachments}"
      @attachments.keys.each do |attachment|
        @columns << attachment if !@columns.include?(attachment)
      end

      check_if_sample_file_is_present
    end

    if @related_sets.any?
      if !@pundit
        puts "********************\nWARNING: You are using --related-sets without using Pundit. This makes the set fully accessible. Use Pundit to prevent a privileged escalation vulnerability\n********************\n"
      end
      @related_sets.each do |key, related_set|
        @columns << related_set[:name] if !@columns.include?(related_set[:name])
        puts "Adding related set :#{related_set[:name]} as-a-column"
      end
    end
  end

  def check_if_sample_file_is_present
    if sample_file_path.nil?
      puts "you have no sample file path set in config/hot_glue.yml"
      settings = File.read("config/hot_glue.yml")
      @sample_file_path = "spec/files/computer_code.jpg"
      added_setting = ":sample_file_path: #{sample_file_path}"
      File.open("config/hot_glue.yml", "w") { |f| f.write settings + "\n" + added_setting }

      puts "adding `#{added_setting}` to config/hot_glue.yml"
    elsif !File.exist?(sample_file_path)
      puts "NO SAMPLE FILE FOUND: adding sample file at #{sample_file_path}"
      template "computer_code.jpg", File.join("#{filepath_prefix}spec/files/", "computer_code.jpg")
    end

    puts ""
  end

  def fields_filtered_for_strong_params
    @columns - @related_sets.collect{|key, set| set[:name]}
  end

  def creation_syntax
    if @factory_creation.nil? && ! @alt_lookups.any?
      (      @hawk_keys.any? ?   "modified_params = hawk_params({#{ hawk_to_ruby }}, modified_params)\n    " : "")  + "@#{singular } = #{ class_name }.new(modified_params)"
    elsif @factory_creation.nil? && @alt_lookups.any?

      prelookup_syntax = @alt_lookups.collect{|lookup, data|
        col = @columns_map[lookup.to_sym]
        col.prelookup_syntax
      }.join("\n")

      prelookup_syntax + "\n     @#{singular } = #{ class_name }.new(modified_params" +
        (@alt_lookups.any? ? (".merge(" + @alt_lookups.collect{|lookup,field|
          field_name = lookup.gsub("_id","")
          "#{field_name}: #{field_name}"
        }.join(",") + ")" ) : "") + ")"

    else
      res = +"begin
      #{@factory_creation}
      "
      res << "\n      " + "@#{singular} = factory.#{singular}" unless res.include?("@#{singular} = factory.#{singular}")
      res << "\n    rescue ActiveRecord::RecordInvalid
      @#{singular} = factory.#{singular}
      @action = 'new'
    end"
      res
    end
  end

  def formats
    [format]
  end

  def format
    nil
  end

  def filepath_prefix
    'spec/dummy/' if $INTERNAL_SPECS
  end

  def copy_controller_and_spec_files
    @default_colspan = @columns.size

    unless @specs_only || @no_controller
      template "controller.rb.erb", File.join("#{filepath_prefix}app/controllers#{namespace_with_dash}", "#{@controller_build_folder}_controller.rb")
      if @namespace
        begin
          eval(controller_descends_from)
        rescue NameError => e
          template "base_controller.rb.erb", File.join("#{filepath_prefix}app/controllers#{namespace_with_dash}", "base_controller.rb")
        end
      end
    end

    unless @no_specs
      dest_file = File.join("#{filepath_prefix}spec/features#{namespace_with_dash}", "#{plural}_behavior_spec.rb")

      if File.exist?(dest_file)
        existing_file = File.open(dest_file)
        existing_content = existing_file.read
        if existing_content =~ /\# HOTGLUE-SAVESTART/
          if existing_content !~ /\# HOTGLUE-END/
            raise "Your file at #{dest_file} contains a # HOTGLUE-SAVESTART marker without # HOTGLUE-END"
          end
          @existing_content = existing_content[(existing_content =~ /\# HOTGLUE-SAVESTART/)..(existing_content =~ /\# HOTGLUE-END/) - 1]
          @existing_content << "# HOTGLUE-END"

        else
          @existing_content = "  # HOTGLUE-SAVESTART\n  # HOTGLUE-END"
        end
        existing_file.rewind
      else
        @existing_content = "  # HOTGLUE-SAVESTART\n  # HOTGLUE-END"
      end

      template "system_spec.rb.erb", dest_file
    end
    # if !File.exist?("#{filepath_prefix}app/views#{namespace_with_dash}/_errors.#{@markup}")
    #   # File.delete("#{filepath_prefix}app/views#{namespace_with_dash}/_errors.#{@markup}")
    #
    #   template "_errors.erb", File.join("#{filepath_prefix}app/views#{namespace_with_dash}", "_errors.#{@markup}")
    # end
  end

  def spec_foreign_association_merge_hash
    ", #{testing_name}: #{testing_name}1"
  end

  def testing_name
    singular_class.gsub("::", "_").underscore
  end

  def factory_testing_name
    if !@self_auth
      "#{singular}1"
    else
      "current_#{singular}"
    end
  end

  def spec_related_column_lets
    @columns_map.collect { |col, col_object|
      col_object.spec_related_column_lets
    }.join("\n")
  end

  def list_column_headings
    @template_builder.list_column_headings(
      column_width: @layout_strategy.column_width,
      singular: @singular
    )
  end

  def columns_spec_with_sample_data
    @columns_map.map { |col, col_object|
      unless col_object.is_a?(AssociationField)
        random_data = col_object.spec_random_data
        col.to_s + ": '" + random_data.to_s + "'"
      end
    }.join(", ")
  end

  def regenerate_me_code
    "bin/rails generate hot_glue:scaffold #{ @meta_args[0][0] } #{@meta_args[1].collect { |x| x.gsub(/\s*=\s*([\S\s]+)/, '=\'\1\'') }.join(" ")}"
  end

  def object_parent_mapping_as_argument_for_specs

    if @self_auth
      ""
    elsif @nested_set.any? && !@nested_set.last[:optional]
      ", " + @nested_set.last[:singular] + ": " + @nested_set.last[:singular]
    elsif @auth && !@god
      ", #{@auth_identifier}: #{@auth}"
    end
  end

  def objest_nest_factory_setup
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

  def nested_path
    @nested_set.collect{| arg| arg[:plural] + "/\#{#{arg[:singular]}.id}/" }.join("/")
  end


  def objest_nest_params_by_id_for_specs
    @nested_set.map { |arg|
      "#{arg[:singular]}_id: #{arg[:singular] }.id"
    }.join(",\n          ")
  end

  def nest_path
    @nested_set.collect{| arg| arg[:singular]  }.join("/") + "/" if @nested_set.any?
  end

  def controller_class_name
    @controller_build_name
  end

  def plural_name
    plural
  end

  def auth_identifier
    @auth_identifier
  end

  def capybara_make_updates(which_partial = :create)
    @columns_map.map { |col, col_obj|
      show_only_list = which_partial == :create ? @show_only : (@update_show_only + @show_only)

      if show_only_list.include?(col)
        # TODO: decide if this should get re-implemeneted
        # "      page.should have_no_selector(:css, \"[name='#{testing_name}[#{ col.to_s }]'\")"
      else
        col_obj.spec_setup_and_change_act(which_partial)
      end
    }.join("\n")
  end

  def path_helper_args
    if @nested_set.any? && @nested
      [(@nested_set).collect { |a| "#{a[:singular]}" }, singular].join(",")
    else
      singular
    end
  end

  def path_helper_singular
    if @nested
      "#{@namespace + "_" if @namespace}#{(@nested_set.collect { |x| x[:singular] }.join("_") + "_" if @nested_set.any?)}#{@controller_build_folder_singular}_path"
    else
      "#{@namespace + "_" if @namespace}#{@controller_build_folder_singular}_path"
    end
  end

  def path_helper_plural(top_level = false)
    HotGlue.optionalized_ternary(namespace: @namespace,
                                 target: @controller_build_folder,
                                 nested_set: @nested_set,
                                 top_level: top_level)
  end

  def edit_parent_path_helper
    # the path to the edit route of the PARENT
    if @nested_set.any? && @nested
      "edit_#{@namespace + "_" if @namespace}#{(@nested_set.collect { |x| x[:singular] }.join("_") + "_" if @nested_set.any?)}path(" +
      "#{@nested_set.collect { |x| x[:singular] }.join(", ")}" + ")"

    else
      "edit_#{@namespace + "_" if @namespace}path"
    end
  end

  def datetime_fields_list
    @columns.each_with_object({}) do |col, hash|
      column = @the_object.columns_hash[col.to_s]
      if column && [:datetime, :time].include?(column.type)
        hash[col.to_sym] = column.type
      end
    end
  end




  def form_path_new_helper
    HotGlue.optionalized_ternary(namespace: @namespace,
                                 target: @controller_build_folder,
                                 nested_set: @nested_set,
                                 with_params: false,
                                 top_level: false)
  end

  def form_path_edit_helper
    HotGlue.optionalized_ternary(namespace: @namespace,
                                 target:  @singular,
                                 prefix: (@controller_prefix ? @controller_prefix.downcase + "_" : ""),
                                 nested_set: @nested_set,
                                 with_params: false,
                                 put_form: true,
                                 top_level: false)
  end

  def delete_path_helper
    HotGlue.optionalized_ternary(namespace: @namespace,
                                 prefix: (@controller_prefix ? @controller_prefix.downcase + "_" : ""),
                                 target: @singular,
                                 nested_set: @nested_set,
                                 with_params: false,
                                 put_form: true)
  end

  def edit_path_helper
    HotGlue.optionalized_ternary(namespace: @namespace,
                                 prefix: (@controller_prefix ? @controller_prefix.downcase + "_" : ""),
                                 target: @singular,
                                 nested_set: @nested_set,
                                 modifier: "edit_",
                                 with_params: false,
                                 put_form: true)
  end

  def new_path_name
    HotGlue.optionalized_ternary(namespace: @namespace,
                                 target: singular,
                                 prefix: (@controller_prefix ? @controller_prefix.downcase + "_" : ""),
                                 nested_set: @nested_set,
                                 modifier: "new_",
                                 with_params: false)
  end


  def path_arity
    res = ""
    if @nested_set.any? && @nested
      res << nested_objects_arity + ", "
    end
    res << "@" + singular
  end

  def line_path_partial
    "#{@namespace + "/" if @namespace}#{@controller_build_folder}/line"
  end

  def show_path_partial
    "#{@namespace + "/" if @namespace}#{@controller_build_folder}/show"
  end

  def list_path_partial
    "#{@namespace + "/" if @namespace}#{@controller_build_folder}/list"
  end


  def nested_assignments
    return "" if @nested_set.none?
    @nested_set.map { |a| "#{a}: #{a}" }.join(", ") # metaprgramming into Ruby hash
  end

  def nested_assignments_top_level # this is by accessing the instance variable-- only use at top level
    @nested_set.map { |a| "#{a[:singular]}" }.join(", ") # metaprgramming into Ruby hash
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
    @nested_set.map { |a| "@#{a[:singular]}" }.join(", ")
  end

  def nested_arity_for_path
    [@nested_set[0..-1].collect { |a| "@#{a[:singular]}" }].join(", ") # metaprgramming into arity for the Rails path helper
  end

  def object_scope
    if @auth && !@god
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
  #
  # def all_objects_variable
  #   all_objects_root + ".page(params[:page])"
  # end

  def auth_object
    @auth
  end

  def current_user_object

    # TODO: in god mode, there's no way for the time input
    # to know who the current user under this design
    # for timeinput = user_centered , we need to know who the current user is
    # so we can set the time zone to the user's time zone

    if options['auth']
      options['auth']
    elsif @god
      "nil"
    else
      @auth
    end
  end

  def no_devise_installed
    !Gem::Specification.sort_by { |g| [g.name.downcase, g.version] }.group_by { |g| g.name }['devise']
  end

  def magic_button_output
    @template_builder.magic_button_output(
      path: HotGlue.optionalized_ternary( namespace: @namespace,
                                          target: @singular,
                                          nested_set: @nested_set,
                                          with_params: false,
                                          put_form: true),
                                          big_edit: @big_edit,
                                          singular: singular,
                                          magic_buttons: @magic_buttons,
                                          small_buttons: @small_buttons
    )
  end

  def nav_template
    "#{namespace_with_trailing_dash}nav"
  end

  def include_nav_template
    File.exist?("#{Rails.root}/app/views/#{namespace_with_trailing_dash}_nav.html.#{@markup}") ||
      File.exist?("#{Rails.root}/app/views/#{namespace_with_trailing_dash}_nav.#{@markup}")
  end

  def copy_view_files
    return if @specs_only
    @edit_within_form_partial = File.exist?("#{filepath_prefix}app/views#{namespace_with_dash}/#{@controller_build_folder}/_edit_within_form.html.#{@markup}")
    @edit_after_form_partial = File.exist?("#{filepath_prefix}app/views#{namespace_with_dash}/#{@controller_build_folder}/_edit_after_form.html.#{@markup}")
    @new_within_form_partial = File.exist?("#{filepath_prefix}app/views#{namespace_with_dash}/#{@controller_build_folder}/_new_within_form.html.#{@markup}")
    @new_after_form_partial = File.exist?("#{filepath_prefix}app/views#{namespace_with_dash}/#{@controller_build_folder}/_new_within_form.html.#{@markup}")
    @index_before_list_partial = File.exist?("#{filepath_prefix}app/views#{namespace_with_dash}/#{@controller_build_folder}/_index_before_list.html.#{@markup}")
    @list_after_each_row_partial = File.exist?("#{filepath_prefix}app/views#{namespace_with_dash}/#{@controller_build_folder}/_list_after_each_row.html.#{@markup}")
    @list_after_each_row_heading_partial = File.exist?("#{filepath_prefix}app/views#{namespace_with_dash}/#{@controller_build_folder}/_list_after_each_row_heading.html.#{@markup}")
    if @no_controller
      File.write("#{Rails.root}/app/views/#{namespace_with_trailing_dash}/#{plural}/REGENERATE.md", regenerate_me_code)
    end

    all_views.each do |view|
      formats.each do |format|
        source_filename = cc_filename_with_extensions("#{@markup}/#{view}", "#{@markup}")
        dest_filename = cc_filename_with_extensions("#{view}", "#{@markup}")
        dest_filepath = File.join("#{filepath_prefix}app/views#{namespace_with_dash}",
                                  @controller_build_folder, dest_filename)

        template source_filename, dest_filepath
        gsub_file dest_filepath, '\%', '%'

      end
    end

    turbo_stream_views.each do |view|
      formats.each do |format|
        source_filename = cc_filename_with_extensions("#{@markup}/#{view}.turbo_stream.#{@markup}")
        dest_filename = cc_filename_with_extensions("#{view}", "turbo_stream.#{@markup}")
        dest_filepath = File.join("#{filepath_prefix}app/views#{namespace_with_dash}",
                                  @controller_build_folder, dest_filename)

        template source_filename, dest_filepath
        gsub_file dest_filepath, '\%', '%'

      end
    end
  end

  def append_model_callbacks
    # somehow the generator invokes this

    if options['with_turbo_streams'] == true
      dest_filename = cc_filename_with_extensions("#{singular_class.underscore}", "rb")
      dest_filepath = File.join("#{filepath_prefix}app/models", dest_filename)

      puts "appending turbo callbacks to #{dest_filepath}"

      text = File.read(dest_filepath)

      append_text = "class #{singular_class} < ApplicationRecord\n"
      if !text.include?("include ActionView::RecordIdentifier")
        append_text << "  include ActionView::RecordIdentifier\n"
      end
      append_text << "  after_update_commit lambda { broadcast_replace_to self, target: \"#{@namespace}__\#{dom_id(self)}\", partial: \"#{@namespace}/#{@plural}/line\" }\n  after_destroy_commit lambda { broadcast_remove_to self, target: \"#{@namespace}__\#{dom_id(self)}\"}\n"

      replace = text.gsub(/class #{singular_class} < ApplicationRecord/, append_text)
      File.open(dest_filepath, "w") { |file| file.puts replace }
    end
  end

  def insert_into_nav_template # called from somewhere in the generator
    return if @no_nav_menu
    if include_nav_template
      if File.exist?("#{Rails.root}/app/views/#{namespace_with_trailing_dash}_nav.html.#{@markup}")
        nav_file = "#{Rails.root}/app/views/#{namespace_with_trailing_dash}_nav.html.#{@markup}"
      elsif File.exist?("#{Rails.root}/app/views/#{namespace_with_trailing_dash}_nav.#{@markup}")
        nav_file = "#{Rails.root}/app/views/#{namespace_with_trailing_dash}_nav.#{@markup}"
      end


      append_text = "  <li class='nav-item'>
    <%= link_to '#{@list_label_heading.humanize}', #{path_helper_plural(@nested_set.any? ? true: false)}, class: \"nav-link \#{'active' if nav == '#{plural_name}'}\" %>
  </li>"
      alt_append_text = "  <li class='nav-item'>
    <%= link_to '#{@list_label_heading.humanize.upcase}', #{path_helper_plural(@nested_set.any? ? true: false)}, class: \"nav-link \#{'active' if nav == '#{plural_name}'}\" %>
  </li>"

      text = File.read(nav_file)
      if text.include?(append_text) || text.include?(alt_append_text)
        puts "SKIPPING: Nav link for #{singular_name} already exists in #{nav_file}"
      else
        puts "APPENDING: nav link for #{singular_name} #{nav_file}"

        replace = text.gsub(/\<\/ul\>/, append_text + "\n</ul>")

        File.open("#{Rails.root}/app/views/#{namespace_with_trailing_dash}_nav.html.#{@markup}", "w") { |file|
          file.puts replace
        }
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
    @namespace ? "#{@namespace}/" : ""
  end

  def all_views
    res = %w(index  _line _list _show)

    unless @no_create
      res += %w(new _new_form _new_button)
    end

    unless @no_edit
      res += %w{edit _edit}
    end

    if !(@no_edit && @no_create)
      res << '_form'
    end

    if @no_list
      res -= %w{_list _line index}
    end

    if @lazy
      res << '_lazy_list'
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

      unless @big_edit
        res << 'update'
      end
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
    @template_builder.all_form_fields(layout_strategy: @layout_strategy)
  end

  def list_label
    @list_label_heading
  end

  def new_thing_label
    @new_thing_label
  end

  def all_line_fields
    @template_builder.all_line_fields(
      perc_width: @layout_strategy.each_col, # undefined method `each_col'
      layout_strategy: @layout_strategy
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
    @magic_buttons.collect { |magic_button|
      "    if #{singular}_params[:#{magic_button}]
      begin
        res = @#{singular}.#{magic_button}!
        res = \"#{magic_button.titleize}ed.\" if res === true
        flash[:notice] = (flash[:notice] || \"\") <<  (res ? res + \" \" : \"\")
      rescue ActiveRecord::RecordInvalid => e
        @#{singular}.errors.add(:base, e.message)
        flash[:alert] = (flash[:alert] || \"\") << 'There was an error #{magic_button}ing your #{@singular}: '
      end
    end"

    }.join("\n") + "\n"
  end

  def controller_update_params_tap_away_magic_buttons
    @magic_buttons.collect { |magic_button|
      ".tap{ |ary| ary.delete('__#{magic_button}') }"
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
      ".includes(" + (@associations.map { |x| x } + @attachments.collect { |k, v| "#{k}_attachment" } ).map { |x| ":#{x.to_s}" }.join(", ") + ")"
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
      "\"" + @nested_set.collect { |arg|
        "__#{arg[:singular]}-\#{" + "@" + arg[:singular] + ".id}"
      }.join("") + "\""
    end
  end

  def nested_for_assignments_constructor(top_level = true)
    instance_symbol = "@" if top_level
    instance_symbol = "" if !top_level
    if @nested_set.none?
      ""
    else
      ", \n    nested_for: \"" + @nested_set.collect { |a| "#{a[:singular]}-" + '#{' + instance_symbol + a[:singular] + ".id}" }.join("__") + "\""
    end
  end


  def load_all_code
    # the inner method definition of the load_all_* method
    res = +""
    if @search_fields
      res << @search_fields.collect{ |field|
        if !@columns_map[field.to_sym].load_all_query_statement.empty?
          @columns_map[field.to_sym].load_all_query_statement
        end
      }.compact.join("\n" + spaces(4)) + "\n"
    end

    if pundit
      res << "    @#{ plural_name } = policy_scope(#{ object_scope })#{record_scope}\n"
    else
      if !@self_auth

        res << spaces(4) + "@#{ plural_name } = #{ object_scope.gsub("@",'') }#{ n_plus_one_includes }#{record_scope}#{".all" if n_plus_one_includes.blank? && record_scope.blank? }"

        if @search_fields
          res << @search_fields.collect{ |field|
            wqs = @columns_map[field.to_sym].where_query_statement
            if !wqs.empty?
              "\n" + spaces(4) +  "@#{ plural_name } = @#{ plural_name }#{ wqs } if #{field}_query"
            end
          }.compact.join
        end



        # res << "\n    @#{plural} = @#{plural}.page(params[:page])#{ '.per(per)' if @paginate_per_page_selector }"

      elsif @nested_set[0] && @nested_set[0][:optional]
        res << "@#{ plural_name } = #{ class_name }.#{record_scope}.all"
      else
        res << "@#{ plural_name } = #{ class_name }.#{record_scope}.where(id: #{ auth_object.gsub("@",'') }.id)#{ n_plus_one_includes }"

        # res << "#{record_scope}"
      end
      res << "\n"

    end
    if @search_fields
      res << "\n"
      res << @search_fields.collect{ |field|
        spaces(4) + "@#{plural_name} = @#{plural_name}" + @columns_map[field.to_sym].where_query_statement + " if #{field}_query"
      }.join("\n") + "\n"
    end

    @phantom_search.each do |phantom_key, phantom_data|
      if phantom_data[:type] == "radio"
        phantom_data[:choices].each do |choice|
          unless choice[:scope] == ".all"
            res << "\n    @#{plural} = @#{plural}#{choice[:scope]} if @q['0'][:#{phantom_key}_search] == \"#{choice[:label]}\""
          end
        end
      elsif phantom_data[:type] == "checkboxes"
        phantom_data[:choices].each do |choice|

          # positive case
          unless choice[:scope] == ".all"
            res << "\n    @#{plural} = @#{plural}#{choice[:scope]} if @q['0'][:#{phantom_key}_search__#{choice[:label].gsub(" ", "_").downcase}] == \"1\""
          end
          unless choice[:scope_negative] == ".all"
            res << "\n    @#{plural} = @#{plural}#{choice[:scope_negative]} if @q['0'][:#{phantom_key}_search___#{choice[:label].gsub(" ", "_").downcase}] != \"1\""
          end
        end
      end

      res << "\n"
    end


    if @pagination_style == "kaminari"
      res << "    @#{plural} = @#{plural}.page(params[:page])#{ ".per(per)" if @paginate_per_page_selector }"
    elsif @pagination_style == "will_paginate"
      res << "    @#{plural} = @#{plural}.paginate(page: params[:page], #{ ", per_page: per" if @paginate_per_page_selector })"
    elsif @pagination_style == "pagy"
      res << "    @pagy, @#{plural} = pagy(@#{plural})"
    end
    res
  end


  private # thor does something fancy like sending the class all of its own methods during some strange run sequence
  # does not like public methods

  def spaces(num)
    " " * num
  end

  def cc_filename_with_extensions(name, file_format = format)
    [name, file_format].compact.join(".")
  end

  def hawk_to_ruby
    res = @hawk_keys.collect { |k, v|
      "#{k.to_s}: [#{v[:bind_to].join(".")}]"
    }.join(", ")
    res
  end

  def controller_attachment_orig_filename_pickup_syntax
    @attachments.collect { |key, attachment| "\n" + "    modified_params[:#{ attachment[:field_for_original_filename] }] = #{singular}_params['#{ key }'].original_filename" if attachment[:field_for_original_filename] }.compact.join("\n")
  end

  def any_datetime_fields?
    (@columns - @attachments.keys.collect(&:to_sym) - @related_sets.keys ).collect { |col| eval("#{singular_class}.columns_hash['#{col}']").type }.include?(:datetime)
  end

  def post_action_parental_updates
    if @nested_set.any?
       @nested_set.collect {  |data|
        parent = data[:singular]
        "#{parent}.reload"
       }
    else
      []
    end
  end

  def turbo_parental_updates
    set_path = @nested_set.collect { |data| "#{data[:singular]}" }.join("/") + "/"
    puts "constructing for #{set_path}"
    @nested_set.collect { |data|
      res = "<%= turbo_stream.replace \"__#{@namespace if @namespace}\#{dom_id(@#{data[:singular]})}\" do %>
    <%= render partial: \"#{@namespace}/#{data[:plural]}/line\", locals: {#{@nested_set.collect { |d|
        (set_path.index(data[:singular] + "/") > set_path.index(d[:singular] + "/") || d[:singular] == data[:singular]  ) ? "#{d[:singular]}: @#{d[:singular]}" : nil
      }.compact.join(", ")}} %>
  <% end %>"

      res
    }.join("\n")
  end


  def search_default
    default_fields = @search_fields.collect{ |foo|
      { "#{foo}_match".to_sym =>
            (@columns_map[foo.to_sym].modify_as && @columns_map[foo.to_sym].modify_as[:binary]) ? "-1" : "", "#{foo}_search".to_sym => ""
      }
    }.reduce({}, :merge)

    phantom_search_fields = @phantom_search.collect{| k,v|
      if v[:type] == "radio"
        default = v[:choices][0]
        {
          "#{k}_match".to_sym => "",
          "#{k}_search".to_sym => "#{default[:label]}"
        }
      elsif v[:type] == "checkboxes"
        v[:choices].collect{ |c|
          {
            "#{k}_#{c[:label].gsub(" ", "_").downcase}".to_sym => ""
          }
        }
      end
    }

    phantom_search_fields.flatten!
    phantom_search_fields = phantom_search_fields.reduce({}, :merge)

    return {"0" => (default_fields.merge(phantom_search_fields))}
  end
end
