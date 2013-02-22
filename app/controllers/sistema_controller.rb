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
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 
# Author: Raúl Gutiérrez
# E-mail Address: rgs@paraguayeduca.org

require 'py_educa_util'
                                                                          
class SistemaController < ApplicationController
  around_filter :rpc_block
  skip_filter :access_control, :only => [:login, :login_info, :logout] 
  skip_filter :do_scoping, :only => [:login, :login_info, :logout]

  def initialize
    super
    @check_authentication = false
  end

  def login_info
    @output[:info] = {
      app_revision: PyEducaUtil::getAppRevisionNum(),
      lang_list: langCombo
    }
  end

  def default_lang
    default = DefaultValue.find_by_key("lang")
    default_lang = default ? default.value : nil
    default_lang = (default_lang && getAcceptedLang.include?(default_lang)) ? default_lang : "es"
  end

  def langCombo
    default = session["lang"] ? session["lang"] : default_lang
    lang_full_list = [default_lang] + (getAcceptedLang - [default])

    comboDef = []
    first = true
    lang_full_list.each { |lang|
      comboDef.push({text: getLangText(lang), value: lang, selected: first })
      first = false if first
    }

    comboDef
  end

  def login
    user = User.login(params[:username], params[:password])
    if user
      session[:user_id] = user.id
      @output["auth"] = true
      @output["privs"] = {}

      lang = params[:lang]
      accepted_languages = getAcceptedLang
      session["lang"] = session["locale"] = accepted_languages.include?(lang) ? lang : default_lang
      @output["verified_lang"] = session["lang"]
    else
      @output["msg"] = _("Wrong user or password.")
    end
  end
  
  def logout
    session[:user_id] = nil
    session["lang"] = default_lang
    @output["msg"] = _("You are no longer in the system, bye-bye.")
  end

  def gui_content
    @output[:label] = _("Applications")
    @output[:image] = "qx/icon/Tango/22/apps/preferences-users.png"
    case current_user.person.profile.internal_tag
      when "developer"
        @output[:elements] = [inventory_menu, support_menu, deployment_menu, system_menu, developer_menu]
      when "root"
        @output[:elements] = [inventory_menu, support_menu, deployment_menu, system_menu]
      when "director"
        @output[:elements] = [deployment_menu]
      when "technician"
        @output[:elements] = [inventory_menu, support_menu, deployment_menu]
      else
        @output[:elements] = []
    end
  end

  private

  def submenu(label, elements = nil)
    menu = {
      label: label,
      type: "option",
      image: "qx/icon/Tango/22/actions/system-search.png",
    }
    menu[:elements] = elements if elements
    menu
  end

  def menu_element(label, type, options = nil)
    attribs = {
      label: label,
      type: type,
      image: "qx/icon/Tango/22/actions/contact-new.png",
    }
    attribs[:options] = options if options
    attribs
  end

  def abm2(option, options = {})
    {
      option: option,
      add: true,
      modify: true,
      details: true,
      destroy: true,
    }.merge(options)
  end

  def abm2_custom_button(data_url, save_url, icon, text)
    {
      initial_data_url: data_url,
      save_url: save_url,
      icon: icon,
      text: text,
      refresh_abm: true,
      addUrl: data_url,
      saveUrl: save_url,
    }
  end

  def report(option)
    {
      option: option
    }
  end

  def developer_menu
    submenu _("Developer config options"), [
      menu_element(_("Run code"), "script_runner"),
      getMenuListAndCreate("notifications", _("Notification types")),
      getMenuListAndCreate("images", _("Images")),
      getMenuListAndCreate("profiles", _("Profiles")),
      getMenuListAndCreate("default_values", _("Default values")),
      developer_info_menu,
    ]
  end

  def developer_info_menu
    submenu _("System configuration"), [
      menu_element(_("Audit records"), "report", report("audit_report"))
    ]
  end

  def getMenuListAndCreate(name, label, addLabel='', listLabel='')
    addLabel  = _("Add ")  + label if addLabel  == ''
    listLabel = _("List ")   + label if listLabel == ''

    submenu label, [
      menu_element(listLabel, "abm2", abm2(name)),
      menu_element(addLabel , "abmform", abm2(name))
    ]
  end

  def inventory_menu
    cButton1 = abm2_custom_button("/assignments/single_mass_assignment",
                                   "/assignments/save_single_mass_assignment", "add", _("Multiple assignment"))
    assignments = submenu _("Assignments"), [
      menu_element(_("List assignments"), "abm2", abm2("assignments", modify: false, destroy: false, custom: [cButton1])),
      menu_element(_("New assignment"), "abmform", abm2("assignments")),
      menu_element(_("Mass assignment"), "barcode_scan", :mode => "assignment"),
    ]

    cButton1 = abm2_custom_button("/movements/single_mass_delivery",
                                   "/movements/save_single_mass_delivery", "add", _("Multiple movement"))
    entregas = submenu _("Movements"), [
      menu_element(_("List movements"), "abm2", abm2("movements", modify: false, destroy: false, custom: [cButton1])),
      menu_element(_("New movement"), "abmform", abm2("movements")),
      menu_element(_("Mass movement"), "barcode_scan", :mode => "movement"),
      menu_element(_("Register handout"), "register_handout"),
    ]

    submenu _("Inventory"), [
      menu_element(_("Laptops"), "abm2", abm2("laptops")),
      assignments,
      entregas,
      menu_element(_("Lots"), "abm2", abm2("lots")),
      inventory_info_menu,
      inventory_config_menu,
    ]
  end

  def inventory_info_menu
    submenu _("Reports"), [
      menu_element(_("Serial numbers per location"), "report", report("serials_per_places")),
      menu_element(_("Where are these laptops?"), "report", report("where_are_these_laptops")),
      menu_element(_("Movements"), "report", report("movements")),
      menu_element(_("Movements grouped by type"), "report", report("movement_types")),
      menu_element(_("Laptops per location"), "report", report("laptops_per_place")),
      menu_element(_("Lendings"), "report", report("lendings")),
      menu_element(_("Laptops per status"), "report", report("statuses_distribution")),
      menu_element(_("Registry of status changes"), "report", report("status_changes")),
      menu_element(_("Print barcodes"), "barcode_report"),
      menu_element(_("Print lot receipt"), "report", report("lots_labels")),
      menu_element(_("Posible errors and inconsistencies"), "report", report("possible_mistakes")),
      menu_element(_("Receipts for individuals"), "report", report("printable_delivery")),
      menu_element(_("Registered laptops"), "report", report("registered_laptops")),
      menu_element(_("People and their laptops"), "report", report("people_laptops")),
      menu_element(_("Laptops and UUIDs"), "report", report("laptops_uuids")),
      menu_element(_("Laptops check"), "report", report("laptops_check")),
      menu_element(_("Lot information"), "report", report("lot_information")),
    ]
  end

  def inventory_config_menu
    submenu _("Configuration"), [
      getMenuListAndCreate("models", _("Laptop models")),
      getMenuListAndCreate("software_versions", _("Software versions")),
      getMenuListAndCreate("movement_types", _("Movement types")),
      getMenuListAndCreate("statuses", _("Status types")),
      getMenuListAndCreate("shipments", _("Shipments")),
    ]
  end

  def support_menu
    cButton1 = abm2_custom_button("/part_movements/new_transfer/0", "/part_movements/save_transfer","add","Transferencias")
    cButton2 = abm2_custom_button("/problem_solutions/change_solution/0",
                                   "/problem_solutions/save_change_solution","add",_("Replacement"))
    cButton3 = abm2_custom_button("/problem_solutions/simple_solution/0",
                                   "/problem_solutions/save_simple_solution","add", _("Simples"))


    submenu _("Technical support"), [
      menu_element(_("Events"), "abm2", abm2("events")),
      menu_element(_("Laptop connectivity log"), "abm2", abm2("connection_events", add: false, modify: false, destroy: false)),
      menu_element(_("Network nodes tracking"), "node_tracker"),
      menu_element(_("Part movements"), "abm2", abm2("part_movements", details: false, custom: [cButton1])),
      menu_element(_("Report a problem"), "abm2", abm2("problem_reports")),
      menu_element(_("Problem solutions"), "abm2", abm2("problem_solutions", add: false, details: false, custom: [cButton2, cButton3])),
      getMenuListAndCreate("bank_deposits", _("Deposits")),
      support_info_menu,
      support_config_menu,
    ]
  end

  def support_info_menu
    submenu _("Reports"), [
      menu_element(_("Replaced parts distribution"), "report", report("parts_replaced")),
      menu_element(_("Problem time response"), "report", report("problems_time_distribution")),
      menu_element(_("Problems by type"), "report", report("problems_per_type")),
      menu_element(_("Problems by school"), "report", report("problems_per_school")),
      menu_element(_("Problems by grade"), "report", report("problems_per_grade")),
      menu_element(_("Replacement parts used by each person"), "report", report("used_parts_per_person")),
      menu_element(_("Network nodes uptime"), "report", report("online_time_statistics")),
      menu_element(_("Problems & deposits"), "report", report("problems_and_deposits")),
      menu_element(_("Deposits"), "report", report("deposits")),
      menu_element(_("Stock status"), "report", report("stock_status_report")),
      menu_element(_("Hardware vs. software dist."), "report", report("is_hardware_dist")),
      menu_element(_("Laptops with recurring problems"), "report", report("laptops_problems_recurrence")),
      menu_element(_("Average repair time"), "report", report("average_solved_time")),
    ]
  end


  def support_config_menu
    submenu _("Configuration"), [
      getMenuListAndCreate("part_types", _("Part types")),
      getMenuListAndCreate("problem_types", _("Problem types")),
      getMenuListAndCreate("solution_types", _("Solution types")),
      getMenuListAndCreate("node_types", _("Node types")),
      getMenuListAndCreate("nodes", _("Nodes")),
      getMenuListAndCreate("school_infos", _("School Servers")),
      getMenuListAndCreate("part_movement_types", _("Part movement types")),
    ]
  end

  def deployment_menu
    people = submenu _("People"), [
      menu_element(_("List people"), "abm2", abm2("people")),
      menu_element(_("Add people") , "abmform", abm2("people")),
      menu_element(_("Move people"), "people_mover"),
    ]

    submenu _("People & locations"), [
      getMenuListAndCreate("places", _("Locations")),
      menu_element(_("Tool Box"), "place_tool_box"),
      people,
      deployment_info_menu,
      deployment_config_menu,
    ]
  end

  def deployment_info_menu
    submenu _("Reports"), [
      menu_element(_("Students & document ids"), "report", report("students_ids_distro")),
      menu_element(_("Document IDs"), "report", report("people_documents")),
    ]
  end

  def deployment_config_menu
    submenu _("Configuration"), [
      getMenuListAndCreate("place_types", _("Location types")),
    ]
  end

  def system_menu
    submenu _("Administrator's configuration"), [
      menu_element(_("Import data"), "data_importer"),
      getMenuListAndCreate("notification_subscribers", _("Notification suscriptions")),
      getMenuListAndCreate("users", _("Users")),
    ]
  end

end
