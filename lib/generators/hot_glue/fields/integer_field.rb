class IntegerField < Field
  def spec_random_data
    rand(1...1000)
  end
end
