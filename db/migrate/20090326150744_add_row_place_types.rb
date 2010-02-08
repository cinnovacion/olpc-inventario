class AddRowPlaceTypes < ActiveRecord::Migration
  def self.up
    PlaceType.transaction do
      PlaceType.create!({ :name => "Educacion Especial", :internal_tag => "special"} )
      PlaceType.create!({ :name => "Preescolar", :internal_tag => "kinder" } )
    end
  end

  def self.down
  end
end
