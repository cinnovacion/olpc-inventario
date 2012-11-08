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

require 'read_file'

class LaptopsController < SearchController
  skip_filter :rpc_block, :only => [:requestBlackList, :reportStolenLaptops, :reportActivatedLaptops]

  def initialize
    super(:includes => [:status, :shipment, :model])
  end

  def new
    if params[:ids] 
      ids = JSON.parse(params[:ids])
      new_batch_edit(ids)
    else
      new_single_edit()
    end
  end
	
  def save
    datos = JSON.parse(params[:payload])

    if datos["ids"]
      modify_batch(datos)
    elsif params[:uploadfile] && params[:uploadfile] != ""
      attribs = datos["fields"].with_indifferent_access
      path = params[:uploadfile].path
      attribs[:arrived_at] = Time.now
      return Laptop.import_xls(path, attribs)
    else
      super
      return
    end 
    @output["msg"] = datos["id"] || datos["ids"] ? _("Changes saved.") : _("Laptop added.")  
  end

  def requestBlackList
    black_list = Laptop.getBlackList
    render :xml => black_list.to_xml
  end

  def reportStolenLaptops
    stolen_status = Status.find_by_internal_tag("stolen")
    stolen_laptops =  params[:hash][:stolen_laptops]
    hostname = params[:hash][:hostname]
    place = SchoolInfo.find_by_server_hostname(hostname).place
    if stolen_laptops && stolen_status && hostname && place
      stolen_laptops.each { |stolen_laptop|
        laptop = Laptop.find_by_serial_number(stolen_laptop[:serial_number])
        if laptop
          laptop.status_id = stolen_status.id
          laptop.save
          Event.register("stolen_laptop_activity", hostname, { :serial_number => laptop.serial_number }.to_json, place.id)
        end
      }
    end
    render :xml => {}.to_xml, :status => :ok
  end

  def reportActivatedLaptops
    laptops_info = params[:hash][:laptops_info]

    if laptops_info
      cond = ["laptops.serial_number in (?)", laptops_info.keys]
      Laptop.find(:all, :conditions => cond).each { |laptop|
        last_activation_date = laptops_info[laptop.serial_number]
        laptop.update_attributes({ :last_activation_date => last_activation_date })
      }
    end

    render :xml => {}.to_xml, :status => :ok
  end

  private

  def new_single_edit
    relation = Laptop.includes(:owner, :assignee)
    laptop = prepare_form(relation: relation)
    form_textfield(laptop, "serial_number", _("Serial Number"))

    id = laptop ? laptop.model_id : -1
    models = buildSelectHash2(Model, id, "name", false, [])
    form_combobox(laptop, "model_id", _("Model"), models)

    id = laptop ? laptop.shipment_arrival_id : -1
    shipments = buildSelectHash2(Shipment, id, "comment", false, [])
    form_combobox(laptop, "shipment_arrival_id", _("Shipment"), shipments)

    if laptop and laptop.owner_id
      form_details_link(_("In hands of"), "personas", laptop.owner_id, laptop.owner.getFullName())
    end

    if laptop and laptop.assignee_id
      form_details_link(_("Assigned to (final recipient)"), "personas", laptop.assignee_id, laptop.assignee.getFullName())
    end

    if !laptop
      people = buildSelectHashSingle(Person, -1, "getFullName()")
      form_select("owner_id", "personas", _("In hands of"), people)
    end

    id = laptop && laptop.status ? laptop.status_id : Status.find_by_internal_tag("deactivated").id
    statuses = buildSelectHash2(Status, id, "description", false, [])
    form_combobox(laptop, "status_id", _("Status"), statuses)

    form_textfield(laptop, "uuid", _("UUID"))

    form_uploadfield(_("Load .xls"), :uploadfile) if !p
  end


  # We save the attributes of the first laptop (only). 
  def new_batch_edit(ids)
    @output["fields"] = []
    p = Laptop.find(ids[0])

    @output["ids"] = ids 

    # User must check fields that where updated 
    @output["needs_update"] = true

    id = p ? p.model_id : -1
    models = buildSelectHash2(Model, id, "name", false, [])
    form_combobox(p, "model_id", _("Model"), models)

    id =  p ? p.shipment_arrival_id : -1
    shipments = buildSelectHash2(Shipment, id, "comment", false, [])
    form_combobox(p, "shipment_arrival_id", _("Shipment"), shipments)

    id = p && p.status ? p.status_id : Status.find_by_internal_tag("deactivated").id
    statuses = buildSelectHash2(Status, id, "description", false, [])
    form_combobox(p, "status_id", _("Status"), statuses)
  end

  def modify_batch(data)
    fields = data["fields"]
    attribs = Hash.new

    ["model_id", "shipment_arrival_id", "status_id"].each { |attr|
      next unless fields.include?(attr) and fields[attr]["updated"]
      attribs[attr] = fields[attr]["value"]
    }

    Laptop.transaction do
      Laptop.find(data["ids"]).each { |laptop|
        laptop.update_attributes!(attribs)
      }
    end
  end
end
