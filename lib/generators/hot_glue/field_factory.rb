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


class FieldFactory
  attr_accessor :field
  def initialize(type: , name: , object: , singular_class: )
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
            end
    @field = field_class.new(name: name,
                             object: object,
                             singular_class: singular_class)
  end
end
