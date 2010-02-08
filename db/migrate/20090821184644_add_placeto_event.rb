class AddPlacetoEvent < ActiveRecord::Migration
  extend DbUtil

  def self.up

    add_column :events, :place_id, :integer
    self.createConstraint("events", "place_id", "places")

    Event.find(:all).each { |event|

      place = nil
      if ["node_up", "node_down"].include?(event.event_type.internal_tag)

        place = Node.find_by_id(event.getHash["id"]).place
      else

        if event.event_type.internal_tag == "stolen_laptop_activity"

          place = SchoolInfo.find_by_server_hostname(event.reporter_info).place
        end
      end

      if place
        event.place_id = place.id
        event.save!
      end
    }
  end

  def self.down

    self.removeConstraint("events", "place_id")
    remove_column :events, :place_id
  end
end
