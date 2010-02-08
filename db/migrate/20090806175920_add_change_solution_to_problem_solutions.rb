class AddChangeSolutionToProblemSolutions < ActiveRecord::Migration
  def self.up

    laptop_change = SolutionType.find_by_internal_tag("laptop_change")
    SolutionType.create!({ 
                           :name => "Cambio de Laptop",
                           :description => "Se reemplaza la laptop entera por otra disponible en el stock",
                           :internal_tag => "laptop_change"
                        }) if !laptop_change

    battery_change = SolutionType.find_by_internal_tag("battery_change")
    SolutionType.create!({ 
                           :name => "Cambio de Bateria",
                           :description => "Se reemplaza la bateria por otra disponible en el stock",
                           :internal_tag => "battery_change" 
                         }) if !battery_change

    charger_change = SolutionType.find_by_internal_tag("charger_change")
    SolutionType.create!({ 
                           :name => "Cambio de Cargador",
                           :description => "Se reemplaza el cargador por otro disponible en el stock",
                           :internal_tag => "charger_change" 
                         }) if !charger_change

  end

  def self.down
  end
end
