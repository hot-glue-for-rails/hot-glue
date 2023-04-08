class AttachmentField < Field
  def spec_setup_let_arg
    nil
  end

  def spec_setup_and_change_act(which_partial = nil)
    "      attach_file(\"#{singular}[#{name.to_s}]\", \"#{sample_file_path}\")"
  end
end
