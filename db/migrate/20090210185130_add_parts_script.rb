class AddPartsScript < ActiveRecord::Migration
  def self.up

    Part.transaction do
      #Laptops to parts.
      Laptop.find(:all).each { |l|
        
        Part.create!({
                      :status_id => AddPartsScript.partStatus(l.status_id),
                      :part_type_id => 1,
                      :laptop_id => l.id,
                      :owner_id => AddPartsScript.getOwner(l.owner_id)
                     }) if l.parts.length == 0
      }

      #Batteries to parts.
      Battery.find(:all).each { |b|
        Part.create!({
                      :status_id => AddPartsScript.partStatus(b.status_id),
                      :part_type_id => 2,
                      :battery_id => b.id,
                      :owner_id => AddPartsScript.getOwner(b.owner_id)
                     }) if b.parts.length == 0
      }

      #Chargers to parts.
      Charger.find(:all).each { |c|
        Part.create!({
                      :status_id => AddPartsScript.partStatus(c.status_id),
                      :part_type_id => 3,
                      :charger_id => c.id,
                      :owner_id => AddPartsScript.getOwner(c.owner_id)
                     }) if c.parts.length == 0
      }
    end
  end

  def self.down
  end

  def self.getOwner(id)
    return id if id
    3
  end

  def self.partStatus(id)
    return 11 if id == nil or id == 3
    return 12 if id == 1
    10
  end

end
