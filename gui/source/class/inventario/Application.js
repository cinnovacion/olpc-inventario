
/*************************************************************************

   Copyright: Paraguay Educa 2008//     This program is free software: you can redistribute it and/or modify
//     it under the terms of the GNU General Public License as published by
//     the Free Software Foundation, either version 3 of the License, or
//     (at your option) any later version.
// 
//     This program is distributed in the hope that it will be useful,
//     but WITHOUT ANY WARRANTY; without even the implied warranty of
//     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//     GNU General Public License for more details.
// 
//     You should have received a copy of the GNU General Public License
//     along with this program.  If not, see <http://www.gnu.org/licenses/>
// 
//                                                                          


   License: GPL

   Authors: Raul Gutierrez S. (con ideas de Sebastian Codas)

************************************************************************ */
/* ************************************************************************

#asset(inventario/*)

************************************************************************ */

/**
 * This is the main application class of your custom application "inventario"
 */
qx.Class.define("inventario.Application",
{
  extend : qx.application.Standalone,

  properties :
  {
    userName :
    {
      check : "String",
      init  : ""
    }
  },




  /*
      *****************************************************************************
         MEMBERS
      *****************************************************************************
      */

  statics : { appInstance : null },

  members :
  {
    /**
     * This method contains the initial application code and gets called 
     * during startup of the application
     *
     * @return {void} 
     */
    main : function()
    {
      // for future references... HACK!
      inventario.Application.appInstance = this;

      // Call super class
      this.base(arguments);

      // Transtation language
      qx.locale.Manager.getInstance().setLocale("es");
      this.startApp();
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    startApp : function()
    {
      this.option_name = null;
      this.object_table = {};

      // clean up visual environment
      inventario.widget.Layout.removeChilds(this.getRoot());

      // Enable logging in debug variant
      if (qx.core.Variant.isSet("qx.debug", "on"))
      {
        // support native logging capabilities, e.g. Firebug for Firefox
        qx.log.appender.Native;

        // support additional cross-browser console. Press F7 to toggle visibility
        qx.log.appender.Console;
      }

      var loginObj = this._getLoginObj();
      loginObj.login("Bienvenido al Sistema");
    },


    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    _getLoginObj : function()
    {
      // TODO: we could save a reference to this object to avoid re-instantiating
      var loginObj = new inventario.sistema.Login("/sistema/login");
      loginObj.setCallBackFn(this._loadMainWin);
      loginObj.setCallBackContext(this);

      return loginObj;
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _loadMainWin : function()
    {
      // Main Vbox, containing the taskbar and the old screen.
      var mainVbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(5));

      // Main toolbar that will act as a taskbar.
      var taskbar = inventario.widget.TaskBar.getInstance();
      taskbar.clearIt();

      var launcher = new inventario.widget.ApplicationLauncher(mainVbox);
      launcher.setContentRequestUrl("/sistema/gui_content");
      launcher.loadGuiContent();
      taskbar.addLeft(launcher);

      var logout = inventario.sistema.Logout.getInstance();
      taskbar.addRight(logout);

      // Main Split Pane
      // var mainsplit = new qx.ui.splitpane.Pane("horizontal");
      var mainsplit = new qx.ui.splitpane.Pane("horizontal");

      // var m = this._makeMenu();
      // mainsplit.add(m, 1);
      var layout = new qx.ui.layout.VBox();
      var panel = new qx.ui.container.Composite(layout);
      this.main_panel = panel;

      var welcomeInfo = new inventario.window.WelcomeInfo(null);
      // pass along the list of menu elements for spotlight widget to make use of them
      welcomeInfo.setMenuElements(launcher.getMenuElements());
      welcomeInfo.setPage(this.main_panel);
      welcomeInfo.show();

      // mainsplit.add(panel, 3);
      mainVbox.add(panel, { flex : 1 });
      mainVbox.add(taskbar);

      this.getRoot().add(mainVbox,
      {
        left   : 0,
        right  : 0,
        top    : 0,
        bottom : 0
      });
    },


    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    _makeMenu : function()
    {
      var tree1 = new qx.ui.tree.Tree();
      tree1.setDecorator(null);

      var root = new qx.ui.tree.TreeFolder("Inicio");
      root.setUserData("start", true);

      tree1.setRoot(root);
      tree1.select(root);

      this.tree = tree1;

      tree1.addListener("changeSelection", this.treeGetSelection, this);
      tree1.addListener("dblclick", this._activate_option_cb, this);

      // Inventory
      var nodes = new Array();

      nodes.push(
      {
        label       : "Cajas",
        option_name : "boxes"
      });

      nodes.push(
      {
        label       : "Laptops",
        option_name : "laptops"
      });

      nodes.push(
      {
        label       : "Baterias",
        option_name : "baterias"
      });

      nodes.push(
      {
        label       : "Cargadores",
        option_name : "cargadores"
      });

      nodes.push(
      {
        label       : "Mov. Cajas",
        option_name : "movimientos_cajas"
      });

      nodes.push(
      {
        label       : "Entregas",
        option_name : "movimientos"
      });

      nodes.push(
      {
        label       : "Ent. x detalles",
        option_name : "movimientos_detalles"
      });

      nodes.push(
      {
        label       : "Activaciones",
        option_name : "activaciones"
      });

      nodes.push(
      {
        label       : "Lotes",
        option_name : "lots"
      });

      this._addSubTree(root, "Inventario", nodes);

      // CATS
      var nodes = new Array();

      // nodes.push({ label : "Call Center", option_name : "activaciones" });
      // nodes.push({ label : "Visitas Periodicas", option_name : "activaciones" });
      // nodes.push({ label : "Mov. Cajas", option_name : "movimientos_cajas" });
      // nodes.push({ label : "Entregas", option_name : "movimientos" });
      // nodes.push({ label : "Ent. x detalles", option_name : "movimientos_detalles" });
      // nodes.push({ label : "Activaciones", option_name : "activaciones" });
      nodes.push(
      {
        label       : "Eventos",
        option_name : "events"
      });

      nodes.push(
      {
        label       : "Estado de Nodos",
        option_name : "nodes_state"
      });

      nodes.push(
      {
        label       : "Partes en stock",
        option_name : "parts"
      });

      nodes.push(
      {
        label       : "Problemas",
        option_name : "problem_reports"
      });

      nodes.push(
      {
        label       : "Reparaciones",
        option_name : "problem_solutions"
      });

      nodes.push(
      {
        label       : "Tipo de partes",
        option_name : "part_types"
      });

      nodes.push(
      {
        label       : "Tipo de problemas",
        option_name : "problem_types"
      });

      nodes.push(
      {
        label       : "Tipo de soluciones",
        option_name : "solution_types"
      });

      this._addSubTree(root, "CATS", nodes);

      // Schools
      var nodes = new Array();

      //       nodes.push( { label :"Escuelas", option_name : "schools" } );
      //       nodes.push( { label : "Docentes", option_name : "teachers" } );
      //       nodes.push( { label : "Alumnos", option_name : "students" } );
      //       nodes.push( { label : "Infraestructura", option_name : "students" } );
      //       nodes.push( { label : "Notas", option_name : "students" } );
      //       nodes.push( { label : "Evaluaciones", option_name : "students" } );
      var root_schools = this._addSubTree(root, "Fichas Escuelas", nodes);
      root_schools.setUserData("schools", true);

      // Training
      var nodes = new Array();

      nodes.push(
      {
        label       : "Formadores",
        option_name : "schools"
      });

      nodes.push(
      {
        label       : "Docentes",
        option_name : "teachers"
      });

      nodes.push(
      {
        label       : "Asistencia",
        option_name : "students"
      });

      nodes.push(
      {
        label       : "Evaluaciones",
        option_name : "students"
      });

      this._addSubTree(root, "Capacitaciones", nodes);

      // Reports
      var nodes = new Array();
      var nodes_status = new Array();

      nodes_status.push(
      {
        label       : "Entregas",
        option_name : "report_deliveries"
      });

      nodes_status.push(
      {
        label       : "Tipo Movimientos",
        option_name : "report_movement_types"
      });

      nodes_status.push(
      {
        label       : "Movimientos en ventana de tiempo",
        option_name : "report_movements_time_range"
      });

      nodes_status.push(
      {
        label       : "Laptops por propietario",
        option_name : "report_laptops_per_owner"
      });

      nodes_status.push(
      {
        label       : "Laptops por localidad",
        option_name : "report_laptops_per_place"
      });

      nodes_status.push(
      {
        label       : "Laptops entregadas por personas",
        option_name : "report_laptops_per_source_person"
      });

      nodes_status.push(
      {
        label       : "Laptops entregadas a personas",
        option_name : "report_laptops_per_destination_person"
      });

      nodes_status.push(
      {
        label       : "Activaciones",
        option_name : "report_activations"
      });

      nodes_status.push(
      {
        label       : "Prestamos",
        option_name : "report_lendings"
      });

      nodes_status.push(
      {
        label       : "Distribucion por estado",
        option_name : "report_statuses_distribution"
      });

      nodes_status.push(
      {
        label       : "Cambios de estado",
        option_name : "report_status_changes"
      });

      nodes_status.push(
      {
        label       : "Impresion de Codigo de Barras",
        option_name : "barcodes"
      });

      nodes_status.push(
      {
        label       : "Impresion de Recibo de entrega",
        option_name : "lots_labels"
      });

      nodes_status.push(
      {
        label       : "Distribucion de laptops",
        option_name : "laptops_per_tree"
      });

      nodes_status.push(
      {
        label       : "Posibles errores durante las entregas.",
        option_name : "possible_mistakes"
      });

      nodes_status.push(
      {
        label       : "Entrega particular Imprimible",
        option_name : "printable_delivery"
      });

      nodes_status.push(
      {
        label       : "Laptops por estado de registro",
        option_name : "registered_laptops"
      });

      nodes.push(
      {
        title : "Inventario y Entregas",
        nodes : nodes_status
      });

      var nodes_status = new Array();

      nodes_status.push(
      {
        label       : "Cantidad de partes reemplazadas",
        option_name : "report_parts_replaced"
      });

      nodes_status.push(
      {
        label       : "Partes en el stock",
        option_name : "report_available_parts"
      });

      nodes_status.push(
      {
        label       : "Problemas por tipo",
        option_name : "report_problems_per_type"
      });

      nodes.push(
      {
        title : "Reparaciones y Partes",
        nodes : nodes_status
      });

      this._addSubTree(root, "Reportes", nodes);

      // Config
      var nodes = new Array();

      nodes.push(
      {
        label       : "Modelos",
        option_name : "modelos"
      });

      nodes.push(
      {
        label       : "Localidades",
        option_name : "localidades"
      });

      nodes.push(
      {
        label       : "Personas",
        option_name : "personas"
      });

      nodes.push(
      {
        label       : "Shipments",
        option_name : "shipments"
      });

      nodes.push(
      {
        label       : "Tipo Movimientos",
        option_name : "motivos_movimientos"
      });

      nodes.push(
      {
        label       : "Valores Laptops",
        option_name : "laptop_configs"
      });

      nodes.push(
      {
        label       : "Estados",
        option_name : "statuses"
      });

      nodes.push(
      {
        label       : "Notificaciones",
        option_name : "notifications"
      });

      nodes.push(
      {
        label       : "Suscripciones",
        option_name : "notification_subscribers"
      });

      nodes.push(
      {
        label       : "Imagenes",
        option_name : "images"
      });

      nodes.push(
      {
        label       : "Perfiles",
        option_name : "profiles"
      });

      nodes.push(
      {
        label       : "Usuarios",
        option_name : "users"
      });

      nodes.push(
      {
        label       : "Tipo de Lugares",
        option_name : "place_types"
      });

      nodes.push(
      {
        label       : "Tipo de Nodos",
        option_name : "node_types"
      });

      nodes.push(
      {
        label       : "Nodos",
        option_name : "nodes"
      });

      nodes.push(
      {
        label       : "Importar Datos",
        option_name : "data_import"
      });

      nodes.push(
      {
        label       : "School Servers",
        option_name : "school_infos"
      });

      this._addSubTree(root, "Configuracion", nodes);

      // Quizzes
      var nodes = new Array();

      nodes.push(
      {
        label       : "Questionarios",
        option_name : "quizzes"
      });

      nodes.push(
      {
        label       : "Respuestas",
        option_name : "answers"
      });

      this._addSubTree(root, "Evaluaciones", nodes);

      return tree1;
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _activate_option_cb : function(e)
    {
      if (this.option_name && this.option_name != "") {
        this._activateMainPanel();
      }
      else
      {
        var treeNode = this.tree.getSelectedItem();

        if (treeNode.getUserData("schools"))
        {
          // request  school's tree
          var params = {};
          params.treeNode = treeNode;
          var hopts = {};
          hopts["url"] = "/places/schools";
          hopts["parametros"] = params;
          hopts["handle"] = this._loadSchoolsResp;
          hopts["data"] = {};

          inventario.transport.Transport.callRemote(hopts, this);
        }
        else if (treeNode.getUserData("start"))
        {
          this.main_panel.removeAll();

          var welcomeInfo = new inventario.window.WelcomeInfo(null);
          welcomeInfo.setPage(this.main_panel);
          welcomeInfo.show();
        }
      }
    },

    // load schools tree
    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _loadSchoolsResp : function(remoteData, params)
    {
      // empty the node first..
      var firstTime = false;
      var treeNode = params.treeNode;

      if (treeNode.getChildren().length == 0) {
        firstTime = true;
      } else {
        treeNode.removeAll();
      }

      this._populateTree(treeNode, remoteData["nodes"]);

      if (firstTime) {
        treeNode.setOpen(true);
      }
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    treeGetSelection : function(e)
    {
      var treeNode = this.tree.getSelectedItem();
      this.option_name = treeNode.getUserData("option_name");
      this.selected_label = treeNode.getUserData("label");
    },


    /**
     * TODOC
     *
     * @param t {var} TODOC
     * @param config {var} TODOC
     * @return {void} 
     */
    _addNode : function(t, config)
    {
      var label = config.label;
      var child = new qx.ui.tree.TreeFile(label);
      child.setUserData("option_name", config.option_name);
      child.setUserData("label", label);
      t.add(child);
    },


    /**
     * TODOC
     *
     * @param tree {var} TODOC
     * @param title {var} TODOC
     * @param nodes {var} TODOC
     * @return {var} TODOC
     */
    _addSubTree : function(tree, title, nodes)
    {
      var root = new qx.ui.tree.TreeFolder(title);

      this._populateTree(root, nodes);

      tree.add(root);

      return root;
    },


    /**
     * TODOC
     *
     * @param root {var} TODOC
     * @param nodes {var} TODOC
     * @return {void} 
     */
    _populateTree : function(root, nodes)
    {
      var len = nodes.length;

      for (var i=0; i<len; i++)
      {
        if (nodes[i]["title"]) this._addSubTree(root, nodes[i]["title"], nodes[i]["nodes"]);
        else this._addNode(root, nodes[i]);
      }
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _activateMainPanel : function()
    {
      this.main_panel.removeAll();

      // agregar catching de objetos
      switch(this.option_name)
      {
        case "boxes":
          var boxes = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("boxes"));
          boxes.setPage(this.main_panel);
          boxes.show();
          break;

        case "laptops":
          var laptops = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("laptops"));
          laptops.setPage(this.main_panel);
          laptops.show();
          break;

        case "baterias":
          var baterias = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("baterias"));
          baterias.setPage(this.main_panel);
          baterias.show();
          break;

        case "cargadores":
          var cargadores = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("cargadores"));
          cargadores.setPage(this.main_panel);
          cargadores.show();
          break;

        case "movimientos_cajas":
          var box_movements = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("box_movements"));
          box_movements.setPage(this.main_panel);
          box_movements.show();
          break;

        case "movimientos":
          var movimientos = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("movimientos"));
          movimientos.setPage(this.main_panel);
          movimientos.setShowModifyButton(false);
          movimientos.setShowDetailsButton(false);
          movimientos.setShowDeleteButton(false);

          var saveCallback = function(remoteData, handleParams)
          {
            var msg = (remoteData["msg"] ? remoteData["msg"] : " Entrega realizada correctamente.");
            inventario.window.Mensaje.mensaje(msg);
          };

          var f = function()
          {
            var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
            var mass_add_form = new inventario.window.AbmForm(null, {});
            mass_add_form.setSaveCallback(saveCallback);
            mass_add_form.setSaveCallbackObj(this);
            mass_add_form.setInitialDataUrl("/movements/new_mass_delivery/0");
            mass_add_form.setSaveUrl("/movements/save_mass_delivery");
            mass_add_form.setPage(hbox);
            mass_add_form.setCloseAfterInsert(true);
            mass_add_form.setUsePopup(true);
            mass_add_form.show();
          };

          var button =
          {
            type            : "button",
            icon            : "add",
            text            : "Entrega por lote",
            callBackFunc    : f,
            callBackContext : this
          };

          movimientos.getToolBarButtons().push(button);

          movimientos.show();
          break;

        case "activaciones":
          var activaciones = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("activaciones"));
          activaciones.setPage(this.main_panel);
          activaciones.show();
          break;

        case "modelos":
          var modelos = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("modelos"));
          modelos.setPage(this.main_panel);
          modelos.show();
          break;

        case "localidades":
          var localidades = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("localidades"));
          localidades.setPage(this.main_panel);
          localidades.show();
          break;

        case "personas":
          var personas = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("personas"));
          personas.setPage(this.main_panel);
          personas.show();
          break;

        case "shipments":
          var shipments = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("shipments"));
          shipments.setPage(this.main_panel);
          shipments.show();
          break;

        case "movimientos_detalles":
          var mov_details = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("movement_details"));
          mov_details.setPage(this.main_panel);
          mov_details.setShowAddButton(false);
          mov_details.setShowModifyButton(false);
          mov_details.setShowDetailsButton(false);
          mov_details.setShowDeleteButton(false);
          mov_details.show();
          break;

        case "motivos_movimientos":
          var mov_types = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("movement_types"));
          mov_types.setPage(this.main_panel);
          mov_types.show();
          break;

        case "laptop_configs":
          var laptop_configs = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("laptop_configs"));
          laptop_configs.setShowAddButton(false);
          laptop_configs.setShowDeleteButton(false);
          laptop_configs.setPage(this.main_panel);
          laptop_configs.show();
          break;

        case "report_deliveries":
          var report_deliveries = new inventario.report.ReportGenerator(null);
          report_deliveries.show("movements", this.selected_label, true);
          break;

        case "report_movement_types":
          var report_mov_types = new inventario.report.ReportGenerator(null);
          report_mov_types.show("movement_types", this.selected_label, true);
          break;

        case "report_movements_time_range":
          var report_mov_time_range = new inventario.report.ReportGenerator(null);
          report_mov_time_range.show("movements_time_range", this.selected_label, true);
          break;

        case "report_laptops_per_owner":
          var report_laptops_per_owner = new inventario.report.ReportGenerator(null);
          report_laptops_per_owner.show("laptops_per_owner", this.selected_label, true);
          break;

        case "report_laptops_per_place":
          var report_laptops_per_place = new inventario.report.ReportGenerator(null);
          report_laptops_per_place.show("laptops_per_place", this.selected_label, true);
          break;

        case "report_laptops_per_source_person":
          var report_laptops_per_source_person = new inventario.report.ReportGenerator(null);
          report_laptops_per_source_person.show("laptops_per_source_person", this.selected_label, true);
          break;

        case "report_laptops_per_destination_person":
          var report_laptops_per_destination_person = new inventario.report.ReportGenerator(null);
          report_laptops_per_destination_person.show("laptops_per_destination_person", this.selected_label, true);
          break;

        case "report_activations":
          var report_activations = new inventario.report.ReportGenerator(null);
          report_activations.show("activations", this.selected_label, true);
          break;

        case "report_lendings":
          var report_lendings = new inventario.report.ReportGenerator(null);
          report_lendings.show("lendings", this.selected_label, true);
          break;

        case "report_statuses_distribution":
          var report_statuses_distribution = new inventario.report.ReportGenerator(null);
          report_statuses_distribution.show("statuses_distribution", this.selected_label, true);
          break;

        case "report_status_changes":
          var report_status_changes = new inventario.report.ReportGenerator(null);
          report_status_changes.show("status_changes", this.selected_label, true);
          break;

        case "statuses":
          var report_statuses = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("statuses"));
          report_statuses.setPage(this.main_panel);
          report_statuses.show();
          break;

        case "notifications":
          var notifications = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("notifications"));
          notifications.setPage(this.main_panel);
          notifications.setShowAddButton(false);
          notifications.setShowDeleteButton(false);
          notifications.show();
          break;

        case "notification_subscribers":
          var notification_subscribers = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("notification_subscribers"));
          notification_subscribers.setPage(this.main_panel);
          notification_subscribers.show();
          break;

        case "part_types":
          var part_types = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("part_types"));
          part_types.setPage(this.main_panel);
          part_types.setShowModifyButton(false);
          part_types.setShowDetailsButton(false);
          part_types.setShowDeleteButton(false);
          part_types.show();
          break;

        case "problem_types":
          var problem_types = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("problem_types"));
          problem_types.setPage(this.main_panel);
          problem_types.show();
          break;

        case "parts":
          var parts = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("parts"));
          parts.setPage(this.main_panel);
          parts.show();
          break;

        case "problem_solutions":
          var problem_solutions = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("problem_solutions"));
          problem_solutions.setPage(this.main_panel);
          problem_solutions.show();
          break;

        case "report_parts_replaced":
          var report_parts_replaced = new inventario.report.ReportGenerator(null);
          report_parts_replaced.show("parts_replaced", this.selected_label, true);
          break;

        case "report_available_parts":
          var report_available_parts = new inventario.report.ReportGenerator(null);
          report_available_parts.show("available_parts", this.selected_label, true);
          break;

        case "report_problems_per_type":
          var report_problems_per_type = new inventario.report.ReportGenerator(null);
          report_problems_per_type.show("problems_per_type", this.selected_label, true);
          break;

        case "images":
          var images = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("images"));
          images.setPage(this.main_panel);
          images.show();
          break;

        case "profiles":
          var profiles = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("profiles"));
          profiles.setPage(this.main_panel);
          profiles.show();
          break;

        case "users":
          var users = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("users"));
          users.setPage(this.main_panel);
          users.show();
          break;

        case "place_types":
          var place_types = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("place_types"));
          place_types.setPage(this.main_panel);
          place_types.show();
          break;

        case "node_types":
          var node_types = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("node_types"));
          node_types.setPage(this.main_panel);
          node_types.show();
          break;

        case "nodes":
          var nodes = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("nodes"));
          nodes.setPage(this.main_panel);
          nodes.show();
          break;

        case "nodes_state":
          var nodes_state = new inventario.widget.NodeTracker(null);
          nodes_state.setPage(this.main_panel);
          nodes_state.setUsePopup(true);
          nodes_state.show();
          break;

        case "data_import":
          var dataImport = new inventario.widget.DataImporter(null);
          dataImport.setPage(this.main_panel);
          dataImport.setUsePopup(true);
          dataImport.show();
          break;

        case "barcodes":
          var barcodes = new inventario.report.ReportGenerator(null);
          barcodes.show("barcodes", this.selected_label, true);
          break;

        case "lots":
          var lots = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("lots"));
          lots.setPage(this.main_panel);
          lots.show();
          break;

        case "lots_labels":
          var lots_labels = new inventario.report.ReportGenerator(null);
          lots_labels.show("lots_labels", this.selected_label, true);
          break;

        case "laptops_per_tree":
          var laptops_per_tree = new inventario.report.ReportGenerator(null);
          laptops_per_tree.show("laptops_per_tree", this.selected_label, true);
          break;

        case "possible_mistakes":
          var possible_mistakes = new inventario.report.ReportGenerator(null);
          possible_mistakes.show("possible_mistakes", this.selected_label, true);
          break;

        case "school_infos":
          var school_infos = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("school_infos"));
          school_infos.setPage(this.main_panel);
          school_infos.show();
          break;

        case "printable_delivery":
          var printable_delivery = new inventario.report.ReportGenerator(null);
          printable_delivery.show("printable_delivery", this.selected_label, true);
          break;

        case "quizzes":
          var quizzes = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("quizzes"));
          quizzes.setPage(this.main_panel);
          quizzes.show();
          break;

        case "answers":
          var answers = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("answers"));
          answers.setShowAddButton(false);
          answers.setPage(this.main_panel);
          answers.show();
          break;

        case "registered_laptops":
          var registered_laptops = new inventario.report.ReportGenerator(null);
          registered_laptops.show("registered_laptops", this.selected_label, true);
          break;

        case "problem_reports":
          var problem_reports = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("problem_reports"));
          problem_reports.setPage(this.main_panel);
          problem_reports.show();
          break;

        case "solution_types":
          var solution_types = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("solution_types"));
          solution_types.setPage(this.main_panel);
          solution_types.show();
          break;

        case "events":
          var events = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("events"));
          events.setPage(this.main_panel);
          events.setShowAddButton(false);
          events.setShowModifyButton(false);
          events.setShowDetailsButton(false);
          events.setShowDeleteButton(false);
          events.show();
          break;

        default:

          if (this.option_name.match(/schoolmanager/))
          {
            var place_id = this.option_name.split(/\+/)[1];
            var school_m = new inventario.window.SchoolManager();
            school_m.setPlaceId(parseInt(place_id));
            school_m.setPage(this.main_panel);
            school_m.show();
          }
          else
          {
            alert("No se que hacer... Recibi opcion: " + this.option_name);
          }

          break;
      }
    }
  }
});
