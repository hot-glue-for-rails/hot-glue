require 'rails_helper'


describe HotGlue::InstallGenerator do
  # include GeneratorsTestHelper

  def setup

  end

  def teardown
  end


  describe "css strategies" do
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
      response = Rails::Generators.invoke("hot_glue:install --theme=dark_knight")

    end
  end
end


