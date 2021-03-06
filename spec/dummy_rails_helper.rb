

ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'



# DUMMY SETUP
# require rails first
# require the gem's core code


# require 'rspec/rails'
# require 'rails/generators/actions'
# require 'rails/generators/erb/scaffold/scaffold_generator'
#

require "rails/all"
require 'rspec/rails'


require "dummy/config/application"
require 'dummy/config/environments/test'



# Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("dummy/app/**/*.rb")].each { |f| require f }


# Dir["./lib/**/*.rb"].each do |x|
#   puts "requiring #{x}"
#   require(x)
# end

# Dummy::Application.initialize!

# require File.expand_path('../../config/environment', __FILE__)

ActiveRecord::Migration.maintain_test_schema!
# set up db
# be sure to update the schema if required by doing
# - cd spec/rails_app
# - rake db:migrate
ActiveRecord::Schema.verbose = false

# TODO: RE-ESTABLISH DB CONNECTION HERE


load 'dummy/db/schema.rb' # use db agnostic schema by default
# require 'spec/dummy/factory'
# require 'spec/dummy/factories'



# require 'database_cleaner'

# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # config.use_transactional_fixtures = false

  config.before(:suite) do




    # load the gem

   end
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
  # config.infer_spec_type_from_file_location!
end