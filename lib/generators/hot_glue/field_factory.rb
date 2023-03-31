class FieldFactory
  attr_accessor :field
  def initialize(type: , name: )
    @field = case type
             when :integer
               if name.to_s.ends_with?("_id")
                 AssociationField.new(name: name)
               else
                 IntegerField.new(name: name)
               end
            when :uuid
              UUIDField.new(name: name)
            when :string
              StringField.new(name: name)
            when :text
              TextField.new(name: name)
            when :float
              FloatField.new(name: name)
            when :datetime
              DateTimeField.new(name: name)
            when :date
              DateField.new(name: name)
            when :time
              TimeField.new(name: name)
            when :boolean
              BooleanField.new(name: name)
            when :enum
              EnumField.new(name: name)
            end
  end
end
