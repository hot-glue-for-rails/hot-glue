class BooleanField < Field
  def test_capybara_block(which_partial = nil)
    "      new_#{name} = 1 \n" +
    "      find(\"[name='#{testing_name}[#{name}]'][value='\#{new_" + name.to_s + "}']\").choose"
  end
end
