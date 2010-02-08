class AddValuesStatus < ActiveRecord::Migration
  def self.up
   Status.transaction do
	Status.create!({:description => "Robado", :abbrev => "S", :internal_tag => "stolen"})
        Status.create!({:description => "Robado Desactivado", :abbrev => "SDA", :internal_tag => "stolen_deactivated"})
        Status.create!({:description => "Perdido", :abbrev => "L", :internal_tag => "lost"})
        Status.create!({:description => "Perdido Desactivado", :abbrev => "LDA", :internal_tag => "lost_deactivated"})
   end
  end

  def self.down
  end
end
