class DateTimeField < Field
  def spec_random_data
    Time.now + rand(1..5).days
  end
end
