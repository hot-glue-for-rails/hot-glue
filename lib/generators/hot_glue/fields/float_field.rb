class FloatField < Field
  def test_capybara_block(which_partial = nil)
    "      " + "new_#{name} = rand(10) \n" +
    "      find(\"[name='#{testing_name}[#{ name.to_s }]']\").fill_in(with: new_#{name.to_s})"

  end

  def spec_setup_let_arg
    "#{name}: rand(1)*10000"
  end
end
