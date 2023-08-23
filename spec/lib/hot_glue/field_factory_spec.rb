require "rails_helper"

describe FieldFactory do
  it "should make a new filed " do
    ff = FieldFactory.new(type: :integer,
                          name: "how_many",
                          generator: OpenStruct.new({
                                                  modify: {},
                                                  display_as: {},
                                                  default_boolean_display: 'radio',
                                                  form_labels_position: nil,
                                                  singular_class: "Hgi",
                                                  layout_strategy: nil,
                                                  form_placeholder_labels: false,
                                                  ownership_field: nil,
                                                  hawk_keys: nil,
                                                  auth: nil,
                                                  attachment_data: nil,
                                                  sample_file_path: nil,
                                                  class_name: "Abc",
                                                  alt_lookups: {},
                                                  singular: "abc",
                                                  update_show_only: [],
                                                  attachments: {}
                                                }))

    expect(ff.field).to be_a(IntegerField)
  end
end
