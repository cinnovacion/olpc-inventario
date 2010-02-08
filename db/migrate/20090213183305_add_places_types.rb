class AddPlacesTypes < ActiveRecord::Migration
  def self.up
    PlaceType.transaction do
      PlaceType.create!({:name => "Primer Grado", :internal_tag => "first_grade"})
      PlaceType.create!({:name => "Segundo Grado", :internal_tag => "second_grade"})
      PlaceType.create!({:name => "Tercer Grado", :internal_tag => "third_grade"})
      PlaceType.create!({:name => "Cuatro Grado", :internal_tag => "fourth_grade"})
      PlaceType.create!({:name => "Quinto Grado", :internal_tag => "fifth_grade"})
      PlaceType.create!({:name => "Sexto Grado", :internal_tag => "sixth_grade"})
    end
  end

  def self.down
  end
end
