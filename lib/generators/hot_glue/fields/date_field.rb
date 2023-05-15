class DateField < Field
  def spec_setup_and_change_act(which_partial = nil)
    "      " + "new_#{name} = Date.current + (rand(100).days) \n" +
    '      ' + "find(\"[name='#{testing_name}[#{ name.to_s }]']\").fill_in(with: new_#{name.to_s})"
  end

  def spec_setup_let_arg
    "#{name}: Date.current + rand(50).days"
  end


end
