class Ghi < ApplicationRecord

  belongs_to :dfg

  def name
    "name_of_#{id}"
  end
end