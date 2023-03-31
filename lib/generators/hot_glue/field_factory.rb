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
