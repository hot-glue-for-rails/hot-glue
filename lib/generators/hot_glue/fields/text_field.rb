class TextField < Field
  def spec_random_data
    FFaker::AnimalUS.common_name
  end

  def test_capybara_block(which_partial = nil)
    "      " + "new_#{name} = FFaker::Lorem.paragraphs(1).join("") \n" +
    "      find(\"[name='#{testing_name}[#{ name.to_s }]']\").fill_in(with: new_#{name.to_s})"
  end
end
