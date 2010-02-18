#     Copyright Paraguay Educa 2009
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>
# 
#                                                                          
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.


# # #
# Author: Raúl Gutiérrez
# E-mail Address: rgs@paraguayeduca.org
# 2009
# # #

# # #
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 
# 2009
# # #


class ApplicationController < ActionController::Base

  #Deprecated but still needed for audited_classes method (Plugin's bug)
  #It also requied to add acts_as_audited inside each model
  audit Person, Place, Laptop

  #gettext support
  #init_gettext("inventario", :locale_path => "#{RAILS_ROOT}/translation/locale")
  #GetText.locale = "es"

  cache_sweeper :object_sweeper
  before_init_gettext :default_locale
  before_filter :auth_control
  before_filter :access_control
  around_filter :do_scoping

  def initialize 
    super
    @check_authentication = true
  end

  private 

  def default_locale
    if !session["lang"]
      set_locale getDefaultLang
    else
      set_locale session["lang"]
    end
  end
 
  init_gettext("inventario", :locale_path => "#{RAILS_ROOT}/translation/locale")

  ###
  # tch says: 
  # Im aware that this method is not the best way acomplish this.
  # But, i had no other choice rather than rewriting it all, so 
  # lets live/get with it.
  def do_scoping(&block)

    # Finding current user's performing places
    person = current_user.person
    inc = [:performs]
    cond = [" performs.person_id = ? and performs.profile_id = ?", person.id, person.profile.id ]
    places_objs = Place.find(:all, :conditions => cond, :include => inc)
    places_ids = places_objs.collect(&:id)

    #File.open("/tmp/debug.txt", "w") { |f| f.write('hola'); }
    # {{{ Change our scope, selecting a sub-scope
    #if params[:vista] and params[:vista].match(/scope_\d/)
        #scope_id = params[:vista].split("_")[1].to_i
        #places_objs.each { |p_obj|
            #if p_obj.getDescendantsIds().include?(scope_id)
                #places_ids = [scope_id]
                #break
            #end
        #}
    #end
    # }}}

    classes = getScopedClasses()
    set_scope(classes, places_ids, block)
    #yield 

  end

  def set_scope(classes, places_ids, block)
   if (classes.length == 1)
       classes[0].setScope(places_ids) { block.call }
     else
       classes[0].setScope(places_ids) { 
          len = classes.length - 1
          set_scope(classes.slice(1, len), places_ids, block) 
       }
     end
  end
  
  ####
  #  this should be moved to lib/ along with a method (add_to_scoped_classes) that allows models 
  #  to register themselves as scoped classes
  #
  def getScopedClasses()      
    [ Place, Person, Laptop, ProblemReport, ProblemSolution, BankDeposit, Event, Node, SchoolInfo, Movement, MovementDetail, Lot, StatusChange, User, PartMovement, NotificationSubscriber ]
  end

  ###
  # Get ID from AbmForm 
  #
  def getId(p_id)
    p_id.to_i != -1 ? p_id.to_i : nil
  end

  ###
  # Check User permissions.
  #
  def verify_permission(controller_name, method_name, user)

    return true if user.hasProfiles?(["root","developer"])

    inc = [:person => {:performs => {:profile => {:permissions => :controller}}}]
    cond = ["users.person_id = ? and permissions.name = ? and controllers.name = ?", user.person.id, method_name, controller_name]
    return true if User.find(:first, :conditions => cond, :include => inc)
    false
  end

  ###
  # Checks for access_control
  #
  def access_control

    ret = verify_permission(params[:controller].camelize, params[:action] , current_user)
    if !ret
      msg = _("No tiene autorizacion para esta seccion")
      case request.format()
        when "application/xml"
          rest_access_response(msg)
        else
          json_access_response(msg)
      end
      return false
    end
  end

  def rest_access_response(msg)
    render :text => msg, :status => 403
  end

  def json_access_response(msg)
    @output["result"] = "Error"
    @output["msg"] =  msg
    render :text => @output.to_json
  end

  ###
  # Controls for authentication.
  #
  def auth_control

    case request.format()
      when "application/xml"
        rest_auth_control
      else
        json_auth_control
    end

  end

  def rest_auth_control
    authenticate_or_request_with_http_basic do |username, pass|
      user = User.login(username, pass)
      if user
        session[:user_id] = user.id
        true
      else
        false
      end
    end
  end

  def json_auth_control
    @output = {}

    if @check_authentication && !session[:user_id]
      @output["result"] = "Error"
      @output["msg"] =  "No esta autenticado"
      render :text => @output.to_json
      return false
    else
      @output["result"] = "ok"
    end
  end

  ####
  #
  #
  def save_object(model_ref, editing_id, attribs)

    if editing_id
      obj = model_ref.find(editing_id)
      obj.update_attributes!(attribs)
    else
      obj = model_ref.create!(attribs)
    end
    obj

  end


  def getAbmFormValue(o)
    if o.class == Hash
      o["value"]
    else
      o
    end
  end

  def ObtenerAtrib(objeto,obj_asociado,atributo,ret=" ")
    o = eval("objeto." + obj_asociado)
    if o
      ret = eval("o." + atributo)
    end
    return ret
  end

  #  Funciones para ACLs
  def current_user
    session[:user_id] ? User.find(session[:user_id]) : User.new
  end

  # buildSelectHash(): retorna una vector de hashes listo p/ que se genere un combobox
  def buildSelectHash(pClassName,pSelectedId,pText)
    ret = []
    for x in pClassName.find(:all)
      v = x.id
      t = eval("x." + pText.to_s)
      s = v.to_i == pSelectedId.to_i ? true : false
      ret.push( {:text => t,:value => v,:selected => s} )
    end
    # TODO: ordenar alfabeticamente por text..
    ret
  end


  # buildSelectHash2(): hice esta para no romper el api de buildSelectHash, eventualmente deberian fusionarse en una sola
  def buildSelectHash2(pClassName,pSelectedId,pText,includeBlank,condiciones = [],extraValues = [], includes = [])
    ret = []

    ret.push( {:text => " ",:value => "-1",:selected => true} ) if includeBlank

    hopts = Hash.new
    if condiciones.length > 0
      hopts[:conditions] = condiciones
      hopts[:include] = includes
    end


    for x in pClassName.find(:all,hopts)
      v = x.id
      t = eval("x." + pText.to_s)
      s = v.to_i == pSelectedId.to_i ? true : false
      h = {:text => t,:value => v,:selected => s}
      h["attribs"] = Hash.new
      extraValues.each { |columna|
        valTemp = x.send(columna.to_sym)
        h["attribs"][columna] = valTemp
      }
      ret.push(h)
    end

    # TODO: ordenar alfabeticamente por text..
    ret
  end

  def buildSelectHashSingle(pClassName, pSelectedId, pText)
    hash = { :text => "", :value => -1, :selected => true }
    if pSelectedId != -1
      hash[:value] = pSelectedId
      hash[:text] = eval("pClassName.find_by_id(pSelectedId)." + pText.to_s)
    end
    [hash]
  end

  # Genera un ComboBox p/ atributos Booleanos
  #
  # FIXME: usar bool en la DB!
  def buildBooleanSelectHash(yesSelected)
    ret = []
    ret.push( {:text => "Si",:value => "S",:selected => yesSelected ? true : false} )
    ret.push( {:text => "No",:value => "N",:selected => yesSelected == false ? true : false} )
    ret
  end

  # Genera un ComboBox p/ atributos Booleanos
  def buildBooleanSelectHash2(yesSelected)
    ret = []
    ret.push( {:text => "Si",:value => "1",:selected => yesSelected ? true : false} )
    ret.push( {:text => "No",:value => "0",:selected => yesSelected == false ? true : false} )
    ret
  end

  # Genera un ComboBox p/ atributos variables
  # @datos vector de hashes { text, value, selected (bool) }
  # FIXME: usar bool en la DB!
  def buildVariableSelectHash(datos,key)
    ret = []
    for d in datos
      ret.push( { :text => d["text"],:value => d["value"],:selected => d["value"] == key ? true : false  } )
    end
    ret
  end

  # rpc_block(): esta funcion es un wrapper para nuestras llamadas desde Qooxdoo
  #
  #
  def rpc_block

    begin
    # aca llamamos al metodo....
      yield
    rescue
      # Hack warning..... no se como evitar esta excepcion.
      if $!.class.to_s != "ActionView::MissingTemplate"
        @output["result"] = "Error"
        @output["msg"] = $!.to_s
        @output["codigo"] = $!.backtrace.join("\n")
      end
    end

    render :text => @output.to_json
  end

  
  ##
  # Obtener el nombre del usuario autenticado..
  #  Esto tal vez deberia ir en un modulo SessionUsuario::getUsuario() p/ q se pueda usar desde los modelos
  def getUsuario() 
    current_user ? current_user.person.getNombreCompleto() : " "
  end

  # Create a hash for Check Boxes.
  def buildCheckHash(pClassName,method,check_included=false,included_list=[])
    list = []
    pClassName.find(:all, :order => "id").each  { |o|
      h = Hash.new
      h[:label] =  o.send(method)
      h[:cb_name] = o.id
      h[:checked] = check_included ? included_list.include?(o) : true
      list.push(h)
    }
    list
  end

  ###
  # Some class has an special hierarchy structure, so this helps to build
  # the combobox entry for it.
  def buildHierarchyHash(modelClass, hierarchyMethod, hierarchyAttribute, infoMethod, targetId, pruneCond, pruneInc, includeBlank)
    
    cb_entries = []
    cb_entries.push(comboBoxifize()) if includeBlank

    objSet = modelClass.roots4(current_user)

    objSet.each { |classSubObj|

      if modelClass.roots4(current_user, pruneCond, pruneInc).include?(classSubObj)

        cb_entries.push(comboBoxifize(classSubObj, targetId, classSubObj.send(infoMethod)))
      end

      cb_entries += buildHierarchyHashR(classSubObj, hierarchyMethod, infoMethod, targetId, pruneCond, pruneInc,nil)
    }

    cb_entries
  end

  def buildHierarchyHashR(classObj, hierarchyMethod, infoMethod, targetId, pruneCond, pruneInc, concatInf)

    cb_entries = []
    next_concatInf = (concatInf ? concatInf+':' : "") + classObj.send(infoMethod)

    objSet = classObj.send(hierarchyMethod)

    objSet.each { |classSubObj|

      if objSet.find(:all, :conditions => pruneCond, :include => pruneInc).include?(classSubObj)
        cb_entries.push(comboBoxifize(classSubObj, targetId, next_concatInf+':'+classSubObj.send(infoMethod)))
      end

      cb_entries += buildHierarchyHashR(classSubObj, hierarchyMethod, infoMethod, targetId, pruneCond, pruneInc, next_concatInf)
    }

    cb_entries
  end

  def comboBoxifize(classObj = nil, targetId = nil, text = nil)
    entry = Hash.new
    entry[:text] = text ? text : ""
    entry[:value] = classObj ? classObj.id : -1
    entry[:selected] = (classObj && classObj.id == targetId) || (!classObj) ? true : false
    entry
  end

  # #
  # Language support facilities
  #
  def getAcceptedLang
    accepted_languages = ["es", "en"]
  end

  def getDefaultLang
    default = DefaultValue.find_by_key("lang")
    default_lang = default ? default.value : nil
    default_lang  = (default_lang && getAcceptedLang.include?(default_lang)) ? default_lang : "es"
  end

  def langCombo
    default_lang = session["lang"] ? session["lang"] : getDefaultLang
    lang_full_list = [default_lang] + (getAcceptedLang - [default_lang])

    comboDef = []
    first = true
    lang_full_list.each { |lang|

      comboDef.push({ :text => lang, :value => lang, :selected => first })
      first = false if first
    }

    comboDef
  end

  def setLanguage(lang)
    accepted_languages = getAcceptedLang
    session["lang"] = accepted_languages.include?(lang) ? lang : getDefaultLang
  end

end
