
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
// PrintManager.js
// fecha: 2007-03-16
// autor: rgs
//
// Singleton p/ reciclar objetos
/**
 * Constructor
 *
 * @param param string
 */
qx.Class.define("inventario.util.PrintManager",
{
  extend : qx.core.Object,

  construct : function()
  {
    // llamar al constructor del padre
    qx.core.Object.call(this);
  },

  statics :
  {
    /**
     * print()
     *
     * @param documento {String} El identificador para obtener el URL del documento que queremos imprimir
     * @param params {Hash} Parametros para enviar al controller de impresion
     * @return {iFrame} que tiene que ser agregado al page del que esta llamando a print()
     */
    print : function(documento, params)
    {
      var iframe = null;

      try
      {
        var url = inventario.util.PrintManager.getPrintUrl(documento);
        var printUrl = url + inventario.transport.Transport.buildParamStr(params, true);
        iframe = new qx.ui.embed.Iframe();

        /*
                         * HACK WARNING:
                	 *  - Si lo que nos devuelven es HTML (osea hay innerHTML) hubo un error,entonces sacamos un alert.
                         *  - Se podria usar JSON aqui en el futuro para meter datos no planos.
                         */

        var f = function(e)
        {
          var str = this.getIframeNode().contentDocument.body.innerHTML;

          if (str)
          {
            if (!str.match(/^ *$/)) {
              inventario.window.Mensaje.mensaje(str);
            }
          }
        };

        iframe.addListener("load", f);
        iframe.setSource(printUrl);
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje("inventario.util.PrintManager.print() " + e);
      }

      inventario.util.PrintManager.printZone = iframe;

      // we make the iframe invisible since it's only needed to offer the download
      iframe.setMaxWidth(1);
      iframe.setMaxHeight(1);

      return iframe;
    },

    /**
     * print()
     *
     * @param documento {String} El identificador para obtener el URL del documento que queremos imprimir
     * @param params {Hash} Parametros para enviar al controller de impresion
     * @return {iFrame} que tiene que ser agregado al page del que esta llamando a print()
     */
    printExcel : function(documento, params)
    {
      var h = {};
      h["url"] = inventario.util.PrintManager.getPrintUrl(documento);
      h["url"] += "_carga_datos";
      h["parametros"] = documento;
      h["handle"] = inventario.util.PrintManager.printExcelResp;
      h["data"] = params;

      inventario.transport.Transport.callRemote(h, null);
    },

    printExcelResp : function(remoteData, params)
    {
      var documento = params;

      var iframe = inventario.util.PrintManager.print(documento, {});
      var document = inventario.Application.appInstance.getRoot();

      document.add(iframe,
      {
        bottom : 1,
        right  : 1
      });
    },

    /*
             * En esta variable de clase guardamos el iframe de impresion
             */

    printZone : null,

    /**
     * getPrintUrl()
     *
     * @param documento {String} El identificador para obtener el URL del documento que queremos imprimir
     * @return {String} el url
     * @throws TODOC
     */
    getPrintUrl : function(documento)
    {
      var print_controller = "/print/";
      var excel_controller = "/planillas/";
      var url = "";

      switch(documento)
      {
        case "planilla":
          url = excel_controller + documento;
          break;

        case "movements":
          case "movement_types":
            case "test_print_report":
              case "movements_time_range":
                case "laptops_per_owner":
                  case "laptops_per_place":
                    case "laptops_per_source_person":
                      case "laptops_per_destination_person":
                        case "activations":
                          case "lendings":
                            case "statuses_distribution":
                              case "status_changes":
                                case "parts_replaced":
                                  case "available_parts":
                                    case "problems_per_type":
                                      case "barcodes":
                                        case "lots_labels":
                                          case "laptops_per_tree":
                                            case "possible_mistakes":
                                              case "printable_delivery":
                                                case "registered_laptops":
                                                  case "problems_per_school":
                                                    case "problems_per_grade":
                                                      case "used_parts_per_person":
                                                        case "where_are_these_laptops":
                                                          case "online_time_statistics":
                                                            case "serials_per_places":
                                                              case "students_ids_distro":
                                                                case "problems_and_deposits":
                                                                  case "deposits":
                                                                    case "spare_parts_registry":
                                                                      case "problems_time_distribution":
                                                                        case "is_hardware_dist":
                                                                          case "laptops_problems_recurrence":
                                                                            case "average_solved_time":
                                                                              case "audit_report":
                                                                                case "stock_status_report":
                                                                                case "people_laptops":
                                                                                case "people_documents":
                                                                                case "laptops_uuids":
                                                                                case "lot_information":
                                                                                case "laptops_check":
                                                                                //PLEASE someone fix this horrible identation
                                                                                url = print_controller + documento;
                                                                                break;

                                                                              default:
                                                                                throw new Error(qx.locale.Manager.tr("The document ") + documento + qx.locale.Manager.tr(" not set to print even"));
                                                                            }

                                                                            return url;
                                                                          }
                                                                        }
                                                                      });
