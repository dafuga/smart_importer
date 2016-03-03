# SmartImporter

Smart importer allows you to import relevant data from spreadsheets (xlsx or csv) to any of your models with one line of code.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'smart_importer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install smart_importer

## Usage

To import data from a spreadsheet to one of your models, first initiate the Importer object. For example:

```ruby
importer = SmartImporter::Importer.new(file_path: "/path/to/file", model: User, key_attribute: :name)
```

**Where:**

  **file_path:** your file_path

  **model:** the active_record model that you want to fill with relevant data from.

  **key_attribute:** is an optional parameter that you are telling the importer must be unique within all records (Can be useful in some cases although your model validations 
  should normally take care of this.)

and then,

To import all data in sheets from the spreadsheet:

```ruby
importer.import_all
```
or

To import all data in sheets from the nth spreadsheet:

```ruby
importer.import_sheet(n)
```
or

To import all data in sheets from the an array or range array_of_sheets:

```ruby
importer.import_sheets(array_of_sheets)
```

Et Voila!! Smart Importer should have found all relevant fields in the spreadsheet and added it to your database.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/smart_importer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

