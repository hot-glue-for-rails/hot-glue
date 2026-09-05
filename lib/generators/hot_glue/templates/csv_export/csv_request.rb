class CsvRequest < ApplicationRecord
  has_one_attached :file, dependent: :purge_later
  belongs_to :owner, polymorphic: true, optional: true

  validates :status, inclusion: { in: %w[pending processing completed failed] }

  def query_params_as_params
    ActionController::Parameters.new(query_params)
  end
end
