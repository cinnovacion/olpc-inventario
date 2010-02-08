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
  observe Laptop

  def before_save(record)

    if !record.new_record?
      case record
        when Laptop
          old_record = record.class.find_by_id record.id
          status_control(record,old_record)
      else
        logger.debug record.class.to_s
      end
    end

  end

  private

  def status_control(record,old_record)

    register_status_change(record,old_record) if check_state_change(record,old_record)
  end

  def check_state_change(new_record,old_record)

    return true if !old_record.status_id and new_record.status_id
    return false if !old_record.status_id and !new_record.status_id
    return false if new_record.status.internal_tag == old_record.status.internal_tag
    true
  end

  def register_status_change(new_record, old_record)

    change = StatusChange.new
    change.previous_state_id = old_record.status_id
    change.new_state_id = new_record.status_id
    change.laptop_id = new_record.id
    change.date_created_at = Fecha::getFecha()
    change.time_created_at = Fecha::getHora()
    change.save!
  end

end
