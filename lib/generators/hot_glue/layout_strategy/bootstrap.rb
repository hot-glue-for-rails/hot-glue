class LayoutStrategy::Bootstrap < LayoutStrategy::Base
  def button_classes # column classes
    " " + "col-sm-#{builder.layout_object[:columns][:button_columns]}"
  end

  def button_applied_classes
    "btn btn-sm"
  end

  def magic_button_classes
    "btn-secondary"
  end


  def column_classes_for_button_column
    "col-md-#{builder.layout_object[:buttons][:size]}"
  end


  def column_classes_for_form_fields
    "col-md-#{builder.layout_object[:columns][:size_each]}"
  end

  def column_classes_for_column_headings
    column_classes_for_line_fields
  end

  def container_name
    "container"
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

  def downnest_portal_stacked_column_width
    "col-sm-4"
  end

  def page_begin
    '<div class="row"> <div class="col-md-12">'
  end

  def row_classes
    "row hg-row"
  end

  def page_end
    '</div> </div>'
  end

  def form_checkbox_input_class
    "form-check-input"
  end

  def form_checkbox_wrapper_class
    "form-check"
  end

  def form_checkbox_label_class
    "form-check-label"
  end

  def search_opening
    '<div class="row"><div class="col-md-12 card"><div class="card-body">'
  end

  def search_closing
    "</div></div></div>"
  end
end
