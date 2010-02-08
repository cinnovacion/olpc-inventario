class AddProblemTypes < ActiveRecord::Migration
  def self.up
     ProblemType.transaction do
       ProblemType.create!({:description => "Cambio de laptop", :internal_tag => "laptop_change"})
       ProblemType.create!({:description => "Cambio de bateria", :internal_tag => "battery_change"})
       ProblemType.create!({:description => "Cambio de cargador", :internal_tag => "charger_change"})
     end
  end

  def self.down
  end
end
