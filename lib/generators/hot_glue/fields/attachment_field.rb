class AttachmentField < Field
  attr_accessor :attachment_data
  def initialize(name:, class_name:, alt_lookups:, default_boolean_display: ,
                 display_as:,
                 singular:, update_show_only:, hawk_keys:, auth:,
                 sample_file_path: nil, attachment_data:, ownership_field:, layout_strategy: ,
                 form_placeholder_labels: , form_labels_position:, modify_as:, self_auth: )
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

    (thumbnail ? "<%= #{singular}.#{name}.attached? ? image_tag(#{singular}.#{name}.variant(:#{thumbnail})) : '' %>" : "")
  end
end
