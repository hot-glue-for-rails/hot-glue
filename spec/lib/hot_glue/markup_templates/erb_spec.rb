require 'rails_helper'


describe HotGlue::ErbTemplate do
  # Jkls
  # t.string :name
  # t.string :blurb
  # t.text :long_description
  # t.float :cost
  # t.integer :how_many_printed
  # t.datetime :approved_at
  # t.date :release_on
  # t.time :time_of_day
  # t.boolean :selected
  # t.integer :genre
  # t.timestamps


  before(:each) do
    @template_builder = HotGlue::ErbTemplate.new
  end

  describe "#all_form_fields" do

    describe "basic columns" do
      it "should create two columns" do
        res = @template_builder.all_form_fields(
          columns: [[:name, :blurb]],
          show_only: [],
          singular_class: Jkl,
          singular: "Jkl",
          col_identifier:  "col-md-2",
          ownership_field: "hgi"
        )
        expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if Jkl.errors.details.keys.include?(:name) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :name, value: @Jkl.name, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>\n       \n      \n      <label class='small form-text text-muted'>Name</label>\n    </span>\n    <br />  \n    <span class='<%= \"alert-danger\" if Jkl.errors.details.keys.include?(:blurb) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :blurb, value: @Jkl.blurb, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>\n       \n      \n      <label class='small form-text text-muted'>Blurb</label>\n    </span>\n    <br />\n  </div>")
      end

      it "should make a text column " do
        res = @template_builder.all_form_fields(
          columns: [[:long_description]],
          show_only: [],
          singular_class: Jkl,
          singular: "Jkl",
          col_identifier:  "col-md-2",
          ownership_field: "hgi"
        )
        expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if Jkl.errors.details.keys.include?(:long_description) %>'  style=\"display: inherit;\"  >\n      <%= f.text_area :long_description, class: 'form-control', autocomplete: 'off', cols: 40, rows: '5' %>\n      <label class='small form-text text-muted'>Long description</label>\n    </span>\n    <br />\n  </div>")
      end

      it "should make a float column " do
        res = @template_builder.all_form_fields(
          columns: [[:cost]],
          show_only: [],
          singular_class: Jkl,
          singular: "Jkl",
          col_identifier:  "col-md-2",
          ownership_field: "hgi"
        )
        expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if Jkl.errors.details.keys.include?(:cost) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :cost, value: @Jkl.cost, autocomplete: 'off', size: 5, class: 'form-control', type: '' %>\n       \n      \n      <label class='small form-text text-muted'>Cost</label>\n    </span>\n    <br />\n  </div>")
      end

      it "should make a integer column " do
        res = @template_builder.all_form_fields(
          columns: [[:cost]],
          show_only: [],
          singular_class: Jkl,
          singular: "Jkl",
          col_identifier:  "col-md-2",
          ownership_field: "hgi"
        )
        expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if Jkl.errors.details.keys.include?(:cost) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :cost, value: @Jkl.cost, autocomplete: 'off', size: 5, class: 'form-control', type: '' %>\n       \n      \n      <label class='small form-text text-muted'>Cost</label>\n    </span>\n    <br />\n  </div>")
      end


      it "should make a datetime column " do
        res = @template_builder.all_form_fields(
          columns: [[:approved_at]],
          show_only: [],
          singular_class: Jkl,
          singular: "Jkl",
          col_identifier:  "col-md-2",
          ownership_field: "hgi"
        )
        expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if Jkl.errors.details.keys.include?(:approved_at) %>'  style=\"display: inherit;\"  >\n      <%= datetime_field_localized(f, :approved_at, Jkl.approved_at, 'Approved at', nil) %>\n      <label class='small form-text text-muted'>Approved at</label>\n    </span>\n    <br />\n  </div>")
      end


      it "should make a date column " do
        res = @template_builder.all_form_fields(
          columns: [[:release_on]],
          show_only: [],
          singular_class: Jkl,
          singular: "Jkl",
          col_identifier:  "col-md-2",
          ownership_field: "hgi"
        )
        expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if Jkl.errors.details.keys.include?(:release_on) %>'  style=\"display: inherit;\"  >\n      <%= date_field_localized(f, :release_on, Jkl.release_on, 'Release on', nil) %>\n      <label class='small form-text text-muted'>Release on</label>\n    </span>\n    <br />\n  </div>")
      end


      it "should make a time column " do
        res = @template_builder.all_form_fields(
          columns: [[:time_of_day]],
          show_only: [],
          singular_class: Jkl,
          singular: "Jkl",
          col_identifier:  "col-md-2",
          ownership_field: "hgi"
        )
        expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if Jkl.errors.details.keys.include?(:time_of_day) %>'  style=\"display: inherit;\"  >\n      <%= time_field_localized(f, :time_of_day, Jkl.time_of_day,  'Time of day', nil) %>\n      <label class='small form-text text-muted'>Time of day</label>\n    </span>\n    <br />\n  </div>")
      end


      it "should make a boolean column " do
        res = @template_builder.all_form_fields(
          columns: [[:selected]],
          show_only: [],
          singular_class: Jkl,
          singular: "Jkl",
          col_identifier:  "col-md-2",
          ownership_field: "hgi"
        )
        expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if Jkl.errors.details.keys.include?(:selected) %>'  style=\"display: inherit;\"  >\n         <span>Selected</span>  <%= f.radio_button(:selected,  '0', checked: Jkl.selected  ? '' : 'checked') %>\n        <%= f.label(:selected, value: 'No', for: 'Jkl_selected_0') %>\n        <%= f.radio_button(:selected, '1',  checked: Jkl.selected  ? 'checked' : '') %>\n        <%= f.label(:selected, value: 'Yes', for: 'Jkl_selected_1') %>\n      \n      <label class='small form-text text-muted'>Selected</label>\n    </span>\n    <br />\n  </div>")
      end



      it "should make a enum column " do
        res = @template_builder.all_form_fields(
          columns: [[:genre]],
          show_only: [],
          singular_class: Jkl,
          singular: "Jkl",
          col_identifier:  "col-md-2",
          ownership_field: "hgi"
        )
        expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if Jkl.errors.details.keys.include?(:genre) %>'  style=\"display: inherit;\"  >\n      <%= f.text_field :genre, value: Jkl.genre, class: 'form-control', size: 4, type: 'number' %>\n      <label class='small form-text text-muted'>Genre</label>\n    </span>\n    <br />\n  </div>")
      end
    end


    describe "with show only fields" do

    end


    describe "with singular_class" do

    end

    describe "with a col_identifier" do

    end

    describe "with an ownership_field" do

    end
  end
end