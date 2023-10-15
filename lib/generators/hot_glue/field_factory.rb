require_relative "fields/association_field"
require_relative "fields/boolean_field"
require_relative "fields/date_field"
require_relative "fields/date_time_field"
require_relative "fields/enum_field"
require_relative "fields/float_field"
require_relative "fields/integer_field"
require_relative "fields/string_field"
require_relative "fields/text_field"
require_relative "fields/time_field"
require_relative "fields/uuid_field"
require_relative "fields/attachment_field"


class FieldFactory
  attr_accessor :field, :class_name
  def initialize(type: , name: , generator: )
    field_class = case type
             when :integer
               if name.to_s.ends_with?("_id")
                 AssociationField
               else
                 IntegerField
               end
            when :uuid
              UUIDField
            when :string
              StringField
            when :text
              TextField
            when :float
              FloatField
            when :datetime
              DateTimeField
            when :date
              DateField
            when :time
              TimeField
            when :boolean
              BooleanField
            when :enum
              EnumField
            when :attachment
              AttachmentField
            end
    @class_name = class_name

    @field = field_class.new(name: name,
                             layout_strategy: generator.layout_strategy,
                             form_placeholder_labels: generator.form_placeholder_labels,
                             form_labels_position: generator.form_labels_position,
                             ownership_field: generator.ownership_field,
                             hawk_keys: generator.hawk_keys,
                             auth: generator.auth,
                             class_name: generator.singular_class,
                             alt_lookups: generator.alt_lookups,
                             singular: generator.singular,
                             self_auth: generator.self_auth,
                             update_show_only: generator.update_show_only,
                             attachment_data: generator.attachments[name.to_sym],
                             sample_file_path: generator.sample_file_path,
                             modify_as: generator.modify_as[name.to_sym] || nil,
                             display_as: generator.display_as[name.to_sym] || nil,
                             default_boolean_display: generator.default_boolean_display)
  end
end
