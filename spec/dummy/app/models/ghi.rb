class Ghi < ApplicationRecord

  belongs_to :def

  def name
    "name_of_#{id}"
  end
end