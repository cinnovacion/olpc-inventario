  
  #####
  #  Basic Methods
  #
  def add_constraint(table, foreign_key, related_table)

    query = "alter table #{table} add CONSTRAINT `#{table}_#{foreign_key}_fk` FOREIGN KEY "
    query += "(`#{foreign_key}`) REFERENCES `#{related_table}` (`id`)"

    ActiveRecord::Base.connection.execute(query)

  end

