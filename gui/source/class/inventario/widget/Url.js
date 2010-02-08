
//     Copyright Paraguay Educa 2009
//
//     This program is free software: you can redistribute it and/or modify
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
// Url.js
// fecha: 2007-03-11
// autor: Kaoru Uchiyamada
//
//
// Clase singleton que sirve para obtener los urls, de producto, tipo, etc.
// de un producto, tipo etc,ect.
/* TODO -> los url tienen que venir del servidor */

/**
 * Constructor
 *
 * @param param string
 */
qx.Class.define("inventario.widget.Url",
{
  extend : qx.core.Object,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  construct : function() {},

  // llamar al constructor del padre
  /*
      *****************************************************************************
         STATICS
      *****************************************************************************
      */

  statics :
  {
    /**
     * TODOC
     *
     * @param param {var} TODOC
     * @return {var} TODOC
     */
    getUrl : function(param)
    {
      var ret = "";

      switch(param)
      {
        case "boxes":
          ret = inventario.widget.Url.BOXES;
          break;

        case "laptops":
          ret = inventario.widget.Url.LAPTOPS;
          break;

        case "baterias":
          ret = inventario.widget.Url.BATERIAS;
          break;

        case "cargadores":
          ret = inventario.widget.Url.CARGADORES;
          break;

        case "movimientos":
          ret = inventario.widget.Url.MOVIMIENTOS;
          break;

        case "activaciones":
          ret = inventario.widget.Url.ACTIVACIONES;
          break;

        case "modelos":
          ret = inventario.widget.Url.MODELOS;
          break;

        case "localidades":
          ret = inventario.widget.Url.LOCALIDADES;
          break;

        case "personas":
          ret = inventario.widget.Url.PERSONAS;
          break;

        case "shipments":
          ret = inventario.widget.Url.SHIPMENTS;
          break;

        case "movement_details":
          ret = inventario.widget.Url.MOVEMENT_DETAILS;
          break;

        case "movement_types":
          ret = inventario.widget.Url.MOVEMENT_TYPES;
          break;

        case "laptop_configs":
          ret = inventario.widget.Url.LAPTOP_CONFIGS;
          break;

        case "box_movements":
          ret = inventario.widget.Url.BOX_MOVEMENTS;
          break;

        case "statuses":
          ret = inventario.widget.Url.STATUSES;
          break;

        case "notifications":
          ret = inventario.widget.Url.NOTIFICATIONS;
          break;

        case "notification_subscribers":
          ret = inventario.widget.Url.NOTIFICATION_SUBSCRIBERS;
          break;

        case "part_types":
          ret = inventario.widget.Url.PART_TYPES;
          break;

        case "parts":
          ret = inventario.widget.Url.PARTS;
          break;

        case "problem_types":
          ret = inventario.widget.Url.PROBLEM_TYPES;
          break;

        case "problem_solutions":
          ret = inventario.widget.Url.PROBLEM_SOLUTIONS;
          break;

        case "images":
          ret = inventario.widget.Url.IMAGES;
          break;

        case "profiles":
          ret = inventario.widget.Url.PROFILES;
          break;

        case "users":
          ret = inventario.widget.Url.USERS;
          break;

        case "place_types":
          ret = inventario.widget.Url.PLACE_TYPES;
          break;

        case "node_types":
          ret = inventario.widget.Url.NODE_TYPES;
          break;

        case "nodes":
          ret = inventario.widget.Url.NODES;
          break;

        case "lots":
          ret = inventario.widget.Url.LOTS;
          break;

        case "school_infos":
          ret = inventario.widget.Url.SCHOOL_INFOS;
          break;

        case "quizzes":
          ret = inventario.widget.Url.QUIZZES;
          break;

        case "answers":
          ret = inventario.widget.Url.ANSWERS;
          break;

        case "problem_reports":
          ret = inventario.widget.Url.PROBLEM_REPORTS;
          break;

        case "solution_types":
          ret = inventario.widget.Url.SOLUTION_TYPES;
          break;

        case "events":
          ret = inventario.widget.Url.EVENTS;
          break;

        case "bank_deposits":
          ret = inventario.widget.Url.BANK_DEPOSITS;
          break;

        case "default_values":
          ret = inventario.widget.Url.DEFAULT_VALUES;
          break;

        case "part_movement_types":
          ret = inventario.widget.Url.PART_MOVEMENT_TYPES;
          break;

        case "part_movements":
          ret = inventario.widget.Url.PART_MOVEMENTS;
          break;

        default:
          alert("erro : No existe " + param);
      }

      return ret;
    },

    LAPTOPS :
    {
      listUrl        : "/laptops/search",
      addUrl         : "/laptops/new",
      saveUrl        : "/laptops/save",
      deleteUrl      : "/laptops/delete",
      searchUrl      : "/laptops/search",
      initialDataUrl : "/laptops/search_options"
    },

    BATERIAS :
    {
      listUrl        : "/batteries/search",
      addUrl         : "/batteries/new",
      saveUrl        : "/batteries/save",
      deleteUrl      : "/batteries/delete",
      searchUrl      : "/batteries/search",
      initialDataUrl : "/batteries/search_options"
    },

    CARGADORES :
    {
      listUrl        : "/chargers/search",
      addUrl         : "/chargers/new",
      saveUrl        : "/chargers/save",
      deleteUrl      : "/chargers/delete",
      searchUrl      : "/chargers/search",
      initialDataUrl : "/chargers/search_options"
    },

    MOVIMIENTOS :
    {
      listUrl        : "/movements/search",
      addUrl         : "/movements/new",
      saveUrl        : "/movements/save",
      deleteUrl      : "/movements/delete",
      searchUrl      : "/movements/search",
      initialDataUrl : "/movements/search_options"
    },

    ACTIVACIONES :
    {
      listUrl        : "/activations/search",
      addUrl         : "/activations/new",
      saveUrl        : "/activations/save",
      deleteUrl      : "/activations/delete",
      searchUrl      : "/activations/search",
      initialDataUrl : "/activations/search_options"
    },

    MODELOS :
    {
      listUrl        : "/models/search",
      addUrl         : "/models/new",
      saveUrl        : "/models/save",
      deleteUrl      : "/models/delete",
      searchUrl      : "/models/search",
      initialDataUrl : "/models/search_options"
    },

    LOCALIDADES :
    {
      listUrl        : "/places/search",
      addUrl         : "/places/new",
      saveUrl        : "/places/save",
      deleteUrl      : "/places/delete",
      searchUrl      : "/places/search",
      initialDataUrl : "/places/search_options"
    },

    PERSONAS :
    {
      listUrl        : "/people/search",
      addUrl         : "/people/new",
      saveUrl        : "/people/save",
      deleteUrl      : "/people/delete",
      searchUrl      : "/people/search",
      initialDataUrl : "/people/search_options"
    },

    SHIPMENTS :
    {
      listUrl        : "/shipments/search",
      addUrl         : "/shipments/new",
      saveUrl        : "/shipments/save",
      deleteUrl      : "/shipments/delete",
      searchUrl      : "/shipments/search",
      initialDataUrl : "/shipments/search_options"
    },

    MOVEMENT_DETAILS :
    {
      listUrl        : "/movement_details/search",
      addUrl         : "/movement_details/new",
      saveUrl        : "/movement_details/save",
      deleteUrl      : "/movement_details/delete",
      searchUrl      : "/movement_details/search",
      initialDataUrl : "/movement_details/search_options"
    },

    MOVEMENT_TYPES :
    {
      listUrl        : "/movement_types/search",
      addUrl         : "/movement_types/new",
      saveUrl        : "/movement_types/save",
      deleteUrl      : "/movement_types/delete",
      searchUrl      : "/movement_types/search",
      initialDataUrl : "/movement_types/search_options"
    },

    LAPTOP_CONFIGS :
    {
      listUrl        : "/laptop_configs/search",
      addUrl         : "/laptop_configs/new",
      saveUrl        : "/laptop_configs/save",
      deleteUrl      : "/laptop_configs/delete",
      searchUrl      : "/laptop_configs/search",
      initialDataUrl : "/laptop_configs/search_options"
    },

    BOXES :
    {
      listUrl        : "/boxes/search",
      addUrl         : "/boxes/new",
      saveUrl        : "/boxes/save",
      deleteUrl      : "/boxes/delete",
      searchUrl      : "/boxes/search",
      initialDataUrl : "/boxes/search_options"
    },

    BOX_MOVEMENTS :
    {
      listUrl        : "/box_movements/search",
      addUrl         : "/box_movements/new",
      saveUrl        : "/box_movements/save",
      deleteUrl      : "/box_movements/delete",
      searchUrl      : "/box_movements/search",
      initialDataUrl : "/box_movements/search_options"
    },

    STATUSES :
    {
      listUrl        : "/statuses/search",
      addUrl         : "/statuses/new",
      saveUrl        : "/statuses/save",
      deleteUrl      : "/statuses/delete",
      searchUrl      : "/statuses/search",
      initialDataUrl : "/statuses/search_options"
    },

    NOTIFICATIONS :
    {
      listUrl        : "/notifications/search",
      addUrl         : "/notifications/new",
      saveUrl        : "/notifications/save",
      deleteUrl      : "/notifications/delete",
      searchUrl      : "/notifications/search",
      initialDataUrl : "/notifications/search_options"
    },

    NOTIFICATION_SUBSCRIBERS :
    {
      listUrl        : "/notification_subscribers/search",
      addUrl         : "/notification_subscribers/new",
      saveUrl        : "/notification_subscribers/save",
      deleteUrl      : "/notification_subscribers/delete",
      searchUrl      : "/notification_subscribers/search",
      initialDataUrl : "/notification_subscribers/search_options"
    },

    PART_TYPES :
    {
      listUrl        : "/part_types/search",
      addUrl         : "/part_types/new",
      saveUrl        : "/part_types/save",
      deleteUrl      : "/part_types/delete",
      searchUrl      : "/part_types/search",
      initialDataUrl : "/part_types/search_options"
    },

    PARTS :
    {
      listUrl        : "/parts/search",
      addUrl         : "/parts/new",
      saveUrl        : "/parts/save",
      deleteUrl      : "/parts/delete",
      searchUrl      : "/parts/search",
      initialDataUrl : "/parts/search_options"
    },

    PROBLEM_TYPES :
    {
      listUrl        : "/problem_types/search",
      addUrl         : "/problem_types/new",
      saveUrl        : "/problem_types/save",
      deleteUrl      : "/problem_types/delete",
      searchUrl      : "/problem_types/search",
      initialDataUrl : "/problem_types/search_options"
    },

    PROBLEM_SOLUTIONS :
    {
      listUrl        : "/problem_solutions/search",
      addUrl         : "/problem_solutions/new",
      saveUrl        : "/problem_solutions/save",
      deleteUrl      : "/problem_solutions/delete",
      searchUrl      : "/problem_solutions/search",
      initialDataUrl : "/problem_solutions/search_options"
    },

    IMAGES :
    {
      listUrl        : "/images/search",
      addUrl         : "/images/new",
      saveUrl        : "/images/save",
      deleteUrl      : "/images/delete",
      searchUrl      : "/images/search",
      initialDataUrl : "/images/search_options"
    },

    PROFILES :
    {
      listUrl        : "/profiles/search",
      addUrl         : "/profiles/new",
      saveUrl        : "/profiles/save",
      deleteUrl      : "/profiles/delete",
      searchUrl      : "/profiles/search",
      initialDataUrl : "/profiles/search_options"
    },

    USERS :
    {
      listUrl        : "/users/search",
      addUrl         : "/users/new",
      saveUrl        : "/users/save",
      deleteUrl      : "/users/delete",
      searchUrl      : "/users/search",
      initialDataUrl : "/users/search_options"
    },

    PLACE_TYPES :
    {
      listUrl        : "/place_types/search",
      addUrl         : "/place_types/new",
      saveUrl        : "/place_types/save",
      deleteUrl      : "/place_types/delete",
      searchUrl      : "/place_types/search",
      initialDataUrl : "/place_types/search_options"
    },

    NODE_TYPES :
    {
      listUrl        : "/node_types/search",
      addUrl         : "/node_types/new",
      saveUrl        : "/node_types/save",
      deleteUrl      : "/node_types/delete",
      searchUrl      : "/node_types/search",
      initialDataUrl : "/node_types/search_options"
    },

    NODES :
    {
      listUrl        : "/nodes/search",
      addUrl         : "/nodes/new",
      saveUrl        : "/nodes/save",
      deleteUrl      : "/nodes/delete",
      searchUrl      : "/nodes/search",
      initialDataUrl : "/nodes/search_options"
    },

    LOTS :
    {
      listUrl        : "/lots/search",
      addUrl         : "/lots/new",
      saveUrl        : "/lots/save",
      deleteUrl      : "/lots/delete",
      searchUrl      : "/lots/search",
      initialDataUrl : "/lots/search_options"
    },

    SCHOOL_INFOS :
    {
      listUrl        : "/school_infos/search",
      addUrl         : "/school_infos/new",
      saveUrl        : "/school_infos/save",
      deleteUrl      : "/school_infos/delete",
      searchUrl      : "/school_infos/search",
      initialDataUrl : "/school_infos/search_options"
    },

    QUIZZES :
    {
      listUrl        : "/quizzes/search",
      addUrl         : "/quizzes/new",
      saveUrl        : "/quizzes/save",
      deleteUrl      : "/quizzes/delete",
      searchUrl      : "/quizzes/search",
      initialDataUrl : "/quizzes/search_options"
    },

    ANSWERS :
    {
      listUrl        : "/answers/search",
      addUrl         : "/answers/new",
      saveUrl        : "/answers/save",
      deleteUrl      : "/answers/delete",
      searchUrl      : "/answers/search",
      initialDataUrl : "/answers/search_options"
    },

    PROBLEM_REPORTS :
    {
      listUrl        : "/problem_reports/search",
      addUrl         : "/problem_reports/new",
      saveUrl        : "/problem_reports/save",
      deleteUrl      : "/problem_reports/delete",
      searchUrl      : "/problem_reports/search",
      initialDataUrl : "/problem_reports/search_options"
    },

    SOLUTION_TYPES :
    {
      listUrl        : "/solution_types/search",
      addUrl         : "/solution_types/new",
      saveUrl        : "/solution_types/save",
      deleteUrl      : "/solution_types/delete",
      searchUrl      : "/solution_types/search",
      initialDataUrl : "/solution_types/search_options"
    },

    EVENTS :
    {
      listUrl        : "/events/search",
      addUrl         : "/events/new",
      saveUrl        : "/events/save",
      deleteUrl      : "/events/delete",
      searchUrl      : "/events/search",
      initialDataUrl : "/events/search_options"
    },

    BANK_DEPOSITS :
    {
      listUrl        : "/bank_deposits/search",
      addUrl         : "/bank_deposits/new",
      saveUrl        : "/bank_deposits/save",
      deleteUrl      : "/bank_deposits/delete",
      searchUrl      : "/bank_deposits/search",
      initialDataUrl : "/bank_deposits/search_options"
    },

    DEFAULT_VALUES :
    {
      listUrl        : "/default_values/search",
      addUrl         : "/default_values/new",
      saveUrl        : "/default_values/save",
      deleteUrl      : "/default_values/delete",
      searchUrl      : "/default_values/search",
      initialDataUrl : "/default_values/search_options"
    },

    PART_MOVEMENT_TYPES :
    {
      listUrl        : "/part_movement_types/search",
      addUrl         : "/part_movement_types/new",
      saveUrl        : "/part_movement_types/save",
      deleteUrl      : "/part_movement_types/delete",
      searchUrl      : "/part_movement_types/search",
      initialDataUrl : "/part_movement_types/search_options"
    },

    PART_MOVEMENTS :
    {
      listUrl        : "/part_movements/search",
      addUrl         : "/part_movements/new",
      saveUrl        : "/part_movements/save",
      deleteUrl      : "/part_movements/delete",
      searchUrl      : "/part_movements/search",
      initialDataUrl : "/part_movements/search_options"
    }
  }
});
