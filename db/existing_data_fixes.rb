# Fixes for existing DB content, in order to keep data changes out of
# migrations.
# Must be resilient to being run multiple times on existing data


# Make sure everyone has a barcode
Person.where("barcode is NULL").each { |person| person.save }


# Fix repeated problem reports
# First is going to fix all the problem reports that already has solutions
# but has been manually checked as unsolved.
solutions = ProblemSolution.includes(:problem_report)
solutions = solutions.where("problem_reports.solved = ?", false)
solutions.each { |problem_solution|
  inconsistant_report = problem_solution.problem_report
  inconsistant_report.solved = true
  inconsistant_report.save
}

# Secondly is going to detect all repeated problem reports and delete them
ProblemReport.order("id DESC").each { |problem_report|
  id = problem_report.id
  created_at = problem_report.created_at
  laptop_serial = problem_report.laptop.serial_number
  problem_type_tag = problem_report.problem_type.internal_tag

  #It can only delete older ones because, theres no way to know if the newest one
  #are repeated entries or they are real new entries, in case the older one is solved.
  repeated_not_solved = ProblemReport.includes(:laptop, :problem_type)
  repeated_not_solved = repeated_not_solved.where("problem_reports.id < ? and problem_reports.created_at <= ? and laptops.serial_number = ? and problem_types.internal_tag = ? and problem_reports.solved = ?", id, created_at, laptop_serial, problem_type_tag, false)

  repeated_not_solved = repeated_not_solved.collect(&:id)
  ProblemReport.destroy(repeated_not_solved)
}


# Profile permissions were previously attempted to be added by migrations,
# but the migrations were wrong and did not add anything.
# Add them here.
permissions = []
permissions.push({ "name" => "Nodes", "methods" => [ "show", "up", "down"] })
permissions.push({ "name" => "Places", "methods" => [ "schools_leases" ] } )
permissions.push({ "name" => "Laptops", "methods" => [ "requestBlackList" ] } )
permissions.push({ "name" => "ConnectionEvents", "methods" => [ "report" ] } )
Profile.find_by_internal_tag("extern_system").register_update({}, permissions)

permissions = []
permissions.push({ "name" => "People", "methods" => [ "search", "do_search","search_options", "new" ] } )
permissions.push({ "name" => "Laptops", "methods" => [ "search", "do_search","search_options", "new" ] } )
permissions.push({ "name" => "Places", "methods" => [ "search", "do_search","search_options", "new" ] } )
Profile.find_by_internal_tag("guest").register_update({}, permissions)

# Delete solutions without an associated problem
# This happened because there was no control or constraint
ProblemSolution.all.each { |problem_solution|
  if !problem_solution.problem_report
    BankDeposit.delete(problem_solution.bank_deposits.collect(&:id))
    ProblemSolution.delete(problem_solution.id)
  end
}

# Fixed unassigned laptops
# When it was developed, the assignments controller incorrrectly used 0
# as the person ID value for an unassigned laptop. Fix up those instances.
Assignment.find_all_by_destination_person_id(0).each { |a|
  a.destination_person_id = nil
  a.save!
}
Assignment.find_all_by_source_person_id(0).each { |a|
  a.source_person_id = nil
  a.save!
}
Laptop.find_all_by_assignee_id(0).each { |laptop|
  laptop.assignee_id = nil
  laptop.save!
}


# Migrate laptop statuses
def migrate_status(old_status_tag, new_status_tag)
  status = Status.find_by_internal_tag(old_status_tag)
  new_status = Status.find_by_internal_tag(new_status_tag)

  if status.nil? or new_status.nil?
    return
  end

  Laptop.find_all_by_status_id(status.id).each { |laptop|
    laptop.status_id = new_status.id
    laptop.save!
  }
  StatusChange.find_all_by_previous_state_id(status).each { |ch|
    ch.previous_state_id = new_status.id
    ch.save!
  }
  StatusChange.find_all_by_new_state_id(status).each { |ch|
    ch.new_state_id = new_status.id
    ch.save!
  }
  status.destroy
end

# migrate stolen_deactivated to stolen, and remove stolen_deactivated
# We don't have control of the activation state of stolen laptops
migrate_status("stolen_deactivated", "stolen")

# migrate lost_deactivated to lost and remove lost_deactivated
# We don't have control of the activation state of lost laptops
migrate_status("lost_deactivated", "lost")

# migrate used to activated and remove used
# This was only intended for parts, which inventario no longer tracks
migrate_status("used", "activated")

# migrate available to activated and remove available
# This was only intended for parts, which inventario no longer tracks
migrate_status("available", "activated")

# rename Desactivado to En desuso
# After a lot of discussion we think this much better reflects the use
# of the status: the laptop is available but not being used, so no
# activations should be generated for it.
status = Status.find_by_internal_tag("deactivated")
status.update_attributes(:description => "En desuso") if !status.nil?

# rename Activado to En uso
# After a lot of discussion we think this much better reflects the use
# of the status: the laptop is being used, so we should generate
# activations for it. (It doesn't necessarily mean that such a laptop has
# received an activation and activated itself, though, thats kind of out
# of scope of inventario).
status = Status.find_by_internal_tag("activated")
status.update_attributes(:description => "En uso") if !status.nil?

# Having 3 entrega movement types (student, docente, formador) was
# not necessary (the person type is a separate entity from the movement).
# Simplify all these into a single "Entrega" type, still with the internal
# tag "entrega_alumno" for now.
entrega_type = MovementType.find_by_internal_tag("entrega_alumno")
if !entrega_type.nil?
  mt = MovementType.find_by_internal_tag("entrega_docente")
  if mt
    Movement.find_all_by_movement_type_id(mt.id).each { |movement|
      movement.movement_type_id = entrega_type.id
      movement.save!
    }
    mt.destroy
  end

  mt = MovementType.find_by_internal_tag("entrega_formador")
  if mt
    Movement.find_all_by_movement_type_id(mt.id).each { |movement|
      movement.movement_type_id = entrega_type.id
      movement.save!
    }
    mt.destroy
  end

  entrega_type.description = "Entrega"
  entrega_type.save!
end
