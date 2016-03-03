$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'smart_importer'
require 'minitest/autorun'

class Model
  @@id = 0
  @@list = []
  
  attr_accessor :id, :name, :dob

  def initialize(params)
    @id = @@id += 1
    update_values(params)
  end

  def self.column_names
    [:id, :name, :dob]
  end

  def self.create(params)
    @@list << new(params) if params
  end

  def self.where(params)
    @@list.find_all { |instance|  instance.match(params) }
  end

  def self.first
    @@list.first
  end

  def self.last
    @@list.last
  end

  def self.count
    @@list.count
  end

  def self.delete_all
    @@list = []
  end

  def update(params)
    update_values(params)
  end

  def to_s
    "Model id: #{@id} name: #{@name} dob: #{@dob}"
  end

  def attributes
    { 'id': @id, 'name': @name, 'dob': @dob }
  end

  def match(params)
    (self.class.column_names & params.keys).all? { |attr| attributes[attr] == params[attr] }
  end

  private

  def update_values(params)
    @name = params['name'] || params[:name]
    @dob = params['dob'] || params[:dob]
  end
end
