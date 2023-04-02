class EnumField < Field
  def test_capybara_block(which_partial = nil)
    "      list_of_#{name.to_s} = #{singular_class}.defined_enums['#{name.to_s}'].keys \n" +
    "      " + "new_#{name.to_s} = list_of_#{name.to_s}[rand(list_of_#{name.to_s}.length)].to_s \n" +
    '      find("select[name=\'' + singular + '[' + name.to_s + ']\']  option[value=\'#{new_' + name.to_s + '}\']").select_option'
  end
end
