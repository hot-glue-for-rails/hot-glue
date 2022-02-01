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
    remove_dir_with_namespace('spec/dummy/app/views/')
    remove_dir_with_namespace('spec/dummy/app/controllers/')
    FileUtils.rm("spec/dummy/app/controllers/users_controller.rb") if File.exists?("spec/dummy/app/controllers/xyzs_controller.rb")

    FileUtils.rm("spec/dummy/app/controllers/xyzs_controller.rb") if File.exists?("spec/dummy/app/controllers/xyzs_controller.rb")
    FileUtils.rm("spec/dummy/app/controllers/dfgs_controller.rb") if File.exists?("spec/dummy/app/controllers/dfgs_controller.rb")

    FileUtils.rm("spec/dummy/app/controllers/all_dfgs_controller.rb") if File.exists?("spec/dummy/app/controllers/dfgs_controller.rb")

    FileUtils.rm("spec/dummy/app/controllers/hello/dfgs_controller.rb") if File.exists?("spec/dummy/app/controllers/hello/dfgs_controller.rb")
    FileUtils.rm("spec/dummy/app/controllers/jkls_controller.rb") if File.exists?("spec/dummy/app/controllers/jkls_controller.rb")

    FileUtils.rm_rf('spec/dummy/spec/')
    FileUtils.rm_rf('spec/dummy/app/views/hello/dfgs')
    FileUtils.rm_rf('spec/dummy/app/views/xyzs')
    FileUtils.rm_rf('spec/dummy/app/views/all_dfgs')

    FileUtils.rm_rf('spec/dummy/app/views/users')

    FileUtils.rm_rf('spec/dummy/app/views/ghis')
    FileUtils.rm_rf('spec/dummy/app/views/abcs')
    FileUtils.rm_rf('spec/dummy/app/views/jkls')

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
          expect(e.message).to eq("*** Oops: It looks like is no association from class called Abc to the current_user. If your user is called something else, pass with flag auth=current_X where X is the model for your users as lowercase. Also, be sure to implement current_X as a method on your controller. (If you really don't want to implement a current_X on your controller and want me to check some other method for your current user, see the section in the docs for auth_identifier.) To make a controller that can read all records, specify with --god.")
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


  describe "--nested" do
    it "should create a file at and specs/system" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Ghi","--nested=dfg"])
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
    describe "by default assumes current_user is --auth" do
      it "should generate code protected to current user" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg"])
        expect(
          File.read("spec/Dummy/app/controllers/dfgs_controller.rb") =~ /before_action :authenticate_user!/
        ).to be_a(Numeric)
      end
    end

    describe "if passed an --auth flag" do
      it "should generate code protected to current user" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--auth=cantelope"])
        expect(
          File.read("spec/Dummy/app/controllers/dfgs_controller.rb") =~ /before_action :authenticate_cantelope!/
        ).to be_a(Numeric)
      end
    end

    describe "--auth_identifier" do
      it "should generate code protected to current user" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--auth_identifier=account"])

        expect(
          File.read("spec/Dummy/app/controllers/dfgs_controller.rb") =~ /before_action :authenticate_account!/
        ).to be_a(Numeric)
      end
    end

    describe "--gd" do
      it "should generate god contorllers" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--gd"])
        expect(
          File.read("spec/Dummy/app/controllers/dfgs_controller.rb") =~ /Dfg.find\(params\[:id\]\)/
        ).to be_a(Numeric)
      end
    end
  end



  describe "--plural" do
    # TODO: implement specs
  end


  describe "choosing which fields to include" do
    describe "--exclude" do
      it "should allow a list of exlcuded fields" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Jkl","--god","--exclude=long_description,cost"])

        # cost is excluded
        expect(
          File.read("spec/Dummy/app/views/jkls/_show.erb") =~ /cost/
        ).to be(nil)
        expect(
          File.read("spec/Dummy/app/views/jkls/_form.erb") =~ /cost/
        ).to be(nil)
        expect(
          File.read("spec/Dummy/app/controllers/jkls_controller.rb") =~ /cost/
        ).to be(nil)

        # long description is excluded
        expect(
          File.read("spec/Dummy/app/views/jkls/_show.erb") =~ /long_description/
        ).to be(nil)
        expect(
          File.read("spec/Dummy/app/views/jkls/_form.erb") =~ /long_description/
        ).to be(nil)
        expect(
          File.read("spec/Dummy/app/controllers/jkls_controller.rb") =~ /long_description/
        ).to be(nil)

        # blurb is not excluded
        expect(
          File.read("spec/Dummy/app/views/jkls/_show.erb") =~ /blurb/
        ).to be_a(Numeric)
        expect(
          File.read("spec/Dummy/app/views/jkls/_form.erb") =~ /blurb/
        ).to be_a(Numeric)
        expect(
          File.read("spec/Dummy/app/controllers/jkls_controller.rb") =~ /blurb/
        ).to be_a(Numeric)
      end
    end

    describe "--include and --smart-layout" do

      describe "basic --include usage" do
        it "should allow a list of whitelisted fields separated by comma fields" do
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Jkl","--god","--include=long_description,blurb"])

          # cost is excluded
          expect(
            File.read("spec/Dummy/app/views/jkls/_show.erb") =~ /cost/
          ).to be(nil)
          expect(
            File.read("spec/Dummy/app/views/jkls/_form.erb") =~ /cost/
          ).to be(nil)
          expect(
            File.read("spec/Dummy/app/controllers/jkls_controller.rb") =~ /cost/
          ).to be(nil)

          # long description is included
          expect(
            File.read("spec/Dummy/app/views/jkls/_show.erb") =~ /long_description/
          ).to be_a(Numeric)
          expect(
            File.read("spec/Dummy/app/views/jkls/_form.erb") =~ /long_description/
          ).to be_a(Numeric)
          expect(
            File.read("spec/Dummy/app/controllers/jkls_controller.rb") =~ /long_description/
          ).to be_a(Numeric)

          # long description is included
          expect(
            File.read("spec/Dummy/app/views/jkls/_show.erb") =~ /blurb/
          ).to be_a(Numeric)
          expect(
            File.read("spec/Dummy/app/views/jkls/_form.erb") =~ /blurb/
          ).to be_a(Numeric)
          expect(
            File.read("spec/Dummy/app/controllers/jkls_controller.rb") =~ /blurb/
          ).to be_a(Numeric)
        end


        describe "layout without smart layout" do
          it "builds 1 column for fields and 2 for the buttons" do
            response = Rails::Generators.invoke("hot_glue:scaffold",
                                                ["User","--gd", "--layout=bootstrap"])
            expect(
               File.read("spec/Dummy/app/views/users/_list.erb") =~ /<div class='col-md-1'>Email<\/div>/
            ).to be_a(Numeric)

            file = File.read("spec/Dummy/app/views/users/_show.erb")

            expect(
              File.read("spec/Dummy/app/views/users/_list.erb") =~ /scaffold-col-heading-buttons col-md-2/
            ).to be_a(Numeric)
          end
        end
      end

      describe "smart layout" do
        describe "when building bootstrap" do
          describe "with no downnested portals" do
            it "builds 10 column for fields and 2 for the buttons" do
              response = Rails::Generators.invoke("hot_glue:scaffold",
                                                  ["User",
                                                   "--gd",
                                                   "--smart-layout",
                                                   "--layout=bootstrap"])



              # TODO: IMPLEMENT ME
              # expect(
              #   File.read("spec/Dummy/app/views/users/_list.erb") =~ /<div class='col-md-10'>Email<\/div>/
              # ).to be_a(Numeric)
              #

              expect(
                File.read("spec/Dummy/app/views/users/_list.erb") =~ /scaffold-col-heading-buttons col-md-2/
              ).to be_a(Numeric)
            end
          end

          describe "with 1 downnested portal" do
            it "builds 4 columns for fields, 6 for the downnested portal, and 2 for the buttons" do
              response = Rails::Generators.invoke("hot_glue:scaffold",
                                                  ["User",
                                                   "--gd",
                                                   "--smart-layout",
                                                   "--downnest=dfgs", "--layout=bootstrap"])
              expect(
                File.read("spec/Dummy/app/views/users/_list.erb") =~ /<div class='col-md-2'>Email<\/div>/
              ).to be_a(Numeric)

              expect(
                File.read("spec/Dummy/app/views/users/_list.erb") =~ /<div class=" scaffold-col-heading col-sm-6" >/
              ).to be_a(Numeric)
              expect(
                File.read("spec/Dummy/app/views/users/_list.erb") =~ /Dfgs/
              ).to be_a(Numeric)
            end
          end

          describe "with 2 downnested portals" do
            it "builds 2 columns for fields, 4 for each of the the downnested portals, and 2 for the buttons" do
              response = Rails::Generators.invoke("hot_glue:scaffold",
                                                  ["User","--gd",
                                                   "--smart-layout",
                                                   "--downnest=dfgs,xyzs",
                                                   "--layout=bootstrap"])
              expect(
                File.read("spec/Dummy/app/views/users/_list.erb") =~ /<div class=" scaffold-col-heading col-sm-4" >/
              ).to be_a(Numeric)


              expect(
                File.read("spec/Dummy/app/views/users/_list.erb") =~ /Dfgs/
              ).to be_a(Numeric)

              expect(
                File.read("spec/Dummy/app/views/users/_list.erb") =~ /Xyzs/
              ).to be_a(Numeric)
            end
          end
        end


        describe "when building with hotglue layout" do
          # TODO: implement specs
          #
          #
        end
      end
    end
  end

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




  describe "ujs syntax" do
    it "should make detele with 'confirm': true for ujs_syntax=true" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc","--god","--ujs_syntax=true"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end
      result = File.read("spec/Dummy/app/views/abcs/_show.erb")
      
      expect(
        result =~ /{data: {'confirm': "Are you sure/
      ).to_not be(nil)
    end



    it "should make delete with 'confirm': true for ujs_syntax=true" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc","--god","--ujs_syntax=true"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      expect(
        File.read("spec/Dummy/app/views/abcs/_show.erb") =~ /data: {'turbo-confirm': 'Are you sure/
      ).to be(nil)


      expect(
        File.read("spec/Dummy/app/views/abcs/_show.erb") =~ / html: {data: {'confirm': "Are you sure /
      ).to_not be(nil)
    end

  end
  # TODO: add tests for
  # --magic-buttons
  # --downnest
  # --display-list-after-update
  # --smart-layout

end
