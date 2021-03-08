require 'rails_helper'

describe <%= controller_class_name %> do
  render_views
  <% unless @auth.nil? %>  let(:<%= @auth %>) {create(:<%= @auth.gsub('current_', '') %>)}<%end%>
  let(:<%= singular %>) {create(:<%= singular %><%= object_parent_mapping_as_argument_for_specs %> )}

<%= objest_nest_factory_setup %>

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:account]

    sign_in <%= @auth %>, scope: :<%= @auth %>
  end

  describe "index" do
    it "should respond" do
      get :index, xhr: true, format: 'js', params: {
          <%= objest_nest_params_by_id_for_specs %>
      }
    end
  end

  describe "new" do
    it "should show form" do
      get :new, xhr: true, format: 'js', params: {
          <%= objest_nest_params_by_id_for_specs %>
      }
    end
  end

  describe "create" do
    it "should create a new <%= singular %>" do
      expect {
        post :create, xhr: true, format: 'js', params: {
          <%= (@nested_args.empty? ? "" : objest_nest_params_by_id_for_specs + ",") %>
            <%= singular %>: {
                <%= columns_spec_with_sample_data %>
        }}
      }.to change { <%= @singular_class %>.all.count }.by(1)
      assert_response :ok
    end

    # it "should not create if there are errors" do
    #   post :create, xhr: true, format: 'js',  params: {id: <%= singular %>.id,
    #                                                    <%= singular %>: {skin_id: nil}}
    #
    #   expect(controller).to set_flash.now[:alert].to(/Oops, your <%= singular %> could not be saved/)
    # end
  end

  describe "edit" do
    it "should return an editable form" do
      get :edit, xhr: true, format: 'js',  params: {
          <%= (@nested_args.empty? ? "" : objest_nest_params_by_id_for_specs + ",") %>
          id: <%= singular %>.id
      }
      assert_response :ok
    end
  end

  describe "show" do
    it "should return a view form" do
      get :show, xhr: true, format: 'js',  params: {
          <%= (@nested_args.empty? ? "" : objest_nest_params_by_id_for_specs + ",") %>
          id: <%= singular %>.id
        }
      assert_response :ok
    end
  end

  describe "update" do
    it "should update" do
      put :update, xhr: true, format: 'js',
          params: {
            <%= (@nested_args.empty? ? "" : objest_nest_params_by_id_for_specs + ",") %>
            id: <%= singular %>.id,
            <%= singular %>: {
                <%= columns_spec_with_sample_data %>
            }}

      assert_response :ok
    end

    # it "should not update if invalid" do
    #   put :update, xhr: true, format: 'js',
    #       params: {
    #         id: <%= singular %>.id,
    #         <%= singular %>: {
    #           <%= columns_spec_with_sample_data %>
    #       }}
    #
    #   assert_response :ok
    #
    #   expect(controller).to set_flash.now[:alert].to(/Oops, your <%= singular %> could not be saved/)
    # end
  end

  describe "#destroy" do
    it "should destroy" do
      post :destroy, format: 'js', params: {
          <%= (@nested_args.empty? ? "" : objest_nest_params_by_id_for_specs + ",") %>
          id: <%= singular %>.id
      }
      assert_response :ok
      expect(<%= @singular_class %>.count).to be(0)
    end
  end
end

