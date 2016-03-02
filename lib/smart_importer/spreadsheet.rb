module SmartImporter
  class Spreadsheet
    def initialize(sheet:, model:, key_attribute:)
      @sheet = sheet
      @model = model
      @header = @sheet.row(right_header_row) if right_header_row
      @added_objects_count = 0
      @key_attribute = key_attribute
      @current_row = 1
    end

    def import_objects(added_attributes: {})
      return 0 unless valid_sheet?
      ((right_header_row+1)..@sheet.last_row).each do |i|
        row = Hash[[@header, @sheet.row(i)].transpose]
        return 0 if row.empty?
        if active_record = @model.where(@key_attribute => valid_attributes(row)).first
          active_record.update(valid_attributes(row))
        else
          @model.creat(valid_attributes(row))
        end
        sleep 0.1
        @added_objects_count += 1
      end
      return @added_objects_count
    end

    private

    def right_header_row
      until valid_line?
        raise 'Invalid sheet' if sheet_is_invalid?
        @current_row += 1 
      end
    end

    def sheet_is_invalid?
      @current_row == 10
    end

    def valid_line?

    end

    def valid_attributes(row)
      formatted_row = {}
      row.each {|key, value| formatted_row[key.downcase.gsub(' ', '_').to_sym] = value if key.present? }
      attribute_keys = @entity_type.column_names.collect(&:to_sym) & formatted_row.keys
      formatted_row.with_indifferent_access.slice(*attribute_keys) || {}
    end

    def valid_sheet?
      valid_cell?(4, 'Webinar ID') || @entity_type != IndigitousEventSessionAttendee
    end

    def valid_cell?(row, cell_content)
      @sheet.cell('A',row) == cell_content
    end
  end
end