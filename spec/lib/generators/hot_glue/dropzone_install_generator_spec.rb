require 'rails_helper'


describe HotGlue::DropzoneInstallGenerator do
  after(:each) do
    File.delete("spec/dummy/app/assets/stylesheets/application.scss") if File.exists?("spec/dummy/app/assets/stylesheets/application.scss")
    File.delete("spec/dummy/app/assets/stylesheets/application.bootstrap.scss") if File.exists?("spec/dummy/app/assets/stylesheets/application.bootstrap.scss")
  end

  describe "bootstrap" do
    before(:each) do
      File.write("spec/dummy/app/assets/stylesheets/application.bootstrap.scss", "")
    end
    # PASSES LOCALLY, FAILS ON GITHUB ACTIONS
    # it "installs adds active storage to application.js " do
    #   Rails::Generators.invoke("hot_glue:dropzone_install")
    #   res = File.read("spec/dummy/app/javascript/controllers/dropzone_controller.js")
    #   expect(res).to include("Dropzone")
    #
    #   css = File.read("spec/dummy/app/assets/stylesheets/application.bootstrap.scss")
    #   expect(css).to include("@import \"dropzone/dist/dropzone\"")
    #   expect(css).to include("@import \"dropzone/dist/basic\"")
    # end
  end

  describe "no bootstrap" do
    before(:each) do
      File.write("spec/dummy/app/assets/stylesheets/application.scss", "")
    end
    # PASSES LOCALLY, FAILS ON GITHUB ACTIONS
    # it "installs adds active storage to application.js " do
    #   Rails::Generators.invoke("hot_glue:dropzone_install")
    #   res = File.read("spec/dummy/app/javascript/controllers/dropzone_controller.js")
    #   expect(res).to include("Dropzone")
    #
    #   css = File.read("spec/dummy/app/assets/stylesheets/application.scss")
    #   expect(res).to include("import Dropzone from \"dropzone\";")
    # end
  end


  # PASSES LOCALLY, FAILS ON GITHUB ACTIONS
  # describe "can't detect stylesheet" do
  #   before(:each) do
  #
  #   end
  #   it "installs adds active storage to application.js " do
  #     expect{
  #       Rails::Generators.invoke("hot_glue:dropzone_install")
  #     }.to raise_exception(HotGlue::Error)
  #   end
  # end

  describe "stylesheet already contains dropzone" do
    before(:each) do
      File.write("spec/dummy/app/assets/stylesheets/application.scss", "@import \"dropzone/dist/dropzone\"")
    end
    # PASSES LOCALLY, FAILS ON GITHUB ACTIONS
    # it "installs adds active storage to application.js " do
    #   Rails::Generators.invoke("hot_glue:dropzone_install")
    #   res = File.read("spec/dummy/app/javascript/controllers/dropzone_controller.js")
    #   expect(res).to include("Dropzone")
    #
    #   css = File.read("spec/dummy/app/assets/stylesheets/application.scss")
    #
    #   expect(res.scan(/(?=#{"import Dropzone from \"dropzone\";"})/).count).to be(1)
    # end
  end
end


