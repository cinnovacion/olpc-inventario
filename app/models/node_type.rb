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
                                                                          
class NodeType < ActiveRecord::Base
  belongs_to :image

  validates_presence_of :name, :message => N_("Must specify the name.")
  validates_presence_of :internal_tag, :message => N_("You must specify the internal tag")
  validates_uniqueness_of :internal_tag, :message => N_("The tag must be unique")

  def self.getColumnas(vista = "")
    [
     {:name => _("Id"), :key => "node_types.id", :related_attribute => "id", :width => 50},
     {:name => _("Name"), :key => "node_types.name", :related_attribute => "getName()", :width => 100},
     {:name => _("Description"), :key => "node_types.description", :related_attribute => "getDescription()", :width => 255},
     {:name => _("Tag"), :key => "node_types.internal_tag", :related_attribute => "getInternalTag()", :width => 100},
     {:name => _("Image"), :key => "images.name", :related_attribute => "getImageName()", :width => 100}
    ]
  end

  def self.getChooseButtonColumns(vista = "")
    ret = Hash.new
    ret["desc_col"] = 0
    ret["id_col"] = 1
    ret
  end

  def self.getControledTypes
    type_tags = ["ap","ap_down","server","server_down"]
    NodeType.find(:all, :conditions => ["internal_tag in (?)", type_tags]).map { |type| type.id }
  end

  def getName()
    self.name ? self.name : " "
  end

  def getDescription()
    self.description ? self.description : " "
  end

  def getInternalTag()
    self.internal_tag ? self.internal_tag : " "
  end

  def getImageName()
    self.image_id ? self.image.getName() : " "
  end

  def icon()
    self.image_id ? "/images/view/#{self.image_id}" : ""
  end

end
