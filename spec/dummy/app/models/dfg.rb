class Dfg < ApplicationRecord
  # can't use DEF as it is a Ruby Keyword

  belongs_to :user

  has_many :ghis
end
