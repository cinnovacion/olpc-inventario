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
                                                                          
class Status < ActiveRecord::Base

  has_many :laptops
	has_many :batteries
	has_many :chargers

  validates_uniqueness_of :internal_tag, :message => _("The tag must be unique")

	def self.getColumnas()
		ret = Hash.new
		ret[:columnas] = [
				  {
					:name => _("Id"),
					:key => "statuses.id",
					:related_attribute => "id",
					:width => 50
				  },
				  {
					:name => _("Description"),
					:key => "statuses.description",
					:related_attribute => "getDescription()",
					:width => 255
				  },
				  {
					:name => _("Abbreviation"),
					:key => "statuses.abbrev",
					:related_attribute => "getAbbreviation()",
					:width => 50
				  }
				 ]
		ret[:columnas_visibles] = [false,true,true]
		ret
	end

	def getDescription()
		self.description
	end

	def getAbbreviation()
		self.abbrev
	end

end
