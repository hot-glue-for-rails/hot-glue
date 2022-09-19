require 'rails_helper'

describe "interaction for GhisController", type: :feature do
  include HotGlue::ControllerHelper
  #HOTGLUE-SAVESTART
  #HOTGLUE-END
  let(:current_user) {create(:user)}
  let!(:dfg1) {create(:dfg)}
  let!(:xyz1) {create(:xyz)}
  let!(:ghi1) {create(:ghi, user: current_user , dfg: dfg1, xyz: xyz1 )}
     
  before do
    login_as(current_user)
  end 

  describe "index" do
    it "should show me the list" do
      visit ghis_path


    end
  end

  describe "new & create" do
    it "should create a new Ghi" do
      visit ghis_path
      click_link "New GHI"
      expect(page).to have_selector(:xpath, './/h3[contains(., "New GHI")]')

      dfg_id_selector = find("[name='ghi[dfg_id]']").click 
      dfg_id_selector.first('option', text: dfg1.name).select_option
      xyz_id_selector = find("[name='ghi[xyz_id]']").click 
      xyz_id_selector.first('option', text: xyz1.name).select_option
      click_button "Save"
      expect(page).to have_content("Successfully created")
      
    end
  end


  describe "edit & update" do
    it "should return an editable form" do
      visit ghis_path
      byebug
      find("a.edit-ghi-button[href='/ghis/#{ghi1.id}/edit']").click

      expect(page).to have_content("Editing #{ghi1.name.squish || "(no name)"}")


      click_button "Save"
      within("turbo-frame#ghi__#{ghi1.id} ") do

      end
    end
  end 

  describe "destroy" do
    it "should destroy" do
      visit ghis_path
      accept_alert do
        find("form[action='/ghis/#{ghi1.id}'] > input.delete-ghi-button").click
      end
      expect(page).to_not have_content(ghi1.name)
      expect(Ghi.where(id: ghi1.id).count).to eq(0)
    end
  end
end

