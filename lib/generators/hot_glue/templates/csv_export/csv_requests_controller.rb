class CsvRequestsController < ApplicationController
  def download
    csv_request = CsvRequest.find(params[:id])
    csv_request.update!(downloaded_at: Time.current)
    DestroyCsvRequestJob.set(wait: 5.minutes).perform_later(csv_request.id)
    redirect_to rails_blob_path(csv_request.file, disposition: "attachment")
  end
end
