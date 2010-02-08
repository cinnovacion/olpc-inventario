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
# E-mail Address: ( mabente@paraguayeduca.org | tincho_02@hotmail.com )
# 2009
# # #


require 'gruff'
require 'rubygems'
require 'tempfile'

module PyEducaGraph

  Images_Path = "#{RAILS_ROOT}/public/images/"
  Image_Format = ".jpg"
  Url_Base_Path = "images/"

  ###
  #
  # HACK: I think that send_data and send_file are NOT thread-safe, that is why
  #       we dump the image to Images_Path and pass it over (its path) to another method
  #       via session
  #
  def self.createPie(pie_data, title = "Grafico")
    g = Gruff::Pie.new
    g.title = title

    pie_data.each { |i| g.data i[:name], i[:value] }

    t, file_path = PyEducaGraph::getImageTempFile("pie_data")
    g.write(file_path)
    PyEducaGraph::getUrlPath(file_path)
  end

  def self.createBar(bar_data, title, range = nil)
    g = Gruff::Bar.new
    g.title = title
    g.sort = false

    bar_data.each { |i| g.data i[:name], i[:value] }
    
    if range
      g.maximum_value = range[:max]
      g.minimum_value = range[:min]
    end

    t, file_path = PyEducaGraph::getImageTempFile("bar_data")
    g.write(file_path)
    PyEducaGraph::getUrlPath(file_path)
  end

  def self.createLine(line_data, title = "Grafico", labels = [])
    g = Gruff::Line.new
    g.title = title
    g.sort = false

    line_data.each { |i| g.data i[:name], i[:value] }
    
    g.labels = labels

    t, file_path = PyEducaGraph::getImageTempFile("line_data")
    g.write(file_path)
    PyEducaGraph::getUrlPath(file_path)
  end

  def self.getImageTempFile(image_name, img_format = PyEducaGraph::Image_Format)
    t = Tempfile.new(image_name, PyEducaGraph::Images_Path)
    file_path = t.path + img_format
    [t, file_path]
  end

  def self.getUrlPath(file_path)
    PyEducaGraph::Url_Base_Path + File.basename(file_path)
  end

end
