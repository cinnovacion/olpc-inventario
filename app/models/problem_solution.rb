#     Copyright Paraguay Educa 2009
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>
# 
# 

# # #
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 
# 2009
# # #
                                                                         
class ProblemSolution < ActiveRecord::Base
  belongs_to :solution_type
  belongs_to :solved_by_person, :class_name => "Person", :foreign_key => :solved_by_person_id
  belongs_to :problem_report
  has_many :bank_deposits

  validates_presence_of :solution_type_id, :message => N_("Specify the solution.")
  validates_presence_of :solved_by_person_id, :message => N_("Specify who made the repair.")
  validates_presence_of :problem_report_id, :message => N_("Specify the problem.")

  def self.getColumnas()
    [ 
     {:name => _("Id"),:key => "problem_solutions.id", :related_attribute => "getId", :width => 50},
     {:name => _("Report"),:key => "problem_reports.id", :related_attribute => "getReportId", :width => 50},
     {:name => _("Problem"),:key => "problem_types.name", :related_attribute => "getProblemType", :width => 150},
     {:name => _("Solution"),:key => "solution_types.name", :related_attribute => "getSolutionName()", :width => 150},
     {:name => _("Date"),:key => "problem_solutions.created_at",:related_attribute => "getDate()", :width => 100},
     {:name => _("Comment"),:key => "problem_solutions.comment",:related_attribute => "getComment()", :width => 100},
     {:name => _("Technician"),:key => "people.name",:related_attribute => "getTechnicianName()", :width => 150},
    ]
  end

  def self.getChooseButtonColumns(vista = "")
    ret = Hash.new

    ret["desc_col"] = 0
    ret["id_col"] = 0

    ret
  end

  def self.register_change(attributes, replacement_laptop_serial, bank_deposits_data)

    ProblemSolution.transaction do

      solution_type = SolutionType.find_by_internal_tag("laptop_change")
      problem_solution = ProblemSolution.new(attributes)
      problem_solution.solution_type_id = solution_type.id
      
      if problem_solution.save!
        BankDeposit.register(problem_solution.id, bank_deposits_data)

        owner_laptop = problem_solution.problem_report.laptop
        replacement_laptop = Laptop.find_by_serial_number(replacement_laptop_serial)
        owner = owner_laptop.owner
        replacement_owner = replacement_laptop.owner
        Movement.for_device(owner_laptop, replacement_owner, "devolucion_problema_tecnico_entrega")
        Movement.for_device(replacement_laptop, owner, "entrega_alumno")
      end
    end
  end

  def self.register_simple_solution(impure_attribs, bank_deposits_data)

    ProblemSolution.transaction do

      problem_report = ProblemReport.find_by_id(impure_attribs[:problem_report_id].to_i)
      solution_type = SolutionType.find_by_id(impure_attribs[:solution_type_id].to_i)

      raise _("The number of deposit is required") if !BankDeposit.check(solution_type, bank_deposits_data)
      raise _("Select the type of solution") if !solution_type
      raise _("Specify the number of report") if !problem_report

      attribs = Hash.new
      attribs[:problem_report_id] = problem_report.id
      attribs[:solution_type_id] = solution_type.id
      attribs[:solved_by_person_id] = impure_attribs[:solved_by_person_id]
      attribs[:created_at] = impure_attribs[:created_at]
      attribs[:comment] = impure_attribs[:comment]

      problem_solution = ProblemSolution.new(attribs)
      
      BankDeposit.register(problem_solution.id, bank_deposits_data) if problem_solution.save!
    end

    true
  end

  def before_create
   self.created_at = Time.now
  end

  def after_create

    #Mark the report as solved
    problem_report.solved = true
    problem_report.save!

    #Generating part movements
    PartMovement.registerReplacements(self)

    #Sending email for notification
    extended_data = { 
                      _("Id of the solution:") => id,
                      _("Id of the problem:") => problem_report.id,
                      _("Subject") => solution_type.getName,
                      _("Solved by:") => solved_by_person.getFullName
                    }
    NotificationsPool.register("problem_solution", extended_data, problem_report.place)
  end

  def getId
    self.id.to_s
  end

  def getSolutionName
    self.solution_type_id ? self.solution_type.name : ""
  end

  def getDate()
   self.created_at ? self.created_at.to_s : ""
  end

  def getTechnicianName()
    self.solved_by_person ? self.solved_by_person.getFullName() : ""
  end

  def getComment
    self.comment ? self.comment : ""
  end

  def getReportId
    self.problem_report_id ? self.problem_report.getId : ""
  end

  def getProblemType
    self.problem_report.problem_type.getName
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)

    find_include = [:problem_report => [{:place => :ancestor_dependencies}, :problem_type]]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    ProblemSolution.with_scope(scope) do
      yield
    end

  end

end
