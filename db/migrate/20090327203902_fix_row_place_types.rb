class FixRowPlaceTypes < ActiveRecord::Migration
  def self.up
    PlaceType.transaction do
      type = PlaceType.find_by_internal_tag("fourth_grade")
      type.name = "Cuarto Grado"
      type.save!
    end
  end

  def self.down
  end
end
