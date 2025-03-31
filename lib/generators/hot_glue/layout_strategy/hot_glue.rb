class LayoutStrategy::HotGlue < LayoutStrategy::Base
  def button_column_style
    'style="flex-basis: 150px'
  end

  def button_style
    'style="flex-basis: ' +  (100 - (column_width * builder.columns.count)).floor.to_s +  '%;"'
  end

  def column_width
    each_col * builder.columns.count
  end

  def column_headings_col_style
    " style='flex-basis: #{column_width}%'"
  end

  def container_name
    "scaffold-container"
  end

  def downnest_column_style
    'style="flex-basis: ' + each_downnest_width.to_s +  '%;'
  end

  def downnest_style
    'style="flex-basis: ' +  each_downnest_width.to_s + '%"'
  end

  def each_downnest_width
    builder.downnest_children.count == 1 ? 33 : (53/builder.downnest_children.count).floor
  end

  def list_classes
    "scaffold-list"
  end

  def row_classes
    "scaffold-row"
  end

  def column_classes_for_form_fields(size = nil)
    "scaffold-cell"
  end

  def row_heading_classes
    "scaffold-heading-row"
  end
  def column_classes_for_line_fields(size = nil)
    "scaffold-cell"
  end

  def column_classes_for_column_headings(size = nil)
    "scaffold-cell"
  end

  def col_width
    downnest_size = case (builder.downnest_children.count)
        when 0
          downnest_size = 0
        when 1
          downnest_size = 40

        else
          downnest_size = 60

        end
    100 - downnest_size - 5
  end

  def page_begin
    '<div class=" scaffold-index-<%= plural %>">'
  end

  def page_end
    '</div>'
  end

  def style_with_flex_basis(perc_width)
    " style='flex-basis: #{perc_width}%'"
  end
end
