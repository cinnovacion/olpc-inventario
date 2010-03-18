/* ************************************************************************

   Copyright: //     This program is free software: you can redistribute it and/or modify
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


   License: GPL v3.0+

   Authors: mabente

************************************************************************ */

/**
 * This class demonstrates how to define unit tests for your application.
 *
 * Execute <code>generate.py test</code> to generate a testrunner application 
 * and open it from <tt>test/index.html</tt>
 *
 * The methods that contain the tests are instance methods with a 
 * <code>test</code> prefix. You can create an arbitrary number of test 
 * classes like this one. They can be organized in a regular class hierarchy, 
 * i.e. using deeper namespaces and a corresponding file structure within the 
 * <tt>test</tt> folder.
 */
qx.Class.define("inventario.test.WidgetsTest",
{
  extend : qx.dev.unit.TestCase,

  members :
  {
    /*
            ---------------------------------------------------------------------------
              TESTS
            ---------------------------------------------------------------------------
            */

    /**
     * Test CheckboxSelector
     *
     * @return {void} 
     */
    testCheckboxSelector : function()
    {
      // this.assertEquals(4, 3+1, "This should never fail!");
      // this.assertFalse(false, "Can false be true?!");
      // this.assertIdentical(a, b, "A rose by any other name is still a rose");
      // this.assertInRange(3, 1, 10, "You must be kidding, 3 can never be outside [1,10]!");
      var v = new Array();

      v.push(
      {
        label   : "Laptop:",
        cb_name : "laptop"
      });

      v.push(
      {
        label   : qx.locale.Manager.tr("Charger:"),
        cb_name : "charger"
      });

      v.push(
      {
        label   : qx.locale.Manager.tr("Battery:"),
        cb_name : "battery"
      });

      v.push(
      {
        label   : qx.locale.Manager.tr("Either:"),
        cb_name : "any"
      });

      // FIXME: invenario.* namespace not being loaded..
      var widget = new inventario.widget.CheckboxSelector(qx.locale.Manager.tr("Parts"), v);

      this.getRoot().add(widget);
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    testDateRange : function() {
      this.getRoot().add(new inventario.widget.DateRange());
    }
  }
});
