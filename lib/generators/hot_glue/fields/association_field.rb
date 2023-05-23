
require_relative './field.rb'

class AssociationField < Field

  attr_accessor :assoc_name, :assoc_class, :assoc

  def initialize(name: , class_name: , alt_lookups: , singular: , update_show_only: ,
                 hawk_keys: , auth: , sample_file_path:,  ownership_field: ,
                 attachment_data: nil , layout_strategy: , form_placeholder_labels: nil,
                 form_labels_position: )
    super

    @assoc_model = eval("#{class_name}.reflect_on_association(:#{assoc})")

    if assoc_model.nil?
      exit_message = "*** Oops: The model #{class_name} is missing an association for :#{assoc_name} or the model #{assoc_name.titlecase} doesn't exist. TODO: Please implement a model for #{assoc_name.titlecase}; or add to #{class_name} `belongs_to :#{assoc_name}`.  To make a controller that can read all records, specify with --god."
      puts exit_message
      raise(HotGlue::Error, exit_message)
    end

    @assoc_class = eval(assoc_model.try(:class_name))

    name_list = [:name, :to_label, :full_name, :display_name, :email]

    if assoc_class && name_list.collect{ |field|
      assoc_class.respond_to?(field.to_s) || assoc_class.instance_methods.include?(field)
    }.none?
      exit_message = "Oops: Missing a label for `#{assoc_class}`. Can't find any column to use as the display label for the #{@assoc_name} association on the #{class_name} model. TODO: Please implement just one of: 1) name, 2) to_label, 3) full_name, 4) display_name 5) email. You can implement any of these directly on your`#{assoc_class}` model (can be database fields or model methods) or alias them to field you want to use as your display label. Then RERUN THIS GENERATOR. (Field used will be chosen based on rank here.)"
      raise(HotGlue::Error, exit_message)
    end

  end

  def assoc_label

  end

  def assoc_name
    assoc
  end

  def assoc
    name.to_s.gsub('_id','')
  end

  def spec_setup_and_change_act(which_partial)
    if which_partial == :update && update_show_only.include?(name)
      # do not update tests
    elsif alt_lookups.keys.include?(name.to_s)
      lookup = alt_lookups[name.to_s][:lookup_as]
      "      find(\"[name='#{singular}[__lookup_#{lookup}]']\").fill_in( with: #{assoc}1.#{lookup} )"
    else
      "      #{name}_selector = find(\"[name='#{singular}[#{name}]']\").click \n" +
      "      #{name}_selector.first('option', text: #{assoc}1.name).select_option"
    end
  end

  def spec_make_assertion
    " expect(page).to have_content(#{assoc}1.name)"
  end

  def spec_setup_let_arg
    "#{name.to_s.gsub('_id','')}: #{name.to_s.gsub('_id','')}1"
  end

  def spec_list_view_assertion

  end

  def spec_related_column_lets
    the_foreign_class = eval(class_name + ".reflect_on_association(:" + assoc + ")").class_name.split("::").last.underscore

    hawk_keys_on_lets = (hawk_keys["#{assoc}_id".to_sym] ? ", #{auth.gsub('current_', '')}: #{auth}": "")

    "  let!(:#{assoc}1) {create(:#{the_foreign_class}" +  hawk_keys_on_lets + ")}"
  end

  def form_field_output
    assoc_name = name.to_s.gsub("_id","")
    assoc = eval("#{class_name}.reflect_on_association(:#{assoc_name})")


    if @alt_lookups.keys.include?(name.to_s)
      alt = @alt_lookups[name.to_s][:lookup_as]
      "<%= f.text_field :__lookup_#{alt}, value: @#{singular}.#{assoc_name}.try(:#{alt}), placeholder: \"search by #{alt}\" %>"
    else
      if assoc.nil?
        exit_message = "*** Oops. on the #{class_name} object, there doesn't seem to be an association called '#{assoc_name}'"
        exit
      end

      is_owner = name == ownership_field
      assoc_class_name = assoc.class_name.to_s
      display_column = HotGlue.derrive_reference_name(assoc_class_name)

      if hawk_keys[assoc.foreign_key.to_sym]
        hawk_definition = hawk_keys[assoc.foreign_key.to_sym]
        hawked_association = hawk_definition[:bind_to].join(".")
      else
        hawked_association = "#{assoc.class_name}.all"
      end

      (is_owner ? "<% unless @#{assoc_name} %>\n" : "") +
        "  <%= f.collection_select(:#{name}, #{hawked_association}, :id, :#{display_column}, {prompt: true, selected: @#{singular}.#{name} }, class: 'form-control') %>\n" +
        (is_owner ? "<% else %>\n <%= @#{assoc_name}.#{display_column} %>" : "") +
        (is_owner ? "\n<% end %>" : "")
    end
  end

  def field_error_name
    name
  end

  def form_show_only_output
    assoc_name = name.to_s.gsub("_id","")
    assoc = eval("#{singular_class}.reflect_on_association(:#{assoc_name})")
    if assoc.nil?
      exit_message = "*spec_helper** Oops. on the #{singular_class} object, there doesn't seem to be an association called '#{assoc_name}'"
      exit
    end

    is_owner = name == ownership_field
    assoc_class_name = assoc.class_name.to_s
    display_column = HotGlue.derrive_reference_name(assoc_class_name)

    if hawk_keys[assoc.foreign_key.to_sym]
      hawk_definition = hawk_keys[assoc.foreign_key.to_sym]
      hawked_association = hawk_definition.join(".")
    else
      hawked_association = "#{assoc.class_name}.all"
    end
    "<%= #{singular}.#{assoc_name}.#{display_column} %>"

  end

  def line_field_output
    display_column =  HotGlue.derrive_reference_name(assoc_class.to_s)
    "<%= #{singular}.#{assoc}.try(:#{display_column}) || '<span class=\"content alert-danger\">MISSING</span>'.html_safe %>"
  end
end
