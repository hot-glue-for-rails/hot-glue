class DateTimeField < Field
  def spec_random_data
    Time.now + rand(1..5).days
  end

  def test_capybara_block(which_partial = nil)
    "      " + "new_#{name} = DateTime.current + (rand(100).days) \n" +
    '      ' + "find(\"[name='#{testing_name}[#{ name.to_s }]']\").fill_in(with: new_#{name.to_s})"

  end

  def capybara_expectation_assertion
    super
  end

  def spec_setup_let_arg
    "#{name}: DateTime.current + rand(1000).seconds"
  end
end
