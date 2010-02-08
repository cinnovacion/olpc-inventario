class PartMovementType < ActiveRecord::Base

  def self.getColumnas()
    [ 
     {:name => "Id", :key => "part_movement_types.id", :related_attribute => "id", :width => 100},
     {:name => "Nombre", :key => "part_movement_types.name", :related_attribute => "getName", :width => 100},
     {:name => "Descripcion", :key => "part_movement_types.description", :related_attribute => "getDescription", :width => 255},
     {:name => "Tag Interno", :key => "part_movement_types.internal_tag", :related_attribute => "getInternalTag", :width => 100},
     {:name => "Direccion", :key => "part_movement_types.direction", :related_attribute => "getDirection", :width => 100}
    ]
  end

  def getName
    self.name ? self.name : ""
  end

  def getDescription
    self.description ? self.description : ""
  end

  def getInternalTag
    self.internal_tag ? self.internal_tag : ""
  end

  def getDirection
    self.direction ? "Entrada" : "Salida"
  end

end
