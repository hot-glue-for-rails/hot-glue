require 'rails_helper'

describe HotGlue::ScaffoldGenerator do

  def setup


    # @path = File.expand_path("spec/dummy", Rails.root)
    # $LOAD_PATH.unshift(@path)
  end


  def remove_dir(path)

    FileUtils.rm_rf(path + "defs/")
    # Dir.foreach(path) do |file1|
    #   fn = File.join(path, file1)
    #
    #   if (file1.to_s == ".") || (file1.to_s == "..")
    #     # do nothing
    #   elsif File.directory?(fn)
    #     Dir.foreach(fn) do |file2|
    #       if ((file2.to_s != ".") and (file2.to_s != ".."))
    #         puts "calling remove_dir #{fn}/#{file2}"
    #         remove_dir("#{fn}/#{file2}") if File.directory?("#{fn}/#{file2}")
    #         # File.delete(fn) if !File.directory?("#{fn}/#{file2}")
    #       end
    #     end
    #     # Dir.delete(fn)
    #   else
    #   end
    #
    #   # File.delete(fn) if file.end_with?('.haml') || file.end_with?('.rb')
    # end
  end

  after(:all) do
    remove_dir('spec/dummy/app/views/')
    remove_dir('spec/dummy/app/controllers/')
    remove_dir('spec/dummy/app/specs/')
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

  end


  it "with an association to an object that doesn't exist" do
    begin
      response = Rails::Generators.invoke("hot_glue:scaffold", ["Xyz"])
    rescue StandardError => e
      expect(e.class).to eq(HotGlue::Error)
      expect(e.message).to eq("*** Oops: The table Xyz has an association for 'nothing', but I can't find an assoicated model for that association. TODO: Please implement a model for nothing that belongs to Xyz ")
    end
  end



  describe "GOOD RESPONSES" do
    # test good builds here
  end
end
