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
                                                                        
class SolutionType < ActiveRecord::Base
  has_many :problem_solutions
  has_many :solution_type_part_types
  has_many :part_types, :through => :solution_type_part_types, :source => :part_type

  validates_uniqueness_of :internal_tag, :message => "El tag debe ser unico"

  def self.getColumnas()
    [ 
      {:name => "Id", :key => "solution_types.id", :related_attribute => "id", :width => 50},
      {:name => "Nombre", :key => "solution_types.name", :related_attribute => "getName()", :width => 200},
      {:name => "Descripcion", :key => "solution_types.description", :related_attribute => "getDescription()", :width => 360},
      {:name => "Tag", :key => "solution_types.name", :related_attribute => "getInternalTag()", :width => 200},
      {:name => "Requiere Parte", :key => "solution_types.part_type_id", :related_attribute => "getPartType()", :width => 200}
    ]
  end

  def self.register(attributes, part_type_ids)

    SolutionType.transaction do

      solution_type = SolutionType.new(attributes)
      if solution_type.save!
        solution_type.register_parts_association(part_type_ids)
      end
    end
  end

  def self.unregister(solution_type_ids)

    SolutionType.transaction do
      part_associations = SolutionTypePartType.find_all_by_solution_type_id(solution_type_ids)
      SolutionTypePartType.delete(part_associations.collect(&:id))
      SolutionType.delete(solution_type_ids)
    end
  end

  def register_update(attributes, part_type_ids)

    SolutionType.transaction do

      #update attributes
      self.update_attributes(attributes)

      #Deleting associations
      SolutionTypePartType.destroy(self.solution_type_part_types)

      #Adding new associations
      self.register_parts_association(part_type_ids)
    end
  end

  def register_parts_association(part_type_ids)

    part_type_ids.each { |part_type_id| 
      SolutionTypePartType.create!({ :solution_type_id => self.id, :part_type_id => part_type_id })
    }
  end

  def getName
    self.name ? self.name : ""
  end

  def getDescription
    self.description ? self.description : ""
  end

  def getExtInfo
    self.extended_info ? self.extended_info : ""
  end

  def getInternalTag
    self.internal_tag ? self.internal_tag : ""
  end

  def requirePart
    self.part_types != [] ? true : false
  end

end
