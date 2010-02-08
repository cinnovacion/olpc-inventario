class AddTransferMovementType < ActiveRecord::Migration
  def self.up
    MovementType.create({ :description => "Transferencia", :internal_tag => "transfer" })
  end

  def self.down
  end
end
