class Ghi < ApplicationRecord

  belongs_to :dfg, optional: true
  belongs_to :xyz, optional: true
  has_one :user, through: :dfg

  def name
    "name_of_#{id}"
  end
end
