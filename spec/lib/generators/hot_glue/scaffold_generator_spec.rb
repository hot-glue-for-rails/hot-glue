require 'rails_helper'

describe HotGlue::ScaffoldGenerator do


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

  it "with both --specs-only and --no-specs" do
    begin
      response = Rails::Generators.invoke("hot_glue:scaffold",
                                          ["Def","--specs-only","--no-specs"])
    rescue StandardError => e
      expect(e.class).to eq(HotGlue::Error)
      expect(e.message).to eq("*** Oops: You seem to have specified both the --specs-only flag and --no-specs flags. this doesn't make any sense, so I am aborting. sorry.")
    end
  end

  describe "GOOD RESPONSES" do
    # test good builds here
  end
end
