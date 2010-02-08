class SyncDeviceStatusesWithParts < ActiveRecord::Migration
  def self.up

      deployment_owners = Person.find_all_by_name("Paraguay Educa")
      activated_status = Status.find_by_internal_tag("activated")
      deactivated_status = Status.find_by_internal_tag("deactivated")
      dead_status = Status.find_by_internal_tag("dead")
      stolen_status = Status.find_by_internal_tag("stolen")

      deviceClasses = [Laptop, Battery, Charger]
      deviceClasses.each { |deviceClass|

        deviceClass.all.each { |device|

          if deployment_owners.include?(device.owner)

            if device.status_id != dead_status.id
              device.status_id = deactivated_status.id
            end

          else

            if device.status_id != stolen_status.id
              device.status_id = activated_status.id
            end

          end

          device.save
        }
      }

  end

  def self.down
  end
end
