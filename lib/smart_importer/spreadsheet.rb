module SmartImporter
  class Spreadsheet
    def initialize(sheet:, entity_type:, key_attribute:)
      @sheet = sheet
      @entity_type = entity_type
      @header = @sheet.row(right_header_row) if right_header_row
      @added_objects_count = 0
      @key_attribute = key_attribute
    end

    def import_attendees
      if indigitous_event_session = IndigitousEventSession.find_by(webinar_id: @sheet.cell(5,'A'))
        extra_attributes = {}
        puts indigitous_event_session
        extra_attributes['session:relationship'] = { 
            'indigitous_event_session' => indigitous_event_session.global_registry_id,
            'client_integration_id' => EntityServices::Uuid.new.to_s
          }
        extra_attributes['indigitous_event_session_id'] = indigitous_event_session.id
      end
      return import_objects(added_attributes: extra_attributes || {})
    end

    def import_objects(added_attributes: {})
      return 0 unless valid_sheet?
      ((right_header_row+1)..@sheet.last_row).each do |i|
        row = Hash[[@header, @sheet.row(i)].transpose]
        return 0 if row.empty?
        GlobalRegistryModels::Retryer.new(RestClient::InternalServerError, max_attempts: 2).try do
          if active_record = @entity_type.where(@key_attribute => valid_attributes(row)[:global_registry_id]).first
            EntityServices::Updater.new(active_record: active_record,
                                        update_params: valid_attributes(row).except(:global_registry_id, :id).merge(added_attributes)).update!
          else
            attributes = valid_attributes(row).merge!(added_attributes)
            EntityServices::Creator.new(active_record_class: @entity_type,
                                              create_params: valid_attributes(row).merge(added_attributes)).create!
          end
        end
        sleep 0.1
        @added_objects_count += 1
      end
      return @added_objects_count
    end

    private

    def right_header_row
      if valid_cell?(8, 'Attended')
        8
      elsif valid_cell?(9, 'Attended')
        9
      else
        1
      end
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