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
    @template_builder = HotGlue::ErbTemplate.new(layout_strategy: LayoutStrategy::HotGlue.new(OpenStruct.new({})))
  end

  def factory_all_form_fields(options)
    @template_builder.all_form_fields({
                                        form_labels_position: 'after',
                                        columns: [[:name, :blurb]],
                                        show_only: [],
                                        singular_class: Jkl,
                                        singular: "jkl",
                                        col_identifier:  "col-md-2",
                                        hawk_keys: {},
                                        ownership_field: "hgi"
                                      }.merge(options)
    )
  end

  def factory_all_line_fields(options)
    @template_builder.all_line_fields({
                                        form_labels_position: 'after',
                                        columns: [[:name, :blurb]],
                                        show_only: [],
                                        singular_class: Jkl,
                                        singular: "jkl",
                                        perc_width: 15,
                                        col_identifier:  "col-md-2",
                                        ownership_field: "hgi"
                                      }.merge(options)
    )
  end

  describe "basic columns" do
    it "should create two columns" do
      res = factory_all_form_fields({})
      expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:name) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :name, value: jkl.name, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>\n       \n      \n      <label class='small form-text text-muted'>Name</label>\n    </span>\n    <br />  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:blurb) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :blurb, value: jkl.blurb, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>\n       \n      \n      <label class='small form-text text-muted'>Blurb</label>\n    </span>\n    <br />\n  </div>")
    end

    it "should make a text column " do
      res = factory_all_form_fields({columns: [[:long_description]]})

      expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:long_description) %>'  style=\"display: inherit;\"  >\n      <%= f.text_area :long_description, class: 'form-control', autocomplete: 'off', cols: 40, rows: '5' %>\n      <label class='small form-text text-muted'>Long description</label>\n    </span>\n    <br />\n  </div>")
    end

    it "should make a float column " do
      res = factory_all_form_fields({columns: [[:cost]]})
      expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:cost) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :cost, value: jkl.cost, autocomplete: 'off', size: 5, class: 'form-control', type: '' %>\n       \n      \n      <label class='small form-text text-muted'>Cost</label>\n    </span>\n    <br />\n  </div>")
    end

    it "should make a integer column " do
      res = factory_all_form_fields({columns: [[:how_many_printed]]})

      expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:how_many_printed) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :how_many_printed, value: jkl.how_many_printed, autocomplete: 'off', size: 4, class: 'form-control', type: 'number' %>\n       \n      \n      <label class='small form-text text-muted'>How many printed</label>\n    </span>\n    <br />\n  </div>")
    end


    it "should make a datetime column " do
      res = factory_all_form_fields({columns: [[:approved_at]]})
      expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:approved_at) %>'  style=\"display: inherit;\"  >\n      <%= datetime_field_localized(f, :approved_at, jkl.approved_at, 'Approved at', nil) %>\n      <label class='small form-text text-muted'>Approved at</label>\n    </span>\n    <br />\n  </div>")
    end

    it "should make a date column " do
      res = factory_all_form_fields({columns: [[:release_on]]})
      expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:release_on) %>'  style=\"display: inherit;\"  >\n      <%= date_field_localized(f, :release_on, jkl.release_on, 'Release on', nil) %>\n      <label class='small form-text text-muted'>Release on</label>\n    </span>\n    <br />\n  </div>")
    end

    it "should make a time column " do
      res = factory_all_form_fields({columns: [[:time_of_day]]})
      expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:time_of_day) %>'  style=\"display: inherit;\"  >\n      <%= time_field_localized(f, :time_of_day, jkl.time_of_day,  'Time of day', nil) %>\n      <label class='small form-text text-muted'>Time of day</label>\n    </span>\n    <br />\n  </div>")
    end

    it "should make a boolean column " do
      res = factory_all_form_fields({columns: [[:selected]]})
      expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:selected) %>'  style=\"display: inherit;\"  >\n       <br />  <%= f.radio_button(:selected,  '0', checked: jkl.selected  ? '' : 'checked') %>\n        <%= f.label(:selected, value: 'No', for: 'jkl_selected_0') %>\n        <%= f.radio_button(:selected, '1',  checked: jkl.selected  ? 'checked' : '') %>\n        <%= f.label(:selected, value: 'Yes', for: 'jkl_selected_1') %>\n      \n      <label class='small form-text text-muted'>Selected</label>\n    </span>\n    <br />\n  </div>")
    end

    # TODO: fix me
    # it "should make a enum column " do
    #   res = factory_all_form_fields({columns: [[:genre]]})
    #   byebug
    #   expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:genre) %>'  style=\"display: inherit;\"  >\n      <%= f.text_field :genre, value: jkl.genre, class: 'form-control', size: 4, type: 'number' %>\n      <label class='small form-text text-muted'>Genre</label>\n    </span>\n    <br />\n  </div>")
    # end
  end

  describe "form_labels_position" do
    it "with 'before' should make the labels appear before the field" do
      res = factory_all_form_fields({columns: [[:name, :blurb]],
                                     form_labels_position: 'before'})
      expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:name) %>'  style=\"display: inherit;\"  >\n      \n      <label class='small form-text text-muted'>Name</label>  <%= f.text_field :name, value: jkl.name, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>\n       \n  \n    </span>\n    <br />  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:blurb) %>'  style=\"display: inherit;\"  >\n      \n      <label class='small form-text text-muted'>Blurb</label>  <%= f.text_field :blurb, value: jkl.blurb, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>\n       \n  \n    </span>\n    <br />\n  </div>")
    end

    it "with 'after' should make the labels appear after the field" do
      res = factory_all_form_fields({columns: [[:name, :blurb]],
                                         form_labels_position: 'after'}
      )

      expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:name) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :name, value: jkl.name, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>\n       \n      \n      <label class='small form-text text-muted'>Name</label>\n    </span>\n    <br />  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:blurb) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :blurb, value: jkl.blurb, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>\n       \n      \n      <label class='small form-text text-muted'>Blurb</label>\n    </span>\n    <br />\n  </div>")
    end

    it "with 'omit' should make no labels" do
      res = factory_all_form_fields({columns: [[:name, :blurb]],
                                     form_labels_position: 'omit'}
      )

      expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:name) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :name, value: jkl.name, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>\n       \n  \n    </span>\n    <br />  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:blurb) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :blurb, value: jkl.blurb, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>\n       \n  \n    </span>\n    <br />\n  </div>")
    end
  end

  describe "form_placeholder_labels" do
    describe "default (no placeholders)" do
      it "with 'omit' should make no labels" do
        res = factory_all_form_fields({columns: [[:name, :blurb]],
                                       form_labels_position: 'omit',
                                       form_placeholder_labels: false})

        expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:name) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :name, value: jkl.name, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>\n       \n  \n    </span>\n    <br />  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:blurb) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :blurb, value: jkl.blurb, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>\n       \n  \n    </span>\n    <br />\n  </div>")
      end
    end

    it "with placeholder labels " do
      res = factory_all_form_fields({columns: [[:name, :blurb]],
                                     form_labels_position: 'omit',
                                     form_placeholder_labels: true})
      expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:name) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :name, value: jkl.name, autocomplete: 'off', size: 40, class: 'form-control', type: '', placeholder: 'Name' %>\n       \n  \n    </span>\n    <br />  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:blurb) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :blurb, value: jkl.blurb, autocomplete: 'off', size: 40, class: 'form-control', type: '', placeholder: 'Blurb' %>\n       \n  \n    </span>\n    <br />\n  </div>")
    end

    it "with placeholder labels for a text area " do
      res = factory_all_form_fields({columns: [[:long_description]],
                                     form_labels_position: 'omit',
                                     form_placeholder_labels: true})
      expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:long_description) %>'  style=\"display: inherit;\"  >\n      <%= f.text_area :long_description, class: 'form-control', autocomplete: 'off', cols: 40, rows: '5', placeholder: 'Long description' %>\n    </span>\n    <br />\n  </div>")
    end

    it "with placeholder labels for a float " do
      res = factory_all_form_fields({columns: [[:cost]],
                                     form_labels_position: 'omit',
                                     form_placeholder_labels: true})


      expect(res).to eq("  <div class='col-md-2' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:cost) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :cost, value: jkl.cost, autocomplete: 'off', size: 5, class: 'form-control', type: '', placeholder: 'Cost' %>\n       \n  \n    </span>\n    <br />\n  </div>")


    end
  end

  describe "inline_list_labels" do
    # note that the labels also appear in the list headings
    # so I am testing below with  no_list_heading: true,

    it "should not show labels when disabled" do
      res = factory_all_line_fields({columns: [[:name], [:blurb], [:cost]],
                                     no_list_heading: true,
                                     inline_list_labels: false})

      expect(res).to_not include("<label class='small form-text text-muted'>Cost</label>")
      expect(res).to_not include("<label class='small form-text text-muted'>Blurb</label>")
      expect(res).to_not include("<label class='small form-text text-muted'>Name</label>")

    end

    it "should show labels when --inline-list-labels" do
      res = factory_all_line_fields({columns: [[:name], [:blurb], [:cost]],
                                     no_list_heading: true,
                                     inline_list_labels: 'before'})

      expect(res).to include("<label class='small form-text text-muted'>Cost</label>")
      expect(res).to include("<label class='small form-text text-muted'>Blurb</label>")
      expect(res).to include("<label class='small form-text text-muted'>Name</label>")

    end

    it "should show labels when --inline-list-labels" do
      res = factory_all_line_fields({columns: [[:name], [:blurb], [:cost]],
                                     no_list_heading: true,
                                     inline_list_labels: 'after'})

      expect(res).to include("<label class='small form-text text-muted'>Cost</label>")
      expect(res).to include("<label class='small form-text text-muted'>Blurb</label>")
      expect(res).to include("<label class='small form-text text-muted'>Name</label>")
    end

    it "should show labels when --inline-list-labels" do
      res = factory_all_line_fields({columns: [[:name], [:blurb], [:cost]],
                                     no_list_heading: true,
                                     inline_list_labels: 'omit'})

      expect(res).to_not include("<label class='small form-text text-muted'>Cost</label>")
      expect(res).to_not include("<label class='small form-text text-muted'>Blurb</label>")
      expect(res).to_not include("<label class='small form-text text-muted'>Name</label>")
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




  describe "hawked foreign keys" do
    #  this test is proxy-texting to HotGlue::ErbTemplate#integer_result
    #
    #


    it "should hawk the dfg_id to the current user" do
      res = factory_all_form_fields({columns: [[:dfg_id]],
                                     alt_lookups: {},
                                     singular_class: Ghi,
                                     singular: "ghi",
                                     hawk_keys: {dfg_id: ["current_user", "dfgs"] }})
      expect(res).to include("f.collection_select(:dfg_id, current_user.dfgs,")
    end
  end
end
