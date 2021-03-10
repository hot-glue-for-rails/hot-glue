class Xyz < ApplicationRecord


  belongs_to :nothing # association does not exist


  belongs_to :user

  def name
    # "nothing here"
  end
end
