
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
qx.Class.define("inventario.widget.Form",
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
    /* mediante esta funcion podemos crear un groupBox
                datos => un array de array[3]  que tiene nombre del label,clase de form(text,comboBox,textarea),y su longitud vertical)
                titulo => es el titulo del comboBox que se muestra arriba, es un string
        */

    /**
     * TODOC
     *
     * @param datos {var} TODOC
     * @param titulo {var} TODOC
     * @return {var} TODOC
     */
    createGroupBox : function(datos, titulo)
    {
      var fs1 = new qx.ui.groupbox.GroupBox(titulo);

      with (fs1)
      {
        setTop(0);
        setLeft(0);
        setDimension("auto", "auto");
      }

      var gl = new qx.ui.layout.GridLayout;

      gl.setLocation(0, 0);
      gl.setDimension("auto", "auto");

      // gl.setBorder("outset");
      gl.setPadding(0);
      gl.setColumnCount(2);
      gl.setRowCount(datos.length);

      gl.setColumnWidth(0, 100);
      gl.setColumnWidth(1, 180);

      gl.setColumnHorizontalAlignment(0, "right");
      gl.setColumnVerticalAlignment(0, "middle");

      gl.setCellPaddingTop(0);
      gl.setCellPaddingRight(0);
      gl.setCellPaddingBottom(0);
      gl.setCellPaddingLeft(0);

      var label = [];
      var input = [];

      try
      {
        for (var i=0; i<datos.length; i++)
        {
          label[i] = new qx.ui.basic.Label(datos[i][0]);
          input[i] = new datos[i][1];
          gl.setRowHeight(i, datos[i][2]);
          gl.add(label[i], 0, i);
          gl.add(input[i], 1, i);
        }
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje(e);
      }

      fs1.add(gl);

      var params =
      {
        groupBox   : fs1,
        gridLayout : gl,
        inputs     : input
      };

      return params;
    },


    /**
     * ***********************************************************************************************
     * Combo Box
     * ************************************************************************************************
     *
     * @param cb {var} TODOC
     * @param vdata {var} TODOC
     * @param sel {var} TODOC
     * @return {void} 
     */
    /**
         * loadComboBox(): cargar un combo box y setea el que esta seleccionado
         * @param cb {qx.ui.form.SelectBox}
         * @param vdata {Array}  vector de hashes {text,value,selected,attribs} donde attribs es hash de atributos
         * @param sel {Boolean} marcar alguno como seleccionado (si no se seleccino otro)
         * @return void
         */
    loadComboBox : function(cb, vdata, sel)
    {
      inventario.widget.Form.clearComboBox(cb);  /* vaciar antes de empezar */
      var len = (vdata) ? vdata.length : 0;

      var hasSelected = false;

      for (var i=0; i<len; i++)
      {
        var t = vdata[i].text;
        var v = vdata[i].value.toString();
        var attribs = (vdata[i].attribs ? vdata[i].attribs : {});
        var s = vdata[i].selected ? vdata[i].selected : false;
        var li = new qx.ui.form.ListItem(t, null, v);

        cb.add(li);

        if (s) {
          //cb.getChildrenContainer().select(li);
          hasSelected = true;
          cb.setSelection([li]);
        }

        /* guardar atributos de la opcion */

        for (var j in attribs) {
          li.setUserData(j, attribs[j]);
        }
      }

      if (!hasSelected && sel && len) {
         var tmp = cb.getSelectables();
         if (tmp.length > 0) {
            cb.setSelection([tmp[0]]);
         }
      }
    },

    /*
            retorna un hash de text y value
        */

    /**
     * TODOC
     *
     * @param cb {var} TODOC
     * @return {Map} TODOC
     */
    comboBoxToHash : function(cb)
    {
      return {
        text  : cb.getField().getValue(),
        value : inventario.widget.Form.getInputValue(cb)
      };
    },


    /**
     * TODOC
     *
     * @param cb {var} TODOC
     * @param value {var} TODOC
     * @return {void} 
     */
    setComboBox : function(cb, value) {
      var items = value.getSelectables();
      for (var i in items) {
          if (i.getModel().toString() == value.toString()) {
                cb.setSelection([i]);
                return true;
          }
      }
      return false;
    },


    /**
     * TODOC
     *
     * @param cb {var} TODOC
     * @param value {var} TODOC
     * @param userData {var} TODOC
     * @return {void} 
     */
    setComboBoxByUserData : function(cb, value, userData)
    {
      var lista = cb.getList().getChildren();
      var len = (lista ? lista.length : 0);

      for (var i=0; i<len; i++)
      {
        var s = lista[i].getUserData(userData);

        if (s == value)
        {
          cb.setSelected(lista[i]);
          break;
        }
      }
    },


    /**
     * TODOC
     *
     * @param cb {var} TODOC
     * @return {void} 
     */
    clearComboBox : function(cb)
    {
      cb.removeAll();
      cb.setSelection([]);
    },


    /**
     * setWithNumberFormat(): carga en un textfield un numero
     *
     * @param input {var} qx.ui.form.TextField
     * @param num {Number} numeric
     * @return {void} void
     */
    setWithNumberFormat : function(input, num)
    {
      var cant_decimales = 0;

      try
      {
        cant_decimales = input.getUserData("cant_decimales");

        if (parseInt(cant_decimales)) {
          cant_decimales = parseInt(cant_decimales);
        } else {
          cant_decimales = 0;
        }
      }
      catch(e)
      {
        cant_decimales = 0;
      }

      var val = inventario.widget.Form.formatNumberToString(num, cant_decimales);
      input.setValue(val);
    },


    /**
     * unFormatNumber(): invierte lo que hace setWithNumberFormat
     *
     * @param num {Number} string con el numero
     * @return {var} float
     *   
     *     Javascript no acepta los separadores de miles :S
     */
    unFormatNumber : function(num)
    {
      var str = num.toString();
      var y = str.replace(/\./g, "");
      y = y.replace(/\,/g, ".");

      return parseFloat(y);
    },


    /**
     * formatNumberToString(): devuelve un string formateado de numero
     *
     * @param num {Number} number
     * @param cant_decimales {Number} cantidad de decimales
     * @return {var} string
     */
    formatNumberToString : function(num, cant_decimales)
    {
      var f = new qx.util.format.NumberFormat("es");
      f.set({ maximumFractionDigits : cant_decimales });
      return f.format(num).toString();
    },


    /**
     * parseStringToNumber(): devuelve un string formateado de numero
     *
     * @param num {Number} string
     * @return {var} double
     */
    parseStringToNumber : function(num)
    {
      var f = new qx.util.format.NumberFormat("es");

      f.set(
      {
        maximumFractionDigits : 0,
        prefix                : "",
        postfix               : ""
      });

      return f.parse(num);
    },

    // getInputValue() :  obtiene el valor del Input
    // params:   @pInput => ref al input
    // returns: valor
    /**
     * FIXME: esto se puede simplificar _si_ todos los widgets cumplen con una interfaz (i.e.: getValue())
     *
     * @param pInput {var} TODOC
     * @param rich_output {var} TODOC
     * @return {var} TODOC
     */
    getInputValue : function(pInput, rich_output)
    {
      var v = "";

      if (pInput instanceof qx.ui.form.PasswordField)
      {
        var string = pInput.getValue().toString();

        if (string != "") {
          v = hex_sha1(string);
        } else {
          v = string;
        }
      }
      else if (pInput instanceof qx.ui.form.TextField || pInput instanceof qx.ui.form.TextArea || pInput instanceof qx.ui.form.Spinner)
      {
        v = pInput.getValue();

        if (rich_output)
        {
          h = {};
          h.value = v;
          h.text = v;
          v = h;
        }
      }
      else if (pInput instanceof qx.ui.form.DateField)
      {
        var dateObj = pInput.getValue();

        if (dateObj)
        {
          var monthStr = (dateObj.getMonth() + 1).toString();
          v = dateObj.getDate().toString() + "-" + monthStr + "-" + dateObj.getFullYear().toString();
        }
        else
        {
          v = "";
        }

        if (rich_output)
        {
          h = {};
          h.value = v;
          h.text = v;
          v = h;
        }
      }
      else if (pInput instanceof qx.ui.form.SelectBox)
      {
        if (pInput.getUserData("text_value") == true) {
            var zSel = pInput.getSelection();
            v = zSel.length > 0 ? zSel[0].getLabel() : "";
        }
        else
        {
            var zSel = pInput.getSelection();
            v = zSel.length > 0 ? zSel[0].getModel() : -1;

            if (rich_output)
            {
                var h = { text : "", value : -1};
                if (zSel.length > 0) {
                  h.text  = zSel[0].getLabel();  
                  h.value = v;
                } 
                v = h;
            }
        }
      }
      else if (pInput instanceof qx.ui.form.CheckBox)
      {
        v = pInput.getChecked();
      }
      else if (pInput instanceof inventario.widget.Table2)
      {
        v = pInput.getHashedData();
      }
      else if (pInput instanceof inventario.widget.DateRange)
      {
        v = pInput.getValue();
      }
      else if (pInput instanceof inventario.widget.CheckboxSelector)
      {
        v = pInput.getSelectedParts();
      }
      else if (pInput instanceof inventario.widget.ComboboxSelector)
      {
        v = pInput.getSelectedValue();
      }
      else if (pInput instanceof inventario.widget.ColumnValueSelector)
      {
        v = pInput.getValues();
      }
      else if (pInput instanceof inventario.widget.ListSelector)
      {
        v = pInput.getSelectedValue();
      }
      else if (pInput instanceof inventario.widget.DynTable)
      {
        v = pInput.getTableData();  // ?
      }
      else if (pInput instanceof inventario.widget.Select)
      {
        var s = pInput.getComboBox().getChildrenContainer().getSelectedItem();
        v = (s ? s.getValue() : -1);

        if (rich_output)
        {
          var h = {};
          h.text = pInput.getComboBox().getValue();
          h.value = v;
          v = h;
        }
      }
      else if (pInput instanceof inventario.widget.Permissions)
      {
        v = pInput.getTreeValues();
      }
      else if (pInput instanceof inventario.widget.MapLocator)
      {
        v = pInput.getValues();
      }
      else if (pInput instanceof inventario.widget.DynamicDeliveryForm)
      {
        v = pInput.getValues();
      }
      else if (pInput instanceof inventario.widget.CoordsTextField)
      {
        v = pInput.getInputValue();
      }
      else if (pInput instanceof inventario.widget.ComboBoxFiltered)
      {
        v = pInput.getSelectedValue();
      }
      else if (pInput instanceof inventario.widget.MultipleChoiceFormMaker)
      {
        v = pInput.getValues();
      }
      else if (pInput instanceof inventario.widget.QuestionForm)
      {
        v = pInput.getValues();
      }
      else if (pInput instanceof inventario.widget.HierarchyOnDemand)
      {
        v = pInput.getValue();

        if (rich_output)
        {
          var h = {};
          h.text = pInput.getItemFullLabel();
          h.value = v;
          v = h;
        }
      }
      else if (pInput instanceof inventario.widget.MultipleHierarchySelection)
      {
        v = pInput.getValues();
      }
      else
      {
        alert("No conozco el tipo de dato " + typeof (pInput));
      }

      return v;
    },


    /**
     * getInputValueValidated(): obtiene el valor y valida
     *
     * @param pInput {var} TODOC
     * @param exMsg {var} TODOC
     * @param inputType {var} TODOC
     * @param re {var} TODOC
     * @return {var} void
     */
    getInputValueValidated : function(pInput, exMsg, inputType, re)
    {
      var val = inventario.widget.Form.getInputValue(pInput);
      inventario.widget.Validation.validate(val, exMsg, inputType, re);
      return val;
    },

    // resetInputs() :  cerar inputs
    // params:   @arrayInputs
    // returns: void
    /**
     * TODOC
     *
     * @param arrayInputs {var} TODOC
     * @return {void} 
     */
    resetInputs : function(arrayInputs)
    {
      var len = arrayInputs.length;

      for (var i=0; i<len; i++)
      {
        var pInput = arrayInputs[i];

        if (pInput instanceof qx.ui.form.TextField) {
          pInput.setValue("");
        }
        else if (pInput instanceof qx.ui.form.SelectBox)
        {
          try
          {
            var child = pInput.getList().getFirstChild();
            pInput.setSelected(child);
          }
          catch(e)
          {
            pInput.setSelected(null);
          }
        }
        else if (pInput instanceof qx.ui.form.Spinner)
        {
          pInput.setValue(0);
        }
        else if (pInput instanceof qx.ui.form.CheckBox)
        {
          pInput.setValue(false);
        }
        else if (pInput instanceof qx.ui.form.TextArea)
        {
          pInput.setValue("");
        } else {}
      }
    },

    //  descomentar para debuggear
    //  inventario.window.Mensaje.mensaje("No conozco el tipo de dato en la fila " + i);
    /**
     * ****************************************************************************
     * 
     * ******************************************************************************
     *
     * @param vdata {var} TODOC
     * @return {var} TODOC
     */
    //  createTable() : crea una tabla, con todos sus parametros
    //  params:  @vdata :  hash{clase,width,height} de cada columna
    createLayout : function(vdata)
    {
      var lay = new vdata["clase"];

      with (lay)
      {
        setLeft(0);
        setTop(0);

        // setBorder("outset");
        setDimension(vdata["width"], vdata["height"]);
        setSpacing(2);
        setPadding(0);
      }

      return lay;
    },


    /**
     * ******************************************************************************************************************
     * List View
     * *******************************************************************************************************************
     *
     * @param dato {var} TODOC
     * @param formato {var} TODOC
     * @param opcion {var} TODOC
     * @return {Map} TODOC
     */
    createListView : function(dato, formato, opcion)
    {
      try
      {
        var view = new qx.ui.listview.ListView(dato, formato);

        with (view)
        {
          setBorder("dark-shadow");
          setBackgroundColor("white");

          // debug(opcion["width"]);
          // setWidth(opcion.width);
          // setHeight(opcion.height);
          setDimension(opcion["width"], opcion["height"]);
          getPane().getManager().setDragSelection(false);
        }
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje(e);
      }

      return {
        tabla : view,
        data  : dato,
        colms : formato
      };
    },


    /**
     * TODOC
     *
     * @param datos {var} TODOC
     * @param list {var} TODOC
     * @return {void} 
     */
    addDataInListView : function(datos, list)
    {
      try
      {
        var len = datos.length;

        for (var i=0; i<len; i++)
        {
          var tmp = {};
          var j = 0;

          for (var x in list.colms)
          {
            var dato = datos[i][j];

            if (typeof (dato) == "string") tmp[x] = { text : dato };
            else if (typeof (dato) == "number")
            {
              // inventario.window.Mensaje.mensaje(dato);
              tmp[x] = { text : inventario.widget.Form.formatNumberToString(dato) };
            }

            // inventario.window.Mensaje.mensaje(tmp[x].text);
            else
            {
              tmp[x] = { text : dato.toString() };
            }

            j++;
          }

          list.data.push(tmp);
        }

        list.tabla.setData(list.data);
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje(e);
      }
    },


    /**
     * TODOC
     *
     * @param list {var} TODOC
     * @return {void} 
     */
    removeListView : function(list)
    {
      qx.lang.Array.removeAll(list.getData());
      list.updateSort();
      list.update();
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    handleDrag : function(e)
    {
      e.addData("qx.ui.listview.ListViewEntries", qx.lang.Array.copy(e.getCurrentTarget().getManager().getSelectedItems()));
      e.addAction("move");
      e.startDrag();
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @param source {var} TODOC
     * @param dest {var} TODOC
     * @return {void} 
     */
    handleDrop : function(e, source, dest)
    {
      var type = e.getDropDataTypes()[0];
      var data = e.getData(type);

      // e.debug(e.getCurrentTarget());
      switch(e.getAction())
      {
        case "move":
          source.getPane().getManager().setSelectedItems([]);
          source.getPane().getManager().setAnchorItem(null);
          source.getPane().getManager().setLeadItem(null);

          dData = dest.getData();

          for (var i=0, l=data.length; i<l; i++)
          {
            var ban = true;

            for (var j=0; j<dData.length; j++)
            {
              if (dData[j][0] == data[i][0])
              {
                ban = false;
                break;
              }
            }

            if (ban)
            {
              qx.lang.Array.remove(source.getData(), data[i]);
              dest.getData().push(data[i]);
            }
          }

          dest.getPane().getManager().setSelectedItems(data);

          source.updateSort();
          dest.updateSort();

          source.update();
          dest.update();
      }
    }
  }
});
