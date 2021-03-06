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

class Image < ActiveRecord::Base
  has_many :people

  attr_accessible :name, :file

  #Se verifica la presencia de los campos.
  validates_presence_of :name, :message => N_("The image must be named.")
  validates_presence_of :file, :message => N_("The image must have an associated file.")

  FIELDS = [
    {name: _("Id"), column: :id, width: 120},
    {name: _("Name"), column: :name, width: 120}
  ]

  def self.getChooseButtonColumns(vista = "")
    ret = Hash.new
    ret["desc_col"] = 1
    ret["id_col"] = 0
    ret
  end

  def self.genAttribs(uploadfile)
    attribs = Hash.new
    attribs[:name] = uploadfile.original_filename.gsub(/[^a-zA-Z0-9.]/, '_')
    attribs[:file] = uploadfile.read
    attribs
  end

  def self.register(uploadfile)
     image = Image.new(Image.genAttribs(uploadfile))
     image.save!
     image
  end

  def register_update(uploadfile)
    self.update_attributes(Image.genAttribs(uploadfile))
  end
end
