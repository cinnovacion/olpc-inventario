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

  attr_accessible :name, :description, :internal_tag
  attr_accessible :image, :image_id

  validates_presence_of :name, :message => N_("Must specify the name.")
  validates_presence_of :internal_tag, :message => N_("You must specify the internal tag")
  validates_uniqueness_of :internal_tag, :message => N_("The tag must be unique")

  FIELDS = [
    {name: _("Id"), column: :id, width: 50},
    {name: _("Name"), column: :name},
    {name: _("Description"), column: :description, width: 255},
    {name: _("Tag"), column: :internal_tag},
    {name: _("Image"), association: :image, column: :name},
  ]

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

  def getImageName()
    self.image_id ? self.image.name : " "
  end

  def icon()
    self.image_id ? "/images/view/#{self.image_id}" : ""
  end

end
