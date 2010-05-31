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
                                                                       
class ReportsController < SearchController

  def movement_types
    @output["widgets"] = Array.new

    # from person
    @output["widgets"].push(listSelector(_("Given by: "), "personas"))

    # to person
    @output["widgets"].push(listSelector(_("Received by: "), "personas"))

    #Rango de fecha
    @output["widgets"].push(dateRange())

    #Place
    @output["widgets"].push(hierarchy(""))

    @output["print_method"] = "movement_types"

  end

  def movements
    @output["widgets"] = Array.new

    # Rango de fecha 
    @output["widgets"].push(dateRange())

    #Seriales.
    csv_fields = Array.new
    csv_fields.push( { :text => _("#Laptop"), :value => "laptop", :datatype => "textfield" } )
    @output["widgets"].push(columnValueSelector(csv_fields))

    #Motivos posibles
    cb_options = buildCheckHash(MovementType, "getDescription")
    @output["widgets"].push(checkBoxSelector(_("Reasons"), cb_options,3))

    # from person
    @output["widgets"].push(listSelector(_("Given by: "), "personas"))

    # to person
    @output["widgets"].push(listSelector(_("Received by: "), "personas"))

    # Place
    @output["widgets"].push(hierarchy(""))

    @output["print_method"] = "movements"
  end

  ##
  # Movimientos en una ventana de tiempo
  def movements_time_range
    @output["widgets"] = Array.new
    @output["widgets"].push(dateRange())
    cb_data = buildHierarchyHash(Place, "places", "places.place_id", "name", -1, nil, nil, true)
    @output["widgets"].push(comboBoxSelector(_("Location"), cb_data))
    @output["print_method"] = "movements_time_range"
  end

  ##
  # Distribucion de laptops por propietario
  def laptops_per_owner
    @output["widgets"] = Array.new
    @output["widgets"].push(listSelector(_("Owner"), "personas"))
    @output["print_method"] = "laptops_per_owner"
  end

  ##
  # Distribucion de laptops entregadas por personas
  def laptops_per_source_person
    @output["widgets"] = Array.new
    @output["widgets"].push(listSelector(_("Delivered by"),"personas"))
    @output["print_method"] = "laptops_per_source_person"
  end

  ##
  # Distribucion de laptops entregadas a personas
  def laptops_per_destination_person
    @output["widgets"] = Array.new
    @output["widgets"].push(listSelector(_("Given to"), "personas"))
    @output["print_method"] = "laptops_per_destination_person"
  end

  ##
  # Listado de activaciones en una ventana de tiempo y por activador.
  def activations
    @output["widgets"] = Array.new
    @output["widgets"].push(dateRange())
    @output["widgets"].push(listSelector(_("Activated by"), "personas"))
    @output["print_method"] = "activations"
  end

  ##
  # Prestamos realizados
  def lendings
    @output["widgets"] = Array.new
    #Rango de fecha
    @output["widgets"].push(dateRange())
    #Persona que entrego y recibio.
    @output["widgets"].push(listSelector(_("Lended by "), "personas"))
    @output["widgets"].push(listSelector(_("Lended to "), "personas"))
    #Filtros por prestamos entregado y no entregados.
    cb_filters = Array.new
    cb_filters.push( { :label => _("Returned"), :cb_name => "returned",:checked => true } )
    cb_filters.push( { :label => _("Not returned"), :cb_name => "not_returned",:checked => true } )
    @output["widgets"].push(checkBoxSelector(_("Filters"), cb_filters))
    @output["print_method"] = "lendings"
  end

  ##
  # Distribucion por estados.
  def statuses_distribution
    @output["widgets"] = Array.new
    @output["widgets"].push(hierarchy(""))
    @output["print_method"] = "statuses_distribution"
  end

  def status_changes
    @output["widgets"] = Array.new
    @output["widgets"].push(dateRange())
    @output["print_method"] = "status_changes"
  end

  def laptops_per_place
    @output["widgets"] = Array.new
    @output["widgets"].push(hierarchy(""))
    @output["print_method"] = "laptops_per_place"
  end

  def parts_replaced
    @output["widgets"] = Array.new
    since = Fecha.usDate((Date.today - 1.month).to_s)
    to = Fecha.usDate(Date.today.to_s)
    @output["widgets"] += multipleDataRange(since, to)
    @output["widgets"].push(hierarchy(_("Locations")))
    @output["widgets"].push(checkBoxSelector(_("Parts"), buildCheckHash(PartType, "getDescription"), 6))
    @output["print_method"] = "parts_replaced"
  end

  def problems_per_type
    @output["widgets"] = Array.new
    @output["widgets"].push(dateRange())
    @output["widgets"].push(hierarchy(_("Since")))
    @output["widgets"].push(checkBoxSelector(_("Problems"), buildCheckHash(ProblemType, "getName"), 3))
    @output["print_method"] = "problems_per_type"
  end

  def barcodes
    @output["widgets"] = Array.new
    cb_data = buildHierarchyHash(Place, "places", "places.place_id", "name", -1, nil, nil, false)
    @output["widgets"].push(multipleHierarchy(""))

    cb_options = Array.new
    cb_options.push( { :label => _("With laptops assigned"), :cb_name => "with",:checked => true } )
    cb_options.push( { :label => _("Without laptops assigned"), :cb_name => "with_out",:checked => true } )
    @output["widgets"].push(checkBoxSelector("Filters", cb_options))

    @output["print_method"] = "barcodes"
  end

  def lots_labels
    @output["widgets"] = Array.new
    @output["widgets"].push(comboBoxSelector(_("Lot"), buildSelectHash2(Lot,-1,"getTitle",false,[])))
    @output["print_method"] = "lots_labels"
  end

  def laptops_per_tree
    @output["widgets"] = Array.new
    cb_filter = buildSelectHash2(PlaceType,id,"name",true,[])
    cb_data = buildHierarchyHash(Place, "places", "places.place_id", "name", -1, nil, nil, false)
    @output["widgets"].push(comboBoxFiltered(_("Location"), cb_filter, cb_data, 360, "/places/requestPlaces"))
    @output["print_method"] = "laptops_per_tree"
  end

  def possible_mistakes
    @output["widgets"] = Array.new
    @output["widgets"].push(hierarchy(""))
    @output["print_method"] = "possible_mistakes"
  end

  def printable_delivery
    @output["widgets"] = Array.new
    mov_ids_fields = Array.new
    mov_ids_fields.push( { :text => _("#Movement"), :value => "id", :datatype => "textfield" } )
    @output["widgets"].push(columnValueSelector(mov_ids_fields))
    @output["print_method"] = "printable_delivery"
  end

  def registered_laptops
    @output["widgets"] = Array.new

    @output["widgets"].push(hierarchy(_("Location")))

    cb_options = Array.new
    cb_options.push( { :label => _("Registered"), :cb_name => true,:checked => true } )
    cb_options.push( { :label => _("Not registered"), :cb_name => false,:checked => true } )
    @output["widgets"].push(checkBoxSelector(_("Filters"), cb_options))

    @output["print_method"] = "registered_laptops"
  end

  def problems_per_school
    @output["widgets"] = Array.new
    @output["widgets"].push(dateRange())
    @output["widgets"].push(comboBoxSelector(_("Group by"), buildSelectHash2(PlaceType, -1, "getName", false, [])))
    @output["widgets"].push(hierarchy(_("Since")))
    @output["widgets"].push(checkBoxSelector(_("Problems"), buildCheckHash(ProblemType,"getName"),2))
    cb_options = Array.new
    cb_options.push( { :label => _("Yes"), :cb_name => true,:checked => true } )
    cb_options.push( { :label => _("No"), :cb_name => false,:checked => true } )
    @output["widgets"].push(checkBoxSelector(_("Solved"), cb_options))
    cb_options = Array.new
    cb_options.push({ :text => _("Solved"), :value => 1 })
    cb_options.push({ :text => _("Not solved"), :value => 2 })
    cb_options.push({ :text => _("Total"), :value => 3 })
    cb_options.push({ :text => _("Number of people"), :value => 4 })
    cb_options.push({ :text => _("Problems per person"), :value => 5 })
    cb_options.push({ :text => _("Eficiency"), :value => 6 })
    @output["widgets"].push(comboBoxSelector(_("Order by"), cb_options))
    @output["print_method"] = "problems_per_school"
  end

  def problems_per_grade
    @output["widgets"] = Array.new
    @output["widgets"].push(dateRange())
    @output["widgets"].push(hierarchy(_("Belong to")))
    @output["widgets"].push(checkBoxSelector(_("Problems"), buildCheckHash(ProblemType,"getName"),2))
    @output["print_method"] = "problems_per_grade"
  end

  def used_parts_per_person
    @output["widgets"] = Array.new
    cb_options = [{ :text => _("Owners"), :value => "owner" },{ :text => "Tecnicos", :value => "solved_by_person" }]
    @output["widgets"].push(comboBoxSelector(_("Given to"), cb_options))
    @output["widgets"].push(comboBoxSelector(_("Group by"), buildSelectHash2(PlaceType, -1, "getName", false, ["internal_tag in (?)",["school","city"]])))
    @output["widgets"].push(hierarchy(_("From")))
    @output["widgets"].push(checkBoxSelector(_("Parts"), buildCheckHash(PartType,"getDescription"),6))
    cb_options = buildSelectHash2(PartType, -1, "getDescription", false)
    cb_options += [{ :text => _("Total"), :value => -1}, { :text => "Persona", :value => -2}]
    @output["widgets"].push(comboBoxSelector("Ordenar por", cb_options))
    cb_options = [{ :text => _("Descending"), :value => "DESC"}, { :text => _("Ascending"), :value => "ASC"}]
    @output["widgets"].push(comboBoxSelector(_("Order"), cb_options))
    @output["print_method"] = "used_parts_per_person"
  end

  def where_are_these_laptops
    @output["widgets"] = Array.new
    @output["widgets"].push(textArea())
    @output["print_method"] = "where_are_these_laptops"
  end

  def online_time_statistics
    @output["widgets"] = Array.new
    since = Fecha.usDate((Date.today - 1.month).to_s)
    to = Fecha.usDate(Date.today.to_s)
    @output["widgets"].push(dateRange(since, to))
    @output["widgets"].push(hierarchy(_("In")))
    @output["print_method"] = "online_time_statistics"
  end

  def serials_per_places
    @output["widgets"] = Array.new
    @output["widgets"].push(multipleHierarchy(""))
    @output["print_method"] = "serials_per_places"
  end

  def students_ids_distro
    @output["widgets"] = Array.new
    since = Fecha.usDate(Date.today.beginning_of_year.to_s)
    to = Fecha.usDate(Date.today.to_s)
    #@output["widgets"].push(dateRange(since, to))
    @output["widgets"] += multipleDataRange(since, to)
    @output["widgets"].push(hierarchy(""))
    @output["print_method"] = "students_ids_distro"
  end

  def problems_and_deposits
    @output["widgets"] = Array.new
    since = Fecha.usDate((Date.today - 1.month).to_s)
    to = Fecha.usDate(Date.today.to_s)
    @output["widgets"].push(dateRange(since, to))
    @output["widgets"].push(hierarchy(""))
    cb_options = Array.new
    cb_options.push( { :label => _("Yes"), :cb_name => true,:checked => true } )
    cb_options.push( { :label => _("No"), :cb_name => false,:checked => true } )
    @output["widgets"].push(checkBoxSelector(_("Solved"),cb_options))
    @output["print_method"] = "problems_and_deposits"
  end

  def deposits
    @output["widgets"] = Array.new
    since = Fecha.usDate((Date.today - 1.month).to_s)
    to = Fecha.usDate(Date.today.to_s)
    @output["widgets"].push(dateRange(since, to))
    @output["widgets"].push(hierarchy(""))
    @output["print_method"] = "deposits"
  end
  

  def spare_parts_registry
    @output["widgets"] = Array.new
    @output["widgets"].push(dateRange)
    @output["widgets"].push(hierarchy(""))
    @output["print_method"] = "spare_parts_registry"
  end

  def problems_time_distribution
    @output["widgets"] = Array.new
    since = Fecha.usDate(Date.today.beginning_of_year.to_s)
    to = Fecha.usDate(Date.today.to_s)
    @output["widgets"] += multipleDataRange(since, to)
    @output["widgets"].push(hierarchy(""))
    @output["widgets"].push(checkBoxSelector(_("Problems"),buildCheckHash(ProblemType,"getName"),3))
    @output["print_method"] = "problems_time_distribution"
  end

  def is_hardware_dist
    @output["widgets"] = Array.new
    @output["widgets"].push(dateRange)
    @output["widgets"].push(hierarchy(""))
    cb_options = Array.new
    cb_options.push( { :label => _("Yes"), :cb_name => true,:checked => true } )
    cb_options.push( { :label => _("No"), :cb_name => false,:checked => true } )
    @output["widgets"].push(checkBoxSelector(_("Solved"),cb_options))
    @output["print_method"] = "is_hardware_dist"
  end 

  def laptops_problems_recurrence
    @output["widgets"] = Array.new
    @output["widgets"].push(dateRange)
    @output["widgets"].push(hierarchy(""))
    @output["print_method"] = "laptops_problems_recurrence"
  end 

  def average_solved_time
    @output["widgets"] = Array.new
    @output["widgets"].push(dateRange)
    @output["widgets"].push(hierarchy(""))
    @output["print_method"] = "average_solved_time"
  end 

  def audit_report
    @output["widgets"] = Array.new
    since = Fecha.usDate((Date.today - 1.month).to_s)
    to = Fecha.usDate(Date.today.to_s)
    @output["widgets"].push(dateRange(since, to))
    cb_options = Audit.audited_classes.map { |audited_class|
      class_name = audited_class.name
      { :text => class_name, :value => class_name, :selected => true }
    }
    @output["widgets"].push(comboBoxSelector(_("Model"), cb_options))
    @output["print_method"] = "audit_report"
  end

  def stock_status_report
    @output["widgets"] = Array.new
    @output["widgets"].push(hierarchy(""))
    @output["print_method"] = "stock_status_report"
  end

  #
  # Helper methods. 
  # 

  private
  def dateRange(since = nil, to = nil)
    h = Hash.new
    h["widget_type"] = "date_range"
    h["options"] = Hash.new
    h["options"]["since"] = since ? since : Fecha.usDate(Date.today.beginning_of_year.to_s)
    h["options"]["to"] = to ? to : Fecha.usDate(Date.today.to_s)
    h
  end

  def checkBoxSelector(label, cb_options, max_column=1)
    h = Hash.new
    h["widget_type"] = "checkbox_selector"
    h["options"] = Hash.new
    h["options"]["label"] = label
    h["options"]["max_column"] = max_column
    h["options"]["cb_options"] = cb_options
    h
  end

  def listSelector(label,list_name)
    h = Hash.new
    h["widget_type"] = "list_selector"
    h["options"] = Hash.new
    h["options"]["label"] = label
    h["options"]["list_name"] = list_name
    h
  end

  def comboBoxSelector(label,cb_options, width=130)
    h = Hash.new
    h["widget_type"] = "combobox_selector"
    h["options"] = Hash.new
    h["options"]["label"] = label
    h["options"]["cb_options"] = cb_options
    h["options"]["width"] = width
    h
  end

   def comboBoxFiltered(label,cb_filter, cb_data, width=130, url = "")
    h = Hash.new
    h["widget_type"] = "combobox_filtered"
    h["options"] = Hash.new
    h["options"]["label"] = label
    h["options"]["cbs_options"] = { :filter => cb_filter, :data => cb_data }
    h["options"]["data_request_url"] = url
    h["options"]["width"] = width
    h
  end

  def columnValueSelector(col_options)
    h = Hash.new
    h["widget_type"] = "column_value_selector"
    h["options"] = Hash.new
    h["options"]["col_options"] = col_options
    h
  end

  def hierarchy(label, width = 360, height = 150)
    h = Hash.new
    h["widget_type"] = "hierarchy_on_demand"
    h["options"] = Hash.new
    h["options"]["label"] = label
    h["options"]["width"] = width
    h["options"]["height"] = height
    h
  end

  def multipleDataRange(since = nil, to = nil)
    widgets = []
    widgets.push(dateRange(since, to))
    cb_options = Array.new
    cb_options.push({ :text => _("Day"), :value => "day" })
    cb_options.push({ :text => _("Week"), :value => "week" })
    cb_options.push({ :text => _("Month"), :value => "month" })
    cb_options.push({ :text => _("Year"), :value => "year" })
    widgets.push(comboBoxSelector(_("Grouped by: "),cb_options))
    widgets
  end

  def textArea()
    h = Hash.new
    h["widget_type"] = "text_area"
    h
  end

  def multipleHierarchy(label = "", width = 360, height = 150)
    h = Hash.new
    h["widget_type"] = "multiple_hierarchy"
    h["options"] = Hash.new
    h["options"]["label"] = label
    h["options"]["width"] = width
    h["options"]["height"] = height
    h
  end

end
