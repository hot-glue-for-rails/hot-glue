class Ghi < ApplicationRecord

  belongs_to :dfg
  belongs_to :xyz
  has_one :user, through: :dfg

  def name
    "name_of_#{id}"
  end
end