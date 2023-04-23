require 'rails_helper'


describe HotGlue::DirectUploadInstallGenerator do
  # include GeneratorsTestHelper

  def setup

  end

  def teardown

  end


  describe "importmap" do

    describe "when app/javascript/application.js is empty" do
      before(:each) do
        File.write("spec/dummy/app/javascript/application.js", "")
      end
      it "installs adds active storage to application.js " do
        Rails::Generators.invoke("hot_glue:direct_upload_install")
        res = File.read("spec/dummy/app/javascript/application.js")
        expect(res).to include("//= require activestorage")
      end
    end


    describe "when app/javascript/application.js already contains //= require activestorage" do
      before(:each) do
        File.write("spec/dummy/app/javascript/application.js", "//= require activestorage")
      end
      # PASSES LOCALLY, FAILS ON GITHUB ACTION
      # it "installs adds active storage to application.js " do
      #   Rails::Generators.invoke("hot_glue:direct_upload_install")
      #   res = File.read("spec/dummy/app/javascript/application.js")
      #   expect(res.scan(/(?=#{"//= require activestorage"})/).count).to be(1)
      # end
    end
  end

  describe "jsbundling" do

  end
end


