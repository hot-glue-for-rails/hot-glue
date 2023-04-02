class TextField < Field
  def spec_random_data
    FFaker::AnimalUS.common_name
  end

  def spec_setup_and_change_act(which_partial = nil)
    "      " + "new_#{name} = FFaker::Lorem.paragraphs(1).join("") \n" +
    "      find(\"[name='#{testing_name}[#{ name.to_s }]']\").fill_in(with: new_#{name.to_s})"
  end

  def spec_setup_let_arg
    "#{name}:  FFaker::Lorem.paragraphs(10).join("  ")"
  end
end
