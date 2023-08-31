class TimeField < Field

  def spec_setup_let_arg
    "#{name}: Time.current + rand(5000).seconds"
  end

  def form_field_output
    "<%= time_field_localized(f, :#{name}, #{singular}.#{name},  '#{ name.to_s.humanize  }') %>"
  end

  def line_field_output
    "<% unless #{singular}.#{name}.nil? %>
      <%= #{singular}.#{name}.in_time_zone(current_timezone).strftime('%l:%M %p ') + timezonize(current_timezone) %>
     <% else %>
    <span class='alert-danger'>MISSING</span>
    <% end %>"
  end

  def spec_make_assertion
    "#expect(page).to have_content(new_#{name} .in_time_zone(current_timezone).strftime('%l:%M %p ') + timezonize(current_timezone))"
  end

  def spec_list_view_assertion
    "#expect(page).to have_content(#{singular}#{1}.#{name})"
  end
end
