module HotGlue
  class TypeaheadInstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)
    class_option :namespace, type: :string, default: nil

    def filepath_prefix
      # todo: inject the context
      'spec/dummy/' if $INTERNAL_SPECS
    end


    def initialize(*args) #:nodoc:
      super

      copy_file "typeahead_views/typeahead.scss", "#{'spec/dummy/' if $INTERNAL_SPECS}app/assets/stylesheets/typeahead.scss"


      try = ["application.scss", "application.bootstrap.scss"]
      try.each do |filename|
        main_scss_file = "#{'spec/dummy/' if $INTERNAL_SPECS}app/assets/stylesheets/#{filename}"
        if File.exist?(main_scss_file)
          insert_into_file main_scss_file do
            "@import 'typeahead';\n"
          end
          puts  "Inserted @import 'typeahead'; into #{main_scss_file}"
          break
        else
          # puts "Could not find #{main_scss_file}. Please add the following line to your main scss file: @import 'typeahead';"
        end
      end
      copy_file "typeahead_views/typeahead_controller.js", "#{'spec/dummy/' if $INTERNAL_SPECS}app/javascript/controllers/typeahead_controller.js"
      copy_file "typeahead_views/typeahead_results_controller.js", "#{'spec/dummy/' if $INTERNAL_SPECS}app/javascript/controllers/typeahead_results_controller.js"

      system("bin/rails stimulus:manifest:update")
    end
  end
end



