

class LayoutStrategy::Bootstrap < LayoutStrategy::Base
  def container_name
    "container-fluid"
  end


  def col_identifier
    "col-md-#{column_width}"
  end

  def column_width
    @scaffold_builder.layout_object[:columns][:size_each]
  end
end
