
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
// GridFormulaParser.js:
// - Store y recuperacion de planillas
// - metodos auxiliares p/ procesamiento de "planillas" (ordenes de compras,facturas,etc.)
//
// fecha: 2007-01-15
// autor: Raul Gutierrez S.
//
/**
 *  Todo es static por aqui....
 *
 * @return void
 */
qx.Class.define("inventario.parser.GridFormulaParser",
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
     * toUserFormat():
     *
     * @param grid {var} TODOC
     * @return {var} void
     */
    toUserFormat : function(grid)
    {
      var ret = new Array();
      var len = (grid && grid.length) ? grid.length : 0;
      var len2 = (len > 0) ? grid[0].length : 0;

      for (var i=0; i<len; i++)
      {
        var f = new Array();

        for (var j=0; j<len2; j++)
        {
          var h = grid[i][j];
          var s = "";

          /*
                               *  formula o comment, no pueden haber ambos! Aunque en el futuro todos deberian poder tomar comment como un tooltip
                               *
                               */

          if (h.formula && h.formula != "") {
            s += "=" + h.formula;
          } else if (h.comment && h.comment != "") {
            s += h.comment;
          }

          /*
                               * Output
                               */

          if (h.output && h.output != "") {
            s += "#" + h.output;
          }

          f.push(s);
        }

        ret.push(f);
      }

      return ret;
    },


    /**
     * toDbFormat():
     *
     * @param datos {var} TODOC
     * @return {var} void
     *     
     *       TODO: levanta excepciones en caso de que haya error de formato
     */
    toDbFormat : function(datos)
    {
      var ret = new Array();
      var len = datos.length;

      for (var i=0; i<len; i++)
      {
        var len2 = datos[i].length;
        var newRow = new Array();

        for (var j=0; j<len2; j++)
        {
          var h = {};
          var s = datos[i][j];
          var output = "";
          var comment = "";
          var formula = "";

          /* parsing */

          if (s.match("#"))
          {
            var t = s.split("#");
            output = t[1];
            s = t[0];
          }

          if (s.match("=")) {
            formula = s.replace("=", "");
          } else {
            comment = s;
          }

          h["formula"] = formula;
          h["comment"] = comment;
          h["output"] = output;

          newRow.push(h);
        }

        ret.push(newRow);
      }

      return ret;
    },


    /**
     * parseGrid():
     *
     * @param dataTable {var} TODOC
     * @param formulasTable {var} TODOC
     * @param context {var} el this del llamante
     * @return {Hash} {changed_data(boolean), table (tabla de datos), calcedFields (vector de hashes de campos fuera de grilla) }
     */
    parseGrid : function(dataTable, formulasTable, context)
    {
      var len = dataTable.length;
      var len2 = len > 0 ? dataTable[0].length : 0;
      var resultHash = {};

      /* Preparar hash de resultados */

      resultHash["table"] = new Array();
      resultHash["changed_data"] = false;  /* hubieron cambios? */
      resultHash["calcedFields"] = new Array();

      for (var i=0; i<len; i++)
      {
        var row = new Array();

        if (inventario.widget.Table2.isEmpty2(dataTable, i, true))
        {

          /* las lineas en blanco no procesamos.. esta prueba convendria hacer sobre todas las columnas */

          for (var j=0; j<len2; j++)
          {
            if (typeof (dataTable[i][j]) == "object")
            {
              var h =
              {
                text  : " ",
                value : "-1"
              };

              row.push(h);
            }
            else
            {
              row.push(" ");
            }
          }
        }
        else
        {
          for (var j=0; j<len2; j++)
          {
            var formula = formulasTable[0][j].formula;  /* siempre estiramos la formula de la primera fila */

            if (formula && formula != "")
            {
              while (true)
              {
                /*
                                                 * La celda viene en formato "a$" donde _a_ es la columna y _$_ es la fila actual
                                                 */

                var m = formula.match(/[a-z]\$/);

                if (!m) {
                  break;
                }

                m = m.toString();

                /*
                                                 * La columna viene como una letra asi que hay convertir a su entero correspondiente...
                                                 */

                var col = m.match(/[a-z]/);
                col = col.toString();
                col = inventario.parser.GridFormulaParser.letter2number(col);

                /* El indice de la fila es el actual de la tabla */

                var fila = i;

                /* si ya evaluamos  esa celda traerlo de la nueva tabla */

                var o = (fila <= i && col <= j) ? dataTable[fila][col] : resultHash["table"][fila][col];

                /*
                                                 * Tenemos un Hash?
                                                 */

                var val = typeof (o) == "object" ? o.value : o;
                val = val ? val : 0;

                formula = formula.replace(m, val.toString());
              }

              /* nuestra formula deberia estar lista para un eval */

              var resultado = eval(formula);

              if (typeof (dataTable[i][j]) == "object")
              {
                row.push(dataTable[i][j]);
                row[j].value = resultado;
              }
              else
              {
                row[j] = resultado;
              }

              resultHash["changed_data"] = true;
            }
            else
            {
              row[j] = dataTable[i][j];
            }
          }
        }

        resultHash["table"].push(row);
      }

      /*
                   *   Evaluar formulas p/ propiedades fuera de la tabla
                   */

      var len = formulasTable.length;

      /* Si sum esta definida, guardar su referencia para luego restaurarla  */

      var oldSum = false;

      try
      {
        if (sum) {
          oldSum = sum;
        }
      }
      catch(e) {}

      var sum = function(col) {
        return inventario.parser.GridFormulaParser.sum(resultHash["table"], col);
      };

      for (var i=1; i<len; i++)
      {
        for (var j=0; j<len2; j++)
        {
          var f = formulasTable[i][j].formula;

          if (f && f != "")
          {

            /* TODO: Aca hay que implementar un parser serio */

            var h = {};
            h["property"] = formulasTable[i][j].output;
            var s = f.replace(/this/g, "context");
            h["number"] = eval(s);

            /* guardar el valor en su propiedad para futuros calculos */

            if (!h["property"].match(/\[/))
            {
              var s = "context.set" + h["property"] + "(" + h["number"] + ")";
              eval(s);
            }

            resultHash["calcedFields"].push(h);
            resultHash["changed_data"] = true;
          }
        }
      }

      if (oldSum) {
        sum = oldSum;
      }

      return resultHash;
    },


    /**
     * sum: sumatoria de columnas (limitado!)
     *
     * @param dataTable {var} TODOC
     * @param colLetter {var} TODOC
     * @return {Number} resultado
     */
    sum : function(dataTable, colLetter)
    {
      var s = 0;
      var len = dataTable.length;
      var col = inventario.parser.GridFormulaParser.letter2number(colLetter);

      for (var i=0; i<len; i++)
      {

        /* Fila  vacia: ya no puede haber nada mas abajo.. salimos */

        if (inventario.widget.Table2.isEmpty2(dataTable, i, true)) {
          break;
        }

        var cell = dataTable[i][col];
        var val = (typeof (cell) == "object") ? cell.value : cell;
        s += parseFloat(val);
      }

      return s;
    },


    /**
     * sum: sumatoria de columnas (limitado!)
     *
     * @param letter {var} TODOC
     * @return {Number} resultado
     */
    letter2number : function(letter)
    {
      var n = parseInt(letter.charCodeAt(0));
      return (n >= 97) ? (n - 97) : (n - 65);
    }
  }
});