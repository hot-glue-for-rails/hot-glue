require 'rails_helper'

describe HotGlue::ScaffoldGenerator do

  before(:each) do
    remove_everything
  end

  after(:each) do
    remove_everything
  end

  def remove_dir_with_namespace(path)
    FileUtils.rm_rf(path + "defs/")
  end

  def remove_dir(path)
    FileUtils.rm_rf(path)
  end




  def remove_everything
    remove_dir_with_namespace('spec/dummy/app/views/')
    remove_dir_with_namespace('spec/dummy/app/controllers/')

    FileUtils.rm("spec/dummy/app/controllers/defs_controller.rb") if File.exists?("spec/dummy/app/controllers/defs_controller.rb")
    FileUtils.rm("spec/dummy/app/controllers/hello/defs_controller.rb") if File.exists?("spec/dummy/app/controllers/hello/defs_controller.rb")
    FileUtils.rm_rf('spec/dummy/spec/')

    remove_dir_with_namespace('spec/dummy/app/views/hello')
    remove_dir_with_namespace('spec/dummy/app/controllers/hello')
  end

  describe "with no object for the model specified" do
    it "with no object for the model specified" do

      begin
        response = Rails::Generators.invoke("hot_glue:scaffold", ["Thing"])
      rescue StandardError => e
        expect(e.class).to eq(HotGlue::Error)
        expect(e.message).to eq("*** Oops: It looks like there is no object for Thing. Please define the object + database table first.")
      end
    end
  end

  describe "with object for the model specified" do
    describe "without an association to the current_user" do
      it "should tell me I need to associate Abc to current_user" do
        begin
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Abc"])
        rescue StandardError => e
          expect(e.class).to eq(HotGlue::Error)
          expect(e.message).to eq("*** Oops: It looks like is no association from current_user to a class called Abc. If your user is called something else, pass with flag auth=current_X where X is the model for your users as lowercase. Also, be sure to implement current_X as a method on your controller. (If you really don't want to implement a current_X on your controller and want me to check some other method for your current user, see the section in the docs for auth_identifier.) To make a controller that can read all records, specify with --god.")
        end
      end
    end
  end


  describe "--specs-only and --no-specs" do
    it "with both --specs-only and --no-specs" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Def","--specs-only","--no-specs"])
      rescue StandardError => e
        expect(e.class).to eq(HotGlue::Error)
        expect(e.message).to eq("*** Oops: You seem to have specified both the --specs-only flag and --no-specs flags. this doesn't make any sense, so I am aborting. sorry.")
      end
    end
  end

  describe "--specs-only" do
    it "should create a file at specs/request/ and specs/system" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Def","--specs-only"])
      rescue StandardError => e
        expect("error building in spec #{e}")
      end
      expect(File.exist?("spec/dummy/spec/request/defs_spec.rb")).to be(true)
      expect(File.exist?("spec/dummy/spec/system/defs_spec.rb")).to be(true)

    end
  end


  describe "--no-specs" do
    it "should NOT create a file at specs/request/ and specs/system" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Def","--no-specs"])
      rescue StandardError => e
        expect("error building in spec #{e}")
      end
      expect(File.exist?("spec/dummy/app/spec/system/defs_spec.rb")).to be(false)
      expect(File.exist?("spec/dummy/app/spec/request/defs_spec.rb")).to be(false)
    end
  end

  it "with an association to an object that doesn't exist" do
    begin
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Xyz"])
    rescue StandardError => e
      expect(e.class).to eq(HotGlue::Error)
      expect(e.message).to eq("*** Oops: The table Xyz has an association for 'nothing', but I can't find an assoicated model for that association. TODO: Please implement a model for nothing that belongs to Xyz ")
    end
  end

  describe "GOOD RESPONSES" do
    describe "with no parameters" do
      it "should create all the haml files" do
        begin
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Def"])
        rescue StandardError => e
          raise("error building in spec #{e}")
        end
        expect(File.exist?("spec/dummy/app/views/defs/edit.haml")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/index.haml")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/new.haml")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/_form.haml")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/_new_form.haml")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/_line.haml")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/_list.haml")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/_new_button.haml")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/_show.haml")).to be(true)
      end


      it "should create all of the turbo stream files" do
        begin
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Def"])
        rescue StandardError => e
          raise("error building in spec #{e}")
        end
        expect(File.exist?("spec/dummy/app/views/defs/create.turbo_stream.haml")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/destroy.turbo_stream.haml")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/edit.turbo_stream.haml")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/update.turbo_stream.haml")).to be(true)
      end


      it "should create the controler" do
        begin
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Def"])
        rescue StandardError => e
          raise("error building in spec #{e}")
        end
        expect(File.exist?("spec/dummy/app/controllers/defs_controller.rb")).to be(true)
      end
    end
  end



  describe "--namespace" do
    it "should create with a namespace" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Def","--namespace=hello"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end
      expect(File.exist?("spec/dummy/app/views/hello/defs/edit.haml")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/index.haml")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/new.haml")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/_form.haml")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/_new_form.haml")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/_line.haml")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/_list.haml")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/_new_button.haml")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/_show.haml")).to be(true)
      expect(File.exist?("spec/dummy/app/controllers/hello/defs_controller.rb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/create.turbo_stream.haml")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/destroy.turbo_stream.haml")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/edit.turbo_stream.haml")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/update.turbo_stream.haml")).to be(true)
      expect(File.exist?("spec/dummy/spec/request/hello/defs_spec.rb")).to be(true)
      expect(File.exist?("spec/dummy/spec/system/hello/defs_spec.rb")).to be(true)
    end
  end


  describe "--nest" do

  end

  describe "--auth" do

  end

  describe "--auth_identifier" do

  end

  describe "--plural" do

  end

  describe "--exclude" do

  end

  describe "--gd" do

  end

  describe "--no-paginate" do

  end


  describe "--no-create" do
    it "should not make the create files" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Def","--no-create"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end
      expect(File.exist?("spec/dummy/app/views/defs/new.haml")).to be(false)
      expect(File.exist?("spec/dummy/app/views/defs/_new_form.haml")).to be(false)
      expect(File.exist?("spec/dummy/app/views/defs/_new_button.haml")).to be(false)
      expect(File.exist?("spec/dummy/app/viewsdefs/create.turbo_stream.haml")).to be(false)
    end
  end


  describe "--no-delete" do

  end

  describe "--big-edit" do

  end

end
