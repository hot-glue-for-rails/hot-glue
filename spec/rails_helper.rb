ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require 'byebug'


# require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
# require 'database_cleaner'
require 'factory_bot'
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config| 

  config.include FactoryBot::Syntax::Methods

  config.infer_spec_type_from_file_location!
end
