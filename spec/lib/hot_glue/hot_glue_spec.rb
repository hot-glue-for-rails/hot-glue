require "rails_helper"

describe HotGlue do
  describe "#optionalized_ternary" do

    describe "when the first parent is optional" do
      it "should work for a one-level nest" do
        target = 'invoices'
        nested_set = [
          {singular: 'account', optional: true, plural: 'accounts'}
        ]

        result = HotGlue.optionalized_ternary(target: 'invoices',
                                              nested_set: nested_set,
                                              namespace: "admin")
        expect(result).to eq("@account ? admin_account_invoices_path : admin_invoices_path")
      end
    end

    describe "for non-optional" do
      it "should work for a one-level nest" do
        target = 'invoices'
        nested_set = [
          {singular: 'account', optional: false, plural: 'accounts'}
        ]

        result = HotGlue.optionalized_ternary(target: 'invoices',
                                              nested_set: nested_set,
                                              namespace: "admin")
        expect(result).to eq("admin_account_invoices_path")
      end


      it "should work for a two-level nest" do

      end

      it "should work for a three-level nest" do

      end
    end
  end
end