
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
// Abm2Extensions.js
// Extensions for Amb2...
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguay.org)
// Paraguay Educa 2009
qx.Class.define("inventario.window.Abm2Extensions",
{
  extend : qx.core.Object,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  construct : function() {},




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
     * @param label {var} TODOC
     * @param options {var} TODOC
     * @param context {var} TODOC
     * @return {void} 
     */
    launch : function(label, options, context)
    {
      var abm2 = new inventario.window.Abm2(null, inventario.widget.Url.getUrl(options.option), label);
      abm2.setPage(context._page);
      abm2.setShowAddButton(options.add);
      abm2.setShowModifyButton(options.modify);
      abm2.setShowDetailsButton(options.details);
      abm2.setShowDeleteButton(options.destroy);
      abm2.setUsePopup(options.popup);

      for (i in options.custom) {
        abm2.getToolBarButtons().push(inventario.window.Abm2Extensions.customAbmFormButton(options.custom[i], context));
      }

      abm2.show();
    },


    /**
     * launch an AbmForm win
     *
     * @param options {var} TODOC
     * @param context {var} TODOC
     * @return {var} TODOC
     *
     *
     * TODO:
     * - establish window title
     */
    launchAbmForm : function(label, option_name, context)
    {
        var options = inventario.widget.Url.getUrl(option_name)
        var f = inventario.window.Abm2Extensions.getAbmFormFunction(options, context);
	    f.call();
    },


    /**
     * TODOC
     *
     * @param options {var} TODOC
     * @param context {var} TODOC
     * @return {var} TODOC
     */
    customAbmFormButton : function(options, context)
    {
	var f = inventario.window.Abm2Extensions.getAbmFormFunction(options, context);

	var button =
	    {
		type            : "button",
		icon            : options.icon,
		text            : options.text,
		callBackFunc    : f,
		callBackContext : context
	    };

	return button;
    }, 


   getAbmFormFunction : function(options, context) {

      var saveCallback = function(newData, remoteData)
      {
        var msg = options.msg;

        if (typeof remoteData.msg != "undefined") {
          msg = remoteData.msg;
        }

        inventario.window.Mensaje.mensaje(msg);
      };

      var f = function()
      {
        var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
        var mass_add_form = new inventario.window.AbmForm(null, {});
        mass_add_form.setSaveCallback(saveCallback);
        mass_add_form.setSaveCallbackObj(context);
        mass_add_form.setInitialDataUrl(options.addUrl);
        mass_add_form.setSaveUrl(options.saveUrl);
        mass_add_form.setPage(hbox);
        mass_add_form.setCloseAfterInsert(true);
        mass_add_form.setUsePopup(true);
        mass_add_form.show();
      };

      return f;
   }

  }
});
