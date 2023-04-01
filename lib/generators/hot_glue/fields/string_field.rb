class StringField < Field
  def spec_random_data
    FFaker::AnimalUS.common_name
  end

  def test_capybara_block(which_partial = nil)
    faker_string =
      if name.to_s.include?('email')
        "FFaker::Internet.email"
      elsif  name.to_s.include?('domain')
        "FFaker::Internet.domain_name"
      elsif name.to_s.include?('ip_address') || name.to_s.ends_with?('_ip')
        "FFaker::Internet.ip_v4_address"
      else
        "FFaker::Movie.title"
      end

    return "      " + "new_#{name} = #{faker_string} \n" +
    "      find(\"[name='#{testing_name}[#{ name.to_s }]']\").fill_in(with: new_#{name.to_s})"
  end
end
