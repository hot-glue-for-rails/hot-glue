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


  describe "css strategies" do
    # it "with no layout " do
    #   expect {Rails::Generators.invoke("hot_glue:install", ["Ghi", ""])}.to raise_exception(/You have selected to install Hot Glue without a theme/)
    #   expect(nil).to be(nil)
    # end

    it "should install correctly with bootstrap " do
      Rails::Generators.invoke("hot_glue:install", ["Ghi", "--layout=bootstrap"])
      res = File.read("spec/dummy/config/hot_glue.yml")

    end
    it "should install correctly with tailwind " do
      Rails::Generators.invoke("hot_glue:install", ["Ghi", "--layout=tailwind"])
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


