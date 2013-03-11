class PartMovementType < ActiveRecord::Base
  attr_accessible :name, :description, :internal_tag, :direction

  FIELDS = [ 
    {name: _("Id"), column: :id},
    {name: _("Name"), column: :name},
    {name: _("Description"), column: :description, width: 255},
    {name: _("Internal Tag"), column: :internal_tag},
    {name: _("Direction"), column: :direction, attribute: :getDirection},
  ]

  def getDirection
    self.direction ? _("Entry") : _("Departure")
  end

end
