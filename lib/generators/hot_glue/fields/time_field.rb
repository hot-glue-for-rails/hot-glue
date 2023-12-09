class TimeField < Field

  def spec_setup_let_arg
    "#{name}: Time.current + rand(5000).seconds"
  end

  def form_field_output
    "<%= time_field_localized(f, :#{name}, #{singular}.#{name},  '#{ name.to_s.humanize  }') %>"
  end

  def line_field_output
    "<% unless #{singular}.#{name}.nil? %>
      <%= #{singular}.#{name}.in_time_zone(current_timezone).strftime('%l:%M %p ') %>
     <% else %>
    <span class=''>MISSING</span>
    <% end %>"
  end

  def spec_setup_and_change_act(which_partial = nil)
    "      new_#{name} = Time.current + 5.seconds \n" +
    '      ' + "find(\"[name='#{testing_name}[#{ name.to_s }]']\").fill_in(with: new_#{name.to_s})"

  end

  def spec_make_assertion
    "expect(page).to have_content(new_#{name}.strftime('%l:%M %p').strip)"
  end

  def spec_list_view_assertion
    # "expect(page).to have_content(#{singular}#{1}.#{name})"
  end

  def search_field_output
    ""
  end
end
