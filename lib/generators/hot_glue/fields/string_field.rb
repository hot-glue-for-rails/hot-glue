class StringField < Field
  def spec_random_data
    FFaker::AnimalUS.common_name
  end

  def spec_setup_and_change_act(which_partial = nil)
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

  def spec_setup_let_arg
    if name.to_s.include?('email')
      "#{name}: FFaker::Internet.email"
    elsif  name.to_s.include?('domain')
      "#{name}: FFaker::Internet.domain_name"
    elsif name.to_s.include?('ip_address') || name.to_s.ends_with?('_ip')
      "#{name}: FFaker::Internet.ip_v4_address"
    else
      "#{name}: FFaker::Movie.title"
    end
  end

  def form_field_output
    if sql_type == "varchar" || sql_type == "character varying"
      field_output(nil, limit || 40)
    else
      text_area_output( 65536)
    end
  end

  # TODO: dry with text_field.rb
  def text_result(col, sql_type, limit)
    if sql_type == "varchar"
      field_output( nil, limit)
    else
      text_area_output( 65536)
    end
  end

  def search_field_output
    "<%= f.select :search__#{name}, options_for_select([['', ''], ['contains', 'contains'], ['is exactly', 'is exactly'], ['starts with', 'starts with'], ['ends with', 'ends with']], @q[0]['search__#{name}']), class: 'form-control' %>"
    + "<%= f.text_field :#{name}, value: @q[0]['search__#{name}'], autocomplete: 'off', size: 40, class: 'form-control', type: 'text' %>"
  end
end
