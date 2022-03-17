require 'rails_helper'


describe HotGlue::ControllerHelper do
  before(:each) do
    # class FakeController < ApplicationController
    #   helper :hot_glue
    # end
  end

  subject {FakeController.new}

  describe "#timezonize" do
    # it "should take a timezone and turn it into a string" do
    #   res = subject.timezoneize(ActiveSupport::TimeZone['Central Time (US & Canada)'])
    #   expect(res).to eq("-06:00")
    # end
  end

  describe "#datetime_field_localized" do

  end

  describe "#date_field_localized" do

  end

  describe "#time_field_localized" do

  end

  describe "#current_timezone" do

  end

  describe "#server_timezone" do

  end

  describe "#date_to_current_timezone" do

  end

  describe "#modify_date_inputs_on_params" do

  end
end