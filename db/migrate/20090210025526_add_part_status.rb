class AddPartStatus < ActiveRecord::Migration
  def self.up
    Status.transaction do
      Status.create!({:description => "Disponible", :abbrev => "AV", :internal_tag => "available"})
      Status.create!({:description => "Entregado", :abbrev => "US", :internal_tag => "used"})
      Status.create!({:description => "Descompuesto+Irreparable", :abbrev => "B", :internal_tag => "broken"})
    end
  end

  def self.down
  end
end
