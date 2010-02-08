class CreateMovementTypes < ActiveRecord::Migration
  def self.up
    create_table :movement_types do |t|
      t.string :description
    end

    MovementType.create!({:description => "Niño aprendiendo"})
    MovementType.create!({:description => "En reparacion"})
    MovementType.create!({:description => "Desarrollador desarrollando"})
    MovementType.create!({:description => "Py Edu - Uso interno"})
    MovementType.create!({:description => "Demostracion"})

  end

  def self.down
    drop_table :movement_types
  end
end
