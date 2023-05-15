class FloatField < Field
  def spec_setup_and_change_act(which_partial = nil)
    "      " + "new_#{name} = rand(10) \n" +
    "      find(\"[name='#{testing_name}[#{ name.to_s }]']\").fill_in(with: new_#{name.to_s})"

  end

  def spec_setup_let_arg
    "#{name}: rand(1)*10000"
  end

  def form_field_output
    field_output(nil, 5)
  end

  def line_field_output
    width = (limit && limit < 40) ? limit : (40)
    "<%= #{singular}.#{name}%>"
  end
end
