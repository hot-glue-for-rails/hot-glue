require "csv"

class CsvConstructor
  def initialize(controller_name:, params:)
    @controller_class = controller_name.to_s.constantize
    @params = params
  end

  def relation
    @relation ||= begin
      plural = @controller_class.name.underscore.sub(/_controller$/, "")
      _, relation = @controller_class.public_send("load_all_#{plural}_query", params: @params)
      relation
    end
  end

  def count
    relation.count
  end

  def columns
    @columns ||= @controller_class::EXPORTABLE_FIELDS
  end

  def build(format)
    format == "xlsx" ? build_xlsx : build_csv
  end

  private

  def build_csv
    CSV.generate do |csv|
      csv << columns.map(&:humanize)
      relation.find_each { |record| csv << columns.map { |c| record[c] } }
    end
  end

  def build_xlsx
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: "Export") do |sheet|
      sheet.add_row columns.map(&:humanize)
      relation.find_each { |record| sheet.add_row columns.map { |c| record[c] } }
    end
    package.to_stream.read
  end
end
