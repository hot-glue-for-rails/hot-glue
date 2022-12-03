require 'spec_helper.rb'

describe "HotGlueHelper" do

  class FakeController
    include HotGlueHelper
  end
  it "#enum_to_collection_select should take a hash" do
    controller = FakeController.new

    controller.enum_to_collection_select({4 => "a"})

  end
end
