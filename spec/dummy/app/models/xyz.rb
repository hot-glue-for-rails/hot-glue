class Xyz < ApplicationRecord


  belongs_to :nothing # association does not exist


  belongs_to :user

  has_many :ghis

  has_many :atw_to_label
  has_many :atw_full_name
  has_many :atw_display_name

  def name
    # "nothing here"
  end
end
