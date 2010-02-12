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

                                                                          
class SistemaController < ApplicationController
  around_filter :rpc_block
  skip_filter :access_control, :only => [:login, :login_info, :logout, :gui_content, :welcome_info] 
  skip_filter :do_scoping, :only => [:login, :login_info, :logout]

  def initialize
    super
    @check_authentication = false
  end

  def login_info
    @output[:info] = Hash.new
    @output[:info][:app_revision] = PyEducaUtil::getAppRevisionNum()
  end

  def login
    user = params[:username]
    password = params[:password]

    user = User.new(:usuario => user, :password => password)
    logged_in_user = user.autenticar
    if logged_in_user
      session[:user_id] = logged_in_user.id
      @output["auth"] = true
      
      # Pasar permisos
      @output["privs"] = {}
    else
      @output["msg"] = "Usuario o password equivocado"
    end
  end
  
  def logout
    session[:user_id] = nil
    @output["msg"] = "Ya no se encuentra en el sistema, hasta luego"
  end

  def welcome_info
#     @output["infoDict"] = Hash.new
# 
#     # laptops for repair
#     num = Movement.getNumberOf("for_repair")
#     @output["infoDict"]["Laptops entregadas p/ repacion"] = num
# 
#     # laptops repaired
#     num = Movement.getNumberOf("repaired")
#     @output["infoDict"]["Laptops reparadas"] = num
# 
#     # laptops loaned
#     num = Movement.getNumberOf("loaned")
#     @output["infoDict"]["Laptops prestadas"] = num
# 
#     # laptops for developers
#     num = Movement.getNumberOf("developer")
#     @output["infoDict"]["Laptops desarrolladores"] = num
# 
#     # laptops for teachers
#     num = Movement.getNumberOf("teachers")
#     @output["infoDict"]["Laptops Docentes"] = num
# 
#     # laptops for students
#     num = Movement.getNumberOf("students")
#     @output["infoDict"]["Laptops alumnos"] = num
# 
#     # laptops "formadores"
#     num = Movement.getNumberOf("formadores")
#     @output["infoDict"]["Laptops formadores"] = num
# 
#     # laptops returned
#     num = Movement.getNumberOf("returned")
#     @output["infoDict"]["Laptops devueltas"] = num
# 
#     # laptops with problems on first boot
#     num = Movement.getNumberOf("first_boot_problem")
#     @output["infoDict"]["Laptops devuelta por problemas de origen"] = num
  end

  ###
  # Tincho says: All the content for the GUI will be localed
  #              in the server side, for usability reasons.
  def gui_content

    @output[:label] = "Aplicaciones"
    @output[:image]= "icon/22/apps/preferences-users.png"
    @output[:elements] = []

    profile_internal_tag = current_user.person.profile.internal_tag
    #RAILS_DEFAULT_LOGGER.error("\n\n\n\n #{profile_internal_tag} \n\n\n\n\n\n ")

    case profile_internal_tag

      when "developer"
        @output[:elements] = [getMenuInventory(), getMenuCats(), getMenuDeployment(), getMenuSystemConfig(), getDeveloperMenu()]

      when "root"
        @output[:elements] = [getMenuInventory(), getMenuCats(), getMenuDeployment(), getMenuSystemConfig()]

      when "director"
        @output[:elements] = [getMenuDeployment()]

      when "technician"
        @output[:elements] = [getMenuInventory(), getMenuCats(), getMenuDeployment()]

      else
        @output[:elements] = []
    end

  end

  private

  def genOption(label)
    attribs = Hash.new
    attribs[:label] = label
    attribs[:type] = "option"
    attribs[:image] = "icon/22/actions/system-search.png"
    attribs[:elements] = []
    attribs 
  end

  def genElement(label, type, options = nil)
    attribs = Hash.new
    attribs[:label] = label
    attribs[:type] = type
    attribs[:image] = "icon/22/actions/contact-new.png"
    attribs[:options] = options if options
    attribs
  end

  def genDataImport
    attribs = Hash.new
    attribs[:option] = "data_importer"
    attribs
  end

  def genScriptRunner
    attribs = Hash.new
    attribs[:option] = "script_runner"
    attribs
  end

  def genAbm2(option, popup = true, add = true, modify = true, details = true, destroy = true, customButtons = [])
    attribs = Hash.new
    attribs[:option] = option
    attribs[:popup] = popup
    attribs[:add] = add
    attribs[:modify] = modify
    attribs[:details] = details
    attribs[:destroy] = destroy
    attribs[:custom] = []
    customButtons.each { |customButton|
      attribs[:custom].push(customButton)
    }
    attribs
  end

  def genCustomAbmForm(initialDataurl, saveUrl, close, clear, confirm)
    attribs = Hash.new
    attribs[:initial_data_url] = initialDataurl
    attribs[:save_url] = saveUrl
    attribs[:close_after_insert] = close
    attribs[:clear_after_insert] = clear
    attribs[:ask_confirmation] = confirm

    attribs[:addUrl] = initialDataurl
    attribs[:saveUrl] = saveUrl

    attribs
  end

  def genAbm2CustomButton(message, initialDataurl, saveUrl, icon, text)
    attribs = Hash.new
    attribs[:msg] = message
    attribs[:initial_data_url] = initialDataurl
    attribs[:save_url] = saveUrl
    attribs[:icon] = icon
    attribs[:text] = text

    attribs[:addUrl] = initialDataurl
    attribs[:saveUrl] = saveUrl
    attribs
  end

  def genReport(option)
    attribs = Hash.new
    attribs[:option] = option
    attribs
  end

  def genSchoolManagerOption
    menu_option = genOption("Fichas Escolares")
    menu_option[:elements] = genSchoolManagerElements
    menu_option
  end

  def genSchoolManagerElements
    school_type_id = PlaceType.find_by_internal_tag("school").id
    Place.roots4(current_user).map { |root|
      genSchoolsTree(root, school_type_id)
    }
  end

  def genSchoolsTree(place, school_type_id)
   if place.place_type_id == school_type_id
     attribs = genElement("Escuela "+place.name, "school_manager", place.id)
   else
     attribs = genOption(place.name)
     attribs[:elements] = place.places.map { |sub_place| genSchoolsTree(sub_place, school_type_id) }
   end
   attribs
  end

  def getDeveloperMenu
    menu_option = genOption("Configuraciones de desarrollador")
    menu_option[:elements].push(genElement("Ejecutar Codigo", "script_runner"))
    menu_option[:elements].push(getMenuListAndCreate("notifications", "Tipo de notificaciones"))
    menu_option[:elements].push(getMenuListAndCreate("images", "Imagenes"))
    menu_option[:elements].push(getMenuListAndCreate("profiles", "Perfiles"))
    menu_option[:elements].push(getMenuListAndCreate("default_values", "Valores por defecto"))
    menu_option[:elements].push(getDeveloperInform)
    menu_option
  end

  def getDeveloperInform
    menu_option = genOption("Configuraciones del sistema")
    menu_option[:elements].push(genElement("Auditoria", "report", genReport("audit_report")))
    menu_option
  end

  def getMenuConference
    menu_option = genOption("Conferencias")
    custom_abmform = genCustomAbmForm("/people/new_visitor/0", "/people/save_visitor", false, true, false)
    menu_option[:elements].push(genElement("Registro de visitantes", "custom_abm_form", custom_abmform))
    menu_option
  end

  def getMenuListAndCreate(name, label, addLabel='', listLabel='')
    addLabel  = "Agregar "  + label if addLabel  == ''
    listLabel = "Listar "   + label if listLabel == ''

    menu = genOption(label)
    menu[:elements].push(genElement(listLabel, "abm2", genAbm2(name)))
    menu[:elements].push(genElement(addLabel , "abmform", genAbm2(name)))
    
    menu
  end

  def getMenuInventory
    menu_option = genOption("Inventario")
    #menu_option[:elements].push(genElement("Cajas", "abm2", genAbm2("boxes")))
    menu_option[:elements].push(genElement("Laptops", "abm2", genAbm2("laptops")))
    #menu_option[:elements].push(genElement("Baterias", "abm2", genAbm2("baterias")))
    #menu_option[:elements].push(genElement("Cargadores", "abm2", genAbm2("cargadores")))
    #menu_option[:elements].push(genElement("Movimiento de Cajas", "abm2", genAbm2("box_movements")))

    entregas = genOption("Entregas")
    cButton1 = genAbm2CustomButton("Entrega realizada","/movements/single_mass_delivery/0","/movements/save_single_mass_delivery","add","Masiva Particular")
    cButton2 = genAbm2CustomButton("Entrega realizada","/movements/new_mass_delivery/0","/movements/save_mass_delivery","add","Lote Alumnos")
    entregas[:elements].push(genElement("Listar Entregas", "abm2", genAbm2("movimientos", true, true, true, true, true, [cButton1,cButton2])))
    entregas[:elements].push(genElement("Agregar Entrega", "abmform", genAbm2("movimientos")))
    menu_option[:elements].push(entregas)

    #menu_option[:elements].push(genElement("Entregas por detalle", "abm2", genAbm2("movement_details")))
    #menu_option[:elements].push(genElement("Activaciones", "abm2", genAbm2("activaciones")))
    menu_option[:elements].push(genElement("Lotes", "abm2", genAbm2("lots")))
    menu_option[:elements].push(getMenuInventoryInform)
    menu_option[:elements].push(getMenuInventoryConfig)
    menu_option
  end

  def getMenuInventoryInform
    menu_option = genOption("Informes")
    menu_option[:elements].push(genElement("Seriales por Localidad", "report", genReport("serials_per_places")))
    menu_option[:elements].push(genElement("Donde estan las laptops?", "report", genReport("where_are_these_laptops")))
    menu_option[:elements].push(genElement("Movimientos", "report", genReport("movements")))
    menu_option[:elements].push(genElement("Movimientos por tipo", "report", genReport("movement_types")))
    #menu_option[:elements].push(genElement("Movimientos ventana de tiempo*", "report", genReport("movements_time_range")))
    #menu_option[:elements].push(genElement("Laptops por propietario*?", "report", genReport("laptops_per_owner")))
    menu_option[:elements].push(genElement("Laptops por localidad", "report", genReport("laptops_per_place")))
    #menu_option[:elements].push(genElement("Entregas por persona*", "report", genReport("laptops_per_source_person")))
    #menu_option[:elements].push(genElement("Entregas a persona*", "report", genReport("laptops_per_destination_person")))
    #menu_option[:elements].push(genElement("Activaciones", "report", genReport("activations")))
    menu_option[:elements].push(genElement("Prestamos", "report", genReport("lendings")))
    menu_option[:elements].push(genElement("Distribucion de laptops por estado", "report", genReport("statuses_distribution")))
    menu_option[:elements].push(genElement("Registro de cambio de estado", "report", genReport("status_changes")))
    menu_option[:elements].push(genElement("Impresion de Codigos de barra", "report", genReport("barcodes")))
    menu_option[:elements].push(genElement("Impresion del recibo de entrega de un lote", "report", genReport("lots_labels")))
    #menu_option[:elements].push(genElement("Distribucion por localidad*?", "report", genReport("laptops_per_tree")))
    menu_option[:elements].push(genElement("Posibles errores e incosistencias", "report", genReport("possible_mistakes")))
    menu_option[:elements].push(genElement("Constancia de entrega a particuales", "report", genReport("printable_delivery")))
    menu_option[:elements].push(genElement("Laptops registradas", "report", genReport("registered_laptops")))
    menu_option
  end

  def getMenuInventoryConfig
    menu_option = genOption("Configuracion")
    menu_option[:elements].push(genElement("Importar Datos", "data_importer"))
    menu_option[:elements].push(getMenuListAndCreate("modelos", "Modelo de laptops"))
    menu_option[:elements].push(getMenuListAndCreate("movement_types", "Tipo de movimientos"))
    menu_option[:elements].push(getMenuListAndCreate("statuses", "Tipo de Estados"))
    menu_option[:elements].push(getMenuListAndCreate("laptop_configs", "Valores de laptop"))
    menu_option[:elements].push(getMenuListAndCreate("shipments", "Cargamentos"))
    menu_option
  end

  def getMenuCats
    menu_option = genOption("CATS")
    menu_option[:elements].push(genElement("Eventos", "abm2", genAbm2("events")))
    menu_option[:elements].push(genElement("Monitoreo de nodos", "node_tracker"))

    cButton1 = genAbm2CustomButton("Transferencias", "/part_movements/new_transfer/0", "/part_movements/save_transfer","add","Transferencias")
    menu_option[:elements].push(genElement("Movimientos de partes", "abm2", genAbm2("part_movements", true, true, true, false, true, [cButton1])))

    menu_option[:elements].push(genElement("Reporte de problemas", "abm2", genAbm2("problem_reports")))

    #cButton1 = genAbm2CustomButton("Solucion Registrada", "/problem_solutions/quick_solution/0", "/problem_solutions/save_quick_solution","add","Rapidas")
    cButton2 = genAbm2CustomButton("Solution Registrada", "/problem_solutions/change_solution/0", "/problem_solutions/save_change_solution","add","Cambios")
    cButton3 = genAbm2CustomButton("Solucion Registrada", "/problem_solutions/simple_solution/0", "/problem_solutions/save_simple_solution","add","Simples")
    menu_option[:elements].push(genElement("Soluciones de problemas", "abm2", genAbm2("problem_solutions", true, false, true, false, true, [cButton2, cButton3])))

    menu_option[:elements].push(getMenuListAndCreate("bank_deposits", "Depositos"))

    menu_option[:elements].push(getMenuCatsInform)
    menu_option[:elements].push(getMenuCatsConfig)
    menu_option
  end

  def getMenuCatsInform
    menu_option = genOption("Informes")
    menu_option[:elements].push(genElement("Distribucion de partes reemplazadas", "report", genReport("parts_replaced")))
    menu_option[:elements].push(genElement("Distribucion en el tiempo de los problemas", "report", genReport("problems_time_distribution")))
    menu_option[:elements].push(genElement("Distribucion de problemas por tipo", "report", genReport("problems_per_type")))
    menu_option[:elements].push(genElement("Distribucion de problemas por escuela", "report", genReport("problems_per_school")))
    menu_option[:elements].push(genElement("Distribucion de problemas por grado", "report", genReport("problems_per_grade")))
    menu_option[:elements].push(genElement("Distribucion de partes utilizadas por persona", "report", genReport("used_parts_per_person")))
    menu_option[:elements].push(genElement("Tiempo de funcionamiento de nodos de red", "report", genReport("online_time_statistics")))
    menu_option[:elements].push(genElement("Problemas y Depositos", "report", genReport("problems_and_deposits")))
    menu_option[:elements].push(genElement("Depositos", "report", genReport("deposits")))
    menu_option[:elements].push(genElement("Estado del stock", "report", genReport("stock_status_report")))
    menu_option[:elements].push(getMenuAldaInform)
    menu_option
  end

  def getMenuAldaInform
    menu_option = genOption("Informes ALDA")
    menu_option[:elements].push(genElement("Distribucion software/hardware", "report", genReport("is_hardware_dist")))
    menu_option[:elements].push(genElement("Numero de laptops con problemas recurrentes", "report", genReport("laptops_problems_recurrence")))
    menu_option[:elements].push(genElement("Tiempo promedio de reparacion", "report", genReport("average_solved_time")))
    menu_option
  end


  def getMenuCatsConfig
    menu_option = genOption("Configuracion")

    menu_option[:elements].push(getMenuListAndCreate("part_types", "Tipo de partes"))
    menu_option[:elements].push(getMenuListAndCreate("problem_types", "Tipo de problemas"))
    menu_option[:elements].push(getMenuListAndCreate("solution_types", "Tipo de soluciones"))
    menu_option[:elements].push(getMenuListAndCreate("node_types", "Tipo de nodos"))
    menu_option[:elements].push(getMenuListAndCreate("nodes", "Nodos"))
    menu_option[:elements].push(getMenuListAndCreate("school_infos", "School Servers"))
    menu_option[:elements].push(getMenuListAndCreate("part_movement_types", "Tipo de movimientos de partes"))
    menu_option
  end

  def getMenuDeployment
    menu_option = genOption("Personas y Localidades")
    menu_option[:elements].push(getMenuListAndCreate("localidades","Localidades"))
    menu_option[:elements].push(genElement("Tool Box", "place_tool_box"))
    menu_option[:elements].push(getMenuListAndCreate("personas","Personas"))
    menu_option[:elements].push(getMenuDeploymentInform)
    menu_option[:elements].push(getMenuDeploymentConfig)
    #menu_option[:elements].push(genSchoolManagerOption)
    menu_option
  end

  def getMenuDeploymentInform
    menu_option = genOption("Informes")
    menu_option[:elements].push(genElement("Distribucion de estudiantes con y sin cedula", "report", genReport("students_ids_distro")))
    menu_option
  end

  def getMenuDeploymentConfig
    menu_option = genOption("Configuracion")
    menu_option[:elements].push(getMenuListAndCreate("place_types", "Tipo de Localidades"))
    menu_option
  end

  def getMenuSystemConfig
    menu_option = genOption("Configuraciones del administrador")
    menu_option[:elements].push(getMenuListAndCreate("notification_subscribers", "Suscripciones a nofiticaciones"))
    menu_option[:elements].push(getMenuListAndCreate("users", "Usuarios"))
    menu_option
  end

end
