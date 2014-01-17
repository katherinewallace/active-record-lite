require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable

  def where(params)
    where_line = params.keys.map { |key| "#{key} = ?"}.join(" AND ")
    sql = <<-SQL
    SELECT *
    FROM #{self.table_name}
    WHERE #{where_line}
    SQL
    results = DBConnection.execute(sql, *params.values)
    self.parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
