class AttachmentField < Field
  def spec_setup_let_arg
    nil
  end

  def spec_setup_and_change_act(which_partial = nil)
    "      attach_file(\"#{singular}[#{name.to_s}]\", \"#{sample_file_path}\")"
  end

  def form_field_output
    direct = attachment_data[:direct_upload]
    dropzone = attachment_data[:dropzone]
    field_result = (attachment_data[:thumbnail] ?   "<%= #{singular}.#{name}.attached? ? image_tag(#{singular}.#{name}.variant(:#{thumbnail})) : '' %>" : "") +
      "<br />\n" + (update_show_only.include?(name) ? "" : "<%= f.file_field :#{name} #{', direct_upload: true ' if direct}#{', "data-dropzone-target": "input"' if dropzone}%>")

    if dropzone
      field_result = "<div class=\"dropzone dropzone-default dz-clickable\" data-controller=\"dropzone\" data-dropzone-max-file-size=\"2\" data-dropzone-max-files=\"1\">\n  "+ field_result + "\n</div>"
    end
    return field_result
  end

  def field_error_name
    name
  end
end
