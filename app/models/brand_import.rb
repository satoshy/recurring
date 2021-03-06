class BrandImport
  # switch to ActiveModel::Model in Rails 4
  include ActiveModel::Model
  attr_accessor :file

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    imported_products.each {|im| puts "--MM #{im.inspect}"}
    if imported_products.map(&:valid?).all?
      imported_products.each(&:save!)
      true
    else
      imported_products.each_with_index do |product, index|
        product.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_products
    @imported_products ||= load_imported_products
  end

  def load_imported_products
    spreadsheet = CSV.read(file.path, :headers => true, :encoding => 'ISO-8859-1')
    # header = spreadsheet[0]
    spreadsheet.map do |row|
      unless Brand.find_by(:prefix => row["prefix"])
        item = Brand.new
        item.attributes = row.to_hash.slice(*Brand.attribute_names())
      else
        item = Brand.find_by(:prefix => row["prefix"])
        id = item.id
        item.attributes = row.to_hash.slice(*Brand.attribute_names())
        item.id = id
      end
      puts "----> #{item.inspect}"
      item
    end
  end

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".csv" then Roo::Spreadsheet.open(file.path, csv_options: {encoding: Encoding::ISO_8859_1})
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

end