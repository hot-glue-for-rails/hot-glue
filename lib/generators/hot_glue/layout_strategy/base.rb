module LayoutStrategy
  class Base
    def initialize(scaffold_builder)
      @scaffold_builder = scaffold_builder
    end

    def button_classes; ""; end
    def button_column_style; "" ; end
    def button_style ; ""; end
    def column_headings_col_style; "" ; end
    def downnest_style ; ""; end
    def downnest_column_style ; "" ; end
    def style_with_flex_basis ; "" ; end
  end
end
