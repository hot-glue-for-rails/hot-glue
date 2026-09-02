class DestroyCsvRequestJob < ApplicationJob
  def perform(csv_request_id)
    CsvRequest.find_by(id: csv_request_id)&.destroy
  end
end
