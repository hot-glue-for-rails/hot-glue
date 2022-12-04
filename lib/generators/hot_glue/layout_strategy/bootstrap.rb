

class LayoutStrategy::Bootstrap < LayoutStrategy::Base
  def container_name
    "container-fluid"
  end


  def column_classes_for_form_fields
    "col-md-#{builder.layout_object[:columns][:size_each]}"
  end


  def downnest_portal_column_width(downnest)
    "col-sm-#{ builder.layout_object[:portals][downnest][:size] }"
  end

  def col_identifier_line_fields
    "col-sm-#{builder.layout_object[:columns][:size_each]}"
  end

  def column_width
    builder.layout_object[:columns][:size_each]
  end

  def row_begin
    '<div class="row"> <div class="col-md-12">'
  end

  def row_end
    '</div> </div>'
  end

  def col_identifier_column_headings
    col_identifier_line_fields
  end

  def button_classes
    " " + col_identifier_line_fields
  end
end
