class CreatePartTypes < ActiveRecord::Migration
  def self.up
    create_table :part_types do |t|
      t.string :description, :limit => 255
      t.string :internal_tag, :limit => 100
    end

    PartType.transaction do
      PartType.create!({:description => "Laptop", :internal_tag => "laptop"})
      PartType.create!({:description => "Bateria", :internal_tag => "battery"})
      PartType.create!({:description => "Cargador", :internal_tag => "charger"})
      PartType.create!({:description => "Pantalla", :internal_tag => "screen"})
      PartType.create!({:description => "Teclado", :internal_tag => "keyboard"})
    end

  end

  def self.down
    drop_table :part_types
  end
end
