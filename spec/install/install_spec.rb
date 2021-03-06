require 'dummy_rails_helper'


Rspec.describe HotGlue::InstallGenerator do
  include GeneratorsTestHelper

  def setup
    @path = File.expand_path("lib", Rails.root)
    $LOAD_PATH.unshift(@path)
  end

  def teardown
    $LOAD_PATH.delete(@path)
  end

  it "should do simple invoke" do
    Rails::Generators.invoke("hot_glue:install")
    # assert File.exist?(File.join(@path, "generators", "model_generator.rb"))
    # assert_called_with(TestUnit::Generators::ModelGenerator, :start, [["Account"], {}]) do
    #   Rails::Generators.invoke("test_unit:model", ["Account"])
    # end
  end




end