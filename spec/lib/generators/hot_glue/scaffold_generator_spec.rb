require 'rails_helper'

describe HotGlue::ScaffoldGenerator do

  # NOTE: a lot of what is tested here is duplicative with the
  # tests in some of the service objects
  # if the functionality has been extracted out of ScaffoldGenerator,
  # then it only needs to be tested whether or not the flag works
  # i.e., the smart layout generation is tested by itself
  #
  # if, in the event that the ScaffoldGenerator, which is the primary setup agent
  # + the god (unfortunate) god object somehow doesn't do ITS job correctly,
  # this file should catch that -- i.e., test only the flags themselves, default, etc.

  # it turns out this is an unfortunate amount of snapshot testing but for
  # this case I think it has actually worked out well (despite the fact that I generally don't prefer snapshot testing)
  #

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
    # FileUtils.rm("spec/dummy/app/controllers/users_controller.rb") if File.exists?("spec/dummy/app/controllers/xyzs_controller.rb")

    FileUtils.rm("spec/dummy/app/controllers/xyzs_controller.rb") if File.exists?("spec/dummy/app/controllers/xyzs_controller.rb")
    FileUtils.rm("spec/dummy/app/controllers/dfgs_controller.rb") if File.exists?("spec/dummy/app/controllers/dfgs_controller.rb")
    FileUtils.rm("spec/dummy/app/controllers/ghis_controller.rb") if File.exists?("spec/dummy/app/controllers/ghis_controller.rb")

    FileUtils.rm("spec/dummy/app/controllers/cantelopes_controller.rb") if File.exists?("spec/dummy/app/controllers/dfgs_controller.rb")

    FileUtils.rm("spec/dummy/app/controllers/all_dfgs_controller.rb") if File.exists?("spec/dummy/app/controllers/dfgs_controller.rb")

    FileUtils.rm("spec/dummy/app/controllers/hello/dfgs_controller.rb") if File.exists?("spec/dummy/app/controllers/hello/dfgs_controller.rb")
    FileUtils.rm("spec/dummy/app/controllers/jkls_controller.rb") if File.exists?("spec/dummy/app/controllers/jkls_controller.rb")

    FileUtils.rm_rf('spec/dummy/spec/')
    FileUtils.rm_rf('spec/dummy/app/views/hello/dfgs')
    FileUtils.rm_rf('spec/dummy/app/views/xyzs')
    FileUtils.rm_rf('spec/dummy/app/views/cantelopes/')
    FileUtils.rm_rf('spec/dummy/app/views/fruits/')

    FileUtils.rm_rf('spec/dummy/app/views/users')

    FileUtils.rm_rf('spec/dummy/app/views/ghis')
    FileUtils.rm_rf('spec/dummy/app/views/abcs')
    FileUtils.rm_rf('spec/dummy/app/views/jkls')
    FileUtils.rm_rf('spec/dummy/app/views/dfgs')

    remove_dir_with_namespace('spec/dummy/app/views/hello')
    remove_dir_with_namespace('spec/dummy/app/controllers/hello')
  end

  describe "#identify_object_owner" do
    # the Dfh model has an association for user_id
    let (:generator) {HotGlue::ScaffoldGenerator.new(["Dfg"], [], {:shell=> Thor::Shell::Color.new})}

    describe "when @object_owner_sym is empty" do
      it "should do nothing" do
        expect{
          generator.identify_object_owner
        }.to_not raise_error(HotGlue::Error)
      end
    end

    describe "when @object_owner_sym is NOT empty it should attempt to find the object's owner" do
      describe "when the object owner symbol is found via reflect_on_association (the current object has such an association)" do
        it "should set the object owner to the association" do
          expect(generator.instance_variable_get(:@ownership_field)).to eq("user_id")
        end
      end

      describe "when the object owner symbol is NOT found via reflect_on_association" do
        let (:generator) {HotGlue::ScaffoldGenerator.new(["Abc"], [], {:shell=> Thor::Shell::Color.new})}

        describe "when there are not any nested args" do
          it "should raise" do
            # the Abc model does not have a user_id
            #
            expect {
              generator.identify_object_owner
            }.to raise_exception
          end
        end

        describe "When there are nested args" do
          describe "when the user accidentally uses the plural form for the object owner" do
            let (:generator) {HotGlue::ScaffoldGenerator.new(["Ghi"], ["--nested=dfgs"], {:shell=> Thor::Shell::Color.new})}

            it "should suggest that I meant the singular version" do
              expect {
                generator.identify_object_owner
              }.to raise_exception("*** Oops: you tried to nest Ghi within a route for `dfgs` but I can't find an association for this relationship. Did you mean `dfg` (singular) instead?")
            end
          end

          describe "when all else fails" do
            # I think not reachable
            # let (:generator) {HotGlue::ScaffoldGenerator.new(["Ghi"], ["--nested=dfg"], {:shell=> Thor::Shell::Color.new})}

            # it "should tell me I'm missing a relationship from Dfg to user " do
            #   expect {
            #     generator.identify_object_owner
            #   }.to raise_exception("")
            # end
          end
        end
      end
    end
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
          expect(e.message).to eq("*** Oops: It looks like is no association `user` from the object Abc. If your user is called something else, pass with flag auth=current_X where X is the model for your users as lowercase. Also, be sure to implement current_X as a method on your controller. (If you really don't want to implement a current_X on your controller and want me to check some other method for your current user, see the section in the docs for auth_identifier.) To make a controller that can read all records, specify with --god.")
        end
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
      expect(File.exist?("spec/dummy/spec/system/dfgs_behavior_spec.rb")).to be(true)
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
      expect(File.exist?("spec/dummy/app/spec/system/dfgs_spec.rb")).to be(false)
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



  describe "#derrive_reference_name" do

    let (:hot_glue) {HotGlue}

    it "should suggest that I meant the singular version" do
      res = hot_glue.derrive_reference_name("Xyz")
      expect(res).to eq( "name")
    end

    it "should refer to a table with to_label if there is no name field" do
      res = hot_glue.derrive_reference_name("AtwToLabel")
      expect(res).to eq( "to_label")
    end

    it "should refer to a table with full_name if there is no name field" do
      res = hot_glue.derrive_reference_name("AtwFullName")
      expect(res).to eq( "full_name")
    end


    it "should refer to a table with display_name if there is no name field" do
      res = hot_glue.derrive_reference_name("AtwDisplayName")
      expect(res).to eq( "display_name")
    end

    it "should refer to a table with email if there is no name field" do
      res = hot_glue.derrive_reference_name("User")
      expect(res).to eq( "email")
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
        expect(File.exist?("spec/dummy/app/views/dfgs/edit.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/dfgs/index.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/dfgs/new.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/dfgs/_form.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/dfgs/_new_form.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/dfgs/_line.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/dfgs/_list.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/dfgs/_new_button.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/dfgs/_show.erb")).to be(true)
      end


      it "should create all of the turbo stream files" do
        begin
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Dfg"])
        rescue StandardError => e
          raise("error building in spec #{e}")
        end
        expect(File.exist?("spec/dummy/app/views/dfgs/create.turbo_stream.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/dfgs/destroy.turbo_stream.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/dfgs/edit.turbo_stream.erb")).to be(true)
        expect(File.exist?("spec/dummy/app/views/dfgs/update.turbo_stream.erb")).to be(true)
      end


      it "should create the controller" do
        begin
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Dfg"])
        rescue StandardError => e
          raise("error building in spec #{e}")
        end
        expect(File.exist?("spec/dummy/app/controllers/dfgs_controller.rb")).to be(true)
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
      expect(File.exist?("spec/dummy/app/views/hello/dfgs/edit.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/dfgs/index.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/dfgs/new.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/dfgs/_form.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/dfgs/_new_form.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/dfgs/_line.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/dfgs/_list.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/dfgs/_new_button.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/dfgs/_show.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/controllers/hello/dfgs_controller.rb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/dfgs/create.turbo_stream.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/dfgs/destroy.turbo_stream.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/dfgs/edit.turbo_stream.erb")).to be(true)
      expect(File.exist?("spec/dummy/app/views/hello/dfgs/update.turbo_stream.erb")).to be(true)
      expect(File.exist?("spec/dummy/spec/system/hello/dfgs_behavior_spec.rb")).to be(true)
    end
  end


  describe "--nested" do
    it "should create a file at and specs/system" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Ghi","--nested=dfg"])

      expect(File.exist?("spec/dummy/app/controllers/ghis_controller.rb")).to be(true)
      expect(File.exist?("spec/dummy/spec/system/ghis_behavior_spec.rb")).to be(true)
    end
  end

  describe "authorization and object ownership" do
    describe "by default assumes current_user is --auth" do
      it "should generate code protected to current user" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg"])
        expect(
          File.read("spec/dummy/app/controllers/dfgs_controller.rb") =~ /before_action :authenticate_user!/
        ).to be_a(Numeric)
      end
    end

    describe "if passed an --auth flag" do
      it "should generate code protected to current user" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--auth=cantelope"])
        expect(
          File.read("spec/dummy/app/controllers/dfgs_controller.rb") =~ /before_action :authenticate_cantelope!/
        ).to be_a(Numeric)
      end
    end

    describe "--auth_identifier" do
      it "should generate code protected to current user" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--auth_identifier=account"])

        expect(
          File.read("spec/dummy/app/controllers/dfgs_controller.rb") =~ /before_action :authenticate_account!/
        ).to be_a(Numeric)
      end
    end

    describe "--gd" do
      it "should generate god contorllers" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--gd"])
        expect(
          File.read("spec/dummy/app/controllers/dfgs_controller.rb") =~ /Dfg.find\(params\[:id\]\)/
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
          File.read("spec/dummy/app/views/jkls/_show.erb") =~ /cost/
        ).to be(nil)
        expect(
          File.read("spec/dummy/app/views/jkls/_form.erb") =~ /cost/
        ).to be(nil)
        expect(
          File.read("spec/dummy/app/controllers/jkls_controller.rb") =~ /cost/
        ).to be(nil)

        # long description is excluded
        expect(
          File.read("spec/dummy/app/views/jkls/_show.erb") =~ /long_description/
        ).to be(nil)
        expect(
          File.read("spec/dummy/app/views/jkls/_form.erb") =~ /long_description/
        ).to be(nil)
        expect(
          File.read("spec/dummy/app/controllers/jkls_controller.rb") =~ /long_description/
        ).to be(nil)

        # blurb is not excluded
        expect(
          File.read("spec/dummy/app/views/jkls/_show.erb") =~ /blurb/
        ).to be_a(Numeric)
        expect(
          File.read("spec/dummy/app/views/jkls/_form.erb") =~ /blurb/
        ).to be_a(Numeric)
        expect(
          File.read("spec/dummy/app/controllers/jkls_controller.rb") =~ /blurb/
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
            File.read("spec/dummy/app/views/jkls/_show.erb") =~ /cost/
          ).to be(nil)
          expect(
            File.read("spec/dummy/app/views/jkls/_form.erb") =~ /cost/
          ).to be(nil)
          expect(
            File.read("spec/dummy/app/controllers/jkls_controller.rb") =~ /cost/
          ).to be(nil)

          # long description is included
          expect(
            File.read("spec/dummy/app/views/jkls/_show.erb") =~ /long_description/
          ).to be_a(Numeric)
          expect(
            File.read("spec/dummy/app/views/jkls/_form.erb") =~ /long_description/
          ).to be_a(Numeric)
          expect(
            File.read("spec/dummy/app/controllers/jkls_controller.rb") =~ /long_description/
          ).to be_a(Numeric)

          # long description is included
          expect(
            File.read("spec/dummy/app/views/jkls/_show.erb") =~ /blurb/
          ).to be_a(Numeric)
          expect(
            File.read("spec/dummy/app/views/jkls/_form.erb") =~ /blurb/
          ).to be_a(Numeric)
          expect(
            File.read("spec/dummy/app/controllers/jkls_controller.rb") =~ /blurb/
          ).to be_a(Numeric)
        end


        describe "layout without smart layout" do
          it "builds 1 column for fields and 2 for the buttons" do
            response = Rails::Generators.invoke("hot_glue:scaffold",
                                                ["User","--gd", "--layout=bootstrap"])
            expect(
               File.read("spec/dummy/app/views/users/_list.erb") =~ /<div class='col-md-1'>Email<\/div>/
            ).to be_a(Numeric)

            file = File.read("spec/dummy/app/views/users/_show.erb")

            expect(
              File.read("spec/dummy/app/views/users/_list.erb") =~ /scaffold-col-heading-buttons col-md-2/
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
              #   File.read("spec/dummy/app/views/users/_list.erb") =~ /<div class='col-md-10'>Email<\/div>/
              # ).to be_a(Numeric)
              #

              expect(
                File.read("spec/dummy/app/views/users/_list.erb") =~ /scaffold-col-heading-buttons col-md-2/
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
                File.read("spec/dummy/app/views/users/_list.erb") =~ /<div class='col-md-2'>Email<\/div>/
              ).to be_a(Numeric)

              expect(
                File.read("spec/dummy/app/views/users/_list.erb") =~ /<div class=" scaffold-col-heading col-sm-4" >/
              ).to be_a(Numeric)
              expect(
                File.read("spec/dummy/app/views/users/_list.erb") =~ /Dfgs/
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
                File.read("spec/dummy/app/views/users/_list.erb") =~ /<div class=" scaffold-col-heading col-sm-4" >/
              ).to be_a(Numeric)


              expect(
                File.read("spec/dummy/app/views/users/_list.erb") =~ /Dfgs/
              ).to be_a(Numeric)

              expect(
                File.read("spec/dummy/app/views/users/_list.erb") =~ /Xyzs/
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
        File.read("spec/dummy/app/views/dfgs/_list.erb") =~ /paginate dfgs/
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

      expect(File.exist?("spec/dummy/app/views/dfgs/new.erb")).to be(false)
      expect(File.exist?("spec/dummy/app/views/dfgs/_new_form.erb")).to be(false)
      expect(File.exist?("spec/dummy/app/views/dfgs/_new_button.erb")).to be(false)
      expect(File.exist?("spec/dummy/app/views/dfgs/create.turbo_stream.erb")).to be(false)
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

      expect(File.exist?("spec/dummy/app/views/dfgs/_form.erb")).to be(false)
      expect(File.exist?("spec/dummy/app/views/dfgs/edit.erb")).to be(false)
      expect(File.exist?("spec/dummy/app/views/dfgs/update.turbo_stream.erb")).to be(false)
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
      expect(File.exist?("spec/dummy/app/views/dfgs/destroy.turbo_stream.erb")).to be(false)
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
        File.read("spec/dummy/app/views/dfgs/_show.erb") =~ /edit_dfg_path\(dfg\)/
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
        File.read("spec/dummy/app/views/dfgs/_form.erb") =~ /f\.text_field :name/
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
      result = File.read("spec/dummy/app/views/abcs/_show.erb")
      
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
        File.read("spec/dummy/app/views/abcs/_show.erb") =~ /data: {'turbo-confirm': 'Are you sure/
      ).to be(nil)


      expect(
        File.read("spec/dummy/app/views/abcs/_show.erb") =~ / html: {data: {'confirm': "Are you sure /
      ).to_not be(nil)
    end

  end

  describe "can build a table name that has a nested model name" do
    it "should generate scaffold for a model at a namespace" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Fruits::Cantelope","--gd"])

      expect(
        File.read("spec/dummy/app/controllers/cantelopes_controller.rb") =~ /class CantelopesController < ApplicationController/
      ).to be_a(Numeric)
    end
  end


  describe "N+1 killer" do
    it "should allow a list of whitelisted fields separated by comma fields" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Dfg","--god","--include=user_id"])
      expect(
        File.read("spec/dummy/app/controllers/dfgs_controller.rb") =~ /\.includes\(:user\)/
      ).to be_a(Numeric)
    end

  end

  describe "--no-list-heading" do
    it "should omit the list heading when flag is passed" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc","--god","--no-list-heading"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      expect(
        File.read("spec/dummy/app/views/abcs/_list.erb") =~ /Abcs/
      ).to be(nil)
    end
  end


  describe "--form-labels-position" do
    it "by default incldue them after" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc","--god"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      expect(
        File.read("spec/dummy/app/views/abcs/_form.erb") =~ /<label class='small form-text text-muted'>Name\<\/label>/
      ).to_not be(nil)
    end

    it "with 'omit' should make no labels" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc","--god",
                                             "--form-labels-position=omit"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      expect(
        File.read("spec/dummy/app/views/abcs/_form.erb") =~ /<label class='small form-text text-muted'>Name\<\/label>/
      ).to be(nil)
    end


    it "with 'before' should make no labels" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc","--god",
                                             "--form-labels-position=before"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      expect(
        File.read("spec/dummy/app/views/abcs/_form.erb") =~ /<label class='small form-text text-muted'>Name\<\/label>  <%= f.text_field :name, value: abc.name, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>/
      ).to_not be(nil)
    end
  end

  describe "--form-placeholder-labels" do
    it "should by default NOT make placeholder labels" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc","--god"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      expect(
        File.read("spec/dummy/app/views/abcs/_form.erb") =~ /<%= f.text_field :name, value: abc.name, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>/
      ).to_not be(nil)
    end

    it "should make placeholder labels" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc","--god",
                                             "--form-placeholder-labels"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      expect(
        File.read("spec/dummy/app/views/abcs/_form.erb") =~ /<%= f.text_field :name, value: abc.name, autocomplete: 'off', size: 40, class: 'form-control', type: '', placeholder: 'Name' %>/
      ).to_not be(nil)
    end
  end

  describe "--inline-list-labels" do
    it "should by default NOT make inline labels on the show page" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc","--god"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      expect(
        File.read("spec/dummy/app/views/abcs/_show.erb") =~ /<label class='small form-text text-muted'>Name\<\/label>/
      ).to be(nil)
    end

    it "should make inline labels on the show page - after" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc","--god",
                                             "--inline-list-labels=after"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      res = File.read("spec/dummy/app/views/abcs/_show.erb")
      expect(res).to include("<%= abc.name %><br/><label class='small form-text text-muted'>Name</label>")

    end

    it "should make inline labels on the show page" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc","--god",
                                             "--inline-list-labels=before"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end
      res = File.read("spec/dummy/app/views/abcs/_show.erb")
      expect(res).to include("<label class='small form-text text-muted'>Name</label><%= abc.name %>")
    end
  end

  describe "--magic-buttons" do

    it "should make a magic button" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--god",
                                             "--magic-buttons=activate"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end
      res = File.read("spec/dummy/app/views/dfgs/_show.erb")
      expect(res).to include("<%= f.submit 'Activate'.html_safe, disabled: (dfg.respond_to?(:activateable?) && ! dfg.activateable? ), class: 'dfg-button btn btn-primary ' %>")
    end
  end


  describe "the hawk" do
    it "should hawk a foreign key with no specified assoc to the current_user" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Ghi",
                                             "--hawk=dfg_id"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end
      res = File.read("spec/dummy/app/views/ghis/_form.erb")
      expect(res).to include("f.collection_select(:dfg_id, current_user.dfgs,")
    end


    it "should hawk a foreign key with two specified assocs to the current user" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Ghi",
                                             "--hawk=dfg_id,xyz_id"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end
      res = File.read("spec/dummy/app/views/ghis/_form.erb")
      expect(res).to include("f.collection_select(:dfg_id, current_user.dfgs,")
      expect(res).to include("f.collection_select(:xyz_id, current_user.xyzs,")
    end


    it "should protect against a malicious input" do
      begin
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Ghi",
                                             "--hawk=dfg_id,xyz_id"])
      rescue StandardError => e
        raise("error building in spec #{e}")
      end

      res = File.read("spec/dummy/app/controllers/ghis_controller.rb")
      expect(res).to include("hawk_params( {dfg_id: [current_user, \"dfgs\"] , xyz_id: [current_user, \"xyzs\"] }, modified_params)")

    end
  end


  describe "--markup" do
    # this is to catch for mistaken entry
    it "raise an exception" do
      expect { Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Ghi",
                                             "--markup=haml"])
      }.to raise_exception("Using --markup flag in the generator is deprecated; instead, use a file at config/hot_glue.yml with a key markup set to `erb` or `haml`")
    end
  end


  describe "--spec-only and --no-specs" do
    # this is to catch for mistaken entry
    it "raise an exception" do
      expect { Rails::Generators.invoke("hot_glue:scaffold",
                                        ["Ghi",
                                         "--specs-only", "--no-specs"])
      }.to raise_exception("*** Oops: You seem to have specified both the --specs-only flag and --no-specs flags. this doesn't make any sense, so I am aborting. Aborting.")
    end
  end

  describe "--exclude and --include" do
    # this is to catch for mistaken entry
    it "raise an exception" do
      expect { Rails::Generators.invoke("hot_glue:scaffold",
                                        ["Ghi",
                                         "--exclude=abc,def", "--include=def"])
      }.to raise_exception("*** Oops: You seem to have specified both --include and --exclude. Please use one or the other. Aborting.")
    end
  end


  describe "mocking the yaml for markup and layout config" do
    let(:yaml_stub) {{layout: "bootstrap", markup: "erb"}}
    describe "for --markup=haml" do
      before(:each) do
        allow(YAML).to receive(:load).and_return(yaml_stub.merge( markup: "haml"))
      end

      it "should tell me no no " do
        expect { Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Ghi"])
        }.to raise_exception("HAML IS NOT IMPLEMENTED")

      end
    end
    describe "for --markup=slim" do
      before(:each) do
        allow(YAML).to receive(:load).and_return(yaml_stub.merge(markup: "slim"))
      end

      it "should tell me no no " do
        expect { Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Ghi"])
        }.to raise_exception("SLIM IS NOT IMPLEMENTED")

      end
    end



    describe "for --layout=nonsense" do
      before(:each) do
        allow(YAML).to receive(:load).and_return(yaml_stub.merge(layout: "nonsense"))
      end

      it "should tell me no no " do
        expect { Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Ghi"])
        }.to raise_exception("Invalid option nonsense in Hot glue config (config/hot_glue.yml). You must either use --layout= when generating or have a file config/hotglue.yml; specify layout as either 'hotglue' or 'bootstrap'")

      end
    end


    describe "for --plural that doesn't end with an s (?should the be supported?)" do

      it "should tell me no no " do
        expect { Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Ghi", "--plural=thing"])
        }.to raise_exception("can't build with controller name thing because it doesn't end with an 's'")

      end
    end

  end

  describe "--downnest" do

  end

  describe "--display-list-after-update" do

  end

  describe "--smart-layout" do

  end
end
