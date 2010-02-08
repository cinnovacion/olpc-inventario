
qx.Class.define("inventario.window.Abm2SetScope",
{
    extend : inventario.window.AbstractWindow,
    type : "singleton",

    construct : function()
    {
    },

    events: {
        "changeScope" : "qx.event.type.Event"
    },

    properties: {
        title : {
            check : "String",
            init  : "Set Scope"
        },
        parentWindow: {
            check : "Object",
            init  : null
        },
        scope: {
            check: "Number",
            init : -1
        }
    },

    members : {
        show : function (page, title) {
            if (this.__visible) {
                return;
            }
            this.__visible = true;
            this.setPage(page);
            var o = new Array();
            this.setInputsOM(o);
            var o = new Array();
            this.setToolBarButtons(o);

            /* Manejo de abreviaciones de teclado */
            var o = new inventario.util.ObjectManager();
            this.setCommandsManager(o);

            var v = new Array();
            this.setAceleradores(v);

            this.prepared = false;
            this._searchMode = false;

            this.setUsePopup(true);
            if (typeof (title) != "undefined") this.setTitle(title);

            get_selected = function (q) {
                var selected_element = this.getSelection()[0];
                var pwindow  = this.getUserData("pwindow");
                if (typeof selected_element != "undefined") {
                    var element_data = selected_element.getUserData("data");
                    if (element_data.id > 0) {
                        pwindow.fireDataEvent("changeScope", element_data.id);
                        pwindow.setScope(element_data.id);
                    }
                }
            }

            var mainVBox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20));
            var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox());
            var input = new inventario.widget.HierarchyOnDemand(null, null);

            input.getTreeWidget().addListener("dblclick", get_selected);
            input.getTreeWidget().setUserData("pwindow", this);
            mainVBox.add(hbox);
            hbox.add(input);
            this._doShow2(mainVBox, false);
            this.setWindowTitle(this.getTitle());

            /* */
            var wpopup = this.getAbstractPopupWindow().getWindow();

            wpopup.addListenerOnce("appear", function() {
                wpopup.set({
                    allowClose  : false,
                    allowGrowX :false,
                    allowGrowY : false,
                    allowMinimize :true,
                    allowMaximize :false,
                    showMaximize : false,
                    showMinimize : true,
                    showClose : false,
                    height: 100,
                    width: 50,
                    alignX : "right",
                    alignY : "middle"
                });
                this.setAlignX("right");
                this.setAlignY("middle");
            }, wpopup);
        }
    }

} );
