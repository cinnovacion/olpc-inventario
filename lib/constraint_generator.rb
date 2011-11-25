# # # #
#  Constraint Generator:
#
#  Author: Martin Abente - tincho_02@hotmail.com
#  For Paraguay Educa OLPC project 2009
#
#  WARNING: Mysql support only

class ConstraintGenerator

  DEFAULT_OUTPUT = Rails.root.join("constraints_#{Date.today.to_s}.rb")

  def self.generate(filepath)

    output = File.new(filepath, "w")
    append_script(output, "lib/constraint_generator_ext.rb")
   
    output.write("\n\t######\n\t#  Structural Constraints\n\t#\n")
    all_tables.each { |table|

      find_constraints(table).each { |constraint|

        output.write("\tadd_constraint(\"#{table}\", \"#{constraint[:foreign_key]}\", \"#{constraint[:table]}\" )\n")
      }
    }

    output.close
  end

  #####
  #  Gets all the tables from the current database
  #
  def self.all_tables

    tables = Array.new

    results = ActiveRecord::Base.connection.execute("show tables")
    while (row = results.fetch_row) do

      tables.push(row[0])
    end

    tables
  end

  private

  ##
  # Gets from MySQL information schema table's constraints
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

  ####
  #  Appends external scripts
  #
  def self.append_script(output, script_path)

    script = File.open(script_path,"r")

    script_code = script.readlines.join
    script.close

    output.write(script_code)
  end

end
