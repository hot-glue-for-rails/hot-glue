require 'rails_helper'

describe "HotGlue::ScaffoldGenerator" do
  before(:all) do
    $INTERNAL_SPECS = true
  end

  after(:all) do
    $INTERNAL_SPECS = nil
  end

  before(:each) do
    remove_everything
  end

  after(:each) do
    remove_everything
  end

  def remove_dir_with_namespace(path)
    FileUtils.rm_rf(path)
  end

  def remove_dir(path)
    FileUtils.rm_rf(path)
  end

  def remove_file(file)
    FileUtils.rm(file) if File.exist?(file)
  end

  def remove_everything
    remove_dir_with_namespace('spec/dummy/app/views/')
    # remove_dir_with_namespace('spec/dummy/app/controllers/')
    remove_file("spec/dummy/app/controllers/users_controller.rb")
    remove_file("spec/dummy/app/controllers/abcs_controller.rb")
    remove_file("spec/dummy/app/controllers/xyzs_controller.rb")
    remove_file("spec/dummy/app/controllers/dfgs_controller.rb")
    remove_file("spec/dummy/app/controllers/ghis_controller.rb")
    remove_file("spec/dummy/app/controllers/atw_display_names_controller.rb")

    remove_file("spec/dummy/app/controllers/cantelopes_controller.rb")
    remove_file("spec/dummy/app/controllers/visits_controller.rb")

    remove_file("spec/dummy/app/controllers/all_dfgs_controller.rb")

    remove_file("spec/dummy/app/controllers/hello/dfgs_controller.rb")
    remove_file("spec/dummy/app/controllers/jkls_controller.rb")

    remove_dir_with_namespace('spec/dummy/app/views/users')
    remove_dir_with_namespace('spec/dummy/spec/features')

    remove_dir_with_namespace('spec/dummy/app/views/ghis')
    remove_dir_with_namespace('spec/dummy/app/views/abcs')
    remove_dir_with_namespace('spec/dummy/app/views/jkls')
    remove_dir_with_namespace('spec/dummy/app/views/dfgs')
    remove_dir_with_namespace('spec/dummy/app/views/xyzs')

    remove_dir_with_namespace('spec/dummy/app/views/hello')
    remove_dir_with_namespace('spec/dummy/app/controllers/hello')
  end

  describe "#identify_object_owner" do
    describe "when @object_owner_sym is NOT empty it should attempt to find the object's owner" do
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
              }.to raise_error(HotGlue::Error, "When trying to nest Ghi within dfgs, check the Ghi model for the dfgs association: \n belongs_to :dfgs")
            end
          end
        end
      end
    end
  end

  describe "with no object for the model specified" do
    it "with no object for the model specified" do
      expect{
        Rails::Generators.invoke("hot_glue:scaffold", ["Thing"])
      }.to raise_exception("*** Oops: It looks like there is no object for Thing. Please define the object + database table first.")
    end
  end

  describe "with object for the model specified" do
    describe "without an association to the current_user" do
      it "should tell me I need to associate Abc to current_user" do
        expect{Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Abc"])
        }.to raise_exception("*** Oops: It looks like is no association `user` from the object Abc. If your user is called something else, pass with flag auth=current_X where X is the model for your users as lowercase. Also, be sure to implement current_X as a method on your controller. (If you really don't want to implement a current_X on your controller and want me to check some other method for your current user, see the section in the docs for auth_identifier.) To make a controller that can read all records, specify with --god.")
      end
    end
  end

  describe "--specs-only" do
    it "should create a file specs/features" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Dfg","--specs-only"])
      expect(File.exist?("spec/dummy/spec/controller/dfgs_controller.rb")).to be(false)
      expect(File.exist?("spec/dummy/spec/features/dfgs_behavior_spec.rb")).to be(true)
    end
  end

  describe "--no-create" do
    it "should not make the create files" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Dfg","--no-create"])

      expect(File.exist?("spec/dummy/app/views/dfgs/new.erb")).to be(false)
      expect(File.exist?("spec/dummy/app/views/dfgs/_new_form.erb")).to be(false)
      expect(File.exist?("spec/dummy/app/views/dfgs/_new_button.erb")).to be(false)
      expect(File.exist?("spec/dummy/app/views/dfgs/create.turbo_stream.erb")).to be(false)
    end
  end

  describe "--no-edit" do
    it "should not make the create files" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Dfg","--no-edit"])
      expect(File.exist?("spec/dummy/app/views/dfgs/edit.erb")).to be(false)
      expect(File.exist?("spec/dummy/app/views/dfgs/update.turbo_stream.erb")).to be(false)
    end
  end

  describe "--no-delete" do
    it "should not make the delete turbostream file" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Dfg","--no-delete"])
      expect(File.exist?("spec/dummy/app/views/dfgs/destroy.turbo_stream.erb")).to be(false)
    end
  end

  describe "--big-edit" do
    it "should not make the delete turbostream file" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Dfg","--big-edit"])

      expect(
        File.read("spec/dummy/app/views/dfgs/_show.erb") =~ /edit_dfg_path\(dfg\)/
      ).to_not be(nil)
    end

    it "should not put downnest portals on the list view instead putting them on the edit page" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["User","--gd",
                                           "--big-edit",
                                           "--smart-layout",
                                           "--downnest=dfgs,xyzs",
                                           "--layout=bootstrap"])

      list_view = File.read("spec/dummy/app/views/users/_show.erb")
      expect(list_view ).to_not include("Dfgs")
      edit_view = File.read("spec/dummy/app/views/users/edit.erb")
      expect(edit_view ).to include("<%= render partial: \"dfgs/list")
    end
  end

  describe "--no-specs" do
    # disabled because it is a false negative
    # it "should NOT create a file at specs/system" do
    #   response = Rails::Generators.invoke("hot_glue:scaffold",
    #                                       ["Dfg","--no-specs"])
    #
    #   expect(File.exist?("spec/dummy/app/spec/system/dfgs_spec.rb")).to be(false)
    # end
  end

  it "with an association to an object that doesn't exist" do
    # FALSE POSITIVE
    # begin
    #   response = Rails::Generators.invoke("hot_glue:scaffold",
    #                                       ["Xyz"])
    # rescue StandardError => e
    #   expect(e.class).to eq(HotGlue::Error)
    #   expect(e.message).to eq(
    #                          "*** Oops: The model Xyz is missing an association for :nothing or the model Nothing doesn't exist. TODO: Please implement a model for Nothing; or add to Xyz `belongs_to :nothing`. To make a controller that can read all records, specify with --god."
    #                        )
    # end
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

  describe "--namespace" do
    it "should create with a namespace" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Dfg","--namespace=hello"])
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
      expect(File.exist?("spec/dummy/spec/features/hello/dfgs_behavior_spec.rb")).to be(true)
    end
  end

  describe "--nested" do
    it "should create a file at and specs/features" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Ghi","--nested=dfg"])

      expect(File.exist?("spec/dummy/app/controllers/ghis_controller.rb")).to be(true)
      expect(File.exist?("spec/dummy/spec/features/ghis_behavior_spec.rb")).to be(true)
    end


    describe "when the user accidentally uses the plural form for the object owner" do
      let (:generator) {HotGlue::ScaffoldGenerator.new(["Ghi"], ["--nested=dfg", "--gd"], {:shell=> Thor::Shell::Color.new})}

      it "should treat the object scope as the last thing in the chain" do
        expect(generator.object_scope).to eq("@dfg.ghis")
      end
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

      describe "when passed an --auth flag with a ." do
        it "should allow me to hawk a nonusual root using curly brace syntax { .. }, like anything that the current_user belongs to" do
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Visit",
                                               "--auth=current_user.family"])


          res = File.read("spec/dummy/app/controllers/visits_controller.rb")
          expect(res).to include("before_action :authenticate_user!")
        end
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

  describe "tailwind" do
    before(:each) do

    end
    it "should generate" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Jkl","--god","--layout=tailwind"])


    end
  end

  describe "choosing which fields to include" do
    it "should not include the object owner by default" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg"])
        _form = File.read("spec/dummy/app/views/dfgs/_form.erb")
        expect(_form).to_not include("<%= f.collection_select(:user_id,")

        _show = File.read("spec/dummy/app/views/dfgs/_show.erb")
        expect(_form).to_not include("<%= dfg.user")
    end

    describe "--exclude" do
      it "should allow a list of exlcuded fields" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Jkl","--god","--exclude=long_description,cost"])

        # cost is excluded
        expect(File.read("spec/dummy/app/views/jkls/_show.erb")).to_not include("cost")
        expect(File.read("spec/dummy/app/views/jkls/_form.erb")).to_not include("cost")

        expect(File.read("spec/dummy/app/controllers/jkls_controller.rb")).to_not include(":cost")

        # long description is excluded
        expect(
          File.read("spec/dummy/app/views/jkls/_show.erb") =~ /long_description/
        ).to be(nil)
        expect(
          File.read("spec/dummy/app/views/jkls/_form.erb") =~ /long_description/
        ).to be(nil)
        expect(
          File.read("spec/dummy/app/controllers/jkls_controller.rb") =~ /:long_description/
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
          # it "builds 1 column for fields and 2 for the buttons" do
          #   response = Rails::Generators.invoke("hot_glue:scaffold",
          #                                       ["User","--gd", "--layout=bootstrap"])
          #
          #   res = File.read("spec/dummy/app/views/users/_list.erb")
          #
          #   expect(res).to include("<div class='col-sm-1' heading--user--email >Email</div>")
          #   res2 = File.read("spec/dummy/app/views/users/_show.erb")
          #   byebug
          #   expect(res2).to include("scaffold-col-heading scaffold-col-heading-buttons")
          # end
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


              file = File.read("spec/dummy/app/views/users/_show.erb")
              expect(file).to include("<div class='hg-col col-sm-2 user--email'> <%= user.email %></div>")
              expect(file).to include("<div class='hg-col col-sm-2 user--family_id'> <%= user.family.try(:name) || '<span class=\"content \">MISSING</span>'.html_safe %></div>")
            end
          end

          describe "with 1 downnested portal" do
            it "builds 4 columns for fields, 6 for the downnested portal, and 2 for the buttons" do
              response = Rails::Generators.invoke("hot_glue:scaffold",
                                                  ["User",
                                                   "--gd",
                                                   "--smart-layout",
                                                   "--downnest=dfgs", "--layout=bootstrap"])

              file = File.read("spec/dummy/app/views/users/_list.erb")

              expect(file).to include("<div class='col-sm-2 hg-heading-row heading--user--email' >")
              expect(file).to include("<div class=\" scaffold-col-heading col-sm-4 \">")
              expect(file).to include("Dfgs")
            end
          end

          describe "with 2 downnested portals" do
            before do
              response = Rails::Generators.invoke("hot_glue:scaffold",
                                                  ["User","--gd",
                                                   "--smart-layout",
                                                   "--downnest=dfgs,xyzs",
                                                   "--layout=bootstrap"])

            end

            it "produces two columns for the fields" do
              res =   File.read("spec/dummy/app/views/users/_list.erb")
              expect(res).to include("<div class='col-sm-2 hg-heading-row heading--user--email-family_id' >Email<br />Family</div>")
            end

            it "has 4 columns for the Dfgs downnnest" do
              expect(
                File.read("spec/dummy/app/views/users/_list.erb") =~ /<div class=" scaffold-col-heading col-sm-4 ">/
              ).to be_a(Numeric)
            end

            it "produces two columns for the buttons" do
              expect(
                File.read("spec/dummy/app/views/users/_list.erb") =~ /<div class=' scaffold-col-heading scaffold-col-heading-buttons col-sm-2' >/
              ).to be_a(Numeric)
            end

            it "produces label" do
              expect(
                File.read("spec/dummy/app/views/users/_list.erb") =~ /Dfgs/
              ).to be_a(Numeric)

              expect(
                File.read("spec/dummy/app/views/users/_list.erb") =~ /Xyzs/
              ).to be_a(Numeric)
            end
          end
        end
      end
    end
  end

  describe "self auth" do
    it "when run with auth as the same name as the object but without --no-create" do
      expect{ Rails::Generators.invoke("hot_glue:scaffold",
                                          ["User","--auth=current_user"])
      }.to raise_exception("This controller appears to be the same as the authentication object but in this context you cannot build a new/create action; please re-run with --no-create flag")

    end

    it "when run with auth as the same name as the object but without --no-create SELF AUTH" do
      res = Rails::Generators.invoke("hot_glue:scaffold",
                                       ["User","--auth=current_user", "--no-create"])


      expect(
        File.read("spec/dummy/app/controllers/users_controller.rb") =~ /@user = \(current_user\)/
      ).to be_a(Numeric)
    end
  end

  describe "--no-paginate" do
    it "should not create a list with pagination" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Dfg","--no-paginate"])


      expect(
        File.read("spec/dummy/app/views/dfgs/_list.erb") =~ /paginate dfgs/
      ).to be(nil)
    end
  end

  describe "with pundit" do
    class DfgPolicy
      def initialize(user, dfg)

      end

      def cantelope_id_able?
        true
      end

      class Scope
        def initialize(user, scope)

        end
      end
    end

    describe "--show-only" do
      it "should make the show only fields visible only" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--show-only=name", "--pundit"])

        expect(
          File.read("spec/dummy/app/views/dfgs/_form.erb") =~ /f\.text_field :name/
        ).to be(nil)

        res = File.read("spec/dummy/app/views/dfgs/_form.erb")
        expect(res).to include("<%= dfg.name %>")
      end

      it "if not on the show only list and there is a *_able? method on the policy, it should delegate to pundit " do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--show-only=name", "--pundit"])

        col = "name"
        res = File.read("spec/dummy/app/views/dfgs/_form.erb")

        expect(res).to include("<% if policy(@dfg).cantelope_id_able? %>  <%= f.collection_select(:cantelope_id, Fruits::Cantelope.all, :id, :name, { prompt: true, selected: dfg.cantelope_id }, class: 'form-control') %>")
        expect(res).to include("<% else %><%= dfg.cantelope&.name %><% end %>")
        expect(res).to include("<label class='text-muted small form-text' for=''>Cantelope</label>")

      end

      it "should not include the show-only fields in the allowed parameters" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--show-only=name", "--pundit"])
        res = File.read("spec/dummy/app/controllers/dfgs_controller.rb")

        expect(res).to include("def update_dfg_params")
        expect(res).to include("def dfg_params\n    fields = :cantelope_id")
      end
    end


    describe "--update-show-only" do
      # note that on the fake Pundit policy there is a method `cantelope_id_able?` but no method `name_able?`
      it "should make the show only fields viewable on the edit action but inputable on the create action" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--update-show-only=cantelope_id",
                                             "--pundit"])
        res = File.read("spec/dummy/app/views/dfgs/_form.erb")
        expect(res).to include("<% if @action == 'new' && policy(@dfg).cantelope_id_able? %>  <%= f.collection_select(:cantelope_id, Fruits::Cantelope.all, :id, :name, { prompt: true, selected: dfg.cantelope_id }, class: 'form-control') %>")
        expect(res).to include("<% else %><%= dfg.cantelope&.name %><% end %>")
      end

      it "should not include the update show-only fields in the allowed parameters" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--include=name,cantelope_id", "--update-show-only=name", "--pundit"])

        res = File.read("spec/dummy/app/controllers/dfgs_controller.rb")
        expect(res).to include("def update_dfg_params")

        expect(res).to include("def update_dfg_params\n    fields = :cantelope_id")
      end


      it "should default to be editable" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--include=name,cantelope_id", "--update-show-only=name", "--pundit"])

        res = File.read("spec/dummy/app/controllers/dfgs_controller.rb")
        expect(res).to include("def update_dfg_params")
        expect(res).to include("def dfg_params\n    fields = :name, :cantelope_id\n    params.require(:dfg).permit(fields)")
        expect(res).to include("def update_dfg_params\n    fields = :cantelope_id")
        expect(res).to include("fields.delete :cantelope_id if !policy(@dfg).cantelope_id_able?\n    params.require(:dfg).permit(fields)")
      end
    end
  end

  describe "without pundit" do
    describe "--show-only" do
      it "should make the show only fields visible only" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--show-only=name", "--pundit"])

        expect(
          File.read("spec/dummy/app/views/dfgs/_form.erb") =~ /f\.text_field :name/
        ).to be(nil)

        res = File.read("spec/dummy/app/views/dfgs/_form.erb")
        expect(res).to include("<%= dfg.name %>")
      end

      it "should delegate to pundit if not" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg", "--include=cantelope_id", "--pundit"])

        col = "name"

        res = File.read("spec/dummy/app/views/dfgs/_form.erb")
        expect(res).to include("<% if policy(@dfg).cantelope_id_able? %>  <%= f.collection_select(:cantelope_id, Fruits::Cantelope.all, :id, :name, { prompt: true, selected: dfg.cantelope_id }, class: 'form-control') %>")
      end
    end

    describe "--show-only " do
      it "should make the show only fields visible only" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--show-only=name"])
        expect(
          File.read("spec/dummy/app/views/dfgs/_form.erb") =~ /f\.text_field :name/
        ).to be(nil)

        res = File.read("spec/dummy/app/views/dfgs/_form.erb")
        expect(res).to include("<%= dfg.name %>")
      end

      it "should not include the show-only fields in the allowed parameters" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Dfg","--show-only=name"])

        res = File.read("spec/dummy/app/controllers/dfgs_controller.rb")
        expect(res).to include(" def dfg_params\n    fields = :cantelope_id")
      end


      describe "--update-show-only" do
        it "should make the show only fields viewable on the edit action but inputable on the create action" do
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Dfg","--update-show-only=name"])

          res  = File.read("spec/dummy/app/views/dfgs/_form.erb")
          expect(res).to include("<% if @action == 'edit' %><%= dfg.name %><% else %>  <%= f.text_field :name, value: dfg.name, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>\n       \n      <% end %>")

          res = File.read("spec/dummy/app/views/dfgs/_form.erb")

          expect(res).to include("<%= f.text_field :name, value: dfg.name, autocomplete: 'off', ")
        end

        it "should not include the update show-only fields in the allowed parameters for the create action but not the update action" do
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Dfg","--update-show-only=name"])
          res = File.read("spec/dummy/app/controllers/dfgs_controller.rb")
          expect(res).to include("def update_dfg_params")

          expect(res).to_not include("def dfg_params\n    params.require(:dfg).permit(:name)")
          expect(res).to_not include("def update_dfg_params\n    fields = :name, :cantelope_id")
          expect(res).to include("def update_dfg_params\n    fields = :cantelope_id")
        end
      end
    end



    it "should automatically add fields that begin with underscore (_) as show only" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Fruits::Cantelope", "--gd"])
      # this table has a field named _a_show_only_field

      expect(
        File.read("spec/dummy/app/views/cantelopes/_form.erb") =~ /f\.text_field :_a_show_only_field/
      ).to be(nil)

      res = File.read("spec/dummy/app/views/cantelopes/_form.erb")
      expect(res).to include("<%= cantelope._a_show_only_field %>")

      res2 = File.read("spec/dummy/app/controllers/cantelopes_controller.rb")
      expect(res2).to include(":_a_show_only_field")
    end


    # why are tehse failing on CI
    # it "should accept a parameter modify to display as currency" do
    #   response = Rails::Generators.invoke("hot_glue:scaffold",
    #                                       ["Jkl", "--gd", "--show-only=selected", "--modify=selected{on|off}"])
    #
    #
    #   res = File.read("spec/dummy/app/views/jkls/_form.erb")
    #   expect(res).to include("<%= jkl.selected ? 'on' : 'off' %>")
    #
    # end

  end

  describe "--modify" do

    # why are tehse failing on CI

    # it "should accept a parameter --modify=cost{$} to display as currency" do
    #   response = Rails::Generators.invoke("hot_glue:scaffold",
    #                                       ["Jkl", "--gd", "--show-only=cost", "--modify=cost{$}"])
    #
    #
    #   res = File.read("spec/dummy/app/views/jkls/_form.erb")
    #   expect(res).to include("<%= number_to_currency(jkl.cost) %>")
    #
    # end

    it "should accept a parameter modify to display as currency" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Jkl", "--gd",  "--modify=selected{on|off}"])


      res = File.read("spec/dummy/app/views/jkls/_form.erb")


      expect(res).to include("<%= f.radio_button(:selected, '0', checked: jkl.selected  ? '' : 'checked', class: '')")
      expect(res).to include("<%= f.label(:selected, value: 'off', for: 'jkl_selected_0') %>")
      expect(res).to include("<%= f.radio_button(:selected, '0', checked: jkl.selected  ? '' : 'checked', class: '') %>")
      expect(res).to include("<%= f.radio_button(:selected, '1',  checked: jkl.selected  ? 'checked' : '' , class: '')")
      expect(res).to include("<%= f.label(:selected, value: 'on', for: 'jkl_selected_1') %>")
    end
  end

  describe "--display" do
    it "should let me specify a boolean as a radio" do

      # 2025-05-08  TODO: why is this failing
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Jkl", "--gd",  "--include=selected", "--display-as=selected{radio}", "--modify=selected{on|off}"])

      res = File.read("spec/dummy/app/views/jkls/_form.erb")
      expect(res).to include("<%= f.radio_button(:selected, '0', checked: jkl.selected  ? '' : 'checked', class: '')")
      expect(res).to include("<%= f.label(:selected, value: 'off', for: 'jkl_selected_0') %>")
      expect(res).to include("<%= f.radio_button(:selected, '0', checked: jkl.selected  ? '' : 'checked', class: '') %>")
      expect(res).to include("<%= f.radio_button(:selected, '1',  checked: jkl.selected  ? 'checked' : '' , class: '')")
      expect(res).to include("<%= f.label(:selected, value: 'on', for: 'jkl_selected_1') %>")

    end

    it "should let me specify a boolean as a checkbox" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Jkl", "--gd",  "--include=selected", "--display-as=selected{checkbox}"])

      res = File.read("spec/dummy/app/views/jkls/_form.erb")

      expect(res).to include("<%= f.check_box(:selected, class: '', id: 'jkl_selected', checked: jkl.selected) %>")
    end

    it "should let me specify a booleans as a switch" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Jkl", "--gd",  "--include=selected", "--display-as=selected{switch}" ])

      res = File.read("spec/dummy/app/views/jkls/_form.erb")
      expect(res).to include("<%= f.check_box(:selected, class: '', role: 'switch', id: 'jkl_selected', checked: jkl.selected) %>")

    end
  end



  describe "ujs syntax" do
    it "should make detele with 'confirm': true for ujs_syntax=true" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Abc","--god","--ujs_syntax=true"])
      result = File.read("spec/dummy/app/views/abcs/_show.erb")
      
      expect(
        result =~ /{data: {'confirm': "Are you sure/
      ).to_not be(nil)
    end

    it "should make delete with 'confirm': true for ujs_syntax=true" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Abc","--god","--ujs_syntax=true"])
      expect(
        File.read("spec/dummy/app/views/abcs/_show.erb") =~ /data: {'turbo-confirm': 'Are you sure/
      ).to be(nil)

      expect(
        File.read("spec/dummy/app/views/abcs/_show.erb") =~ / html: {data: {'confirm': "Are you sure /
      ).to_not be(nil)
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
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Abc","--god","--no-list-heading"])
      expect(
        File.read("spec/dummy/app/views/abcs/_list.erb") =~ /Abcs/
      ).to be(nil)
    end
  end

  describe "--form-labels-position" do
    # I'm testing this in the erb_spec.rb object
    # it "by default include them after" do
    #   response = Rails::Generators.invoke("hot_glue:scaffold",
    #                                       ["Abc","--god"])
    #
    #   expect(
    #     File.read("spec/dummy/app/views/abcs/_form.erb") =~ /<label class='small form-text text-muted'>Name\<\/label>/
    #   ).to_not be(nil)
    # end

    it "with 'omit' should make no labels" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Abc","--god",
                                           "--form-labels-position=omit"])

      expect(
        File.read("spec/dummy/app/views/abcs/_form.erb") =~ /<label class='small form-text text-muted'>Name\<\/label>/
      ).to be(nil)
    end


    it "with 'before' should make no labels" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc","--god",
                                             "--form-labels-position=before"])

      res = File.read("spec/dummy/app/views/abcs/_form.erb")

      label_pos = res.index /<label class='text-muted small form-text' for=''>Name\<\/label>/
      field_pos = res.index /<%= f.text_field :name, value: abc.name, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>/
      expect(label_pos < field_pos).to be(true)
    end
  end

  describe "--form-placeholder-labels" do
    it "should by default NOT make placeholder labels" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc","--god"])
      expect(
        File.read("spec/dummy/app/views/abcs/_form.erb") =~ /<%= f.text_field :name, value: abc.name, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>/
      ).to_not be(nil)
    end

    it "should make placeholder labels" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc","--god",
                                             "--form-placeholder-labels=true"])

      res =  File.read("spec/dummy/app/views/abcs/_form.erb")
      expect(res).to include("<%= f.text_field :name, value: abc.name, autocomplete: 'off', size: 40, class: 'form-control', type: '', placeholder: 'Name' %>")
    end
  end

  describe "--inline-list-labels" do
    it "should by default NOT make inline labels on the show page" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc","--god"])
      expect(
        File.read("spec/dummy/app/views/abcs/_show.erb") =~ /<label class='small form-text text-muted'>Name\<\/label>/
      ).to be(nil)
    end

    it "should make inline labels on the show page - after" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Abc","--god",
                                           "--inline-list-labels=after"])

      res = File.read("spec/dummy/app/views/abcs/_show.erb")
      expect(res).to include("<%= abc.name %><br/><label class='small form-text text-muted'>Name</label>")

    end

    it "should make inline labels on the show page" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Abc","--god",
                                           "--inline-list-labels=before"])
      res = File.read("spec/dummy/app/views/abcs/_show.erb")
      expect(res).to include("<label class='small form-text text-muted'>Name</label><br/><%= abc.name %>")
    end

    describe "#list_label" do
      it "should table has no @@table_label_plural on the class if present" do

        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["AtwDisplayName","--god"])

        res = File.read("spec/dummy/app/views/atw_display_names/_list.erb")
        expect(res).to include("<h4>
        ATW DISPLAY NAMES
      </h4>")

      end

      it "should tabelis if NO @@table_label_plural on the class if present" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc","--god",
                                             "--inline-list-labels=before"])

        res = File.read("spec/dummy/app/views/abcs/_list.erb")
        expect(res).to include("<h4>
        Apples
      </h4>")

      end
    end

    describe "#thing_label" do
      describe "when there is no @@table_label_singular on the class" do
        it "should tabelize the class" do
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["AtwDisplayName","--god"])

          res = File.read("spec/dummy/app/views/atw_display_names/_new_button.erb")
          expect(res).to include("<%= link_to \"New Atw Display Name\",")
        end
      end


      describe "when there IS a @@table_label_singular on the class" do
        it "should tabelize the class" do
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Abc","--god"])
          res = File.read("spec/dummy/app/views/abcs/_list.erb")
          expect(res).to include("<h4>
        Apples
      </h4>")
        end
      end
    end



    describe "#display_class" do

      let (:generator) {HotGlue::ScaffoldGenerator.new(["Xyz"], ["--include=name", "--gd"], {:shell=> Thor::Shell::Color.new})}
      it "should suggest that I meant the singular version" do
        expect(generator.display_class).to eq( "name")
      end


      describe "for to_label" do
        let (:generator) {HotGlue::ScaffoldGenerator.new(["AtwToLabel"], ["--gd"], {:shell=> Thor::Shell::Color.new})}
        it "should refer to a table with to_label if there is no name field" do
          expect(generator.display_class).to eq( "to_label")
        end

      end

      describe "for full_name" do
        let (:generator) {HotGlue::ScaffoldGenerator.new(["AtwFullName"], ["--gd"], {:shell=> Thor::Shell::Color.new})}
        it "should refer to a table with full_name if there is no name field" do
          expect(generator.display_class).to eq( "full_name")
        end
      end


      describe "for display_name" do
        let (:generator) {HotGlue::ScaffoldGenerator.new(["AtwDisplayName"], ["--gd", "--include="], {:shell=> Thor::Shell::Color.new})}
        it "should refer to a table with full_name if there is no name field" do
          expect(generator.display_class).to eq( "display_name")
        end
      end
    end
  end

  describe "--magic-buttons" do

    it "should make a magic button" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Dfg","--god",
                                           "--magic-buttons=activate"])
      res = File.read("spec/dummy/app/views/dfgs/_show.erb")
      expect(res).to include("<%= f.submit 'Activate'.html_safe, disabled: (dfg.respond_to?(:activate_able?) && ! dfg.activate_able? ), class: 'dfg-button  ' %>")
    end
  end


  describe "the hawk" do
    it "should hawk a foreign key with no specified assoc to the current_user" do

      response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Ghi",
                                             "--hawk=dfg_id"])

      res = File.read("spec/dummy/app/views/ghis/_form.erb")
      expect(res).to include("f.collection_select(:dfg_id, current_user.dfgs,")
    end


    it "should hawk a foreign key with two specified assocs to the current user" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Ghi",
                                             "--hawk=dfg_id,xyz_id"])
      res = File.read("spec/dummy/app/views/ghis/_form.erb")
      expect(res).to include("f.collection_select(:dfg_id, current_user.dfgs,")
      expect(res).to include("f.collection_select(:xyz_id, current_user.xyzs,")
    end


    it "should protect against a malicious input" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Ghi",
                                             "--hawk=dfg_id,xyz_id"])

      res = File.read("spec/dummy/app/controllers/ghis_controller.rb")
      expect(res).to include("hawk_params({dfg_id: [current_user.dfgs], xyz_id: [current_user.xyzs]}, modified_params)")

    end

    it "should allow me to hawk a nonusual root using curly brace syntax { .. }, like anything that the current_user belongs to" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Visit",
                                           "--hawk=user_id{current_user.family}",
                                           "--auth=current_user.family"])


      res = File.read("spec/dummy/app/controllers/visits_controller.rb")

      expect(res).to include("@visit = current_user.family.visits.find(params[:id])")

      expect(res).to include("modified_params = hawk_params({user_id: [current_user.family]}, modified_params)")

      expect(res).to include("def load_visit
    @visit = current_user.family.visits.find(params[:id])
  end")

      expect(res).to include("@visits = current_user.family.visits.includes(:user).page(params[:page])")
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
  end

  describe "for --form-labels-position is invalid" do
    it "should tell me no no " do
      expect { Rails::Generators.invoke("hot_glue:scaffold",
                                        ["Ghi", "--form-labels-position=nonsense"])

      }.to raise_exception("You passed 'nonsense' as the setting for --form-labels-position but the only allowed options are before, after (default), and omit")
    end
  end

  describe "for --inline-list-labels is invalid" do
    it "should tell me no no " do
      expect { Rails::Generators.invoke("hot_glue:scaffold",
                                        ["Ghi", "--inline-list-labels=nonsense"])

      }.to raise_exception("You passed 'nonsense' as the setting for --inline-list-labels but the only allowed options are before, after, and omit (default)")
    end
  end

  describe "for --include with specified grouping and also --smart-layout" do
    it "should tell me no no " do
      expect { Rails::Generators.invoke("hot_glue:scaffold",
                                        ["Xyz", "--include=abc:","--smart-layout"])

      }.to raise_exception("You specified both --smart-layout and also specified grouping mode (there is a : character in your field include list); you must remove the colon(s) from your --include tag or remove the --smart-layout option")
    end
  end

  describe "for --nest deprecated syntax" do
    it "should tell me no no " do
      expect { Rails::Generators.invoke("hot_glue:scaffold",
                                        ["Ghi", "--nest=xyz"])

      }.to raise_exception("STOP: the flag --nest has been replaced with --nested; please re-run using the --nested flag")
    end
  end

  describe "for when there are no fields" do
    it "should tell me no no " do
      generator = Rails::Generators.invoke("hot_glue:scaffold",
                                           ["Ghi", "--exclude=dfg_id,xyz_id"])

      res = File.read("spec/dummy/app/views/ghis/_form.erb")
      expect(res).to include('%= f.hidden_field "_________" %>')
    end
  end



  describe "a table that has a field that should be an association (_id) but is missing" do
    it "should tell me no no " do
      expect { Rails::Generators.invoke("hot_glue:scaffold",
                                        ["Borked", "--gd"])

      }.to raise_exception("*** Oops: The model Borked is missing an association for :xyz or the model Xyz doesn't exist. TODO: Please implement a model for Xyz; or add to Borked `belongs_to :xyz`.  To make a controller that can read all records, specify with --god.")
    end
  end


  describe "a table that has a field that should be an association (_id) but is missing" do
    it "should tell me no no " do
      expect {
         Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Borked", "--gd", "--include=missing_label_table_id"])
      }.to raise_exception("*** Oops: Can't find any column to use as the display label on Borked model . TODO: Please implement just one of: 1) name, 2) to_label, 3) full_name, 4) display_name, 5) email, or 6) number directly on your Borked model (either as database field or model methods), then RERUN THIS GENERATOR. (If more than one is implemented, the field to use will be chosen based on the rank here, e.g., if name is present it will be used; if not, I will look for a to_label, etc)")
    end
  end

  describe "When a base controller doesn't already exist" do
    it "should copy the base controller to the namespace" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Abc","--namespace=hello", "--gd"])

      res = File.read("spec/dummy/app/controllers/hello/base_controller.rb")

      expect(res).to include("class Hello::BaseController < ApplicationController")
    end
  end

  describe "--with-turbo-streams" do
    it "should not include turbo_stream_from if not specified" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                         ["Abc", "--gd"])
      res = File.read("spec/dummy/app/views/abcs/_line.erb")
      expect(res).to_not include("<%= turbo_stream_from abc  %>")
    end

    it "should not include turbo_stream_from if not specified" do
      dest_filepath = "spec/dummy/app/models/abc.rb"
      original_abc_model = File.read(dest_filepath)
      
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Abc", "--gd", "--with-turbo-streams"])
      res = File.read("spec/dummy/app/views/abcs/_line.erb")
      expect(res).to include("<%= turbo_stream_from abc  %>")

      res = File.read(dest_filepath)
      expect(res).to include('include ActionView::RecordIdentifier')
      expect(res).to include('after_update_commit lambda { broadcast_replace_to self, target: "__#{dom_id(self)}", partial: "/abcs/line" }')
      expect(res).to include('after_destroy_commit lambda { broadcast_remove_to self, target: "__#{dom_id(self)}')
      File.open(dest_filepath, "w") {|file| file.puts original_abc_model}
    end
  end

  describe "base controller" do
    let(:bc_path) {"spec/dummy/app/controllers/fruits/base_controller.rb"}
    before(:each) do
      File.delete(bc_path) if File.exist?(bc_path)
    end
    after(:each) do
      File.delete(bc_path) if File.exist?(bc_path)
    end

    it "should add a base controller if it doesn't already exist" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Abc","--gd", "--namespace=fruits"])

      res = File.read("spec/dummy/app/controllers/fruits/base_controller.rb")
      expect(res).to include("class Fruits::BaseController < ApplicationController")
    end

    # PASSES LOCALLY FAILS ON GITHUB ACTIONS
    # it "should skiping adding a base controller if it already exists" do
    #   File.open("spec/dummy/app/controllers/fruits/base_controller.rb", "w") {|file| file.puts "don't replace me"}
    #   res = File.read("spec/dummy/app/controllers/fruits/base_controller.rb")
    #   expect(res).to include("don't replace me")
    # end
  end


  describe "attachments parameter syntax" do
    describe "for short form syntax" do
      it "should not generate OK for a bad attachment name" do
        expect { response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc", "--gd", "--attachments=xyz"])
        }.to raise_exception(HotGlue::Error, /Could not find xyz attachment/)

      end

      it "should generate automatic thumbnail if there is a matching 'thumb' variant" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc","--gd", "--attachments=aaa"])

        _form = File.read("spec/dummy/app/views/abcs/_form.erb")
        _show = File.read("spec/dummy/app/views/abcs/_show.erb")
        expect(_form).to include("<%= f.file_field :aaa %>")
      end

      it "should generate with no thumbnail if no variant 'thumb' exists" do
        response = Rails::Generators.invoke("hot_glue:scaffold",
                                            ["Abc", "--gd", "--attachments=bbb"])
        _form = File.read("spec/dummy/app/views/abcs/_form.erb")
        _show = File.read("spec/dummy/app/views/abcs/_show.erb")
        expect(_form).to include("<%= f.file_field :bbb %>")
      end
    end


    describe "long form syntax with 1 parameter - thumbnail" do
      describe "When passed a thumbnail name for a variant that does not exist" do
        it "should raise an error" do
          expect { response = Rails::Generators.invoke("hot_glue:scaffold",
                                                       ["Abc", "--gd", "--attachments=aaa{badthumbnail}"])
          }.to raise_exception(HotGlue::Error, /you specified to use badthumbnail as the thumbnail/)
        end
      end
      describe "When a variant matches the given thumbnail" do
        it "generate with the given thumbnail" do

        end
      end
    end
    describe "long form syntax with 2 parameters" do
      describe "when 1st parameter is empty string" do

      end

      describe "when
1st parameter is not empty string" do

      end
    end
    describe "long form syntax with 3 parameters" do
      describe "when passed 'direct'" do
        it "should render" do
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Abc", "--gd", "--attachments=bbb{||direct}"])
          _form = File.read("spec/dummy/app/views/abcs/_form.erb")
          expect(_form).to include('<%= f.file_field :bbb , direct_upload: true %>')
        end
      end
      describe "when passed anything else" do
        it "should raise an error" do
          expect { response = Rails::Generators.invoke("hot_glue:scaffold",
                                                       ["Abc", "--gd", "--attachments=bbb{||xxx}"])
          }.to raise_exception(HotGlue::Error, /received 3rd parameter in attachment long form specification that was not/)
        end
      end
    end
    describe "long form syntax with 4 parameters" do
      describe "when passed 'dropzone'" do
        it "should render" do
          response = Rails::Generators.invoke("hot_glue:scaffold",
                                              ["Abc", "--gd", "--attachments=bbb{||direct|dropzone}"])
          _form = File.read("spec/dummy/app/views/abcs/_form.erb")
          # _show = File.read("spec/dummy/app/views/abcs/_show.erb")
          expect(_form).to include('class="dropzone dropzone-default dz-clickable"')
          expect(_form).to include('<%= f.file_field :bbb , direct_upload: true , "data-dropzone-target": "input"%>')
        end
      end
      describe "when passed anything else" do
        it "should raise an error" do
          expect { response = Rails::Generators.invoke("hot_glue:scaffold",
                                                       ["Abc", "--gd", "--attachments=bbb{||direct|xxx}"])
          }.to raise_exception(HotGlue::Error, /received 4th parameter in attachme long form specification that was not 'dropzone'/)
        end
      end
    end
  end

  describe "search syntax" do
    it "should include search fields" do
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Jkls", "--gd", "--search=set",
                                           "--search-fields=blurb,long_description,approved_at"])


      # NOT IMPLEMENTED: float field, integer field
      _list = File.read("spec/dummy/app/views/jkls/_list.erb")
      expect(_list).to include("%= f.select 'q[0][blurb_match]', options_for_select([['', ''], ['contains', 'contains'], ['is exactly', 'is_exactly'], ['starts with', 'starts_with'], ['ends with', 'ends_with']], @q['0']['blurb_match'] ), {} , { class: 'form-control match' } %><%= f.text_field 'q[0][blurb_search]', value: @q['0'][:blurb_search], autocomplete: 'off', size: 40, class: 'form-control', type: 'text' %>")
      expect(_list).to include("<%= f.select 'q[0][long_description_match]', options_for_select([['', ''], ['contains', 'contains'], ['is exactly', 'is_exactly'], ['starts with', 'starts_with'], ['ends with', 'ends_with']], @q['0']['long_description_match'] ), {} , { class: 'form-control match' } %><%= f.text_field 'q[0][long_description_search]', value: @q['0'][:long_description_search], autocomplete: 'off', size: 40, class: 'form-control', type: 'text' %>")
      expect(_list).to include("<div data-controller='date-range-picker' >")

      expect(_list).to include("<%= f.select 'q[0][approved_at_match]', options_for_select([['', ''], ['is on', 'is_on'],")
      expect(_list).to include("['is between', 'is_between'], ['is on or after', 'is_on_or_after'],")
      expect(_list).to include("['is before or on', 'is_before_or_on'], ['not on', 'not_on']], @q['0']['approved_at_match'] ), {} ,")
      expect(_list).to include("{ class: 'form-control match', 'data-action': 'change->date-range-picker#matchSelection' } %>")
      expect(_list).to include("<%= datetime_local_field 'q[0]', 'approved_at_search_start', {value: @q['0'][:approved_at_search_start], autocomplete: 'off', size: 40, class: 'form-control', placeholder: 'start', 'data-date-range-picker-target': 'start' } %>")
      expect(_list).to include("<%= datetime_local_field 'q[0]', 'approved_at_search_end', {value: @q['0'][:approved_at_search_end], autocomplete: 'off', size: 40, class: 'form-control', placeholder: 'end' , 'data-date-range-picker-target': 'end' } %>")
      expect(_list).to include("</div>")

    end
  end
end
