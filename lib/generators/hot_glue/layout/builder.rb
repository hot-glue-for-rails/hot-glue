

module HotGlue
  module Layout
    class Builder
      attr_reader :include_setting,
                  :downnest_object,
                  :buttons_width, :columns,
                  :smart_layout, :specified_grouping_mode

      def initialize(include_setting: nil,
                     downnest_object: nil,
                     buttons_width: nil,
                     smart_layout: nil,
                     columns: nil)
        @include_setting = include_setting
        @downnest_object = downnest_object
        @buttons_width = buttons_width
        @columns = columns
        @smart_layout = smart_layout

        @no_buttons = @buttons_width == 0
        @specified_grouping_mode = include_setting.include?(":")
      end

      def construct
        layout_object = {
          columns: {
            size_each: smart_layout ? 2 : (specified_grouping_mode ? nil : 1),
            container: [] # array of arrays
          },
          portals:  {

          },
          buttons: { size: @buttons_width}
        }

        # downnest_object.each do |child, size|
        #   layout_object[:portals][child] = {size: size}
        # end

        # smart layout: 2 columns per field; 4 column for EACH downnested portals, 2 column for buttons
        how_many_downnest = downnest_object.size

        bootstrap_columns = (12 - @buttons_width )

        bootstrap_columns = bootstrap_columns - (downnest_object.collect{|k,v| v}.sum)

        available_columns = (bootstrap_columns / 2).floor # bascially turns the 12-column grid into a 6-column grid

        if available_columns < 0
          raise "Cannot build layout with #{how_many_downnest} downnested portals"
        end

        downnest_children_width = []

        downnest_object.each do |child, size|
          layout_object[:portals][child] = {size:  size}
        end


        if smart_layout
          # automatic control
          #
          layout_object[:columns][:button_columns] = 2

          if columns.size > available_columns
            if available_columns == 0
              raise "Oopps... No available columns in SMART LAYOUT"
            end

            each_col_can_have = (columns.size.to_f / available_columns.to_f).round

            layout_object[:columns][:container] = (0..available_columns-1).collect { |x|
              columns.slice(0+(x*each_col_can_have),each_col_can_have)
            }
            layout_object[:columns][:container].last.append *columns.slice(0+(available_columns*each_col_can_have),each_col_can_have)

          else
            layout_object[:columns][:container] = (0..available_columns-1).collect { |x|
              [ columns[x]]
            }
            layout_object[:columns][:container] = (0..available_columns-1).collect { |x|  [columns[x]] }
            layout_object[:columns][:container].reject!{|x| x == [nil]}
            layout_object[:columns][:size_each] = 2
          end
        elsif ! specified_grouping_mode
          # not smart and no specified grouping
          layout_object[:columns][:button_columns] = 2

          layout_object[:columns][:container] = columns.collect{|col| [col]}

        else # specified grouping mode -- the builder is given control
          layout_object[:columns][:button_columns] = 2

          (0..available_columns-1).each do |int|
            layout_object[:columns][:container][int] = []
          end

          # input control

          user_layout_columns = @include_setting.split(":")
          size_each = (bootstrap_columns / user_layout_columns.count).floor # this is the bootstrap size

          layout_object[:columns][:size_each] = size_each

          if user_layout_columns.size > available_columns
            raise "Your include statement #{@include_setting } has #{user_layout_columns.size} columns, but I can only construct up to #{available_columns}"
          end
          user_layout_columns.each_with_index  do |column,i|
            layout_object[:columns][:container][i] = column.split(",").collect(&:to_sym)
          end

          if user_layout_columns.size < layout_object[:columns][:container].size
            layout_object[:columns][:container].reject!{|x| x == []}
          end
        end

        # TODO: do I want this code that expands the downnest portal
        # maybe refactor into a setting on the --downnest flag itself somehow
        # if layout_object[:columns][:container].size < available_columns
        #   available = available_columns - layout_object[:columns][:container].size
        #   downnest_child_count = 0
        #
        #   while(available > 0)
        #     if (downnest_child_count <= downnest_children.size-1)
        #       layout_object[:portals][downnest_children[downnest_child_count]][:size] = layout_object[:portals][downnest_children[downnest_child_count]][:size]  + 2
        #     else
        #       # leave as-is
        #     end
        #     downnest_child_count = downnest_child_count + 1
        #     available = available - 1
        #   end
        #   # give some space back to the downnest
        # end

        puts "*** constructed smart layout columns #{layout_object.inspect}"
        layout_object
      end

    end
  end
end
