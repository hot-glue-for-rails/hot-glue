class TimeField < Field

  def spec_setup_let_arg
    "#{name}: Time.current + rand(5000).seconds"
  end
end
