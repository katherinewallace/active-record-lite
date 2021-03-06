require_relative '04_associatable'

module Associatable

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      source_table = source_options.model_class.table_name
      through_table = through_options.model_class.table_name
      join_key_name = source_options.primary_key
      sql = <<-SQL
        SELECT #{source_table}.*
        FROM #{through_table}
        JOIN #{source_table}
          ON #{through_table}.#{join_key_name} =
        #{source_table}.#{source_options.primary_key}
        WHERE #{through_table}.#{through_options.primary_key} = ?
      SQL
      results = DBConnection.execute(sql, self.send(through_options.foreign_key))
      source_options.model_class.parse_all(results)[0]
    end
  end
end
