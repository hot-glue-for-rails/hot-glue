ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'

# require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'database_cleaner'

# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

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