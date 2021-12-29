

module HotGlue
  module Layout
    class Builder
      attr_reader :include_setting, :downnest_children, :no_edit, :no_delete, :columns, :smart_layout

      def initialize(params)
        @include_setting = params[:include_setting]
        @downnest_children = params[:downnest_children]
        @no_edit = params[:no_edit]
        @no_delete = params[:no_delete]
        @columns = params[:columns]
        @smart_layout = params[:smart_layout]
      end

      def construct
        layout_object = {
          columns: {
            size_each: nil,
            container: [] # array of arrays
          },
          portals:  {

          },
          buttons: { size: ''}
        }

        downnest_children.each do |child|
          layout_object[:portals][child] = {size: 4}
        end

        # smart layout: 2 columns per field; 4 column for EACH downnested portals, 2 column for buttons
        how_many_downnest = downnest_children.size
        button_column_size = (no_edit && no_delete) ? 0 : 2

        bootstrap_columns = (12-button_column_size)
        bootstrap_columns = bootstrap_columns - (how_many_downnest*4)
        available_columns = (bootstrap_columns / 2).floor # bascially turns the 12-column grid into a 6-column grid

        if available_columns < 0
          raise "Cannot build layout with #{how_many_downnest} downnested portals"
        end

        @downnest_children_width = []
        @downnest_children.each_with_index{ |child, i| @downnest_children_width[i] = 4}

        if include_setting.nil?

        end

        if smart_layout
          # automatic control
          #

          if columns.size > available_columns
            each_col_can_have = (columns.size.to_f / available_columns.to_f).round
            # byebug
            layout_object[:columns][:container] = (0..available_columns-1).collect { |x|
              columns.slice(0+(x*each_col_can_have),each_col_can_have)
            }
            layout_object[:columns][:container].last.append *columns.slice(0+(available_columns*each_col_can_have),each_col_can_have)

          else
            layout_object[:columns][:container] = (0..available_columns-1).collect { |x|
              [ columns[x]]
            }
            layout_object[:columns][:container].reject!{|x| x == [nil]}
          end
        elsif !include_setting.include?(":")
          layout_object[:columns][:container] = columns.collect{|col| [col]}

        else
          (0..available_columns-1).each do |int|
            layout_object[:columns][:container][int] = []
          end

          # input control
          user_layout_columns = options['include'].split(":")

          if user_layout_columns.size > available_columns
            raise "Your include statement #{options['include']}  has #{user_layout_columns.size} columns, but I can only construct up to #{available_columns}"
          end
          user_layout_columns.each_with_index  do |column,i|
            layout_object[:columns][:container][i] = column.split(",")
          end

          if user_layout_columns.size < layout_object[:columns][:container].size
            layout_object[:columns][:container].reject!{|x| x == []}
          end
        end

        if layout_object[:columns][:container].size < available_columns
          available = available_columns - layout_object[:columns][:container].size
          downnest_child_count = 0

          while(available > 0)
            if (downnest_child_count <= downnest_children.size-1)
              layout_object[:portals][downnest_children[downnest_child_count]][:size] = layout_object[:portals][downnest_children[downnest_child_count]][:size]  + 2
            else
              # leave as-is
            end
            downnest_child_count = downnest_child_count + 1
            available = available - 1
          end
          # give some space back to the downnest
        end

        puts "*** constructed layout columns #{layout_object.inspect}"
        layout_object
      end

    end
  end
end