class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :dfgs
  has_many :xyzs

  has_many :ghis, through: :dfgs

  belongs_to :family

  def to_label
    email
  end
end
