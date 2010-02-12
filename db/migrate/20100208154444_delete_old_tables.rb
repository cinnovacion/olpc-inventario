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
    "spare_parts_registries",
    "teaches"
  ]

  def self.up

    @dropable_tables.each { |dropable_table|

      begin
        all_tables.each { |table|

          constraints = find_constraints(table)
          constraints.each { |constraint|

            if constraint[:table] == dropable_table
              removeConstraint(table.to_s, constraint[:foreign_key].to_s)
            end
          }
        }
        drop_table dropable_table.to_sym
      rescue
        puts "Ignoring error related to table #{dropable_table}"  
      end

    }
  end

  def self.down
  end

  def self.all_tables

    tables = Array.new

    results = ActiveRecord::Base.connection.execute("show tables")
    while (row = results.fetch_row) do

      tables.push(row[0])
    end

    tables
  end

  def self.find_constraints(table)

    list = Array.new

    results = ActiveRecord::Base.connection.execute("select * from information_schema.key_column_usage where table_schema = schema() and table_name = \"#{table}\"")
    while (row = results.fetch_row) do

      table = row[10]
      foreign_key = row[6]
      list.push({ :table => table, :foreign_key => foreign_key }) if table && foreign_key
    end
 
    list
  end

end
