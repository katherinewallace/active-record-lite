require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end
end

class SQLObject < MassObject
  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.underscore.pluralize
  end

  def self.all
    query = <<-SQL
      SELECT #{@table_name}.*
      FROM #{@table_name}
    SQL
    results = DBConnection.execute(query)
    self.parse_all(results)
  end

  def self.find(id)
    query = <<-SQL
      SELECT #{self.table_name}.*
      FROM #{self.table_name}
      WHERE id = ?
    SQL
    results = DBConnection.execute(query, id)
    self.parse_all(results)[0]
  end

  def insert
    col_names = self.class.attributes.join(",")
    question_marks = (["?"]*(self.class.attributes.length)).join(",")
     sql = <<-SQL
      INSERT INTO #{self.class.table_name}
        (#{col_names})
      VALUES
       (#{question_marks})
     SQL
     DBConnection.execute(sql, *self.attribute_values)
     self.id = DBConnection.last_insert_row_id
  end

  def save
     self.id.nil? ?  self.insert : self.update
  end

  def update
    set_line = self.class.attributes.map { |attr| "#{attr} = ?" }.join(",")
    sql = <<-SQL
      UPDATE #{self.class.table_name}
      SET #{set_line}
      WHERE id = ?
    SQL
    DBConnection.execute(sql, *self.attribute_values, self.id)
  end

  def attribute_values
     self.class.attributes.map { |attr| self.send(attr) }
  end
end
