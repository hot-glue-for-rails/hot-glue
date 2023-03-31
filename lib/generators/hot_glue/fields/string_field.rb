class StringField < Field
  def spec_random_data
    FFaker::AnimalUS.common_name
  end
end
