/**
 *	author: crodas (crodas@member.fsf.org)
 *	
 *	GPL
 */
qx.Class.define("inventario.widget.Autocomplete",
{
    extend : qx.core.Object,

    construct: function(page)
    {
        this.base(arguments, page);
    },

    properties:
    {
        autocompleteElements :
        {
            check:"Array",
            init: [], 
			apply: "_addData"
        },
        container: 
        {
            check:"Object",
            init: null
        },
		callback: {
			init: null
		}
    },

    members:
    {

		clearData: function() {
			this.init = [];
		},

		_addData: function(value) {
			this.getAutocompleteElements().concat(value);
		},

		/* show()  {{{
		   This function renders the widget into the container  */
        show: function() 
        { 
            this._createLayout();
            this.__textfield = new qx.ui.form.TextField();
            this.__list      = new qx.ui.form.List();

            /* local references {{{ */
                var textfield  = this.__textfield;
                var list       = this.__list;
                var container  = this.__container;
            /* }}} */

            list.hide();
            textfield.setLiveUpdate(true);
            container.add(textfield);

            this.__popup.add(list);
			this.__popup.setMinWidth(textfield.getWidth());
			list.setMinWidth(textfield.getWidth());

            textfield.addListener("changeValue", this._onChange, this);
            textfield.addListener("keypress", this._onTextKeypress, this);
            list.addListener("keypress", this._onListKeypress, this);
        },
		/* }}} */

        _onTextKeypress: function(e) {
			if (this.__list.getVisibility() != 'visible') {
				return false;
			}
            switch (e.getKeyIdentifier()) {
			case 'Enter':
				var select = this.__list.getSelection();
				if (select.length != 1) {
					return;
				}
				var f = select[0].getUserData("callback_function");
				var context = select[0].getUserData("callback_context");
				f.call(context);
				this.__popup.hide();
                this.__list.hide();

				break;
			case 'Down':
                var items = this.__list.getSelectables();
                if (items.length == 0) {
                    return; /* it should never happen */
                }
                this.__list.setSelection([ items[0] ]);
                this.__list.focus();
                this.__lastKey = 0;
				break;
			}
        },

        _onListKeypress: function(e) {
            var select = this.__list.getSelection();
            if (select.length != 1) {
                return;
            }
            switch (e.getKeyIdentifier()) {
			case 'Enter':
				var f = select[0].getUserData("callback_function");
				var context = select[0].getUserData("callback_context");
				f.call(context);
				this.__popup.hide();
                this.__list.hide();
				break;
			case 'Up':
                if (select[0].getModel() == this.__lastKey && this.__lastKey == 0) {
                    this.__textfield.focus();
                    this.__list.resetSelection();
                } 
				break;
            }
            this.__lastKey = select[0].getModel(); 
        },

        _createLayout: function() 
        {
            this.__container = new qx.ui.container.Composite(new qx.ui.layout.VBox(5));
			this.__popup     = new qx.ui.popup.Popup(new qx.ui.layout.VBox(20)).set({
				//backgroundColor: "#DFFAD3",
				padding: [2, 4],
				offset : 0,
				position : "bottom-left"
			});
            this.getContainer().add(this.__container);
        },

        
        _onChange: function(e)
        {

            /* local references {{{ */
                var textfield = this.__textfield;
                var list      = this.__list;
            /* }}} */

            var data    = this.getAutocompleteElements();
            var rawData = [];
            var text    = textfield.getValue().toLowerCase();
            list.removeAll();

            for (var i in data) {
                if (data[i].label.toLowerCase().match(text)) {
                    rawData.push(data[i]);
                }
            }
            
            if (rawData.length > 0 && text.length > 0) {
				var size = rawData.length > 10 ? 10 : rawData.length;
                list.setHeight(parseInt(25 * (size + 0.2)));
                for (var i in rawData) {
                    var _item = new qx.ui.form.ListItem(rawData[i].label, "", i);
					_item.setUserData("callback_function", rawData[i].callback);
					_item.setUserData("callback_context", rawData[i].context);
                    list.add(_item);
                    /* select the first element */
                    if (i==0) {
                        list.setSelection([_item]);
                    }
					if (parseInt(i)+1 >= size) {
						break;
					}
                }
                list.show();
				this.__popup.placeToWidget(textfield);
				this.__popup.show();
				this.__popup.setWidth(250);
            } else {
				this.__popup.hide();
                list.hide();
            }
        }
    }
});


/*
 * Local variables:
 * tab-width: 4
 * c-basic-offset: 4
 * End:
 * vim600: noet sw=4 ts=4 fdm=marker
 * vim<600: noet sw=4 ts=4
 */
