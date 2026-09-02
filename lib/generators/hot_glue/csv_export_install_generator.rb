

module HotGlue
  class CsvExportInstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def filepath_prefix
      # todo: inject the context
      'spec/dummy/' if $INTERNAL_SPECS
    end

    def initialize(*args) #:nodoc:
      super

      # global service object, model, jobs, controller & views shared by every
      # scaffold's CSV/Excel exporter (built per-controller with the --csv flag)
      copy_file "csv_export/csv_constructor.rb", "#{filepath_prefix}app/services/csv_constructor.rb"
      copy_file "csv_export/csv_request.rb", "#{filepath_prefix}app/models/csv_request.rb"
      copy_file "csv_export/build_csv_job.rb", "#{filepath_prefix}app/jobs/build_csv_job.rb"
      copy_file "csv_export/destroy_csv_request_job.rb", "#{filepath_prefix}app/jobs/destroy_csv_request_job.rb"
      copy_file "csv_export/csv_requests_controller.rb", "#{filepath_prefix}app/controllers/csv_requests_controller.rb"

      copy_file "csv_export/_pending.erb", "#{filepath_prefix}app/views/csv_requests/_pending.erb"
      copy_file "csv_export/_ready.erb", "#{filepath_prefix}app/views/csv_requests/_ready.erb"
      copy_file "csv_export/_failed.erb", "#{filepath_prefix}app/views/csv_requests/_failed.erb"

      # Stimulus controller that auto-triggers the download when the background
      # export's "ready" Turbo Stream arrives (registers it in the manifest,
      # then overwrites the stub with the real implementation)
      system("./bin/rails generate stimulus AutoDownload")
      copy_file "csv_export/auto_download_controller.js", "#{filepath_prefix}app/javascript/controllers/auto_download_controller.js"

      timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
      migration_version = ActiveRecord::Migration.current_version
      create_file "#{filepath_prefix}db/migrate/#{timestamp}_create_csv_requests.rb", <<~RUBY
        class CreateCsvRequests < ActiveRecord::Migration[#{migration_version}]
          def change
            create_table :csv_requests do |t|
              t.string :controller_name, null: false
              t.string :format, null: false, default: "csv"
              t.jsonb :query_params, null: false, default: {}
              t.string :status, null: false, default: "pending"
              t.string :owner_type
              t.bigint :owner_id
              t.text :error_message
              t.datetime :downloaded_at

              t.timestamps
            end
            add_index :csv_requests, [:owner_type, :owner_id]
          end
        end
      RUBY

      puts <<~MSG

        ============================================================
        HOT GLUE --> CSV/Excel export installed.

        Finish setup with these one-time steps:

        1. Add these gems to your Gemfile:
             gem "caxlsx"   # .xlsx / Excel export
             gem "csv"      # required on Ruby 3.4+ (csv is no longer default)

        2. Install Active Storage (the export file is stored as an attachment):
             bin/rails active_storage:install

        3. Run migrations:
             bin/rails db:migrate

        4. Add routes to config/routes.rb:

           a) the global download route (once):
                resources :csv_requests, only: [] do
                  member { get :download }
                end

           b) for EACH scaffold you build with --csv, add an export
              collection route to that resource, e.g. for Things:
                resources :things do
                  collection { post :export }
                end

        5. IMPORTANT — Action Cable must be CROSS-PROCESS.
           When an export is too large it runs in a background job and, on
           completion, broadcasts a Turbo Stream to the browser. The job and the
           web server are separate processes in any real deployment (and in dev
           if you run a separate worker), so your Action Cable adapter must be
           shared across processes -- solid_cable, or redis. The `async` adapter
           (Rails' dev default) only works in-process and will make the export
           appear to hang on "Preparing...". If you use the redis adapter, note
           that Action Cable requires the redis gem < 6:
                gem "redis", "~> 5.0"
        ============================================================

      MSG
    end
  end
end
