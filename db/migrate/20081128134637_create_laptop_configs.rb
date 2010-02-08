class CreateLaptopConfigs < ActiveRecord::Migration

  def self.up
    create_table :laptop_configs do |t|
      t.string :key, :limit => 100
      t.string :value, :limit => 100
      t.string :description, :limit => 100
      t.string :resource_name, :limit => 100
    end
    
    LaptopConfig.create!( { :key => "build_version", :description => "Version SO" } )
    LaptopConfig.create!( { :key => "model_id", :description => "Modelo" } )
    LaptopConfig.create!( { :key => "shipment_id",:description => "Cargamento" } )
    LaptopConfig.create!( { :key => "person_id", :description => "En manos de", :resource_name => "personas" } )
    LaptopConfig.create!( { :key => "place_id", :description => "Localidad" } )

  end

  def self.down
    drop_table :laptop_configs
  end
end
