
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
// TextField.js
// fecha: 2007-09-05
// autor: Raul Gutierrez S.
//
//
// TextField q' cambia apariencia al recibir foco
//
// TODO: seria bueno que se pudiese usar (setable via parametro) TextField en vez de Combobox
/**
 * Constructor
 *
 * @param param {}  El parametro p/ Popup
 * @param options {} Hash con parametros opcionales
 */
qx.Class.define("inventario.qooxdoo.TextField",
{
  extend : qx.ui.form.TextField,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  construct : function(value)
  {
    qx.ui.form.TextField.call(this, value);

    /*
             * guardamos el border original
             */

    this.addListener("appear", function(e) {
      this._obtenerBorderOriginal();
    }, this);

    this.addListener("focus", function(e)
    {
      qx.event.Timer.once(function()
      {
        // REVISAR:
        // esto puedeser peligroso...
        // que pasa si deja de existe el TextField para el momento en que es llamado
        this.selectAll();
      },
      this, 100);
    },
    this);

    /*
             * Cambiamos a nuestro borde al recibir la atencion
             */

    this.addListener("focusin", function(e)
    {
      var b = this.getPropiedadBorderFocused();

      if (!b) {
        b = this._initBorder();
      }

      this.setBorder(b);
    },
    this);

    /*
             * Perdimos foco... volver a nuestra apariencia original
             */

    this.addListener("focusout", function(e)
    {
      var b = this._obtenerBorderOriginal();
      this.setBorder(b);
    },
    this);
  },




  /*
      *****************************************************************************
         PROPERTIES
      *****************************************************************************
      */

  properties :
  {
    propiedadBorderFocused :
    {
      init     : null,
      nullable : true
    },

    propiedadBorderOriginal :
    {
      init     : null,
      nullable : true
    },

    propiedadWidth :
    {
      check : "Number",
      init  : 2
    },

    propiedadStyle :
    {
      check : "String",
      init  : "solid"
    },

    propiedadColor :
    {
      check : "String",
      init  : "blue"
    },

    propiedadBlocked :
    {
      check : "Boolean",
      init  : false
    },

    propiedadCantidadDecimales :
    {
      check : "Number",
      init  : 2
    }
  },




  /*
      *****************************************************************************
         MEMBERS
      *****************************************************************************
      */

  members :
  {
    /**
     * TODOC
     *
     * @param num {Number} TODOC
     * @return {void} 
     */
    setNumero : function(num)
    {
      var cant_decimales = this.getPropiedadCantidadDecimales();
      var s = inventario.widget.Form.formatNumberToString(num, cant_decimales);
      this.setValue(s);

      /* Esto deberia ser en tiempo de construccion o activacion de la propiedad */

      this.setLiveUpdate(true);
      this.setTextAlign("right");
      this.setUserData("desformatear_numero", "si");
    },


    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    getNumero : function()
    {
      var s = this.getValue();
      return inventario.widget.Form.unFormatNumber(s);
    },


    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    _initBorder : function()
    {
      var width = this.getPropiedadWidth();
      var style = this.getPropiedadStyle();
      var color = this.getPropiedadColor();

      var b = new qx.ui.core.Border(width, style, color);
      this.setPropiedadBorderFocused(b);
      return b;
    },


    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    _obtenerBorderOriginal : function()
    {
      var b = this.getPropiedadBorderOriginal();

      if (!b)
      {
        var b = this.getBorder();
        this.setPropiedadBorderOriginal(b);
      }

      return b;
    },


    /**
     * TODOC
     *
     * @param activar {var} TODOC
     * @return {void} 
     */
    setMascara : function(activar)
    {
      if (activar)
      {
        this.setTextAlign("right");
        this.setLiveUpdate(true);
        this.addListener("changeValue", this._enMascarar, this);
      }
      else
      {
        this.setTextAlign("left");
        this.setLiveUpdate(false);
        this.removeListener("changeValue", this._enMascarar, this);
      }
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _enMascarar : function(e)
    {
      if (!this.getPropiedadBlocked())
      {
        this.setPropiedadBlocked(true);
        var val = e.getTarget().getComputedValue();
        e.getTarget().setValue(this._doEnMascarar(val));
        this.setPropiedadBlocked(false);
      }
    },


    /**
     * TODOC
     *
     * @param str {String} TODOC
     * @return {var} TODOC
     */
    _doEnMascarar : function(str)
    {
      var v = null;
      var decimales = "";

      if (str.toString().match(/\./))
      {
        v = str.split(/\./);
        str = v[0];
        decimales = v[1];
      }

      var parteEntera = "";
      str = str.replace(/,/g, "");
      var len = (str.length - 1);
      var j = 0;

      for (var i=len; i>=0; i--)
      {
        if (isNaN(str[i])) {
          continue;
        }
        else
        {
          if ((j % 3 == 0) && j > 0) {
            parteEntera = "," + parteEntera;
          }

          parteEntera = str[i] + parteEntera;
          j++;
        }
      }

      /*
                   * Limpia la parte decimal
                   */

      var decimalesLimpio = "";
      var len = decimales.length;

      for (var i=0; i<len; i++)
      {
        if (isNaN(decimales[i]) == false) {
          decimalesLimpio += decimales[i];
        }
      }

      return (v == null ? parteEntera : (parteEntera + "." + decimalesLimpio));
    },


    /**
     * TODOC
     *
     * @param mensaje {var} TODOC
     * @param regex {var} TODOC
     * @return {var} TODOC
     */
    getTexto : function(mensaje, regex)
    {
      if (!mensaje) mensaje = "El campo no puede estar vacio";
      if (!regex) regex = "[^(^ *$)]";

      return inventario.widget.Form.getInputValueValidated(this, mensaje, "text", regex);
    }
  }
});