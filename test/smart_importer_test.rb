require 'test_helper'

class SmartImporterTest < Minitest::Test
  def setup
    Model.delete_all
  end

  def test_that_it_has_a_version_number
    refute_nil ::SmartImporter::VERSION
  end

  def test_import_all
    test_method('sample_spreadsheet.csv') do |importer|
      assert importer.import_all
    end
    assert_equal 2, Model.count
  end

  def test_import_sheet
    test_method('sample_spreadsheet.csv') do |importer|
      assert importer.import_sheet(1)
    end
    assert_equal 2, Model.count
  end

  def test_import_sheets_with_existent_data
    Model.create('dob': '17 dec 2000', 'name': 'TestName')
    test_method('second_sample_spreadsheet.csv') do |importer|
      assert importer.import_sheets(1..1)
    end
    assert_equal 3, Model.count
  end

  private

  def test_method(sheet)
    importer = SmartImporter::Importer.new(file_path: "#{Dir.pwd}/test/files/#{sheet}", model: Model, key_attribute: :name)
    silence_stream(STDOUT) do
      yield importer
    end
    assert_equal '17 dec 2000', Model.where(name: 'TestName').first.dob
    assert_equal 'Meredith Palmer', Model.last.name
  end
end