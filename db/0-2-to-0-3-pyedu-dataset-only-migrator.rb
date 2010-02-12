# # #
# This scripts exists only for Paraguay Educa data set 
# concerning inventory version migration from 0.2 to 0.3
#
# Author: Martin Abente | mabente@paraguayeduca.org

def clean_movements
  cond = ["movement_details.laptop_id is NULL"]

    to_delete_details_ids = MovementDetail.find(:all, :conditions => cond).collect(&:id)
    MovementDetail.delete(to_delete_details_ids)

    Movement.all.each { |movement| 
      Movement.delete(movement.id) if movement.movement_details.length < 1
    }

    true
end

def clean_statuses
  to_delete_tags = ["broken", "used", "available", "ripped"]

  cond = ["statuses.internal_tag in (?)", to_delete_tags]
  to_delete_statuses_ids = Status.find(:all, :conditions => cond).collect(&:id)

  cond = ["status_changes.previous_state_id in (?) or status_changes.new_state_id in (?)", to_delete_statuses_ids, to_delete_statuses_ids]
  to_delete_changes_ids = StatusChange.find(:all, :conditions => cond).collect(&:id)
  StatusChange.delete(to_delete_changes_ids)

  Status.delete(to_delete_statuses_ids)

  true
end

def clean_part_types
  to_delete_tags = ["laptop"]

  cond = ["part_types.internal_tag in (?)", to_delete_tags]
  to_delete_part_types = PartType.find(:all, :conditions => cond)
  
  PartType.delete(to_delete_part_types.collect(&:id))

  true
end

def create_solution_part_association

  SolutionTypePartType.create!({ :solution_type_id => 2, :part_type_id => 2 })
  SolutionTypePartType.create!({ :solution_type_id => 6, :part_type_id => 3 })
  SolutionTypePartType.create!({ :solution_type_id => 10, :part_type_id => 5 })
  SolutionTypePartType.create!({ :solution_type_id => 15, :part_type_id => 3 })
  SolutionTypePartType.create!({ :solution_type_id => 1, :part_type_id => 4 })

  true
end

def create_part_movements

  ProblemSolution.all.each { |problem_solution|
    PartMovement.registerReplacements(problem_solution)
  }

  true
end

clean_movements
clean_statuses
clean_part_types
create_solution_part_association
create_part_movements
