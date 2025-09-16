

module HotGlue
  class SetSearchInterfaceInstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def filepath_prefix
      # todo: inject the context
      'spec/dummy/' if $INTERNAL_SPECS
    end

    def initialize(*args) #:nodoc:
      super

      ['date_range_picker',
       'time_range_picker',
       'search_form'].each do |file|


        system("./bin/rails generate stimulus #{file.titlecase.gsub(" ", "")}")
        copy_file "javascript/#{file}_controller.js", "#{filepath_prefix}app/javascript/controllers/#{file}_controller.js"
        puts "HOT GLUE --> copying #{file} stimulus controller into app/javascript/controllers/#{file}_controller.js"

      end
    end
  end
end



