

class LayoutStrategy::Bootstrap < LayoutStrategy::Base
  def container_name
    "container-fluid"
  end

  def col_identifier_form_fields
    "col-md-#{@scaffold_builder.layout_object[:columns][:size_each]}"
  end

  def col_identifier_column_headings
    "col-md-#{column_width}"
  end

  def col_identifier_line_fields
    "col-md-#{@scaffold_builder.layout_object[:columns][:size_each]}"
  end

  def column_width
    @scaffold_builder.layout_object[:columns][:size_each]
  end


  def row_begin
    '<div class="row"> <div class="col-md-12">'
  end

  def row_end
    '</div> </div>'
  end

  def button_classes
    " col-md-#{ @layout_object[:buttons][:size] }"
  end
end
