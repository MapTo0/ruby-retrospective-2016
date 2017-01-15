module DataModelUtilities
  def save
    if self.class.data_store.include? @settings
      update_store
    else
      create_instance_id(self.class)
      self.class.data_store.create(@settings)
    end
    self
  end

  def delete
    if @data_store.include? @settings
      @data_store.delete(@settings)
    else
      raise DataModel::DeleteUnsavedRecordError, 'intance is not saved'
    end
  end

  def ==(entity)
    if self.class == entity.class
      same_attributes = (self.settings.to_a - entity.settings.to_a).empty?
      if same_attributes && (@data_store.include? entity.settings)
        self.id == entity.id
      else
        self.object_id == entity.object_id
      end
    end
  end

  private
  def update_store
    updates = {}
    @attributes.each_key do |key|
      updates[key] = self.send(key)
      @settings[key] = updates[key]
    end
    @data_store.update(@settings[:id], updates)
  end

  def create_instance_id class_name
    @id = class_name.class_variable_get(last_id)
    class_name.last_id += 1
    @settings[:id] = @id
  end
end

module DataModelErrors
  class DeleteUnsavedRecordError < ::StandardError
  end

  class UnknownAttributeError < ArgumentError
    def initialize(attribute_name)
      super "Unknown attribute #{attribute_name}"
    end
  end
end

module DataModelMethods
  def attributes(*attribute_store)
    if attribute_store.empty?
      @attributes.keys
    else
      @attributes = {}
      save_attributes(attribute_store)
    end
  end

  def data_store(store = nil)
    @data_store = store if store
    @data_store
  end

  def where(entities = {})
    result = []
    @data_store.each do |setting|
      if (entities.keys - @attributes.keys).empty?
        if (entities.to_a - setting.to_a).empty?
          result << self.new(setting) && result
        end
      else
        raise DataModel::UnknownAttributeError.new((entities.keys - @attributes.keys)[0])
      end
    end
  end

  def take_attributes
    @attributes
  end

  private
  def save_attributes(attribute_store)
    attribute_store.each_index do |index|
      @attributes[attribute_store[index]] = true
       method_name = ("find_by_" + attribute_store[index].to_s).to_sym
       define_singleton_method(method_name) do |attribute|
         where({ attribute_store[index] => attribute })
       end
    end
  end
end

class DataModel
  include DataModelUtilities
  include DataModelErrors
  @data_store = nil
  @last_id = 1
  attr_accessor :id, :settings
  def initialize(settings = {})
    @settings = settings
    @attributes = self.class.take_attributes
    @attributes.each_key do |key|
      self.class.send(:attr_accessor, key)
      instance_variable_set("@#{key}", settings[key])
    end
    self
  end

  extend DataModelMethods
end

class BaseStore
  include Enumerable
  attr_accessor :store, :id

  def find(hash)
    result = []
    each do |setting|
      result << setting if (hash.to_a - setting.to_a).empty?
    end
    result
  end
end

class ArrayStore < BaseStore
  def initialize
    @store = []
  end

  def each
    @store.each do |member|
      yield(member)
    end
  end

  def include?(hash)
    @store.include? hash
  end

  def create(hash)
    @store.push hash
  end

  def update(id, updates)
    model = @store.select { |model| model[:id] == id }.first
    updates.each_key do |key|
      model[key] = updates[key]
    end
  end
end

class HashStore < BaseStore
  def initialize
    @store = {}
  end

  def each
    @store.each do |_, value|
      yield(value)
    end
  end

  def include?(hash)
    @store[:id] == hash
  end

  def create(hash)
    @store[hash[:id]] = hash
  end

  def update(id, updates)
    model = @store[id.to_sym]
    updates.each_key do |key|
      model[key] = updates[key]
    end
  end
end

class User < DataModel
  attributes :name, :email
  data_store ArrayStore.new
end

record = User.new(name: 'Ivan', email: 'Ivanov')
record.save

expect(User.find_by_name('Ivan').map(&:id)).to eq [record.id]