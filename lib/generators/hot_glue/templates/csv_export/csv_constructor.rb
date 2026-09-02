require "csv"

class CsvConstructor
  def initialize(controller_name:, params:, owner: nil)
    @controller_class = controller_name.to_s.constantize
    @params = params
    @owner = owner
  end

  def relation
    @relation ||= begin
      plural = @controller_class.name.underscore.sub(/_controller$/, "")
      _, relation = if @controller_class.respond_to?(:csv_export_scope)
        @controller_class.public_send("load_all_#{plural}_query", params: @params, scope: @controller_class.csv_export_scope(@owner))
      else
        @controller_class.public_send("load_all_#{plural}_query", params: @params)
      end
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
      relation.find_each { |record| csv << columns.map { |c| format_value(record, c) } }
    end
  end

  def build_xlsx
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: "Export") do |sheet|
      sheet.add_row columns.map(&:humanize)
      relation.find_each { |record| sheet.add_row columns.map { |c| format_value(record, c) } }
    end
    package.to_stream.read
  end

  def format_value(record, column)
    value = record[column]
    if time_column?(column) && value.respond_to?(:strftime)
      value.strftime("%H:%M:%S")
    else
      value
    end
  end

  def time_only_columns
    @time_only_columns ||= relation.klass.columns_hash.select { |_, c| c.type == :time }.keys
  end

  def time_column?(column)
    time_only_columns.include?(column.to_s)
  end
end
