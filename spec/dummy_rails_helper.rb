

ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'



# DUMMY SETUP
# require rails first
require "rails/all"
# require the gem's core code

Dir["./lib**/*.rb"].each do |x|
  require(x)
end
require "dummy/application"
require 'dummy/config/environment/test'

require "rspec/rails"


Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/dummy/app/**/*.rb")].each { |f| require f }

Dummy::Application.initialize!


# require File.expand_path('../../config/environment', __FILE__)




ActiveRecord::Migration.maintain_test_schema!

# set up db
# be sure to update the schema if required by doing
# - cd spec/rails_app
# - rake db:migrate
ActiveRecord::Schema.verbose = false
load 'spec/dummy/db/schema.rb' # use db agnostic schema by default

# require 'spec/dummy/factory'
# require 'spec/dummy/factories'




require 'rspec/rails'
require 'database_cleaner'

# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # config.use_transactional_fixtures = false

  # config.before(:suite) do
  #   DatabaseCleaner.clean_with(:truncation)
  # end
  #
  # config.before(:each) do
  #   DatabaseCleaner.strategy = :truncation
  # end

  # config.before(:each, js: true) do
  #   DatabaseCleaner.strategy = :truncation
  # end
  # config.before(:each) do
  #   DatabaseCleaner.start
  # end
  # config.after(:each) do
  #   DatabaseCleaner.clean
  # end
  # config.before(:all) do
  #   DatabaseCleaner.start
  # end
  # config.after(:all) do
  #   DatabaseCleaner.clean
  # end
  config.infer_spec_type_from_file_location!
end