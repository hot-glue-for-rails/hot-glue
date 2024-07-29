module LayoutStrategy
  class Base
    attr_accessor :builder
    def initialize(scaffold_builder)
      @builder = scaffold_builder
    end

    def button_applied_classes; end
    def column_classes_for_button_column; ""; end
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
    def list_classes; ""; end
    def magic_button_classes; ""; end
    def row_classes; ""; end
    def row_heading_classes; ""; end
    def page_begin; '<div> '; end
    def page_end ; '</div> '; end
    def style_with_flex_basis(x); "" ; end
    def form_checkbox_input_class; ""; end
    def form_checkbox_label_class; ""; end
    def form_checkbox_wrapper_class; ""; end

    def search_opening
      ""
    end

    def search_closing
      ""
    end
  end
end
