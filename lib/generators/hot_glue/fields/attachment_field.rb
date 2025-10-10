class AttachmentField < Field
  attr_accessor :attachment_data
  def initialize(scaffold:, name:)
    super

    @attachment_data = attachment_data
  end

  def spec_setup_let_arg
    nil
  end

  def spec_list_view_natural_assertion
    "within('div.#{singular}--#{name}') do
        img = page.find('img')
        expect(img['src']).to end_with('glass_button.png')
      end"

    # "expect(page).to have_content(#{singular}#{1}.#{name})"
  end


def spec_setup_and_change_act(which_partial = nil)
    "      attach_file(\"#{singular}[#{name.to_s}]\", \"#{sample_file_path}\")"
  end

  def thumbnail
    attachment_data[:thumbnail]
  end

  def form_field_output
    direct = attachment_data[:direct_upload]
    dropzone = attachment_data[:dropzone]
    field_result = (thumbnail ?   "<%= #{singular}.#{name}.attached? ? image_tag(#{singular}.#{name}.variant(:#{thumbnail})) : '' %>" : "") +
      "<br />\n" + (update_show_only.include?(name) ? "" : "<%= f.file_field :#{name} #{', direct_upload: true ' if direct}#{', "data-dropzone-target": "input"' if dropzone}%>")

    if dropzone
      field_result = "<div class=\"dropzone dropzone-default dz-clickable\" data-controller=\"dropzone\" data-dropzone-max-file-size=\"2\" data-dropzone-max-files=\"1\">\n  "+ field_result + "\n</div>"
    end
    return field_result
  end

  def line_field_output
    thumbnail = attachment_data[:thumbnail]
    if thumbnail
      "<% if #{singular}.#{name}.attached? %>
    <% if !#{singular}.#{name}.variable? %>
      <span class=\"badge bg-secondary\"><%= #{singular}.#{name}.blob.content_type.split('/')[1] %></span>
    <% else %>
      <%= image_tag(#{singular}.#{name}.variant(:thumb)) %>
    <% end %>
    <% end %>"
    else
      ""
    end
  end
end
