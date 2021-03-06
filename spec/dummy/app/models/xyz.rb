class Xyz < ApplicationRecord


  belongs_to :nothing # association does not exist


  belongs_to :user
end
