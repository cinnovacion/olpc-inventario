class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |t|
      t.string :description, :limit => 255
      t.string :abbrev, :limit => 10
      t.string :internal_tag, :limit => 100
    end

   Status.transaction do
	Status.create!({:description => "Dead on arrival", :abbrev => "DOA", :internal_tag => "dead"})
	Status.create!({:description => "Desactivado", :abbrev => "DA", :internal_tag => "deactivated"})
	Status.create!({:description => "Activado", :abbrev => "A", :internal_tag => "activated"})
	Status.create!({:description => "En reparacion", :abbrev => "ER", :internal_tag => "on_repair"})
	Status.create!({:description => "Reparado", :abbrev => "R", :internal_tag => "repaired"})
   end

  end

  def self.down
    drop_table :statuses
  end
end
