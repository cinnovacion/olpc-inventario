# # # # #
#   WARNING:
#   Fix scripts must be idempotent, because every script will 
#   be executed everytimes the system its installed or updated
#
#   Author: Martin Abente (tch) - tincho_02@hotmail.com | mabente@paraguayeduca.org
#   For Paraguay Educa OLPC Deployment
#


# WARNING: all methods identifiers must start with "fix_"
class SeedDataFixes

  def fix_barcode_for_everyone
    Person.find(:all, :conditions => ["people.barcode is NULL"]).each { |person| person.save }
    true
  end


  def fix_repeated_problem_reports

    # First is going to fix all the problem reports that already has solutions
    # but has been manually checked as unsolved.
    pre_cond = ["problem_reports.solved = ?", false]
    pre_include = [:problem_report]

    ProblemSolution.find(:all, :conditions => pre_cond, :include => pre_include).each { |problem_solution|

      inconsistant_report = problem_solution.problem_report
      inconsistant_report.solved = true
      inconsistant_report.save
    }

    # Secondly is going to detect all repeated problem reports and delete them
    ProblemReport.find(:all, :order => "problem_reports.id DESC").each { |problem_report|

      id = problem_report.id
      created_at = problem_report.created_at
      laptop_serial = problem_report.laptop.serial_number
      problem_type_tag = problem_report.problem_type.internal_tag

      inc = [:laptop, :problem_type]
      cond = [""]

      #It can only delete older ones because, theres no way to know if the newest one
      #are repeated entries or they are real new entries, in case the older one is solved.
      cond[0] += "problem_reports.id < ? and "
      cond[0] += "problem_reports.created_at <= ? and "
      cond[0] += "laptops.serial_number = ? and "
      cond[0] += "problem_types.internal_tag = ? and "
      cond[0] += "problem_reports.solved = ?"

      cond.push(id)
      cond.push(created_at)
      cond.push(laptop_serial)
      cond.push(problem_type_tag)
      cond.push(false)

      repeated_not_solved = ProblemReport.find(:all, :conditions => cond, :include => inc).collect(&:id)
      #puts "For #{id} deleting #{repeated_not_solved.join(',')}!" if repeated_not_solved != []
      ProblemReport.destroy(repeated_not_solved)
    }
    true
  end

  def fix_profile_permissions
    # Profile permissions were previously attempted to be added by migrations,
    # but the migrations were wrong and did not add anything.
    # As we may be dealing with existing installations, we cannot add these
    # permissions through seed_data (as we cannot reserve id numbers).
    # Add them here.
    permissions = []
    permissions.push({ "name" => "Nodes", "methods" => [ "show", "up", "down"] })
    Profile.find_by_internal_tag("extern_system").register_update({}, permissions)

    permissions = []
    permissions.push({ "name" => "People", "methods" => [ "search", "do_search","search_options", "new" ] } )
    permissions.push({ "name" => "Laptops", "methods" => [ "search", "do_search","search_options", "new" ] } )
    permissions.push({ "name" => "Places", "methods" => [ "search", "do_search","search_options", "new" ] } )
    Profile.find_by_internal_tag("guest").register_update({}, permissions)
  end

end

fixes = SeedDataFixes.new
fixes.methods.each { |method| fixes.send(method) if method.match("^fix_") }

