# # #
# Seed Data Generation and Seed Task
#
# Author: Martin Abente - tincho_02@hotmail.com
# For Paraguay Educa OLPC project 2009
#

require 'lib/constraint_generator'

def run_file(filepath)
  require filepath
end

namespace :seed_data do
  desc "Loads initial data schema and constraints"

  task(:install => :environment) do

    if ConstraintGenerator.all_tables == []

      run_file("db/initial_schema.rb")
      puts "db/initial_schema.rb file, loaded!"

      run_file("db/initial_constraints.rb")
      puts "db/initial_constraints.rb file, loaded!"
    end

  end

end

namespace :seed_data do
  desc "Loads seed data"

  task(:setup => :environment) do

    run_file("db/seeds.rb")
    puts "db/seeds.rb file, loaded!"
  end

end

namespace :seed_data do
  desc "Generates the \"db/seeds.rb\" file with data from the esscential models"

  task(:generate => :environment) do

    essential_models = ["event_types", "laptop_configs","models","movement_types","node_types","notifications","part_types","profiles","place_types","statuses"]
    extra_seeds = ["db/non_trivial_seeds.rb"]
    banned_attributes = { "node_types" => ["image_id"] }

    SeedData.generate(essential_models, "db/seeds.rb", extra_seeds, banned_attributes)
    puts "db/seeds.rb file, created!"
  end

end


namespace :seed_data do
  desc "Generates \"db/initial_schema.rb\" and \"db/initial_constraints.rb\" files"

  task(:synthesize => :environment) do

    File.send("copy", "db/schema.rb", "db/initial_schema.rb")
    puts "db/initial_schema.rb file, created!"

    ConstraintGenerator.generate("db/initial_constraints.rb")
    puts "db/initial_constraints.rb file, created!"
  end

end

namespace :seed_data do
  desc "Runs fixes that are idempotent to data"

  task(:fix => :environment) do

    run_file("db/seed_data_fixes.rb")
    puts "db/seed_data_fixes.rb ran perfectly!"
  end

end
