require 'rails_helper'

require './app/helpers/hot_glue/controller_helper.rb'
require 'rails'

describe HotGlue::ControllerHelper do
  class FakeController
    include HotGlue::ControllerHelper
  end

  class FakeControllerWithCurrentUser
    include HotGlue::ControllerHelper
    def current_user
      OpenStruct.new()
    end
  end


  class FakeControllerWithCurrentUserAndTimezone
    include HotGlue::ControllerHelper
    def current_user
      OpenStruct.new(timezone: "-4")
    end
  end

  let(:fake_controller) {FakeController.new}

  let(:lookup_context) {OpenStruct.new}
  let(:assigns) {OpenStruct.new}
  let(:object_name) {"Xyz"}
  let(:object) { Xyz.new }
  let(:template) {ActionView::Base.new(lookup_context, assigns, fake_controller)}
  let(:options) { {} }

  let(:form_builder) {ActionView::Helpers::FormBuilder.new(object_name, object, template, options)}


  describe "#timezonize" do
    it "should return +00:00 for nil " do
      expect(fake_controller.timezonize(nil)).to eq("+00:00")
    end
    it "should return -04:00 for -4 " do
      expect(fake_controller.timezonize(-4)).to eq("-04:00")
    end
  end

  describe "#datetime_field_localized" do
    it "should render a datetime field output" do
      expect(fake_controller.datetime_field_localized(
        form_builder, :when_at, nil, "When at"
      )).to eq("<input class=\"form-control\" type=\"datetime-local\" name=\"Xyz[when_at]\" id=\"Xyz_when_at\" />+00:00")

    end
  end

  describe "#date_field_localized" do
    it "should render a datetime field output" do
      expect(fake_controller.date_field_localized(
        form_builder, :when_at, nil, "When at"
      )).to eq("<input class=\"form-control\" type=\"date\" name=\"Xyz[when_at]\" id=\"Xyz_when_at\" />")

    end
  end

  describe "#time_field_localized" do
    it "should render a time field output" do
      expect(fake_controller.time_field_localized(
        form_builder, :when_at, nil, "When at"
      )).to eq("<input class=\"form-control\" type=\"time\" name=\"Xyz[when_at]\" id=\"Xyz_when_at\" />+00:00")

    end
  end


  describe "#current_timezone" do
    describe "When current_user is defined" do
      let(:fake_controller) {FakeControllerWithCurrentUser.new}

      describe "When the current user has a timezone" do
        let(:fake_controller) {FakeControllerWithCurrentUserAndTimezone.new}

        it "should return the current user's time zone" do
          expect(fake_controller.current_timezone).to eq(-3)
        end
      end

      describe "When the current user does not have a timezone" do
        it "should return the server timezone" do
          expect(fake_controller.current_timezone).to eq( Time.now.strftime("%z").to_i/100)
        end
      end
    end

    describe "when current_user is not defined" do
      it "should return the server timezone" do
        expect(fake_controller.current_timezone).to eq( Time.now.strftime("%z").to_i/100)

      end
    end
  end

end