class Field
  attr_accessor :name, :object, :singular_class
  def initialize(name: , object: , singular_class: )
    @name = name
    @object = object
    @singular_class = singular_class
  end
end
