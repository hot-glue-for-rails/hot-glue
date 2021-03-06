require 'dummy_rails_helper'

require 'rake'
Dummy::Application.load_tasks
Rspec.describe "HotGlue::Generator" do
  it "should allow basic generation" do
    Rake::Task['hot_glue:ge'].execute({account_id: 111})
  end
end