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

  let(:layout_strategy) {
    LayoutStrategy::HotGlue.new(OpenStruct.new({}))
  }

  def base_generator options
    OpenStruct.new({downnest_object: {} ,
                    columns: nil,
                    smart_layout: false,
                    attachments: {},
                    bootstrap_column_width: 2,
                    singular_class: "Jkl",
                    form_placeholder_labels: nil,
                    singular: "jkl" }.merge(  hawk_keys: options[:hawk_keys],
                                          columns: options[:columns],
                                          form_placeholder_labels: options[:form_placeholder_labels],
                                          singular: options[:singular] || "jkl"))
  end


  def factory_all_form_fields(options)
    generator = base_generator(options)

    builder = HotGlue::Layout::Builder.new(include_setting: '',
                                           generator: generator,
                                           buttons_width: 0,)
    layout_object = builder.construct

    @template_builder = HotGlue::ErbTemplate.new(
      show_only: [],
      singular_class: options[:singular_class] || "Jkl",
      singular: options[:singular] || "jkl",
      hawk_keys: options[:hawk_keys] || {},
      ownership_field: "hgi",
      layout_strategy: layout_strategy,
      magic_buttons: [],
      small_buttons: false,
      inline_list_labels: 'omit',
      form_placeholder_labels: options[:form_placeholder_labels],
      form_labels_position: options[:form_labels_position],
      update_show_only: [],
      alt_lookups: {},
      columns_map: columns_map_sample(generator: generator, options: options),
      attachments: {})

    @template_builder.all_form_fields( layout_strategy: layout_strategy,
                                       layout_object: layout_object)

  end


  def columns_map_sample(generator: , options: {})
    {
      long_description: FieldFactory.new(type: :text, name: "long_description", generator: generator).field,

      cost: FieldFactory.new(type: :float, name: "cost", generator: generator).field,
      blurb: FieldFactory.new(type: :string, name: "blurb", generator: generator).field,

      selected: FieldFactory.new(type: :boolean, name: "selected", generator: generator).field,
      name: FieldFactory.new(type: :string, name: "name", generator: generator).field,
      hgi_id: AssociationField.new(layout_strategy: layout_strategy,
                                   form_labels_position: 'before',
                                   ownership_field: "", name: "hgi_id", class_name: "Jkl", alt_lookups: {},
                                   singular: generator.singular, update_show_only: nil, hawk_keys: options[:hawk_keys],
                                   auth: "", sample_file_path: nil, attachment_data: nil),
      time_of_day: FieldFactory.new(type: :time, name: "time_of_day", generator: generator).field,
      release_on: FieldFactory.new(type: :date, name: "release_on", generator: generator).field,
      approved_at: FieldFactory.new(type: :datetime, name: "approved_at", generator: generator).field,
      how_many_printed: FieldFactory.new(type: :integer, name: "how_many_printed", generator: generator).field,
      genre: FieldFactory.new(type: :enum, name: "genre", generator: generator).field,
    }
  end


  def factory_all_line_fields(options)

    generator = base_generator(options)

    builder = HotGlue::Layout::Builder.new(include_setting: '',
                                           generator: generator,
                                           buttons_width: 0)


    layout_object = builder.construct


    @template_builder = HotGlue::ErbTemplate.new(
      show_only: [],
      columns_map: columns_map_sample(generator: generator, options: options),
      singular_class: "Jkl",
      singular: "jkl",
      hawk_keys: {},
      ownership_field: "hgi",
      layout_strategy: layout_strategy,
      magic_buttons: [],
      small_buttons: false,
      inline_list_labels: options[:inline_list_labels],
      form_placeholder_labels: options[:form_placeholder_labels],
      form_labels_position: options[:form_labels_position],
      update_show_only: [],
      alt_lookups: [],
      attachments: {})

    @template_builder.all_line_fields( perc_width: 15,
                                       layout_strategy: layout_strategy,
                                       layout_object: layout_object)

  end

  describe "basic columns" do
    it "should create two columns" do
      res = factory_all_form_fields({columns: [:name, :blurb]})

      expect(res).to eq("  <div class='scaffold-cell cell--jkl--name' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:name) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :name, value: jkl.name, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>\n       \n  \n    </span>\n    <br />\n  </div>\n  <div class='scaffold-cell cell--jkl--blurb' >  \n    <span class='<%= \"alert-danger\" if jkl.errors.details.keys.include?(:blurb) %>'  style=\"display: inherit;\"  >\n        <%= f.text_field :blurb, value: jkl.blurb, autocomplete: 'off', size: 40, class: 'form-control', type: '' %>\n       \n  \n    </span>\n    <br />\n  </div>")

      list_res = factory_all_line_fields({columns: [:name, :blurb]})
      expect(list_res).to include(" <%= jkl.name %></div>\n<div class=' jkl--blurb' style='flex-basis: 15%'> <%= jkl.blurb %>")
    end

    it "should make a text column " do
      res = factory_all_form_fields({columns: [:long_description]})
      expect(res).to include("<%= f.text_area :long_description, class: 'form-control', autocomplete: 'off', cols: 40, rows: '5' %>")

      list_res = factory_all_line_fields({columns: [:long_description]})

      expect(list_res).to include("<%= jkl.long_description %>")
      expect(list_res).to include("class=' jkl--long_description'")
    end

    it "should make a float column " do
      res = factory_all_form_fields({columns: [:cost]})
      expect(res).to include("<%= f.text_field :cost, value: jkl.cost, autocomplete: 'off', size: 5,")


      list_res = factory_all_line_fields({columns: [:cost]})
      expect(list_res).to include("<%= jkl.cost %>")
    end

    it "should make a integer column " do
      res = factory_all_form_fields({columns: [:how_many_printed]})

      expect(res).to include("<%= f.text_field :how_many_printed, value: jkl.how_many_printed, autocomplete: 'off', size: 4, class: 'form-control', type: 'number' %>")

      list_res = factory_all_line_fields({columns: [:how_many_printed]})
      expect(list_res).to include("<%= jkl.how_many_printed %>")

    end


    it "should make a datetime column" do
      res = factory_all_form_fields({columns: [:approved_at]})
      expect(res).to include("<%= datetime_field_localized(f, :approved_at, jkl.approved_at, 'Approved at', nil) %>")

      list_res = factory_all_line_fields({columns: [:approved_at]})
      expect(list_res).to include("<%= jkl.approved_at.in_time_zone(current_timezone).strftime('%m/%d/%Y @ %l:%M %p ') + timezonize(current_timezone) %>")
    end

    it "should make a date column " do
      res = factory_all_form_fields({columns: [:release_on]})
      expect(res).to include("<%= date_field_localized(f, :release_on, jkl.release_on, 'Release on', nil) %>")

      list_res = factory_all_line_fields({columns: [:release_on]})
      expect(list_res).to include("<%= jkl.release_on %>")

    end

    it "should make a time column " do
      res = factory_all_form_fields({columns: [:time_of_day]})
      expect(res).to include("<%= time_field_localized(f, :time_of_day, jkl.time_of_day,  'Time of day', nil) %>")

      list_res = factory_all_line_fields({columns: [:release_on]})
      expect(list_res).to include("<%= jkl.release_on %>")
    end

    it "should make a boolean column " do
      res = factory_all_form_fields({columns: [:selected]})
      expect(res).to include("<%= f.radio_button(:selected,  '0', checked: jkl.selected  ? '' : 'checked') %>")
      expect(res).to include("<%= f.radio_button(:selected, '1',  checked: jkl.selected  ? 'checked' : '') %>")


      list_res = factory_all_line_fields({columns: [:selected]})
      expect(list_res).to include("<% elsif jkl.selected %>\n      YES\n    <% else %>\n      NO\n    <% end %>")
    end

    it "should make a enum column " do
      res = factory_all_form_fields({columns: [:genre]})
      expect(res).to include(" <%= f.collection_select(:genre, enum_to_collection_select(Jkl.defined_enums['genres']), :key, :value, {selected: jkl.genre },")

      list_res = factory_all_line_fields({columns: [:genre]})
      expect(list_res).to include("<%=  Jkl.defined_enums['genres'][jkl.genre.to_sym] %>")
    end
  end

  describe "form_labels_position" do
    it "with 'before' should make the labels appear before the field" do
      res = factory_all_form_fields({columns: [:name, :blurb],
                                     form_labels_position: 'before'})

      label_pos = res.index /<label class='small form-text text-muted'>Name/
      field_pos = res.index /<%= f.text_field :name,/
      expect(label_pos < field_pos).to be(true)
    end

    it "with 'after' should make the labels appear after the field" do
      res = factory_all_form_fields({columns: [:name, :blurb],
                                         form_labels_position: 'after'}
      )
      label_pos = res.index /<label class='small form-text text-muted'>Name/
      field_pos = res.index /<%= f.text_field :name,/
      expect(label_pos > field_pos).to be(true)
    end

    it "with 'omit' should make no labels" do
      res = factory_all_form_fields({columns: [:name, :blurb],
                                     form_labels_position: 'omit'}
      )

      expect(res).to_not include("<label class='small form-text text-muted'>Name</label>")
    end
  end

  describe "form_placeholder_labels" do
    describe "default (no placeholders)" do
      it "with 'omit' should make no labels" do
        res = factory_all_form_fields({columns: [:name, :blurb],
                                       form_labels_position: 'omit',
                                       form_placeholder_labels: false})

        expect(res).to_not include(", placeholder: 'Name'")
      end
    end

    it "with placeholder labels " do


      res = factory_all_form_fields({columns: [:name, :blurb],
                                     form_labels_position: 'omit',
                                     form_placeholder_labels: true})
      expect(res).to  include(", placeholder: 'Name'")
      expect(res).to  include(", placeholder: 'Blurb'")
    end

    it "with placeholder labels for a text area " do


      res = factory_all_form_fields(columns: [:long_description],
                                     form_labels_position: 'omit',
                                     form_placeholder_labels: true)
      expect(res).to include("placeholder: 'Long description' ")
    end

    it "with placeholder labels for a float " do
      # res = factory_all_form_fields({columns: [:cost],
      #                                form_labels_position: 'omit',
      #                                form_placeholder_labels: true})
      #
      # expect(res).to include("placeholder: 'Cost'")
    end
  end

  describe "inline_list_labels" do
    # note that the labels also appear in the list headings
    # so I am testing below with  no_list_heading: true,

    it "should not show labels when disabled" do
      res = factory_all_line_fields({columns: [:name, :blurb, :cost],
                                     no_list_heading: true,
                                     inline_list_labels: false})

      expect(res).to_not include("<label class='small form-text text-muted'>Cost</label>")
      expect(res).to_not include("<label class='small form-text text-muted'>Blurb</label>")
      expect(res).to_not include("<label class='small form-text text-muted'>Name</label>")

    end

    it "should show labels when --inline-list-labels" do
      res = factory_all_line_fields({columns: [:name, :blurb, :cost],
                                     no_list_heading: true,
                                     inline_list_labels: 'before'})

      expect(res).to include("<label class='small form-text text-muted'>Cost</label>")
      expect(res).to include("<label class='small form-text text-muted'>Blurb</label>")
      expect(res).to include("<label class='small form-text text-muted'>Name</label>")

    end

    it "should show labels when --inline-list-labels" do
      res = factory_all_line_fields({columns: [:name, :blurb, :cost],
                                     no_list_heading: true,
                                     inline_list_labels: 'after'})

      expect(res).to include("<label class='small form-text text-muted'>Cost</label>")
      expect(res).to include("<label class='small form-text text-muted'>Blurb</label>")
      expect(res).to include("<label class='small form-text text-muted'>Name</label>")
    end

    it "should show labels when --inline-list-labels" do
      res = factory_all_line_fields({columns: [:name, :blurb, :cost],
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

  describe "assocaciation field" do

    let (:hawk_keys_for_hgi_id) {{hgi_id: {bind_to: ["current_user.hgis"], optional: false }}}

    describe "edit and list" do

      it "should render stuff correctly" do
        res = factory_all_form_fields({columns: [:hgi_id],
                                       alt_lookups: {},
                                       singular_class: Jkl,
                                       singular: "jkl",
                                       hawk_keys: {}})

        expect(res).to include("<%= f.collection_select(:hgi_id, Hgi.all,")


        list_res = factory_all_line_fields({columns: [:hgi_id]})
        expect(list_res).to include("<%= jkl.hgi.try(:name) || '<span class=\"content alert-danger\">MISSING</span>'.html_safe %>")
      end
    end


    describe "hawked foreign keys" do
      #  this test is proxy-texting to HotGlue::ErbTemplate#integer_result
      #

      it "should hawk the hgi_id to the current user" do
        res = factory_all_form_fields({columns: [:hgi_id],
                                       alt_lookups: {},
                                       singular_class: Jkl,
                                       singular: "jkl",
                                       hawk_keys: hawk_keys_for_hgi_id})

        expect(res).to include("<%= f.collection_select(:hgi_id, current_user.hgis,")
      end
    end
  end


end
