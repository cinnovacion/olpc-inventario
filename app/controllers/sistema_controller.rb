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

require 'lib/py_educa_util'
                                                                          
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
    @output[:info][:lang_list] = langCombo
  end

  def login
    user = params[:username]
    password = params[:password]
    lang = params[:lang] ? params[:lang].to_s : nil

    user = User.new(:usuario => user, :password => password)
    logged_in_user = user.authenticate()
    if logged_in_user
      session[:user_id] = logged_in_user.id
      @output["auth"] = true
      
      # Pasar permisos
      @output["privs"] = {}

      #Setting language
      setLanguage(lang)
      @output["verified_lang"] = session["lang"]
    else
      @output["msg"] = _("Wrong user or password.")
    end
  end
  
  def logout
    session[:user_id] = nil
    session["lang"] = getDefaultLang
    @output["msg"] = _("You are no longer in the system, bye-bye.")
  end

  def welcome_info
  end

  ###
  # Tincho says: All the content for the GUI will be located
  #              in the server side, for usability reasons.
  def gui_content
    @output[:label] = _("Applications")
    @output[:image]= "qx/icon/Tango/22/apps/preferences-users.png"
    @output[:elements] = []

    profile_internal_tag = current_user.person.profile.internal_tag

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
    attribs[:image] = "qx/icon/Tango/22/actions/system-search.png"
    attribs[:elements] = []
    attribs 
  end

  def genElement(label, type, options = nil)
    attribs = Hash.new
    attribs[:label] = label
    attribs[:type] = type
    attribs[:image] = "qx/icon/Tango/22/actions/contact-new.png"
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

  def genAbm2(option, add = true, modify = true, details = true, destroy = true, customButtons = [])
    attribs = Hash.new
    attribs[:option] = option
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

  def genAbm2CustomButton(initialDataurl, saveUrl, icon, text, refresh_abm)
    attribs = Hash.new
    attribs[:initial_data_url] = initialDataurl
    attribs[:save_url] = saveUrl
    attribs[:icon] = icon
    attribs[:text] = text
    attribs[:refresh_abm] = refresh_abm

    attribs[:addUrl] = initialDataurl
    attribs[:saveUrl] = saveUrl
    attribs
  end

  def genReport(option)
    attribs = Hash.new
    attribs[:option] = option
    attribs
  end

  def getDeveloperMenu
    menu_option = genOption(_("Developer config options"))
    menu_option[:elements].push(genElement(_("Run code"), "script_runner"))
    menu_option[:elements].push(getMenuListAndCreate("notifications", _("Notification types")))
    menu_option[:elements].push(getMenuListAndCreate("images", _("Images")))
    menu_option[:elements].push(getMenuListAndCreate("profiles", _("Profiles")))
    menu_option[:elements].push(getMenuListAndCreate("default_values", _("Default values")))
    menu_option[:elements].push(getDeveloperInform)
    menu_option
  end

  def getDeveloperInform
    menu_option = genOption(_("System configuration"))
    menu_option[:elements].push(genElement(_("Audit records"), "report", genReport("audit_report")))
    menu_option
  end

  def getMenuListAndCreate(name, label, addLabel='', listLabel='')
    addLabel  = _("Add ")  + label if addLabel  == ''
    listLabel = _("List ")   + label if listLabel == ''

    menu = genOption(label)
    menu[:elements].push(genElement(listLabel, "abm2", genAbm2(name)))
    menu[:elements].push(genElement(addLabel , "abmform", genAbm2(name)))
    
    menu
  end

  def getMenuInventory
    menu_option = genOption(_("Inventory"))
    #menu_option[:elements].push(genElement("Cajas", "abm2", genAbm2("boxes")))
    menu_option[:elements].push(genElement(_("Laptops"), "abm2", genAbm2("laptops")))
    #menu_option[:elements].push(genElement("Baterias", "abm2", genAbm2("baterias")))
    #menu_option[:elements].push(genElement("Cargadores", "abm2", genAbm2("cargadores")))
    #menu_option[:elements].push(genElement("Movimiento de Cajas", "abm2", genAbm2("box_movements")))

    assignments = genOption(_("Assignments"))

    cButton1 = genAbm2CustomButton("/assignments/single_mass_assignment/0",
                                   "/assignments/save_single_mass_assignment", "add", _("Multiple assignment"), true)

    assignments[:elements].push(genElement(_("List assignments"), "abm2", 
                                        genAbm2("assignments", true, false, true, false, [cButton1])))
    assignments[:elements].push(genElement(_("New assignment"), "abmform", genAbm2("assignments")))
    assignments[:elements].push(genElement(_("Mass assignment"), "barcode_scan", :mode => "assignment"))
    menu_option[:elements].push(assignments)

    entregas = genOption(_("Movements"))
 
    cButton1 = genAbm2CustomButton("/movements/single_mass_delivery/0",
                                   "/movements/save_single_mass_delivery", "add", _("Multiple movement"), true)
    cButton2 = genAbm2CustomButton("/movements/new_handout/0",
                                   "/movements/save_handout", "add", _("Register handout"), true)
    entregas[:elements].push(genElement(_("List movements"), "abm2", 
                                        genAbm2("movimientos", true, false, true, false, [cButton1,cButton2])))
    entregas[:elements].push(genElement(_("New movement"), "abmform", genAbm2("movimientos")))
    entregas[:elements].push(genElement(_("Mass movement"), "barcode_scan", :mode => "movement"))
    menu_option[:elements].push(entregas)

    #menu_option[:elements].push(genElement("Entregas por detalle", "abm2", genAbm2("movement_details")))
    #menu_option[:elements].push(genElement("Activaciones", "abm2", genAbm2("activaciones")))
    menu_option[:elements].push(genElement(_("Lots"), "abm2", genAbm2("lots")))
    menu_option[:elements].push(getMenuInventoryInform)
    menu_option[:elements].push(getMenuInventoryConfig)
    menu_option
  end

  def getMenuInventoryInform
    menu_option = genOption(_("Reports"))
    menu_option[:elements].push(genElement(_("Serial numbers per location"), "report", genReport("serials_per_places")))
    menu_option[:elements].push(genElement(_("Where are these laptops?"), "report", genReport("where_are_these_laptops")))
    menu_option[:elements].push(genElement(_("Movements"), "report", genReport("movements")))
    menu_option[:elements].push(genElement(_("Movements grouped by type"), "report", genReport("movement_types")))
    #menu_option[:elements].push(genElement("Movimientos ventana de tiempo*", "report", genReport("movements_time_range")))
    #menu_option[:elements].push(genElement("Laptops por propietario*?", "report", genReport("laptops_per_owner")))
    menu_option[:elements].push(genElement(_("Laptops per location"), "report", genReport("laptops_per_place")))
    #menu_option[:elements].push(genElement("Entregas por persona*", "report", genReport("laptops_per_source_person")))
    #menu_option[:elements].push(genElement("Entregas a persona*", "report", genReport("laptops_per_destination_person")))
    #menu_option[:elements].push(genElement("Activaciones", "report", genReport("activations")))
    menu_option[:elements].push(genElement(_("Lendings"), "report", genReport("lendings")))
    menu_option[:elements].push(genElement(_("Laptops per status"), "report", genReport("statuses_distribution")))
    menu_option[:elements].push(genElement(_("Registry of status changes"), "report", genReport("status_changes")))
    menu_option[:elements].push(genElement(_("Print barcodes"), "report", genReport("barcodes")))
    menu_option[:elements].push(genElement(_("Print lot receipt"), "report", genReport("lots_labels")))
    #menu_option[:elements].push(genElement("Distribucion por localidad*?", "report", genReport("laptops_per_tree")))
    menu_option[:elements].push(genElement(_("Posible errors and inconsistencies"), "report", genReport("possible_mistakes")))
    menu_option[:elements].push(genElement(_("Receipts for individuals"), "report", genReport("printable_delivery")))
    menu_option[:elements].push(genElement(_("Registered laptops"), "report", genReport("registered_laptops")))
    menu_option[:elements].push(genElement(_("People and their laptops"), "report", genReport("people_laptops")))
    menu_option[:elements].push(genElement(_("People and their laptops (XLS)"), "report", genReport("people_laptops_xls")))
    menu_option[:elements].push(genElement(_("Laptops and UUIDs"), "report", genReport("laptops_uuids")))
    menu_option[:elements].push(genElement(_("Laptops check"), "report", genReport("laptops_check")))
    menu_option[:elements].push(genElement(_("Lot information"), "report", genReport("lot_information")))
    menu_option
  end

  def getMenuInventoryConfig
    menu_option = genOption(_("Configuration"))
    menu_option[:elements].push(getMenuListAndCreate("modelos", _("Laptop models")))
    menu_option[:elements].push(getMenuListAndCreate("movement_types", _("Movement types")))
    menu_option[:elements].push(getMenuListAndCreate("statuses", _("Status types")))
    menu_option[:elements].push(getMenuListAndCreate("laptop_configs", _("Laptop (default) values")))
    menu_option[:elements].push(getMenuListAndCreate("shipments", _("Shipments")))
    menu_option
  end

  def getMenuCats
    menu_option = genOption(_("Technical support"))
    menu_option[:elements].push(genElement(_("Events"), "abm2", genAbm2("events")))
    menu_option[:elements].push(genElement(_("Network nodes tracking"), "node_tracker"))

    cButton1 = genAbm2CustomButton("/part_movements/new_transfer/0", "/part_movements/save_transfer","add","Transferencias", true)
    menu_option[:elements].push(genElement(_("Part movements"), "abm2", genAbm2("part_movements", true, true, false, true, [cButton1])))

    menu_option[:elements].push(genElement(_("Report a problem"), "abm2", genAbm2("problem_reports")))

    #cButton1 = genAbm2CustomButton("/problem_solutions/quick_solution/0", "/problem_solutions/save_quick_solution","add","Rapidas")
    cButton2 = genAbm2CustomButton("/problem_solutions/change_solution/0",
                                   "/problem_solutions/save_change_solution","add",_("Replacement"), true)
    cButton3 = genAbm2CustomButton("/problem_solutions/simple_solution/0",
                                   "/problem_solutions/save_simple_solution","add", _("Simples"), true)
    menu_option[:elements].push(genElement(_("Problem solutions"), "abm2", 
                                           genAbm2("problem_solutions", false, true, false, true, [cButton2, cButton3])))

    menu_option[:elements].push(getMenuListAndCreate("bank_deposits", _("Deposits")))

    menu_option[:elements].push(getMenuCatsInform)
    menu_option[:elements].push(getMenuCatsConfig)
    menu_option
  end

  def getMenuCatsInform
    menu_option = genOption(_("Reports"))
    menu_option[:elements].push(genElement(_("Replaced parts distribution"), "report", genReport("parts_replaced")))
    menu_option[:elements].push(genElement(_("Problem time response"), "report", genReport("problems_time_distribution")))
    menu_option[:elements].push(genElement(_("Problems by type"), "report", genReport("problems_per_type")))
    menu_option[:elements].push(genElement(_("Problems by school"), "report", genReport("problems_per_school")))
    menu_option[:elements].push(genElement(_("Problems by grade"), "report", genReport("problems_per_grade")))
    menu_option[:elements].push(genElement(_("Replacement parts used by each person"), "report", genReport("used_parts_per_person")))
    menu_option[:elements].push(genElement(_("Network nodes uptime"), "report", genReport("online_time_statistics")))
    menu_option[:elements].push(genElement(_("Problems & deposits"), "report", genReport("problems_and_deposits")))
    menu_option[:elements].push(genElement(_("Deposits"), "report", genReport("deposits")))
    menu_option[:elements].push(genElement(_("Stock status"), "report", genReport("stock_status_report")))
    menu_option[:elements].push(genElement(_("Hardware vs. software dist."), "report", genReport("is_hardware_dist")))
    menu_option[:elements].push(genElement(_("Laptops with recurring problems"), "report", genReport("laptops_problems_recurrence")))
    menu_option[:elements].push(genElement(_("Average repair time"), "report", genReport("average_solved_time")))
    menu_option
  end


  def getMenuCatsConfig
    menu_option = genOption(_("Configuration"))

    menu_option[:elements].push(getMenuListAndCreate("part_types", _("Part types")))
    menu_option[:elements].push(getMenuListAndCreate("problem_types", _("Problem types")))
    menu_option[:elements].push(getMenuListAndCreate("solution_types", _("Solution types")))
    menu_option[:elements].push(getMenuListAndCreate("node_types", _("Node types")))
    menu_option[:elements].push(getMenuListAndCreate("nodes", _("Nodes")))
    menu_option[:elements].push(getMenuListAndCreate("school_infos", _("School Servers")))
    menu_option[:elements].push(getMenuListAndCreate("part_movement_types", _("Part movement types")))
    menu_option
  end

  def getMenuDeployment
    menu_option = genOption(_("People & locations"))
    menu_option[:elements].push(getMenuListAndCreate("localidades", _("Locations")))
    menu_option[:elements].push(genElement(_("Tool Box"), "place_tool_box"))

    submenu = genOption(_("People"))
    submenu[:elements].push(genElement(_("List people"), "abm2", genAbm2("personas", true, true, true, true)))
    submenu[:elements].push(genElement(_("Add people") , "abmform", genAbm2("personas")))
    submenu[:elements].push(genElement(_("Move people"), "people_mover"))
    menu_option[:elements].push(submenu)
    menu_option[:elements].push(getMenuDeploymentInform)
    menu_option[:elements].push(getMenuDeploymentConfig)
    menu_option
  end

  def getMenuDeploymentInform
    menu_option = genOption(_("Reports"))
    menu_option[:elements].push(genElement(_("Students & document ids"), "report", genReport("students_ids_distro")))
    menu_option[:elements].push(genElement(_("Document IDs"), "report", genReport("people_documents")))
    menu_option
  end

  def getMenuDeploymentConfig
    menu_option = genOption(_("Configuration"))
    menu_option[:elements].push(getMenuListAndCreate("place_types", _("Location types")))
    menu_option
  end

  def getMenuSystemConfig
    menu_option = genOption(_("Administrator's configuration"))
    menu_option[:elements].push(genElement(_("Import data"), "data_importer"))
    menu_option[:elements].push(getMenuListAndCreate("notification_subscribers", _("Notification suscriptions")))
    menu_option[:elements].push(getMenuListAndCreate("users", _("Users")))
    menu_option
  end

end
