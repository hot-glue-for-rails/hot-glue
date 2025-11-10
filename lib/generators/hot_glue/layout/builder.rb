

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
                     include_setting:,
                     buttons_width: )


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
            container: [] , # array of arrays,
            bootstrap_column_width: [],
            column_custom_widths: [],
            fields: {

            }, # hash of fields
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
            bootstrap_columns = bootstrap_columns - (downnest_object.size * 4)
          else
            bootstrap_columns = bootstrap_columns - 4
          end

          # downnest_children_width = []


          @downnest_object.each do |child, data|
            layout_object[:portals][child] = {size: data[:extra_size] + 4}
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

          end

        elsif ! specified_grouping_mode
          # not smart and no specified grouping
          layout_object[:columns][:button_columns] = bootstrap_column_width

          layout_object[:columns][:container] = columns.collect{|col| [col]}

          if include_setting.split(",").any?{|col| col.include?("(")}
            raise "Your include list has a ( character; to specify a column width, use specified grouping mode only"
          end


        else # specified grouping mode -- the builder is given control unless a column width is explicitly set using (..)
          layout_object[:columns][:button_columns] = bootstrap_column_width

          (0..available_columns-1).each do |int|
            layout_object[:columns][:container][int] = []
          end

          # input control

          user_layout_columns = @include_setting.split(":")
          fixed_widths = {}

          user_layout_columns.each_with_index do |column_data,i |
            if column_data.include?("(")
              column_data =~ /(.*)\((.*)\)/
              column_fields = $1
              fixed_col_width = $2
              fixed_widths[i] = fixed_col_width
            else
              column_fields = column_data
            end
            user_layout_columns[i] = column_fields
          end


          extra_columns = available_columns - user_layout_columns.size

          columns_to_work_with =  (12 - @buttons_width)

          if columns_to_work_with < user_layout_columns.size
            raise "Your include statement #{@include_setting } has #{user_layout_columns.size} columns, but I can only construct up to #{columns_to_work_with}"
          end

          target_col_size = columns_to_work_with / user_layout_columns.size
          extra_columns = columns_to_work_with % user_layout_columns.size


          user_layout_columns.each_with_index  do |column, i|

            layout_object[:columns][:container][i] = column.split(",").collect{|x|
              x.gsub("-","").gsub("=","")
              if x.include?("(")
                x =~ /(.*)\((.*)\)/
                x = $1

              end
              x
            }.collect(&:to_sym)


            layout_object[:columns][:bootstrap_column_width][i] = fixed_widths[i] || target_col_size

            if i < extra_columns && ! fixed_widths[i]
              layout_object[:columns][:bootstrap_column_width][i] += 1
            end
          end

          if user_layout_columns.size < layout_object[:columns][:container].size
            layout_object[:columns][:container].reject!{|x| x == []}
          end
        end

        # go through the columns and build the split visibility (show / form)

        columns.each do |col|
          layout_object[:columns][:fields][col] = {show: true, form: true}
        end

        @include_setting.split(":").collect { |column_list|
          column_list.split(",").collect do |field|
            if field.include?("(")
              field =~ /(.*)\((.*)\)/
              field_short = $1
            else
              field_short = field
            end

            field_short =  field_short.gsub("-", "").gsub("=", "")

            layout_object[:columns][:fields][field_short.to_sym] = {
              show: true,
              form: true
            }

            if field.starts_with?("**")
              nil
            end

            if field.include?("-")
              layout_object[:columns][:fields][field_short.to_sym][:show] = false;
            end
            if field.include?("=")
              layout_object[:columns][:fields][field_short.to_sym][:form] = false;
            end

          end
        }
        puts "*** SPECIFIED GROUPING SETTINGS: #{layout_object.inspect}"
        layout_object
      end
    end
  end
end
