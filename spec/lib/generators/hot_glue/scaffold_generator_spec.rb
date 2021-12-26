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
    # TODO: this feels a little ugly but is effective
    remove_dir_with_namespace('spec/dummy/app/views/')
    remove_dir_with_namespace('spec/dummy/app/controllers/')

    FileUtils.rm("spec/dummy/app/controllers/xyzs_controller.rb") if File.exists?("spec/dummy/app/controllers/xyzs_controller.rb")
    FileUtils.rm("spec/dummy/app/controllers/defs_controller.rb") if File.exists?("spec/dummy/app/controllers/defs_controller.rb")
    FileUtils.rm("spec/dummy/app/controllers/hello/defs_controller.rb") if File.exists?("spec/dummy/app/controllers/hello/defs_controller.rb")
    FileUtils.rm_rf('spec/dummy/spec/')
    FileUtils.rm_rf('spec/dummy/app/views/hello/defs')
    FileUtils.rm_rf('spec/dummy/app/views/xyzs')
    FileUtils.rm_rf('spec/dummy/app/views/ghis')

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
          expect(e.message).to eq("*** Oops: The model Abc is missing an association for :def or the model Def doesn't exist. TODO: Please implement a model for Def; your model Abc should belong_to :def.  To make a controller that can read all records, specify with --god.")
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
    it "should create a file specs/system" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Def","--specs-only"])
      rescue StandardError => e
        expect("error building in spec #{e}")
      end
      expect(File.exist?("spec/dummy/spec/system/defs_behavior_spec.rb")).to be(true)
    end
  end


  describe "--no-specs" do
    it "should NOT create a file at specs/system" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Def","--no-specs"])
      rescue StandardError => e
        expect("error building in spec #{e}")
      end
      expect(File.exist?("spec/dummy/app/spec/system/defs_spec.rb")).to be(false)
    end
  end

  it "with an association to an object that doesn't exist" do
    begin
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Xyz"])
    rescue StandardError => e
      expect(e.class).to eq(HotGlue::Error)
      expect(e.message).to eq(
                             "*** Oops: The model Xyz is missing an association for :nothing or the model Nothing doesn't exist. TODO: Please implement a model for Nothing; your model Xyz should belong_to :nothing.  To make a controller that can read all records, specify with --god."
                           )
    end
  end

  describe "GOOD RESPONSES" do
    describe "with no parameters" do
      it "should create all the erb files" do
        begin
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Def"])
        rescue StandardError => e
          raise("error building in spec #{e}")
        end
        expect(File.exist?("spec/dummy/app/views/defs/edit.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/index.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/new.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/_form.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/_new_form.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/_line.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/_list.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/_new_button.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/_show.erb")).to be(true)
      end


      it "should create all of the turbo stream files" do
        begin
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Def"])
        rescue StandardError => e
          raise("error building in spec #{e}")
        end
        expect(File.exist?("spec/dummy/app/views/defs/create.turbo_stream.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/destroy.turbo_stream.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/edit.turbo_stream.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/defs/update.turbo_stream.erb")).to be(true)
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
      expect(File.exist?("spec/dummy/app/views/hello/defs/edit.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/index.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/new.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/_form.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/_new_form.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/_line.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/_list.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/_new_button.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/_show.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/controllers/hello/defs_controller.rb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/create.turbo_stream.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/destroy.turbo_stream.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/edit.turbo_stream.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/defs/update.turbo_stream.erb")).to be(true)
      expect(File.exist?("spec/dummy/spec/system/hello/defs_behavior_spec.rb")).to be(true)
    end
  end


  describe "--nest" do
    it "should create a file at and specs/system" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Ghi","--nest=def"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      expect(File.exist?("spec/dummy/app/controllers/ghis_controller.rb")).to be(true)
      expect(File.exist?("spec/dummy/spec/system/ghis_behavior_spec.rb")).to be(true)
    end
  end

  describe "authorization and object ownership" do
    describe "--auth" do
      # TODO: implement specs
    end

    describe "--auth_identifier" do
      # TODO: implement specs
    end

    describe "--gd" do
      # TODO: implement specs
    end
  end

  describe "--plural" do
    # TODO: implement specs
  end


  describe "choosing which fields to include" do
    describe "--exclude" do
      # TODO: implement specs
    end

    describe "--incldue" do
      # TODO: implement specs
    end
  end


  describe "--no-paginate" do
    it "should not make the create files" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Def","--no-paginate"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      expect(
        File.read("spec/dummy/app/views/defs/_list.erb") =~ /paginate defs/
      ).to be(nil)
    end
  end

  describe "--no-create" do
    it "should not make the create files" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Def","--no-create"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end
      expect(File.exist?("spec/dummy/app/views/defs/new.erb")).to be(false)
      expect(File.exist?("spec/dummy/app/views/defs/_new_form.erb")).to be(false)
      expect(File.exist?("spec/dummy/app/views/defs/_new_button.erb")).to be(false)
      expect(File.exist?("spec/dummy/app/viewsdefs/create.turbo_stream.erb")).to be(false)
    end
  end


  describe "--no-delete" do
    it "should not make the delete turbostream file" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Def","--no-delete"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end
      expect(File.exist?("spec/dummy/app/views/defs/destroy.turbo_stream.erb")).to be(false)
    end
  end

  describe "--big-edit" do
    it "should not make the delete turbostream file" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Def","--big-edit"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      expect(
        File.read("spec/dummy/app/views/defs/_show.erb") =~ /edit_def_path\(def\), 'data-turbo' => 'false',/
      ).to_not be(nil)
    end
  end

  describe "--show-only" do
    it "should make the show only fields visible only" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Def","--show-only=name"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      expect(
        File.read("spec/dummy/app/views/defs/_form.erb") =~ /f\.text_field :name/
      ).to be(nil)

    end

    it "should not include the show-only fields in the allowed parameters" do
      # TODO ***IMPLEMENT ME FOR SECURITY***
      # WITHOUT THIS THE CONTROLLERS GENERATED CAN BE HACKED!!!

    end
  end
end
