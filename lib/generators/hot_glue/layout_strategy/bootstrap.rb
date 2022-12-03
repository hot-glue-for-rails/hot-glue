

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

  def column_headings_col_style
    ""
  end

  def style_with_flex_basis
    ""
  end
end
