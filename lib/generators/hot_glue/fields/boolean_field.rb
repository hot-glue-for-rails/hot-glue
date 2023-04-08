class BooleanField < Field
  def spec_setup_and_change_act(which_partial = nil)
    "      new_#{name} = 1 \n" +
    "      find(\"[name='#{testing_name}[#{name}]'][value='\#{new_" + name.to_s + "}']\").choose"
  end

  def spec_make_assertion
    ["expect(page).to have_content(#{singular}#{1}.#{name} ? 'YES' : 'NO')"].join("\n      ")
  end

  def spec_setup_let_arg
    "#{name}: !!rand(2).floor"
  end

  def spec_list_view_assertion
    "      " + ["expect(page).to have_content(#{singular}#{1}.#{name} ? 'YES' : 'NO')"].join("\n      ")
  end
end
