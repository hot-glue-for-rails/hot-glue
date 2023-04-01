class Field
  attr_accessor :name, :object, :singular_class, :class_name

  def initialize(name: , class_name: , singular_class: )
    @name = name
    @singular_class = singular_class
    @class_name = class_name
  end

  def getName
    @name
  end

  def spec_random_data

  end

  def testing_name
    singular_class.to_s.gsub("::","_").underscore
  end

  def test_capybara_block(which_partial = nil)
    ""
  end
end
