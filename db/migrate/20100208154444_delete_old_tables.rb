require 'db_util'

class DeleteOldTables < ActiveRecord::Migration
  extend DbUtil
  @dropable_tables =[
    "activations",
    "answers", 
    "batteries", 
    "box_movement_details",
    "box_movements",
    "boxes",
    "choices",
    "copia",
    "chargers",
    "options",
    "parts",
    "people_profiles",
    "questions",
    "quizzes",
    "relationships",
    "teaches"
  ]

  def self.up

    @dropable_tables.each { |dropable_table|
        ActiveRecord::Base.connection.tables.each { |table|

          constraints = find_constraints(table)
          constraints.each { |constraint|

            if constraint[:table] == dropable_table
              removeConstraint(table.to_s, constraint[:foreign_key].to_s)
            end
          }
        }
        drop_table dropable_table.to_sym

    }
  end

  def self.down
  end

  def self.find_constraints(table)

    list = Array.new

    results = ActiveRecord::Base.connection.execute("select * from information_schema.key_column_usage where table_schema = schema() and table_name = \"#{table}\"")
   results.each { |row|
      table = row[10]
      foreign_key = row[6]
      list.push({ :table => table, :foreign_key => foreign_key }) if table && foreign_key
    }
 
    list
  end

end
