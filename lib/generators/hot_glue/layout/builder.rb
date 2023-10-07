

module HotGlue
  module Layout
    class Builder
      include DefaultConfigLoader
      attr_reader :include_setting,
                  :downnest_object,
                  :buttons_width, :columns,
                  :smart_layout, :specified_grouping_mode,
                  :stacked_downnesting, :bootstrap_column_width

      def initialize(generator: ,
                     include_setting: ,
                     buttons_width:  )


        @generator = generator

        @modify_as = generator.modify_as
        @display_as =  generator.display_as
        @columns = generator.columns
        @smart_layout = generator.smart_layout
        @stacked_downnesting = generator.stacked_downnesting || false
        @downnest_object = generator.downnest_object

        @include_setting = include_setting
        @buttons_width = buttons_width

        @no_buttons = @buttons_width == 0
        @specified_grouping_mode = include_setting.include?(":")
        @bootstrap_column_width = generator.bootstrap_column_width.to_i
        @big_edit = generator.big_edit

        @default_boolean_display = get_default_from_config(key: :default_boolean_display)

      end

      def construct
        layout_object = {
          columns: {
            size_each: smart_layout ? bootstrap_column_width : (specified_grouping_mode ? nil : 1),
            container: [] # array of arrays
          },
          portals:  {

          },
          buttons: { size: @buttons_width},
          modify_as: @modify_as,
          display_as: @display_as
        }

        # downnest_object.each do |child, size|
        #   layout_object[:portals][child] = {size: size}
        # end

        bootstrap_columns = (12 - @buttons_width )

        unless @big_edit
          # how_many_downnest = downnest_object.size
          if(!stacked_downnesting)
            bootstrap_columns = bootstrap_columns - (downnest_object.collect{|k,v| v}.sum)
          else
            bootstrap_columns = bootstrap_columns - 4
          end

          # downnest_children_width = []
          downnest_object.each do |child, size|
            layout_object[:portals][child] = {size:  size}
          end
        end
        available_columns = (bootstrap_columns / bootstrap_column_width).floor

        # when set to 2, turns the 12-column grid into a 6-column grid
        if available_columns < 0
          raise "Cannot build layout -- too few columns"
        end

        # smart layout: bootstrap_column_width columns per field; 4 column for EACH downnested portal, 2 column for buttons
        if smart_layout
          # automatic control
          #

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
              [ columns[x] ]
            }
            layout_object[:columns][:container] = (0..available_columns-1).collect { |x|  [columns[x]] }
            layout_object[:columns][:container].reject!{|x| x == [nil]}
            layout_object[:columns][:size_each] = bootstrap_column_width
          end
        elsif ! specified_grouping_mode
          # not smart and no specified grouping
          layout_object[:columns][:button_columns] = bootstrap_column_width

          layout_object[:columns][:container] = columns.collect{|col| [col]}

        else # specified grouping mode -- the builder is given control
          layout_object[:columns][:button_columns] = bootstrap_column_width

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

        puts "*** constructed smart layout columns #{layout_object.inspect}"
        layout_object
      end

    end
  end
end
