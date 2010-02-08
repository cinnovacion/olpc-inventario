class AddNodeDownEventType < ActiveRecord::Migration
  def self.up
    EventType.create({ :name  => "Nodo Caido", :description => "Un nodo entro en estado de inactividad", :internal_tag => "node_down"})
  end

  def self.down
  end
end
