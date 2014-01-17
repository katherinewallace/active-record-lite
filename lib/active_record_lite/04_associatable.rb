require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      :foreign_key => "#{name}_id".to_sym,
      :class_name => "#{name.to_s.camelcase}",
      :primary_key => :id
    }
    options = defaults.merge(options)
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      :foreign_key => "#{self_class_name.underscore}_id".to_sym,
      :class_name => "#{name.singularize.camelcase}",
      :primary_key => :id
    }
    options = defaults.merge(options)
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    assoc_options[name] = BelongsToOptions.new(name, options)
    options = assoc_options[name]
    define_method(name) do
      foreign_key = self.send(options.foreign_key)
      model_class = options.model_class
      model_class.where(:id => foreign_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name.to_s, self.name, options)
    define_method(name) do
      primary_key = self.send(options.primary_key)
      foreign_key = options.foreign_key
      model_class = options.model_class
      model_class.where(foreign_key => primary_key)
    end
  end

  def assoc_options
    @assoc_options ||= Hash.new
  end
end

class SQLObject
  extend Associatable
end
