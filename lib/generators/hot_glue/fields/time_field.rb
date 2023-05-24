class TimeField < Field

  def spec_setup_let_arg
    "#{name}: Time.current + rand(5000).seconds"
  end

  def form_field_output
    "<%= time_field_localized(f, :#{name}, #{singular}.#{name},  '#{ name.to_s.humanize  }', #{auth ? auth+'.timezone' : 'nil'}) %>"
  end

  def line_field_output
    "<% unless #{singular}.#{name}.nil? %>
      <%= #{singular}.#{name}.in_time_zone(current_timezone).strftime('%l:%M %p ') + timezonize(current_timezone) %>
     <% else %>
    <span class='alert-danger'>MISSING</span>
    <% end %>"
  end
end
