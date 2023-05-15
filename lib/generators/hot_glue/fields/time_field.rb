class TimeField < Field

  def spec_setup_let_arg
    "#{name}: Time.current + rand(5000).seconds"
  end

  def form_field_output
    "<%= time_field_localized(f, :#{name}, #{singular}.#{name},  '#{ name.to_s.humanize  }', #{auth ? auth+'.timezone' : 'nil'}) %>"
  end
end
