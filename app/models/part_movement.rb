#     Copyright Paraguay Educa 2009, 2010
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
# Author: Martin Abente - mabente@paraguayeduca.org
#


class PartMovement < ActiveRecord::Base
  belongs_to :part_movement_type
  belongs_to :part_type
  belongs_to :place
  belongs_to :person

  before_save :set_created_at

  def self.getColumnas()
    [ 
     {:name => _("Id"), :key => "part_movements.id", :related_attribute => "id", :width => 100},
     {:name => _("Movement"), :key => "part_movement_types.name", :related_attribute => "getPartMovementTypeName", :width => 100},
     {:name => _("Part"), :key => "part_types.description", :related_attribute => "getPartTypeDescription", :width => 255},
     {:name => _("Amount"), :key => "part_movements.amount", :related_attribute => "getAmount", :width => 100},
     {:name => _("Responsible (CI)"), :key => "people.id_document", :related_attribute => "getResponsibleIdDoc", :width => 100},
     {:name => _("Creation Date"), :key => "part_movements.created_at", :related_attribute => "getCreatedAt", :width => 100}
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

  def set_created_at
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
    scope = includes({:place => :ancestor_dependencies})
    scope = scope.where("place_dependencies.ancestor_id in (?)", places_ids)
    PartMovement.with_scope(scope) do
      yield
    end
  end

end
