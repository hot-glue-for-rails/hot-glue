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

  describe "#date_to_current_timezone" do
    describe "for date nil" do
      it "should return nil" do
        expect(fake_controller.date_to_current_timezone("2022-03-18 08:44AM", -4)).to eq("2022-03-18T08:44")
      end
    end


    describe "for timezone nil" do
      it "should use the server's timezone" do
        expect(fake_controller.date_to_current_timezone("2022-03-18 08:44AM", nil)).to eq("2022-03-18T08:44")
      end
    end


    describe "for a parseable timezone" do
      it "should reformat the time into the provided timezone" do
        expect(fake_controller.date_to_current_timezone("2022-03-18 08:44AM", -8)).to eq("2022-03-18T08:44")
      end
    end
  end


  describe "#modify_date_inputs_on_params" do
    let (:current_user) {OpenStruct.new}
    let(:params) {ActionController::Parameters.new "name"=>"", "approved_at"=>date, "genre"=>"mystery"}
    let(:date) {"2022-03-19T07:56"}
    let(:use_timezone) {Time.now.strftime("%z")}

    describe "with a current_user who has a timezone" do
      describe "when a param ends with _at" do
        let(:params) {ActionController::Parameters.new "name"=>"", "approved_at"=>"2022-03-19T07:56", "genre"=>"mystery"}

        it "should reformat the provided time" do
          expect(DateTime.strptime("#{date} #{use_timezone}", '%Y-%m-%dT%H:%M %z')).to eq(fake_controller.modify_date_inputs_on_params(params, current_user)[:approved_at])
        end
      end

      describe "when a param ends with _date" do
        it "should reformat the provided date" do

        end
      end
    end

    describe "when a current user who has a timezone" do
      let (:current_user) {OpenStruct.new(timezone: -9)}
      let(:use_timezone) {-9}
      it "should use the server's timezone" do
        expect(DateTime.strptime("#{date} #{use_timezone}", '%Y-%m-%dT%H:%M %z')).to eq(fake_controller.modify_date_inputs_on_params(params, current_user)[:approved_at])
      end
    end
    describe "with a current user who does not have a timezone" do
      it "should use the server's timezone" do
        expect(DateTime.strptime("#{date} #{use_timezone}", '%Y-%m-%dT%H:%M %z')).to eq(fake_controller.modify_date_inputs_on_params(params, current_user)[:approved_at])
      end
    end
  end

  describe "#hawk_params" do
    let(:human) {Human.create}
    let(:pet) {Pet.create(human: human)}
    let(:pet2) {Pet.create(human: Human.create)}

    let(:input_params) { ActionController::Parameters.new( {"when_at"=>"", "pet_id"=>pet.id})}
    let(:hawk_params) {{:pet_id=>[human, "pets"]}}

    describe "When the hawked params aren't passed at all" do
      it "should do nothing" do
        expect(input_params).to eq(fake_controller.hawk_params({}, input_params))
      end
    end

    describe "when the hawked params are passed and validly within the scope" do
      it "should return the same params it was passed" do
        expect(input_params).to eq(fake_controller.hawk_params(hawk_params, input_params))
      end
    end

    describe "when the hawked params are passed and the foreign key is out of scope" do
      let(:input_params) { ActionController::Parameters.new( {"when_at"=>"", "pet_id"=>pet2.id})}

      it "should set the hawk_alarm" do
        fake_controller.hawk_params(hawk_params, input_params)
        expect("You aren't allowed to set pet_id to 1. ").to eq(fake_controller.instance_variable_get(:@hawk_alarm))
      end

      it "should tap away the parameters" do
        expect(fake_controller.hawk_params({}, input_params)[:human_id]).to be(nil)
      end
    end
  end
end