require 'rails_helper'


describe HotGlue::InstallGenerator do
  # include GeneratorsTestHelper

  def setup
    # @path = File.expand_path("spec/dummy", Rails.root)
    # $LOAD_PATH.unshift(@path)
  end

  def teardown
    # $LOAD_PATH.delete(@path)
  end


  describe "with bootstrap" do
    it "should install correctly with bootstrap " do
      # not sure how how I can invoke this
      # # alternative: do rake here?

      # generator = HotGlue::InstallGenerator.new("layout=bootstrap")
    end
  end

  describe "with a theme " do
    it "should install correctly with hotglue layout syntax" do
      # response = Rails::Generators.invoke("hot_glue:install --theme=dark_knight")

    end
  end

  # describe "ERROR RESPONESES" do
  #   it "with missing object name should give error" do
  #     response = Rails::Generators.invoke("hot_glue:install --theme=dark_knight")
  #     expect(File.exist?("spec/dummy/app/views/layouts/_flash_notices.erb")).to be(true)
  #   end
  # end
end


