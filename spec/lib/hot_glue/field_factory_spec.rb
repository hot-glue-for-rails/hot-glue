require "rails_helper"

describe FieldFactory do
  it "should make a new filed " do
    ff = FieldFactory.new(type: :integer,
                          name: "Abc",
                          generator: OpenStruct.new({
                                                  class_name: "Abc",
                                                  alt_lookups: {},
                                                  singular: "abc",
                                                  update_show_only: []
                                                }))

    expect(ff.field).to be_a(IntegerField)
  end
end
