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
  belongs_to :src_part, :class_name => "Part", :foreign_key => :src_part_id
  belongs_to :dst_part, :class_name => "Part", :foreign_key => :dst_part_id
  belongs_to :problem_report
  has_many :bank_deposits

  validates_presence_of :solution_type_id, :message => "Debe especificar la solucion."
  validates_presence_of :solved_by_person_id, :message => "Debe especificar quien realizo la reparacion."
  validates_presence_of :src_part_id, :message => "Debe especificar la parte reparada."

  def self.getColumnas()
    [ 
     {:name => "Id",:key => "problem_solutions.id", :related_attribute => "getId", :width => 50},
     {:name => "Reporte",:key => "problem_reports.id", :related_attribute => "getReportId", :width => 50},
     {:name => "Problema",:key => "problem_types.name", :related_attribute => "getProblemType", :width => 150},
     {:name => "Solucion",:key => "solution_types.name", :related_attribute => "getSolutionName()", :width => 150},
     {:name => "Fecha",:key => "problem_solutions.created_at",:related_attribute => "getDate()", :width => 100},
     {:name => "Comentario",:key => "problem_solutions.comment",:related_attribute => "getComment()", :width => 100},
     {:name => "Tecnico",:key => "people.name",:related_attribute => "getTechnicianName()", :width => 150},
     {:name => "Parte",:key => "part_types.description",:related_attribute => "getPartType()", :width => 80},
     {:name => "#Serial Reportado", :key => "parts.on_device_serial", :related_attribute => "getRepairedSerial()", :width => 120},
     {:name => "#Serial Repuesto", :key => "dst_parts_problem_solutions.on_device_serial", :related_attribute => "getReplacementSerial()", :width => 120}
    ]
  end

  def self.getChooseButtonColumns(vista = "")
    ret = Hash.new

    ret["desc_col"] = 0
    ret["id_col"] = 0

    ret
  end

  def self.register_quick_solution(problem_type_id, laptop_srl, solution_type_id, replacement_laptop_srl, technician, comment, bank_deposits_data)

    problem_type = ProblemType.find_by_id(problem_type_id)
    laptop = Laptop.find_by_serial_number(laptop_srl)
    solution_type = SolutionType.find_by_id(solution_type_id)
    replacement_laptop = Laptop.find_by_serial_number(replacement_laptop_srl)

    raise "La informacion provista no es suficiente." if !(problem_type && laptop && solution_type && technician)

    ProblemReport.transaction do

      problem_report = ProblemReport.new({ :problem_type_id => problem_type.id, :laptop_id => laptop.id, :person_id => technician.id, :comment => comment })
      raise "Error del sistema al crear el reporte, contacte su administrador." if !problem_report.save!

      impure_attribs = {
                         :solved_by_person_id => technician.id,
                         :replacement_laptop_serial => replacement_laptop_srl,
                         :created_at => Time.now,
                         :problem_report_id => problem_report.id,
                         :solution_type_id => solution_type.id,
                         :comment => comment
                       }
      ProblemSolution.register_simple_solution(impure_attribs, bank_deposits_data)
    end

  end

  def self.register_change(part_type_id, problem_report_id, orig_dev_srl, rep_dev_srl, technician, comment, bank_deposits_data)

    part_type = PartType.find_by_id(part_type_id)
    problem_report = ProblemReport.find_by_id(problem_report_id)

    dev_tag = part_type.internal_tag
    classname = dev_tag.camelize.constantize

    orig_dev = classname.find_by_serial_number(orig_dev_srl)
    rep_dev = classname.find_by_serial_number(rep_dev_srl)

    if rep_dev.class == Laptop and (rep_dev.is_ghost || orig_dev.is_ghost)
      raise "No se puede se puede intercambiar un dispositivo fantasma"
    end

    ProblemSolution.transaction do
      if part_type && problem_report

        change_solution_type = SolutionType.find_by_internal_tag(dev_tag+"_change")
        raise "No existe el tipo solucion #{dev_tag}_change" if !change_solution_type

        raise "Se requiere el numero de deposito" if !BankDeposit.check(change_solution_type, bank_deposits_data)

        laptop = problem_report.laptop
        owner = laptop.owner
        
        if !orig_dev
          orig_dev = classname.new({ :serial_number => orig_dev_srl, :owner_id => owner.id })
          orig_dev.save!
        end
        orig_dev_prt = Part.send("find_by_"+dev_tag+"_id_and_part_type_id", orig_dev.id, part_type.id)
        if !orig_dev_prt
          orig_dev_prt = Part.new({ :part_type_id => part_type.id, :on_device_serial => orig_dev_srl, (dev_tag+"_id").to_sym => orig_dev.id })
          orig_dev_prt.save!
        end

        if !rep_dev
          rep_dev = classname.new({ :serial_number => rep_dev_srl, :owner_id => technician.id })
          rep_dev.save!
        end
        rep_dev_prt = Part.send("find_by_"+dev_tag+"_id_and_part_type_id", rep_dev.id, part_type.id)
        if !rep_dev_prt
          rep_dev_prt = Part.new({ :part_type_id => part_type.id, :on_device_serial => rep_dev_srl, (dev_tag+"_id").to_sym => rep_dev.id })
          rep_dev_prt.save!
        end

        raise "La parte de repuesto no esta completamente disponible" if !Part.isValidReplacement?(rep_dev)

        attribs = Hash.new
        attribs[:problem_report_id] = problem_report.id
        attribs[:solved_by_person_id] = technician.id
        attribs[:src_part_id] = orig_dev_prt.id
        attribs[:dst_part_id] = rep_dev_prt.id
        attribs[:solution_type_id] = change_solution_type.id
        attribs[:comment] = comment
      
        problem_solution = ProblemSolution.new(attribs)
        problem_solution.save!

        BankDeposit.register(problem_solution.id, bank_deposits_data)
      else
        raise "Informacion faltante"
      end

    end

    true
  end

  def self.register_simple_solution(impure_attribs, bank_deposits_data)

    ProblemSolution.transaction do

      problem_report = ProblemReport.find_by_id(impure_attribs[:problem_report_id].to_i)
      solution_type = SolutionType.find_by_id(impure_attribs[:solution_type_id].to_i)
      part_type = solution_type.part_type

      raise "Se requiere el numero de deposito" if !BankDeposit.check(solution_type, bank_deposits_data)

      # Mandatory controls
      if !solution_type
        raise "Debe seleccionar el tipo de solucion."
      end

      if !problem_report
        raise "Debe especificar el numero del reporte."
      end
      laptop = problem_report.laptop

      banned_type_tags = ["battery","charger", "laptop"]
      if part_type && banned_type_tags.include?(part_type.internal_tag)
        error_str = "Esta ventana es exclusiva para soluciones que no requieren partes"
        error_str += " o cuyas partes son deducibles de la laptop #{laptop.getSerialNumber}, " 
        error_str += "para cambios de partes tipo #{banned_type_tags.join(',')} debe utilizar la ventana de cambios."
        raise error_str
      end

      #The Magic begins x.x
      part_type_tag = part_type ? part_type.internal_tag : "laptop"

      src_part = Part.findPart(laptop, part_type_tag)
      src_part = Part.register_part(laptop, "used", part_type_tag) if !src_part

      dst_part = nil
      if solution_type.requirePart

        replacement_laptop = Laptop.find_by_serial_number(impure_attribs[:replacement_laptop_serial])
        raise "La Laptop #{impure_attribs[:replacement_laptop_serial]} de cual proviene el respuesto no existe." if !replacement_laptop

        isUsedMainPart = Part.findPart(replacement_laptop, "laptop", "used")
        raise "La Laptop de la cual se extrae el respuesto no se encuentra disponible" if isUsedMainPart

        dst_part = Part.findPart(replacement_laptop, part_type_tag, "available")
        if !dst_part

          control_dst_part = Part.findPart(replacement_laptop, part_type_tag)
          raise "La parte correspondiente a #{replacement_laptop.getSerialNumber} no se encuentra disponible."  if control_dst_part || replacement_laptop.is_ghost
          dst_part = Part.register_part(replacement_laptop, "available", part_type_tag)
        end
  
      end

      attribs = Hash.new
      attribs[:problem_report_id] = problem_report.id
      attribs[:solution_type_id] = solution_type.id
      attribs[:solved_by_person_id] = impure_attribs[:solved_by_person_id]
      attribs[:src_part_id] = src_part.id
      attribs[:dst_part_id] = dst_part.id if dst_part
      attribs[:created_at] = impure_attribs[:created_at]
      attribs[:comment] = impure_attribs[:comment]

      problem_solution = ProblemSolution.new(attribs)
      problem_solution.save!

      BankDeposit.register(problem_solution.id, bank_deposits_data)
    end

    true
  end

  def before_create

   #Hard Core control.
   solution_type = SolutionType.find_by_id(self.solution_type_id)
   if solution_type.requirePart
     raise "Debe especificar ambas partes!" if !(self.dst_part && self.src_part)
     raise "Parte de reemplazo no corresponde!" if self.dst_part.part_type != solution_type.part_type
     raise "Parte reemplazada no corresponde!" if self.src_part.part_type != solution_type.part_type
     raise "La parte de reemplazo no se encuentra disponible!" if self.dst_part.status.internal_tag != "available" 
   end

    self.created_at = Time.now if !self.created_at
  end

  ###
  # To make it understandable:
  # device => (Laptop, Battery, Charger)
  # main part => device's part with device's part type
  # part => the part being exchanged
  # ? => In some cases, main_part equals to part 
  def after_create

    #Mark the report as solved
    problem_report.solved = true
    problem_report.save!

    #Part exchange update
    if self.solution_type.requirePart

      broken_status = Status.find_by_internal_tag("broken")
      used_status = Status.find_by_internal_tag("used")
      ripped_status = Status.find_by_internal_tag("ripped")

      src_dev = src_part.getParent
      src_owner = src_dev.owner

      dst_dev = dst_part.getParent
      dst_owner = dst_dev.owner

      # When the main_part are exchanged, it has to update the its devices also,
      # and we need to create in/out movements for the inventory module.
      if src_part.isMainPart?

        Movement.for_device(src_dev, dst_dev.owner, "devolucion_problema_tecnico_entrega")
        Movement.for_device(dst_dev, src_dev.owner, "entrega_alumno")

        src_part.setMainPartAs!(broken_status)
        dst_part.setMainPartAs!(used_status) #Movements side effects do this already!
      else

        Part.swaps!(src_part, dst_part, broken_status, used_status)
        src_part.setMainPartAs!(ripped_status)
      end

    end

    #Sending email for notification
    extended_data = { 
                      "Id de la solucion:" => id,
                      "Id del problema:" => problem_report.id,
                      "subject" => solution_type.getName,
                      "Solucionado por:" => solved_by_person.getFullName
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

  def getPartType()
    self.solution_type.part_type_id ? self.solution_type.part_type.getDescription : "Laptop"
  end

  def getComment
    self.comment ? self.comment : ""
  end

  def getReportId
    self.problem_report_id ? self.problem_report.getId : ""
  end

  def getRepairedSerial
    self.src_part ? self.src_part.getParentSerial : ""
  end

  def getReplacementSerial
    self.dst_part ? self.dst_part.getParentSerial : ""
  end

  def getProblemType
    self.problem_report.problem_type.getName
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)

    find_include = [:problem_report => [{:owner => {:performs => {:place => :ancestor_dependencies}}}, :problem_type]]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    ProblemSolution.with_scope(scope) do
      yield
    end

  end

end
