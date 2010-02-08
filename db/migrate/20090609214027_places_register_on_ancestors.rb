class PlacesRegisterOnAncestors < ActiveRecord::Migration
  def self.up
    Place.transaction do
      Place.find(:all).each { |place| 
        place.register_on_ancestors
        place.save! 
      }
    end
  end

  def self.down
  end
end
