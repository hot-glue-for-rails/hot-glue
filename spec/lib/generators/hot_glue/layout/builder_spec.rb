require 'rails_helper'


describe HotGlue::Layout::Builder do
  describe "#initialize" do
    let(:builder) {HotGlue::Layout::Builder.new(include_setting: nil,
                                                 downnest_object: {},
                                                 no_edit: false,
                                                 no_delete: false,
                                                 columns: [],
                                                 smart_layout: true)
    }
  end

  describe "#construct" do
    describe "without smart layouts" do
      describe "without downnested portals" do
        it "should make 3 columns if given 3 fields" do

        end

        it "should make 5 2-columns if given 11 fields" do
          x = HotGlue::Layout::Builder.new(include_setting: "",
                                            downnest_object: {},
                                            buttons_width: 2,
                                            columns: [:name, :author_id, :blurb, :long_description, :cost, :how_many_printed, :approved_at, :release_on, :time_of_day, :selected, :genre],
                                            smart_layout: true)
          result = x.construct


          expect(result).to eq({:columns=>{:size_each=>2,
                                           # :button_columns => 2,
                                           :container=>
                                             [[:name, :author_id],
                                              [:blurb, :long_description],
                                              [:cost, :how_many_printed],
                                              [:approved_at, :release_on],
                                              [:time_of_day, :selected, :genre]]
                                            }, :portals=>{}, :buttons=>{:size=>2}})

        end
      end

      describe "with 1 downnest portal and fewer than 4 columns " do
        it "should give 6 columns to the downnested portal" do

        end
      end
      describe "with 1 downnest portal and 6 columns" do
        it "should give 4 columns to the downnested portal" do
          # TODO: implement me

        end
      end

      describe "with 2 downnest portals" do
        it "should give 4 columns each to the downensted portals" do
          # TODO: implement me

        end
      end
    end


    describe "Specified Grouping mode ( using colons)" do
      it "should concat the two fields into one column " do
        x = HotGlue::Layout::Builder.new(include_setting: "api_key,api_id:",
                                          downnest_object:  {get_emails_rules: 4},
                                          buttons_width: 2,
                                          columns: [:api_key, :api_id],
                                          smart_layout: false)
        result = x.construct
        expect(result[:columns][:container]).to eq([[:api_key, :api_id]])
        expect(result[:portals][:get_emails_rules][:size]).to eq(4)
      end
    end

    describe "with smart layouts" do
      describe "when not using semicolons" do
        it "should concat the two fields and give 2 more columns back to the downnest" do
          x = HotGlue::Layout::Builder.new(include_setting: "api_key,api_id",
                                            downnest_object: {get_emails_rules: 4},
                                            buttons_width: 2,
                                            columns: [:api_key, :api_id],
                                            smart_layout: true)
          result = x.construct
          expect(result[:columns][:container]).to eq([[:api_key], [:api_id]])
          expect(result[:portals][:get_emails_rules][:size]).to eq(4)
        end
      end


      describe "when given 4 fields and 1 downnested portal" do
        it "should give 4 - 4 - 2" do
        end
      end


      describe "when given 7 fields and 1 downnested portal" do
        it "should give 4 - 4 - 2" do

        end
      end
    end


    describe "When not specified grouping mode and when not smarty layouts" do
      it "should just give 1 column per field" do
        x = HotGlue::Layout::Builder.new(include_setting: "name,how_many",
                                         downnest_object: {},
                                          buttons_width: 2,
                                          columns: [:name, :how_many],
                                          smart_layout: false)
        result = x.construct
        expect(result[:columns][:container]).to eq([[:name], [:how_many]])

      end
    end
  end
end
