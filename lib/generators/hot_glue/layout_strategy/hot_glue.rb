
class LayoutStrategy::HotGlue < LayoutStrategy::Base

  def each_col
    return col_width if @scaffold_builder.columns.count == 0
    (col_width/(@scaffold_builder.columns.count)).to_i
  end

  def column_width
    each_col * @scaffold_builder.columns.count
  end


  def column_headings_col_style
    " style='flex-basis: #{column_width}%'"
  end


  def style_with_flex_basis(perc_width)
    " style='flex-basis: #{perc_width}%'"
  end

  def container_name
    "scaffold-container"
  end


  def col_identifier_form_fields
    "scaffold-cell"
  end

  def col_identifier_line_fields
    "scaffold-cell"
  end

  def col_identifier_column_headings
    "scaffold-cell"
  end

  def col_width
    downnest_size = case (@scaffold_builder.downnest_children.count)
        when 0
          downnest_size = 0
        when 1
          downnest_size = 40

        else
          downnest_size = 60

        end
    100 - downnest_size - 5
  end

  def row_begin
    '<div class=" scaffold-index-<%= plural %>">'
  end

  def row_end
    '</div>'
  end
end
