
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
// SearchAdvanced.js
// fecha: 2007-04-12
// autor: Kaoru Uchiyamada
// Qooxdoo 0.8 Port + Datatype extensions + Mass rewrite
// fecha: 2009-07-01 - 2009-10-08
// autor: Martin Abente (tincho_02@hotmail.com)
// Crear un pop up de buscador avanzado
/**
 * @param param un array de objetos
 * @return void
 */
qx.Class.define("inventario.widget.SearchAdvanced",
{
  extend : qx.core.Object,

  construct : function(param, data)
  {
    qx.core.Object.call(this);

    this.setCallBackFunction(data["funcion"]);
    this.setCallBackObject(data["objeto"]);

    if (data["fecha"]) {
      this.setFecha(data["fecha"]);
    }

    var win = new inventario.widget.Window();
    win.setModal(false);
    var vbox = win.getVbox();

    this.setWindow(win);

    var len = param.length;
    var form = new Array();

    var gl = new qx.ui.container.Composite(new qx.ui.layout.Grid());

    var width = 400;
    var height = (len * 26) + 50;

    var humanQuery =
    {
      column : {},
      widget : new qx.ui.form.TextArea("")
    };

    try
    {
      for (var i=0; i<len; i++)
      {
        var tf = this._setComponent(param[i]);

        var options = new qx.ui.form.SelectBox();
        options.add(new qx.ui.form.ListItem(qx.locale.Manager.tr("Contains"), '', 'regexp'));
        options.add(new qx.ui.form.ListItem(qx.locale.Manager.tr("It contains"), '', 'not regexp'));
        options.add(new qx.ui.form.ListItem(qx.locale.Manager.tr("Same"), '', '='));
        options.add(new qx.ui.form.ListItem(qx.locale.Manager.tr("Minor"), '', '<'));
        options.add(new qx.ui.form.ListItem(qx.locale.Manager.tr("Major"), '', '>'));
        options.add(new qx.ui.form.ListItem(qx.locale.Manager.tr("Unlike"), '', '!='));


        var addButton = new qx.ui.form.Button("+", "icon/16/add.png");
        addButton.setUserData("widget", tf);
        addButton.setUserData("comp", options);
        addButton.addListener("execute", this.addQueryElement, this);

        var removeButton = new qx.ui.form.Button("-", "icon/16/add.png");
        removeButton.setUserData("widget", tf);
        removeButton.addListener("execute", this.removeQueryElement, this);

        if (param[i]["datatype"] == "date") {
          width = 650;
        }

        gl.add(new qx.ui.basic.Label(param[i]["text"]),
        {
          row    : i,
          column : 0
        });

        gl.add(options, {
            row : i,
            column: 1
        });

        gl.add(tf,
        {
          row    : i,
          column : 2
        });

        gl.add(addButton,
        {
          row    : i,
          column : 3
        });

        gl.add(removeButton,
        {
          row    : i,
          column : 4
        });

        form.push(tf);

        humanQuery.column[param[i].value] = param[i].text;
      }
    }
    catch(e)
    {
      inventario.window.Mensaje.mensaje("SearchAdvanced.constructor " + e.toString());
    }

    vbox.add(gl);
    this.setForm(form);

    vbox.add(humanQuery.widget);
    this.setHumanQuery(humanQuery);

    var bSave = new qx.ui.form.Button(qx.locale.Manager.tr("Search"), "icon/16/search.png");
    bSave.addListener("execute", this.search, this);
    vbox.add(bSave);

    this.setQueryComponents({});
    this.getWindow().show();
  },

  properties :
  {
    window :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    form :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    humanQuery :
    {
      check : "Object",
      init  : null
    },

    queryComponents :
    {
      check : "Object",
      init  : null
    },

    callBackObject :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    callBackFunction :
    {
      check    : "Function",
      init     : null,
      nullable : true
    },

    fecha :
    {
      check : "String",
      init  : ""
    }
  },

  members :
  {
    _setComponent : function(param)
    {
      var tf;

      switch(param["datatype"])
      {
        case "date":
          tf = new inventario.widget.DateRange({ fecha : this.getFecha() });
          break;

        case "combobox":
          tf = new qx.ui.form.SelectBox;
          inventario.widget.Form.loadComboBox(tf, param["data"], true);
          break;

        case "select":
          tf = new inventario.widget.Select(param["options"]);
          tf.getAbm().setVista(param["vista"]);
          break;

        default:
          tf = new qx.ui.form.TextField("");
          break;
      }

      tf.setUserData("key", param["value"]);
      return tf;
    },

    _getComponent : function(form)
    {
      var ret;

      try
      {
        if (form instanceof qx.ui.form.TextField)
        {
          ret = form.getValue();
          ret = ret == "" ? null : ret;
        }
        else if (form instanceof qx.ui.form.SelectBox)
        {
          ret = inventario.widget.Form.getInputValue(form, true).text;
          ret = ret == "" || ret == " " ? null : ret;
        }
        else if (form instanceof inventario.widget.DateRange)
        {
          ret = inventario.widget.Form.getInputValue(form, true);
          ret = ret.date_since == "" && ret.date_to == "" ? null : ret;
        }
        else if (form instanceof inventario.widget.Select)
        {
          ret = inventario.widget.Form.getInputValue(form, true).text;
          ret = ret == "" || ret == " " ? null : ret;
        }
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje("SearchAdvanced.getComponent =>" + e);
      }

      return ret;
    },

    add_all : function()
    {
      var forms = this.getForm();
      var len = forms.length;

      for (var i=0; i<len; i++) {
        this.addQueryElement(null, forms[i]);
      }
    },

    fixDate : function(dateStr)
    {
      var dateArr = dateStr.split("-");
      return dateArr[2] + "-" + dateArr[1] + "-" + dateArr[0];
    },

    addComponent : function(key, operator, value)
    {
      var components = this.getQueryComponents();

      if (typeof components[key] == "undefined")
      {
        components[key] =
        {
          operators : [],
          values    : []
        };
      }

      if (components[key].operators.indexOf(operator) < 0) {
        components[key].operators.push(operator);
      }

      components[key].values.push(value);
    },

    dateRangeQueryElement : function(key, value)
    {
      if (value.date_since) {
        this.addComponent(key, ' >= ? ', this.fixDate(value.date_since));
      }

      if (value.date_to) {
        this.addComponent(key, ' <= ? ', this.fixDate(value.date_to));
      }
    },

    addQueryElement : function(e)
    {
      var widget = e.getTarget().getUserData("widget");
      var comp   = e.getTarget().getUserData("comp").getSelection()[0];
      var value = this._getComponent(widget);

      if (value != null)
      {
        var key = widget.getUserData("key").toString();

        if (widget instanceof inventario.widget.DateRange) {
          this.dateRangeQueryElement(key, value);
        } else {
          this.addComponent(key, ' ' + comp.getModel() + ' ? ', value);
        }
      }

      this.humanizeQuery();
    },

    removeQueryElement : function(e)
    {
      var widget = e.getTarget().getUserData("widget");
      var key = widget.getUserData("key").toString();
      var components = this.getQueryComponents();

      if (typeof components[key] != "undefined")
      {
        var opLen = components[key].operators.length;

        for (var i=0; i<opLen; i++) {
          components[key].values.pop();
        }

        var valLen = components[key].values.length;

        if (valLen < 1) {
          delete (components[key]);
        }
      }

      this.humanizeQuery();
    },

    search : function()
    {
      // this.getWindow().getWindow().close();
      var f = this.getCallBackFunction();
      f.call(this.getCallBackObject(), this.getQueryComponents());
    },

    humanizeQuery : function()
    {
      var humanQuery = this.getHumanQuery();
      var queryComponents = this.getQueryComponents();

      var queryArr = [];

      for (var key in queryComponents) {
        var oprLen = queryComponents[key].operators.length;
        var valLen = queryComponents[key].values.length;

        var operators = queryComponents[key].operators;
        var values = queryComponents[key].values.slice().reverse();

        var opArr = [];
        var times = (valLen / oprLen);

        for (var i=0; i<times; i++) {
          var subOpArr = [];

          for (var j=0; j<oprLen; j++) {
            subOpArr.push(("\"" + humanQuery.column[key] + "\" " + operators[j]).replace("?", "\"" + values.pop() + "\""));
          }

          opArr.push("(" + subOpArr.join(" and ") + ")");
        }

        queryArr.push("(" + opArr.join(" or ") + ")");
      }

      humanQuery.widget.setValue(queryArr.join(" and "));
    }
  }
});
