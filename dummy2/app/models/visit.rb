class Visit < ApplicationRecord

  belongs_to :user
  has_one :family, through: :user
end
