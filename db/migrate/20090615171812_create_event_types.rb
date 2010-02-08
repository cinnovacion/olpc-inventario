class CreateEventTypes < ActiveRecord::Migration
  def self.up
    create_table :event_types do |t|
      t.string :name, :limit => 100
      t.string :description, :limit => 255
      t.string :internal_tag, :limit => 100
    end

   #For now just this event_type, later im adding a full interface for this model.
   attribs = Hash.new
   attribs[:name] = "Laptop Robada"
   attribs[:description] = "Se detecto el intento de activacion de una de las laptops robadas en el School Server"
   attribs[:internal_tag] = "stolen_laptop_activity"
   EventType.create(attribs)

  end

  def self.down
    drop_table :event_types
  end
end
