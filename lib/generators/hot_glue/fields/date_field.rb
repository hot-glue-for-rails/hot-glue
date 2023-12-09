class DateField < Field
  def spec_setup_and_change_act(which_partial = nil)
    "      " + "new_#{name} = Date.current + (rand(100).days) \n" +
    '      ' + "find(\"[name='#{testing_name}[#{ name.to_s }]']\").fill_in(with: new_#{name.to_s})"
  end

  def spec_setup_let_arg
    "#{name}: Date.current + rand(50).days"
  end


  def form_field_output
    "<%= date_field_localized(f, :#{name}, #{singular}.#{name}, '#{ name.to_s.humanize  }') %>"
  end

  def line_field_output
    "<% unless #{singular}.#{name}.nil? %>
      <%= #{singular}.#{name} %>
    <% else %>
      <span class=''>MISSING</span>
    <% end %>"
  end

  def search_field_output
    ""
  end
end
