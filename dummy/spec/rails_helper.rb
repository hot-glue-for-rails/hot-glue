# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'rspec/retry'
require 'support/capybara_login.rb'

puts "reloading app..."
def reload!(print = true)
  puts 'Reloading ...' if print
  # Main project directory.
  root_dir = File.expand_path('..', __dir__)
  # Directories within the project that should be reloaded.
  reload_dirs = %w{lib}
  # Loop through and reload every file in all relevant project directories.
  reload_dirs.each do |dir|
    Dir.glob("#{root_dir}/#{dir}/**/*.rb").each { |f| load(f) }
  end
  # Return true when complete.
  true
end
reload!

puts "finished reloading app..."


# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.include FactoryBot::Syntax::Methods

  # System specs (spec/system) run through ActionDispatch::SystemTestCase,
  # which shares the DB connection between the test thread and the
  # in-process Puma server thread. Plain :feature specs with a real
  # Selenium driver don't get this, which caused intermittent
  # "record not visible to the server thread" failures (e.g. login
  # appearing to fail even though the user was just created).
  #
  # We use :chrome (not Rails' :headless_chrome) because
  # ActionDispatch::SystemTesting::Browser hardcodes the legacy
  # `--headless` flag. Legacy headless Chrome runs a materially different
  # rendering/input pipeline than real Chrome and has known bugs where a
  # native click is dispatched but never reaches the page (no JS error, no
  # network request -- confirmed by correlating failures against the
  # server log). `--headless=new` (Chrome 109+) uses the same pipeline as
  # headed Chrome and doesn't have this problem.
  config.before(:each, type: :system) do
    driven_by :selenium, using: :chrome, screen_size: [1366, 1200] do |options|
      options.add_argument("--headless=new")
    end
  end

  # Real-browser system specs hit several distinct classes of transient,
  # infrastructure-level flakiness that have nothing to do with application
  # correctness: headless Chrome occasionally drops a native click event
  # entirely (no request ever sent, no JS error), and a full-page Turbo
  # Drive navigation can race a Capybara content read into a raw
  # Selenium::WebDriver::Error::UnknownError ("node does not belong to the
  # document") that Capybara's own stale-element retry doesn't catch.
  # Chasing each one with bespoke per-interaction retries is whack-a-mole;
  # retrying the whole example is the standard fix for this class of
  # problem. rspec-retry (rather than a hand-rolled example.run loop)
  # correctly re-instantiates the example group so `let`/`let!` factories
  # actually re-run on retry instead of reusing stale memoized state.
  config.verbose_retry = true
  config.default_retry_count = 3
  config.retry_callback = proc { Capybara.reset_sessions! }
  config.around(:each, type: :system) do |example|
    example.run_with_retry retry: 3
  end
end

# Default of 2s is too tight for headless Chrome + Devise + Turbo page
# renders under load, causing sporadic false-negative waits.
Capybara.default_max_wait_time = 5
