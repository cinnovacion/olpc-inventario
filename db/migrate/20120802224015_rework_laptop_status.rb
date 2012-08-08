class ReworkLaptopStatus < ActiveRecord::Migration
  def self.migrate_status(old_status_tag, new_status_tag)
    status = Status.find_by_internal_tag(old_status_tag)
    new_status = Status.find_by_internal_tag(new_status_tag)

    if status.nil? or new_status.nil?
      return
    end

    Laptop.find_all_by_status_id(status.id).each { |laptop|
      laptop.status_id = new_status.id
      laptop.save!
    }
    StatusChange.find_all_by_previous_state_id(status).each { |ch|
      ch.previous_state_id = new_status.id
      ch.save!
    }
    StatusChange.find_all_by_new_state_id(status).each { |ch|
      ch.new_state_id = new_status.id
      ch.save!
    }
    status.destroy
  end

  def self.up
    # migrate stolen_deactivated to stolen, and remove stolen_deactivated
    # We don't have control of the activation state of stolen laptops
    migrate_status("stolen_deactivated", "stolen")
    
    # migrate lost_deactivated to lost and remove lost_deactivated
    # We don't have control of the activation state of lost laptops
    migrate_status("lost_deactivated", "lost")

    # migrate used to activated and remove used
    # This was only intended for parts, which inventario no longer tracks
    migrate_status("used", "activated")

    # migrate available to activated and remove available
    # This was only intended for parts, which inventario no longer tracks
    migrate_status("available", "activated")

    # rename Desactivado to En desuso
    # After a lot of discussion we think this much better reflects the use
    # of the status: the laptop is available but not being used, so no
    # activations should be generated for it.
    status = Status.find_by_internal_tag("deactivated")
    status.update_attributes(:description => "En desuso") if !status.nil?

    # rename Activado to En uso
    # After a lot of discussion we think this much better reflects the use
    # of the status: the laptop is being used, so we should generate
    # activations for it. (It doesn't necessarily mean that such a laptop has
    # received an activation and activated itself, though, thats kind of out
    # of scope of inventario).
    status = Status.find_by_internal_tag("activated")
    status.update_attributes(:description => "En uso") if !status.nil?
  end

  def self.down
  end
end
