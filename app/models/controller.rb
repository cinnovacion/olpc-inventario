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
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 
# 2009
# # #
                                                                        
class Controller < ActiveRecord::Base
  has_many :permissions

  def self.refreshMethodsTree()

    list = Array.new
    controllers = Dir.new(Rails.root.join("app", "controllers")).entries.sort
    methods_ancestors = Object.instance_methods + ApplicationController.instance_methods
    controllers.each { |controller|
      if controller =~ /_controller.rb\z/
        h = Hash.new
        controller_name = controller.camelize.gsub(".rb","")
        h["name"] = controller_name.gsub("Controller","")
        methods_curr_controller = eval("#{controller_name}.instance_methods")
        h["methods"] = (methods_curr_controller - methods_ancestors).map { |method| 
                    { "name" => method, "selected" => false }
        }
      list.push(h)
      end
      #break if list.length == 12
    }
    #list.delete(nil) if list.include?(nil)
    list
  end

  
  def self.doMethodsTree(permissions)
    permissions_ids = []

    permissions.each { |controller|

      controllerObj = Controller.find_by_name(controller["name"])
      if !controllerObj
        controllerObj = Controller.new({:name => controller["name"] })
        controllerObj.save!
      end

      controller["methods"].each { |method|
        permissionObj = Permission.find_by_name_and_controller_id(method, controllerObj.id)
        if !permissionObj
          permissionObj = Permission.new({ :name => method, :controller_id => controllerObj.id })
          permissionObj.save!
        end
        permissions_ids.push(permissionObj.id)
      }
    }

    permissions_ids

  end
end
