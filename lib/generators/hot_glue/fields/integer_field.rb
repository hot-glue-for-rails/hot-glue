class IntegerField < Field
  def spec_random_data
    rand(1...1000)
  end

  def test_capybara_block
    if name.to_s.ends_with?("_id")
      capybara_block_for_association(name_name: name, which_partial: which_partial)
    else
      "      new_#{name} = rand(10) \n" +
        "      find(\"[name='#{testing_name}[#{ name.to_s }]']\").fill_in(with: new_#{name.to_s})"
    end
  end
end
