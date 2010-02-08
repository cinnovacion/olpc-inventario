class ExtendSolutionTypeSupportPartControl < ActiveRecord::Migration
  extend DbUtil

  def self.up

    add_column :solution_types, :part_type_id, :integer, :default => nil
    self.createConstraint("solution_types", "part_type_id", "part_types")

    data_list = [["change_screen","screen"], ["battery_change","battery"], ["laptop_change","laptop"], ["charger_change","charger"]]
    data_list.each { |data|

      solution_type = SolutionType.find_by_internal_tag(data[0])
      part_type = PartType.find_by_internal_tag(data[1])

      solution_type.part_type_id = part_type.id
      solution_type.save!

    }

  end

  def self.down

    self.removeConstraint("solution_types", "part_type_id")
    remove_column :solution_types, :part_type_id


  end
end
