class Dfg < ApplicationRecord
  # can't use DEF as it is a Ruby Keyword

  belongs_to :user
  belongs_to :cantelope, class_name: "Fruits::Cantelope"

  has_many :ghis


end
