
require_relative './field.rb'

class AssociationField < Field
  attr_accessor :assoc_model, :assoc_name, :assoc_class, :associations, :alt_lookups, :assoc_label

  def initialize(name: , class_name: , alt_lookups: , singular: , update_show_only: )
    super
    assoc_model = eval("#{class_name}.reflect_on_association(:#{assoc})")

    if assoc_model.nil?
      exit_message = "*** Oops: The model #{class_name} is missing an association for :#{assoc_name} or the model #{assoc_name.titlecase} doesn't exist. TODO: Please implement a model for #{assoc_name.titlecase}; or add to #{class_name} `belongs_to :#{assoc_name}`.  To make a controller that can read all records, specify with --god."
      puts exit_message
      raise(HotGlue::Error, exit_message)
    end

    begin
      assoc_class = eval(assoc_model.try(:class_name))
    end

    name_list = [:name, :to_label, :full_name, :display_name, :email]

    if assoc_class && name_list.collect{ |field|
      assoc_class.respond_to?(field.to_s) || assoc_class.instance_methods.include?(field)
    }.none?
      exit_message = "Oops: Missing a label for `#{assoc_class}`. Can't find any column to use as the display label for the #{@assoc_name} association on the #{singular_class} model. TODO: Please implement just one of: 1) name, 2) to_label, 3) full_name, 4) display_name 5) email. You can implement any of these directly on your`#{assoc_class}` model (can be database fields or model methods) or alias them to field you want to use as your display label. Then RERUN THIS GENERATOR. (Field used will be chosen based on rank here.)"
      raise(HotGlue::Error, exit_message)
    end

    # set teh assoc label
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
end
