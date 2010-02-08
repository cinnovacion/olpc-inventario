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

// TODO: esto deberia ser un Singleton (nose como se implmenta :( )
//       Si esto es un singleton despues podemos acceder al desde todo el sistema
//       y obtener info acerca del usuario autenticado
qx.Class.define("inventario.sistema.Login",
{
  extend : qx.core.Object,
  include : [qx.locale.MTranslation],





  /*
  *****************************************************************************
     CONSTRUCTOR
  *****************************************************************************
  */

  construct : function(loginUrl)
  {
    this.base(arguments);
   // llamar al constructor del padre

    if (loginUrl && loginUrl != "") {
      this.setLoginUrl(loginUrl);
    }
  },




  /*
  *****************************************************************************
     PROPERTIES
  *****************************************************************************
  */

  properties :
  {
    loginUrl :
    {
	check : "String"
    },

    loginOk :
    {
	check : "Boolean",
	init : false
    },

    callBackFn :
    {
	check : "Function"
    },

    callBackContext :
    {
	check : "Object"
    },

    passwordField :
    {
	check : "Object"
    },

    nameField :
    {
	check : "Object"
    },

    window :
    {
	check : "Object"
    },

    userName :
    {
	check : "String"
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
     * login(): iniciar Ventana de Login
     *
     * @type member
     * @param msg {String} motivo de la autenticacion
     * @return {void} void
     */
    login : function() {
      var opts = {};
      opts["url"] = "/sistema/login_info";
      opts["parametros"] = null;
      opts["handle"] = this._loginResp;
      opts["data"] = null;
      inventario.transport.Transport.callRemote(opts, this);
    },

   _loginResp : function(remoteData, handleParams) {
      var revision_num = remoteData.info.app_revision;
      //var msg = "Bienvenido al Sistema (revision " + revision_num.toString() +  ")";
      var msg = this.tr("Bienvenido al sistema");
      this.loginWindow(msg);
    },

    /* this.doLogin(); */

    /**
     * doLogin(): bloquearse hasta que se haya autenticado
     *
     * @type member
     * @return {void} void
     */
    doLogin : function()
    {
      if (!this.getLoginOk()) {
        qx.event.Timer.once(this.doLogin, this, 100);
      }
    },

    /* setTimeout(this.doLogin,0); */

    /**
     * loginWindow(): autenticarse & ingresar al sistema
     *
     * @type member
     * @param msg {String} motivo de la autenticacion
     * @return {void} void
     */
    loginWindow : function(msg)
    {
      var win = new qx.ui.window.Window("Ingresar al Sistema", "icon/16/status/dialog-password.png");
      win.addListener("appear", function(e){ win.center();});

      win.setLayout(new qx.ui.layout.VBox(10));
      this.setWindow(win);

      with (win)
      {
        setModal(true);
        setShowClose(false);
        setShowMaximize(false);
        setShowMinimize(false);
      }

      var vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20));

      /* motivo de autenticacion */
      var l = new qx.ui.basic.Label((msg && msg != "") ? msg : "Bienvenido al Sistema");
      vbox.add(l);

      /* grid */
      var gl = new qx.ui.layout.Grid();
      var container = new qx.ui.container.Composite(gl);

      /* datos p/ ingresar */
      var userLabel = new qx.ui.basic.Label("Usuario");
      container.add(userLabel, {row: 0, column: 0});

      var userName = new qx.ui.form.TextField;
      this.setNameField(userName);
      container.add(userName, {row: 0, column: 1});


      var passwdLabel = new qx.ui.basic.Label("Password");
      container.add(passwdLabel, {row: 1, column: 0});
      var passwdInput = new qx.ui.form.PasswordField;
      this.setPasswordField(passwdInput);
      container.add(passwdInput, {row: 1, column: 1});

      vbox.add(container);

      /* submit */
      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(10));

      var spacer = new qx.ui.core.Spacer(30, 40);
      hbox.add(spacer, { flex : 1 });

      var bLogin = new qx.ui.form.Button("Ingresar");
      bLogin.addListener("execute", this._login_cb, this);
      hbox.add(bLogin, { flex : 2 });

      spacer = new qx.ui.core.Spacer(30, 40);
      hbox.add(spacer, { flex : 1 });

      vbox.add(hbox);


      win.add(vbox);
      win.addListener("appear", this._appear_cb, this);

      // FIXME: es necesario esto para centrar la ventana?
      // win.setMinWidth();
      // win.setMinHeight();

      win.center();
      win.open();
      win.addListener("keydown", this._eventHandler, this);
    },


    /**
     * TODOC
     *
     * @type member
     * @param e {Event} TODOC
     * @return {void}
     */
    _eventHandler : function(e)
    {
        if (e.getKeyIdentifier() == 'Enter') {
            this.loginHandler(this.getNameField().getValue(), this.getPasswordField().getValue());
        }
    },


    /**
     * loginHandler(): autenticarse & ingresar al sistema
     *
     * @type member
     * @param userName {var} TODOC
     * @param passwd {var} TODOC
     * @return {void} void
     */
    loginHandler : function(userName, passwd)
    {
      /*
       * SECURITY WARNING: habria que chequear si estamos sobre https o rehusar hacer esto...
       */

      var errorMsg;
      if (userName && userName.toString().length > 0) {
	if (passwd && passwd.toString().length > 0) {
	  /* todo bien */
	  errorMsg = "";
	} else { errorMsg = "Ingrese correctamente su Password";  }
      } else { errorMsg = "Ingrese correctamente su Usuario"; }

      if (errorMsg && errorMsg != "") {
	var f = function() {};
	inventario.window.Mensaje.mensaje(errorMsg,f,this);
	return;
      }

      this.setUserName(userName);
      var data =
	{
	  username : userName,
	  password : hex_sha1(passwd.toString())
	};

      var url = this.getLoginUrl();

      try
	{
	  inventario.transport.Transport.callRemote(
						    {
						      url        : url,
							parametros : null,
							handle     : this.loginHandlerResp,
							data       : data
							},
						    this);
	}
      catch(e)
	{
	  inventario.window.Mensaje.mensaje(e);
	}
    },


    /**
     * loginHandlerResp():
     *
     * @type member
     * @param remoteData {var} TODOC
     * @param handleParams {var} TODOC
     * @return {void} void
     */
    loginHandlerResp : function(remoteData, handleParams)
    {
      this.getWindow().removeListener("keydown", this._eventHandler, this);

      if (remoteData["auth"])
      {
        this.setLoginOk(true);
        var c = this.getCallBackContext();
        c.setUserName(this.getUserName());
        this.getCallBackFn().call(c, remoteData["privs"]);  /* ceder el mando al que pidio la autenticacion */
        this.getWindow().close();
      }
      else
      {
        var f = function() {
            this.getPasswordField().setValue("");
            this.getWindow().addListener("keydown", this._eventHandler, this);
        };
        inventario.window.Mensaje.mensaje(remoteData["msg"],f,this);
      }
    },

    _appear_cb : function() {
      this.getNameField().focus();
    },

    _login_cb : function(e) {
      this.loginHandler(this.getNameField().getValue(), this.getPasswordField().getValue());
    }


  }
});
