class FixPlacesHierarchy < ActiveRecord::Migration
  def self.up

    Place.transaction do
      PlaceDependency.transaction do
        paraguay_place = Place.new({ :name => "Paraguay", :description => "Corazon del America del Sur", :place_id => nil })
    
        if paraguay_place.save!

          cond = ["places.place_id is NULL and places.id != ? ", paraguay_place.id]
          Place.find(:all, :conditions => cond).each { |ex_root_place|

            ex_root_place.place_id = paraguay_place.id
            ex_root_place.save!
          }

        end
      end
    end

  end

  def self.down
  end
end
