require "rails_helper"

describe FieldFactory do
  it "should make a new filed " do
    ff = FieldFactory.new(type: :integer,
                          name: "abc",
                          class_name: "Abc",
                          singular_class: "Abc")

    expect(ff.field).to be_a(IntegerField)
  end
end
