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
# db_util.rb
#
# Helpers for migratins
#

# # #
# Author: Raúl Gutiérrez
# E-mail Address: rgs@paraguayeduca.org
# 2009
# # #

module DbUtil 

  def createConstraint(table, fk_col, related_table)
    

    related_class = eval(related_table.camelize.singularize)
    self.nullify_dangling_fks(table, fk_col, related_class) 
    

    q = "alter table #{table} add CONSTRAINT `#{table}_#{fk_col}_fk` FOREIGN KEY "
    q += "(`#{fk_col}`) REFERENCES `#{related_table}` (`id`)"
    execute q
  end

  def removeConstraint(table, fk_col)
    q = "alter table #{table} drop foreign key #{table}_#{fk_col}_fk"
    execute q
  end

  def nullify_dangling_fks(table, fk_col, related_class)
    clazz_ref = eval(table.camelize.singularize)

    clazz_ref.transaction do 
      clazz_ref.find(:all).each { |obj|
        col_value = obj.send(fk_col.to_sym)
        if col_value
          if !related_class.find_by_id(col_value)
            obj.send("#{fk_col}=".to_sym, nil)
            obj.save!
          end

        end
      }
    end

  end


end
