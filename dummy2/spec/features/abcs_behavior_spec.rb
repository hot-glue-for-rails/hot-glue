require 'rails_helper'

describe 'interaction for AbcsController' do
  include HotGlue::ControllerHelper
  include ActionView::RecordIdentifier

    #HOTGLUE-SAVESTART
  #HOTGLUE-END
  

  let!(:abc1) {create(:abc , name: FFaker::Movie.title )}
  
  describe "index" do
    it "should show me the list" do
      visit abcs_path
      expect(page).to have_content(abc1.name)
    end
  end

  describe "new & create" do
    it "should create a new Abc" do
      visit abcs_path
      click_link "New Apple"
      expect(page).to have_selector(:xpath, './/h3[contains(., "New Apple")]')
      new_name = FFaker::Movie.title 
      find("[name='abc[name]']").fill_in(with: new_name)
      click_button "Save"
      expect(page).to have_content("Successfully created")

      expect(page).to have_content(new_name)
    end
  end


  describe "edit & update" do
    it "should return an editable form" do
      visit abcs_path
      find("a.edit-abc-button[href='/abcs/#{abc1.id}/edit']").click

      expect(page).to have_content("Editing #{abc1.name.squish || "(no name)"}")
      new_name = FFaker::Movie.title 
      find("[name='abc[name]']").fill_in(with: new_name)
      click_button "Save"
      within("turbo-frame#__#{dom_id(abc1)} ") do
        expect(page).to have_content(new_name)
      end
    end
  end 

  describe "destroy" do
    it "should destroy" do
      visit abcs_path
      accept_alert do
        find("form[action='/abcs/#{abc1.id}'] > input.delete-abc-button").click
      end
      expect(page).to_not have_content(abc1.name)
      expect(Abc.where(id: abc1.id).count).to eq(0)
    end
  end
end

