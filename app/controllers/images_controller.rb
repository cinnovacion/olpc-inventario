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

# # #
# Author: Raúl Gutiérrez
# E-mail Address: rgs@paraguayeduca.org
# 2009
# # #
                                                                       
class ImagesController < SearchController
  skip_filter :rpc_block, :only => [ :view, :view_by_name ]
  skip_filter :access_control, :only => [ :view, :view_by_name ]
  skip_filter :do_scoping, :only => [ :view, :view_by_name ]

  def search
    do_search(Image, nil)
  end

  def search_options
    crearColumnasCriterios(Image)
    do_search(Image, nil)
  end

  def new
    @output["fields"] = []

    if params[:id]
      image = Image.find_by_id(params[:id])
      @output["id"] = image.id
    else
      image = nil
    end

    if image
      path = "/images/view/#{image.id}"
      h = { "label" => _("Image"),"datatype" => "image", "value" => path }
      @output["fields"].push(h)
    end

    h = { "label" => _("Load image"), "datatype" => "uploadfield", :field_name => :uploadfile }
    @output["fields"].push(h)

  end

  def save
    datos = JSON.parse(params[:payload])

    if params[:uploadfile]
      if datos["id"]
        image = Image.find_by_id(datos["id"])
        image.register_update(params[:uploadfile])
      else
        Image.register(params[:uploadfile])
      end
    end
  @output["msg"] = datos["id"] ? _("Changes saved.") : _("Image added.")
  end

  def delete
    id = JSON.parse(params[:payload])
    Image.destroy(id)
    @output["msg"] = _("Image deleted.")
  end

  def view
    image = Image.find(params[:id])
    show_image(image)
  end

  def view_by_name
    image = Image.find_by_name(params[:id] + ".jpg")
    show_image(image)
  end

  private 
  def show_image(image)
    if not image
      send_data nil
      return
    end
    send_data image.file, :filename => image.name ,:type => "image/jpeg", :disposition => "inline"
  end
end
