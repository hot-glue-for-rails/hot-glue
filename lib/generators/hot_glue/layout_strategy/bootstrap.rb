class LayoutStrategy::Bootstrap < LayoutStrategy::Base
  def button_classes
    " " + "col-sm-#{builder.layout_object[:columns][:button_columns]}"
  end

  def column_classes_for_button_column
    "col-md-#{builder.layout_object[:columns][:button_columns]}"
  end


  def column_classes_for_form_fields
    "col-md-#{builder.layout_object[:columns][:size_each]}"
  end

  def column_classes_for_column_headings
    column_classes_for_line_fields
  end

  def container_name
    "container-fluid"
  end

  def column_classes_for_line_fields
    "col-sm-#{builder.layout_object[:columns][:size_each]}"
  end

  def column_width
    builder.layout_object[:columns][:size_each]
  end

  def downnest_portal_column_width(downnest)
    "col-sm-#{ builder.layout_object[:portals][downnest][:size] }"
  end

  def page_begin
    '<div class="row"> <div class="col-md-12">'
  end

  def row_classes
    "row"
  end

  def page_end
    '</div> </div>'
  end
end
