class FloatField < Field
  def spec_setup_and_change_act(which_partial = nil)
    "      " + "new_#{name} = rand(10) \n" +
    "      find(\"[name='#{testing_name}[#{ name.to_s }]']\").fill_in(with: new_#{name.to_s})"

  end

  def spec_setup_let_arg
    "#{name}: rand(1)*10000"
  end
end
