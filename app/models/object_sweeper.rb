#     Copyright Paraguay Educa 2009
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>
# 
#  

# # #
# Author: Raúl Gutiérrez
# E-mail Address: rgs@paraguayeduca.org
# 2009
# # #

# # #
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 
# 2009
# # #
                                                                        
class ObjectSweeper < ActionController::Caching::Sweeper

  # Include observed classes...
  observe Laptop, Battery, Charger


  def before_create(record)
    # msg = "Se esta por crear un objeto de clase #{record.class.to_s}"
    # logger.debug msg
  end


  def before_save(record)

    if !record.new_record?
      case record
        when Laptop
          old_record = record.class.find_by_id record.id
          status_control(record,old_record)
          onwer_control(record,old_record)
        when Battery
          old_record = record.class.find_by_id record.id
          status_control(record,old_record)
          onwer_control(record,old_record)
        when Charger
          old_record = record.class.find_by_id record.id
          status_control(record,old_record)
          onwer_control(record,old_record)
      else
        logger.debug record.class.to_s
      end
    end

  end

  private

  def part_check_owner_change(new_record,old_record)
    return true if new_record.owner_id != old_record.owner_id
    false
  end

  def onwer_control(new_record,old_record)
    Part.updateOwner(new_record) if part_check_owner_change(new_record,old_record)
  end

  def status_control(record,old_record)
    if part_check_state_change(record,old_record)
      part_register_status_change(record,old_record)
      Part.modify_part_status_as(record,"available") if record.status.internal_tag == "deactivated"
      Part.modify_part_status_as(record,"broken") if record.status.internal_tag == "dead"
      Part.modify_part_status_as(record,"used") if record.status.internal_tag == "activated"
    end
  end

  def part_check_state_change(new_record,old_record)
    #DEBUG: return false if !old_record.class.method_defined?(:status_id)
    return true if !old_record.status_id and new_record.status_id
    return false if !old_record.status_id and !new_record.status_id
    return false if new_record.status.internal_tag == old_record.status.internal_tag
    true
  end

  def part_check_state_machine(new_record,old_record)
    #DEBUG: raise "#{old_record.status.internal_tag} y #{new_record.status.internal_tag}"
    case old_record.status.internal_tag
    when "dead"
      return true if new_record.status.internal_tag == "dead"
    when "deactivated"
      return true if new_record.status.internal_tag == "activated"
    when "activated"
      return true if ["deactivated","on_repair","lost","stolen"].include? new_record.status.internal_tag
    when "on_repair"
      return true if new_record.status.internal_tag == "repaired"
    when "repaired"
      return true if new_record.status.internal_tag == "activated"
    when "lost"
      return true if new_record.status.internal_tag == "lost_deactivated"
    when "stolen"
      return true if new_record.status.internal_tag == "stolen_deactivated"
    end
    false
  end

  def part_register_status_change(new_record,old_record)
    change = StatusChange.new
    change.previous_state_id = old_record.status_id
    change.new_state_id = new_record.status_id
    case new_record
      when Laptop
        change.laptop_id = new_record.id
      when Battery
        change.battery_id = new_record.id
      when Charger
        change.charger_id = new_record.id
    end
    change.date_created_at = Fecha::getFecha()
    change.time_created_at = Fecha::getHora()
    change.save!
  end

end
