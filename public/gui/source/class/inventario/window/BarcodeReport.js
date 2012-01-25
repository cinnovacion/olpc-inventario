
//     Copyright Daniel Drake 2012
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
// A dialog to show the options for creating a laptop barcode report.

qx.Class.define("inventario.window.BarcodeReport",
{
  extend : inventario.window.AbstractWindow,

  construct : function()
  {
    this.base(arguments, qx.locale.Manager.tr("Print barcodes"));
    this.getVbox().getLayout().setSpacing(10);

    this._place_selector = new inventario.widget.MultipleHierarchySelection();
    this.getVbox().add(this._place_selector, {flex: 1});

    var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox());
    hbox.getLayout().setSpacing(30);
    this.getVbox().add(hbox);

    var vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox());
    vbox.getLayout().setSpacing(10);
    hbox.add(vbox);

    var filters = [
      { label: this.tr("With laptops in hands"), cb_name: "with", checked: true },
      { label: this.tr("Without laptops in hands"), cb_name: "with_out", checked: true },
      { label: this.tr("With laptops assigned"), cb_name: "with_assigned", checked: true },
      { label: this.tr("Without laptops assigned"), cb_name: "with_out_laptops_assigned", checked: true }
    ];
    this._laptop_filter = new inventario.widget.CheckboxSelector(this.tr("Filters"), filters, 1);
    vbox.add(this._laptop_filter);

    var profiles = [
      { label: this.tr("Student"), cb_name: "student", checked: true },
      { label: this.tr("Teacher"), cb_name: "teacher", checked: true }
    ];
    this._profile_filter = new inventario.widget.CheckboxSelector(this.tr("Profiles"), profiles, 1);
    vbox.add(this._profile_filter);

    vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox());
    hbox.add(vbox);

    this._print_laptop_names = new qx.ui.form.CheckBox(this.tr("Print laptop name labels"));
    vbox.add(this._print_laptop_names);

    vbox.add(new qx.ui.core.Spacer(0, 10));
    vbox.add(new qx.ui.basic.Label(this.tr("Box labels:")));

    this._box_labels_group = new qx.ui.form.RadioButtonGroup();
    vbox.add(this._box_labels_group);
    this._box_labels_group.getLayout().setSpacing(0);

    this._box_labels_none = new qx.ui.form.RadioButton(this.tr("None"));
    this._box_labels_none.setModel("none");
    this._box_labels_group.add(this._box_labels_none);

    this._box_labels_short = new qx.ui.form.RadioButton(this.tr("Short"));
    this._box_labels_short.setValue(true);
    this._box_labels_short.setModel("short");
    this._box_labels_group.add(this._box_labels_short);

    this._box_labels_detailed = new qx.ui.form.RadioButton(this.tr("Detailed"));
    this._box_labels_detailed.setModel("detailed");
    this._box_labels_group.add(this._box_labels_detailed);
    
    this._generate_button = new qx.ui.form.Button(this.tr("Generate"),
                                                  "inventario/22/adobe-reader.png");
    this._generate_button.addListener("execute", this._generate_cb, this);
    this.getVbox().add(this._generate_button);
  },

  members : {
    _generate_cb : function(e) {
      var params = {
        places: this._place_selector.getValues(),
        laptop_filter: this._laptop_filter.getSelectedParts(),
        profile_filter: this._profile_filter.getSelectedParts(),
        box_labels: this._box_labels_group.getModelSelection().getItem(0)
      };

      if (this._print_laptop_names.getValue())
        params["laptop_names"] = 1;

      var opts = { print_params: qx.lang.Json.stringify(params) };
      var iframe = inventario.util.PrintManager.print("barcodes", opts);
      var document = inventario.Application.appInstance.getRoot();
      document.add(iframe, { bottom: 1, right: 1 });
    }
  }
});
