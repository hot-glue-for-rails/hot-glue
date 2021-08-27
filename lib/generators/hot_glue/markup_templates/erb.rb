module  HotGlue
  class ErbTemplate < TemplateBase
    def all_form_fields(*args)

      # cannot sub-build because of HAML blockers here
      # haml_builder = HotGlue::HamlTemplate.new
      # haml_result = haml_builder.all_form_fields(args[0])
      # byebug
      # haml_engine = Haml::Engine.new("%div\n" + haml_result)
      # haml_engine.render
    end


    def paginate(*args)
      haml_builder = HotGlue::HamlTemplate.new
      haml_result = haml_builder.paginate(args[0])
      haml_engine = Haml::Engine.new(haml_result)
      haml_engine.render


    end

    def all_line_fields(*args)
      haml_builder = HotGlue::HamlTemplate.new
      haml_engine = haml_builder.all_line_fields(args[0])
      haml_engine = Haml::Engine.new(haml_result)
      haml_engine.render
    end
  end

end