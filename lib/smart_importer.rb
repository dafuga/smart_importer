require "smart_importer/version"
require "smart_importer/spreadsheet"
require "roo"

module SmartImporter
  class SpreadsheetImporter
    def initialize(file_path:, entity_type:, key_attribute: id)
      @file_path = file_path
      @entity_type = entity_type
      @xlsx = Roo::Spreadsheet.open(@file_path)
      @number_of_imported_records = 0
      @key_attribute = key_attribute
    end

    def import_all
      import_sheets(1..@xlsx.sheets.count-1)
    end

    def import_sheet(sheet)
      import_sheets(Array(sheet))
    end

    def import_sheets(sheet_array)
      raise 'Import sheets expects an array of sheet numbers.' unless sheet_array.to_a.all? {|i| i.is_a?(Integer) }
      logger = Logger.new(STDOUT)
      logger.info "Importing #{@entity_type.to_s.underscore.pluralize} from #{@file_path}..."
      begin
        import_these_sheets sheet_array
      rescue => exception
       logger.error "Failed to import #{@entity_type} because #{exception}"
      else
        logger.info "Done importing. Imported #{@number_of_imported_records} #{@entity_type.to_s.pluralize}."
      end
    end

    private

    def import_these_sheets(sheet_array)
      @xlsx.sheets.each do |sheet|
        @xlsx.default_sheet = sheet
        spreadsheet = Spreadsheet.new(sheet: @xlsx, entity_type: @entity_type, key_attribute: @key_attribute)
        @number_of_imported_records += (importing_attendees? ? spreadsheet.import_attendees : spreadsheet.import_objects)
        puts @number_of_imported_records
      end
    end

    def importing_attendees?
      @entity_type == IndigitousEventSessionAttendee
    end
  end
end
