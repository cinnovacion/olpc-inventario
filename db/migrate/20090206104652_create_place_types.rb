class CreatePlaceTypes < ActiveRecord::Migration
  def self.up
    create_table :place_types do |t|
      t.string :name, :limit => 100
      t.string :internal_tag, :limit => 100
    end

    PlaceType.transaction do
      PlaceType.create!({:name => "Pais", :internal_tag => "country"})
      PlaceType.create!({:name => "Departamento", :internal_tag => "state"})
      PlaceType.create!({:name => "Ciudad", :internal_tag  => "city"})
      PlaceType.create!({:name => "Escuela", :internal_tag => "school"})
    end

  end

  def self.down
    drop_table :place_types
  end
end
