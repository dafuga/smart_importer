module SmartImporter
  class Spreadsheet
    def initialize(sheet:, model:, key_attribute:)
      @sheet = sheet
      @key_attribute = key_attribute
      @number_imports = 0
      @looking_at_row = 1
      @model = model
    end

    def import_objects(added_attributes: {})
      ((right_header_row + 1)..@sheet.last_row).each do |i|
        unless @sheet.row(i).empty?
          row = Hash[[@sheet.row(right_header_row), @sheet.row(i)].transpose]
          if active_record = @model.where(name: row['name']).try(:first)
            active_record.update(valid_attributes(row))
          else
            @model.create(valid_attributes(row))
          end
        end
        @number_imports += 1
      end
      @number_imports
    end

    private

    def right_header_row
      until valid_header_line?
        @looking_at_row += 1
        raise "#{@sheet.last_row} sheet does not appear to have any relevant information." if sheet_is_invalid?
      end
      @looking_at_row
    end

    def sheet_is_invalid?
      @looking_at_row == 10
    end

    def valid_header_line?
      @sheet.row(@looking_at_row).any?{|cell| @model.column_names.include?(cell.to_s.underscore.try(:to_sym))}
    end

    def valid_attributes(row)
      formatted_row = {}
      row.each {|key, value| formatted_row[key.downcase.gsub(' ', '_').to_sym] = value if key.present? }
      attribute_keys = @model.column_names.collect(&:to_sym) & formatted_row.keys
      formatted_row.with_indifferent_access.slice(*attribute_keys) || {}
    end
  end
end