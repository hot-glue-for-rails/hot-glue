class BuildCsvJob < ApplicationJob
  def perform(csv_request_id)
    csv_request = CsvRequest.find(csv_request_id)
    csv_request.update!(status: "processing")

    constructor = CsvConstructor.new(
      controller_name: csv_request.controller_name,
      params: csv_request.query_params_as_params
    )
    content = constructor.build(csv_request.format)

    csv_request.file.attach(
      io: StringIO.new(content),
      filename: "export-#{csv_request.id}.#{csv_request.format}",
      content_type: csv_request.format == "xlsx" ? "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" : "text/csv"
    )
    csv_request.update!(status: "completed")

    csv_request.broadcast_replace_to(
      csv_request,
      target: "csv_request_#{csv_request.id}",
      partial: "csv_requests/ready",
      locals: { csv_request: csv_request }
    )
  rescue => e
    csv_request&.update!(status: "failed", error_message: e.message)
    csv_request&.broadcast_replace_to(
      csv_request,
      target: "csv_request_#{csv_request.id}",
      partial: "csv_requests/failed",
      locals: { csv_request: csv_request }
    )
    raise
  end
end
