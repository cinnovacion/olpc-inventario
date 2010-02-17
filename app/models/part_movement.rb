class PartMovement < ActiveRecord::Base
  belongs_to :part_movement_type
  belongs_to :part_type
  belongs_to :place
  belongs_to :person


  def self.getColumnas()
    [ 
     {:name => "Id", :key => "part_movements.id", :related_attribute => "id", :width => 100},
     {:name => "Movimiento", :key => "part_movement_types.name", :related_attribute => "getPartMovementTypeName", :width => 100},
     {:name => "Parte", :key => "part_types.description", :related_attribute => "getPartTypeDescription", :width => 255},
     {:name => "Cantidad", :key => "part_movements.amount", :related_attribute => "getAmount", :width => 100},
     {:name => "Responsable (CI)", :key => "people.id_document", :related_attribute => "getResponsibleIdDoc", :width => 100},
     {:name => "Fecha", :key => "part_movements.created_at", :related_attribute => "getCreatedAt", :width => 100}
    ]
  end

  def self.registerReplacements(problem_solution)

    attribs = {}
    attribs[:part_movement_type_id] = PartMovementType.find_by_internal_tag("part_replacement_out").id
    attribs[:person_id] = problem_solution.solved_by_person.id    
    attribs[:place_id] = problem_solution.problem_report.place.id
    problem_solution.solution_type.part_types.each { |part_type|
      attribs[:amount] = 1
      attribs[:part_type_id] = part_type.id
      attribs[:created_at] = problem_solution.created_at if problem_solution.created_at
      PartMovement.create!(attribs)
    }
  end

  def self.registerTransfer(attribs, from_place_id, to_place_id)

    part_movement_type_out_id = PartMovementType.find_by_internal_tag("part_transfered_out").id
    part_movement_type_in_id = PartMovementType.find_by_internal_tag("part_transfered_in").id

    attribs[:place_id] = from_place_id
    attribs[:part_movement_type_id] = part_movement_type_out_id
    PartMovement.create!(attribs)

    attribs[:place_id] = to_place_id
    attribs[:part_movement_type_id] = part_movement_type_in_id
    PartMovement.create!(attribs)
  end

  def before_save
    self.created_at = Time.now if !self.created_at
  end

  def getPartMovementTypeName
    self.part_movement_type ? self.part_movement_type.getName : ""
  end

  def getPartTypeDescription
    self.part_type ? self.part_type.getDescription : ""
  end

  def getAmount
    self.amount ? self.amount.to_s : "?"
  end

  def getResponsibleIdDoc
    self.person ? self.person.getIdDoc : ""
  end

  def getCreatedAt
    self.created_at ? self.created_at : ""
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)

    find_include = [{:place => :ancestor_dependencies}]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    PartMovement.with_scope(scope) do
      yield
    end
  end

end