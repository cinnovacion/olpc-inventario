class AddRowSectionPlaceType < ActiveRecord::Migration
  def self.up
    PlaceType.transaction do
      PlaceType.create!({ :name => "Seccion", :internal_tag => "section" })
      PlaceType.create!({ :name => "Turno", :internal_tag => "shift" })
    end
  end

  def self.down
  end
end
