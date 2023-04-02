class BooleanField < Field
  def test_capybara_block(which_partial = nil)
    "      new_#{name} = 1 \n" +
    "      find(\"[name='#{testing_name}[#{name}]'][value='\#{new_" + name.to_s + "}']\").choose"
  end

  def capybara_expectation_assertion
    ["expect(page).to have_content(#{singular}#{1}.#{name} ? 'YES' : 'NO')"].join("\n      ")
  end

  def spec_setup_let_arg
    "#{name}: !!rand(2).floor"
  end
end
