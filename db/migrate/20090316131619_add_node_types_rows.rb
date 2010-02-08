class AddNodeTypesRows < ActiveRecord::Migration
  def self.up
    NodeType.transaction do
      NodeType.create!({:name => "Centro", :description => "Indica el punto inicial en el cual se enfoca el mapa.", :internal_tag => "center"})
      NodeType.create!({:name => "Access Point", :description => "Punto de accesso a red inalambrica.", :internal_tag => "ap"})
      NodeType.create!({:name => "Servidor", :description => "Servidor de la escuela.", :internal_tag => "server"})
      NodeType.create!({:name => "Torre", :description => "Torre del ISP para distribucion wimax.", :internal_tag => "tower"})
    end
  end

  def self.down
  end
end
