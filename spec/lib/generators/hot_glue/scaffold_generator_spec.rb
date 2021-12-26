require 'rails_helper'

describe HotGlue::ScaffoldGenerator do

  before(:each) do
    remove_everything
  end

  after(:each) do
    remove_everything
  end

  def remove_dir_with_namespace(path)
    FileUtils.rm_rf(path + "dfgs/")
  end

  def remove_dir(path)
    FileUtils.rm_rf(path)
  end

  def remove_everything
    # TODO: this feels a little ugly but is effective
    remove_dir_with_namespace('spec/Dummy/app/views/')
    remove_dir_with_namespace('spec/Dummy/app/controllers/')

    FileUtils.rm("spec/Dummy/app/controllers/xyzs_controller.rb") if File.exists?("spec/Dummy/app/controllers/xyzs_controller.rb")
    FileUtils.rm("spec/Dummy/app/controllers/dfgs_controller.rb") if File.exists?("spec/Dummy/app/controllers/dfgs_controller.rb")
    FileUtils.rm("spec/Dummy/app/controllers/hello/dfgs_controller.rb") if File.exists?("spec/Dummy/app/controllers/hello/dfgs_controller.rb")
    FileUtils.rm_rf('spec/Dummy/spec/')
    FileUtils.rm_rf('spec/Dummy/app/views/hello/dfgs')
    FileUtils.rm_rf('spec/Dummy/app/views/xyzs')
    FileUtils.rm_rf('spec/Dummy/app/views/ghis')
    FileUtils.rm_rf('spec/Dummy/app/views/abcs')

    remove_dir_with_namespace('spec/Dummy/app/views/hello')
    remove_dir_with_namespace('spec/Dummy/app/controllers/hello')
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
                                            ["Dfg","--specs-only","--no-specs"])
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
                                            ["Dfg","--specs-only"])
      rescue StandardError => e
        expect("error building in spec #{e}")
      end
      expect(File.exist?("spec/Dummy/spec/system/dfgs_behavior_spec.rb")).to be(true)
    end
  end


  describe "--no-specs" do
    it "should NOT create a file at specs/system" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--no-specs"])
      rescue StandardError => e
        expect("error building in spec #{e}")
      end
      expect(File.exist?("spec/Dummy/app/spec/system/dfgs_spec.rb")).to be(false)
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
                                              ["Dfg"])
        rescue StandardError => e
          raise("error building in spec #{e}")
        end
        expect(File.exist?("spec/Dummy/app/views/dfgs/edit.erb")).to be(true)
        expect(File.exist?("spec/Dummy/app/views/dfgs/index.erb")).to be(true)
        expect(File.exist?("spec/Dummy/app/views/dfgs/new.erb")).to be(true)
        expect(File.exist?("spec/Dummy/app/views/dfgs/_form.erb")).to be(true)
        expect(File.exist?("spec/Dummy/app/views/dfgs/_new_form.erb")).to be(true)
        expect(File.exist?("spec/Dummy/app/views/dfgs/_line.erb")).to be(true)
        expect(File.exist?("spec/Dummy/app/views/dfgs/_list.erb")).to be(true)
        expect(File.exist?("spec/Dummy/app/views/dfgs/_new_button.erb")).to be(true)
        expect(File.exist?("spec/Dummy/app/views/dfgs/_show.erb")).to be(true)
      end


      it "should create all of the turbo stream files" do
        begin
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Dfg"])
        rescue StandardError => e
          raise("error building in spec #{e}")
        end
        expect(File.exist?("spec/Dummy/app/views/dfgs/create.turbo_stream.erb")).to be(true)
        expect(File.exist?("spec/Dummy/app/views/dfgs/destroy.turbo_stream.erb")).to be(true)
        expect(File.exist?("spec/Dummy/app/views/dfgs/edit.turbo_stream.erb")).to be(true)
        expect(File.exist?("spec/Dummy/app/views/dfgs/update.turbo_stream.erb")).to be(true)
      end


      it "should create the controler" do
        begin
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Dfg"])
        rescue StandardError => e
          raise("error building in spec #{e}")
        end
        expect(File.exist?("spec/Dummy/app/controllers/dfgs_controller.rb")).to be(true)
      end
    end
  end



  describe "--namespace" do
    it "should create with a namespace" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--namespace=hello"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end
      expect(File.exist?("spec/Dummy/app/views/hello/dfgs/edit.erb")).to be(true)
      expect(File.exist?("spec/Dummy/app/views/hello/dfgs/index.erb")).to be(true)
      expect(File.exist?("spec/Dummy/app/views/hello/dfgs/new.erb")).to be(true)
      expect(File.exist?("spec/Dummy/app/views/hello/dfgs/_form.erb")).to be(true)
      expect(File.exist?("spec/Dummy/app/views/hello/dfgs/_new_form.erb")).to be(true)
      expect(File.exist?("spec/Dummy/app/views/hello/dfgs/_line.erb")).to be(true)
      expect(File.exist?("spec/Dummy/app/views/hello/dfgs/_list.erb")).to be(true)
      expect(File.exist?("spec/Dummy/app/views/hello/dfgs/_new_button.erb")).to be(true)
      expect(File.exist?("spec/Dummy/app/views/hello/dfgs/_show.erb")).to be(true)
      expect(File.exist?("spec/Dummy/app/controllers/hello/dfgs_controller.rb")).to be(true)
      expect(File.exist?("spec/Dummy/app/views/hello/dfgs/create.turbo_stream.erb")).to be(true)
      expect(File.exist?("spec/Dummy/app/views/hello/dfgs/destroy.turbo_stream.erb")).to be(true)
      expect(File.exist?("spec/Dummy/app/views/hello/dfgs/edit.turbo_stream.erb")).to be(true)
      expect(File.exist?("spec/Dummy/app/views/hello/dfgs/update.turbo_stream.erb")).to be(true)
      expect(File.exist?("spec/Dummy/spec/system/hello/dfgs_behavior_spec.rb")).to be(true)
    end
  end


  describe "--nest" do
    it "should create a file at and specs/system" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Ghi","--nest=dfg"])
      # begin
      #
      # rescue StandardError => e
      #   raise("error building in spec #{e}")
      # end

      expect(File.exist?("spec/Dummy/app/controllers/ghis_controller.rb")).to be(true)
      expect(File.exist?("spec/Dummy/spec/system/ghis_behavior_spec.rb")).to be(true)
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

    describe "--include and --smart-layout" do
      # TODO: implement specs

      describe "for bootstrap layout" do

      end


      describe "for hotglue layout" do

      end

    end
  end

  # --show-only
  # --magic-buttons
  # --downnest
  # --display-list-after-update
  # --smart-layout

  describe "--no-paginate" do
    it "should not create a list with pagination" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--no-paginate"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      expect(
        File.read("spec/Dummy/app/views/dfgs/_list.erb") =~ /paginate dfgs/
      ).to be(nil)
    end
  end

  describe "--no-create" do
    it "should not make the create files" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--no-create"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      expect(File.exist?("spec/Dummy/app/views/dfgs/new.erb")).to be(false)
      expect(File.exist?("spec/Dummy/app/views/dfgs/_new_form.erb")).to be(false)
      expect(File.exist?("spec/Dummy/app/views/dfgs/_new_button.erb")).to be(false)
      expect(File.exist?("spec/Dummy/app/views/dfgs/create.turbo_stream.erb")).to be(false)
    end
  end


  describe "--no-edit" do
    it "should not make the create files" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--no-edit"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      expect(File.exist?("spec/Dummy/app/views/dfgs/_form.erb")).to be(false)
      expect(File.exist?("spec/Dummy/app/views/dfgs/edit.erb")).to be(false)
      expect(File.exist?("spec/Dummy/app/views/dfgs/update.turbo_stream.erb")).to be(false)
    end
  end


  describe "--no-delete" do
    it "should not make the delete turbostream file" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--no-delete"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end
      expect(File.exist?("spec/Dummy/app/views/dfgs/destroy.turbo_stream.erb")).to be(false)
    end
  end

  describe "--big-edit" do
    it "should not make the delete turbostream file" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--big-edit"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      expect(
        File.read("spec/Dummy/app/views/dfgs/_show.erb") =~ /edit_dfg_path\(dfg\), 'data-turbo' => 'false',/
      ).to_not be(nil)
    end
  end

  describe "--show-only" do
    it "should make the show only fields visible only" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--show-only=name"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      expect(
        File.read("spec/Dummy/app/views/dfgs/_form.erb") =~ /f\.text_field :name/
      ).to be(nil)

    end

    it "should not include the show-only fields in the allowed parameters" do
      # TODO ***IMPLEMENT ME FOR SECURITY***
      # WITHOUT THIS THE CONTROLLERS GENERATED CAN BE HACKED!!!

    end
  end
end
