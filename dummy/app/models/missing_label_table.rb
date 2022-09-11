class MissingLabelTable < ApplicationRecord
  has_many :borked

  # this table is missing a name field
end
