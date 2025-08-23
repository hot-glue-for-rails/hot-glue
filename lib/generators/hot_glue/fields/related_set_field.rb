class RelatedSetField < Field

  attr_accessor :assoc_name, :assoc_class, :assoc, :label_field, :hawk

  def initialize( scaffold: , name: )
    super

    @related_set_model = eval("#{class_name}.reflect_on_association(:#{name})")

    if @related_set_model.nil?
          raise "You specified a related set #{name} but there is no association on #{singular_class} for #{name}; please add a `has_and_belongs_to_many :#{name}` OR a `has_many :#{name}, through: ...` to the #{singular_class} model"

      # exit_message = "*** Oops: The model #{class_name} is missing an association for :#{assoc_name} or the model #{assoc_name.titlecase} doesn't exist. TODO: Please implement a model for #{assoc_name.titlecase}; or add to #{class_name} `belongs_to :#{assoc_name}`.  To make a controller that can read all records, specify with --god."
      puts exit_message
      raise(HotGlue::Error, exit_message)
    end

    @assoc_class = eval(@related_set_model.try(:class_name))


    @deets = scaffold.related_sets[name.to_sym]

    if @deets[:label_field].nil?
      @label_field = "label"

      # name_list = [:name, :to_label, :full_name, :display_name, :email]
      #
      # if assoc_class && name_list.collect{ |field|
      #   assoc_class.respond_to?(field.to_s) || assoc_class.instance_methods.include?(field)
      # }.none?
      #   exit_message = "Oops: Missing a label for `#{assoc_class}`. Can't find any column to use as the display label for the #{@assoc_name} association on the #{class_name} model. TODO: Please implement just one of: 1) name, 2) to_label, 3) full_name, 4) display_name 5) email. You can implement any of these directly on your`#{assoc_class}` model (can be database fields or model methods) or alias them to field you want to use as your display label. Then RERUN THIS GENERATOR. (Field used will be chosen based on rank here.)"
      #   raise(HotGlue::Error, exit_message)
      # end
    else
      @label_field = @deets[:label_field]
    end
  end


  def form_field_output
    disabled_syntax = +""

    if pundit
      disabled_syntax << ", {disabled: ! #{class_name}Policy.new(#{auth}, @#{singular}).role_ids_able?}"
    end
    " <%= f.collection_check_boxes :#{association_ids_method}, #{record_scope}, :id, :#{label_field}, {}#{disabled_syntax} do |m| %>
    <%= m.check_box %> <%= m.label %><br />
  <% end %>"
  end

  def record_scope
    if hawk.nil?
      "#{association_class_name}.all"
    else
      hawk
    end
  end

  def label_field
    @label_field
  end

  def association_ids_method
    eval("#{class_name}.reflect_on_association(:#{name})").class_name.underscore + "_ids"
  end

  def association_class_name
    eval("#{class_name}.reflect_on_association(:#{name})").class_name
  end

  def viewable_output
    "<%= #{singular}.#{name}.collect(&:#{label_field}).join(\", \") %>"
  end
end


