class PartMovementType < ActiveRecord::Base

  def self.getColumnas()
    [ 
     {:name => _("Id"), :key => "part_movement_types.id", :related_attribute => "id", :width => 100},
     {:name => _("Name"), :key => "part_movement_types.name", :related_attribute => "getName", :width => 100},
     {:name => _("Description"), :key => "part_movement_types.description", :related_attribute => "description", :width => 255},
     {:name => _("Internal Tag"), :key => "part_movement_types.internal_tag", :related_attribute => "internal_tag", :width => 100},
     {:name => _("Direction"), :key => "part_movement_types.direction", :related_attribute => "getDirection", :width => 100}
    ]
  end

  def getName
    self.name ? self.name : ""
  end

  def getDirection
    self.direction ? _("Entry") : _("Departure")
  end

end
