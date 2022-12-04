module LayoutStrategy
  class Base
    attr_accessor :builder
    def initialize(scaffold_builder)
      @builder = scaffold_builder
    end

    def button_classes; ""; end
    def button_column_style; "" ; end
    def button_style ; ""; end
    def column_headings_col_style; "" ; end
    def downnest_style ; ""; end
    def downnest_column_style ; "" ; end
    def style_with_flex_basis(x)
      ""
    end



    def each_col
      return col_width if builder.columns.count == 0
      (col_width/(builder.columns.count)).to_i
    end

    def col_width
      100
    end
  end
end
