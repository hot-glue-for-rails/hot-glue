class Fruits::Cantelope < ApplicationRecord
  self.table_name = 'cantelopes'

  has_many :dfgs
end
