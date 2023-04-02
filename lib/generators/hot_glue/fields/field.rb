class Field
  attr_accessor :name, :object, :singular_class, :class_name, :singular,
                :update_show_only

  def initialize(name: , class_name: , alt_lookups: , singular: , update_show_only: )
    @name = name
    @alt_lookups = alt_lookups
    @singular = singular
    @class_name = class_name
    @update_show_only = update_show_only
  end

  def getName
    @name
  end

  def spec_random_data

  end

  def testing_name
    class_name.to_s.gsub("::","_").underscore
  end

  def test_capybara_block(which_partial = nil)
    ""
  end

  def capybara_expectation_assertion
    "expect(page).to have_content(new_#{name})"
  end

  def spec_setup_let_arg

  end
end
