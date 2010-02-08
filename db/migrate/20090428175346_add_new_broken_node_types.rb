class AddNewBrokenNodeTypes < ActiveRecord::Migration
  def self.up
    NodeType.transaction do
      NodeType.create!({:name => "Access Point Abajo", :description => "Access Point que actualmente no esta en servicio.", :internal_tag => "ap_down"})
      NodeType.create!({:name => "Servidor Abajo", :description => "Servidor de la escuela que actualmente no esta en servicio.", :internal_tag => "server_down"})
    end
  end

  def self.down
  end
end
