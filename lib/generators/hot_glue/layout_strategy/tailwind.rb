

class LayoutStrategy::Tailwind < LayoutStrategy::Base
  def button_classes; ""; end
  def button_column_style; "" ; end
  def button_style ; ""; end
  def column_headings_col_style; "" ; end
  def column_width; ""; end
  def column_classes_for_line_fields; ""; end
  def column_classes_for_form_fields; ""; end
  def column_classes_for_column_headings; ""; end
  def col_width; 100; end
  def container_name; ""; end
  def downnest_style ; ""; end
  def downnest_column_style ; "" ; end
  def each_col
    return col_width if builder.columns.count == 0
    (col_width/(builder.columns.count)).to_i
  end

  def list_classes; "overflow-x-auto w-full"; end
  def row_classes; "grid grid-cols-4 gap-x-16 py-5 px-4 text-sm text-gray-700 border-b border-gray-200 dark:border-gray-700"; end
  def row_heading_classes; "grid grid-cols-4 gap-x-16 p-4 text-sm font-medium text-gray-900 bg-gray-100 border-t border-b border-gray-200 dark:bg-gray-800 dark:border-gray-700 dark:text-white"; end
  def page_begin; '<div class="overflow-hidden min-w-max"> '; end
  def page_end ; '</div> '; end
  def style_with_flex_basis(x); "" ; end

end
