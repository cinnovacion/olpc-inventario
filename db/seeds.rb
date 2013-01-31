# -*- coding: utf-8 -*-

require "digest/sha1"

# SEED DATA

EventType.transaction do
  EventType.find_or_create_by_internal_tag("stolen_laptop_activity", :name => "Laptop Robada", :description => "Se detecto el intento de activacion de una de las laptops robadas en el School Server")
  EventType.find_or_create_by_internal_tag("node_down", :name => "Nodo Caido", :description => "Un nodo entro en estado de inactividad")
  EventType.find_or_create_by_internal_tag("node_up", :name => "Nodo Arriba", :description => "Un nodo de red entro en estado de actividad")
end

Model.transaction do
  Model.find_or_create_by_name("XO-1", description: "Estas son las primeras XOs, de material rugoso, verde y blanca")
  Model.find_or_create_by_name("XO-1 (B2)", description: "Modelos de laptop lisa")
  Model.find_or_create_by_name("XO-1.5", description: "XO-1.5 laptop con VIA CPU")
  Model.find_or_create_by_name("XO-1.75", description: "XO-1.75 laptop con ARM CPU")
  Model.find_or_create_by_name("XO-4", description: "XO-4 laptop con ARM CPU")
end

MovementType.transaction do
  MovementType.find_or_create_by_internal_tag("reparacion", :description => "Reparacion o Verificacion", :is_delivery => "false")
  MovementType.find_or_create_by_internal_tag("reparacion_finalizada", :description => "Reparacion Finalizada - Devolucion Propietario", :is_delivery => "false")
  MovementType.find_or_create_by_internal_tag("verificacion_finalizada", :description => "Verificacion Finalizada - Devolucion Propietario", :is_delivery => "false")
  MovementType.find_or_create_by_internal_tag("uso_desarrollador", :description => "Uso Desarrollador", :is_delivery => "true")
  MovementType.find_or_create_by_internal_tag("prestamo", :description => "Prestamo", :is_delivery => "true")
  MovementType.find_or_create_by_internal_tag("devolucion", :description => "Devolucion", :is_delivery => "false")
  MovementType.find_or_create_by_internal_tag("entrega_alumno", :description => "Entrega", :is_delivery => "true")
  MovementType.find_or_create_by_internal_tag("devolucion_problema_tecnico_entrega", :description => "Devolucion Problema Técnico en Entrega", :is_delivery => "false")
  MovementType.find_or_create_by_internal_tag("transfer", :description => "Transferencia", :is_delivery => "false")
end

NodeType.transaction do
  NodeType.find_or_create_by_internal_tag("center", :name => "Centro", :description => "Indica el punto inicial en el cual se enfoca el mapa.")
  NodeType.find_or_create_by_internal_tag("ap", :name => "Access Point", :description => "Punto de accesso a red inalambrica.")
  NodeType.find_or_create_by_internal_tag("server", :name => "Servidor", :description => "Servidor de la escuela.")
  NodeType.find_or_create_by_internal_tag("tower", :name => "Torre", :description => "Torre del ISP para distribucion wimax.")
  NodeType.find_or_create_by_internal_tag("ap_down", :name => "Access Point Abajo", :description => "Access Point que actualmente no esta en servicio.")
  NodeType.find_or_create_by_internal_tag("server_down", :name => "Servidor Abajo", :description => "Servidor de la escuela que actualmente no esta en servicio.")
end

Notification.transaction do
  Notification.find_or_create_by_internal_tag("problem_report", :name => "Problema reportado", :description => "Un problema ha sido reportado", :active => "true")
  Notification.find_or_create_by_internal_tag("problem_solution", :name => "Problema Solucionado", :description => "Un problema ha sido solucionado", :active => "true")
  Notification.find_or_create_by_internal_tag("node_down", :name => "Nodo Abajo", :description => "Un Nodo ha dejado de funcionar", :active => "true")
  Notification.find_or_create_by_internal_tag("node_up", :name => "Nodo Arriba", :description => "Un Nodo ha vuelto a funcionar", :active => "true")
end

PartType.transaction do
  PartType.find_or_create_by_internal_tag("laptop", :cost => "", :description => "Laptop")
  PartType.find_or_create_by_internal_tag("battery", :cost => "", :description => "Bateria")
  PartType.find_or_create_by_internal_tag("charger", :cost => "", :description => "Cargador")
  PartType.find_or_create_by_internal_tag("screen", :cost => "", :description => "Pantalla")
  PartType.find_or_create_by_internal_tag("keyboard", :cost => "", :description => "Teclado")
  PartType.find_or_create_by_internal_tag("antenna", :cost => "", :description => "Antena")
end

Profile.transaction do
  Profile.find_or_create_by_internal_tag("developer", :access_level => "600", :description => "Desarrollador")
  Profile.find_or_create_by_internal_tag("root", :access_level => "500", :description => "Administrador")
  Profile.find_or_create_by_internal_tag("technician", :access_level => "300", :description => "Tecnico")
  Profile.find_or_create_by_internal_tag("educator", :access_level => "0", :description => "Formador")
  Profile.find_or_create_by_internal_tag("teacher", :access_level => "200", :description => "Maestro")
  Profile.find_or_create_by_internal_tag("volunteer", :access_level => "0", :description => "Voluntario")
  Profile.find_or_create_by_internal_tag("student", :access_level => "100", :description => "Estudiante")
  Profile.find_or_create_by_internal_tag("director", :access_level => "300", :description => "Director")
  Profile.find_or_create_by_internal_tag("electric_technician", :access_level => "0", :description => "Electricista")
  Profile.find_or_create_by_internal_tag("guardian", :access_level => "0", :description => "Custodio")
  Profile.find_or_create_by_internal_tag("guest", :access_level => "0", :description => "Invitado")
  Profile.find_or_create_by_internal_tag("extern_system", :access_level => "0", :description => "Extern System")
  Profile.find_or_create_by_internal_tag("network_control", :access_level => "0", :description => "NetworkControl")
  Profile.find_or_create_by_internal_tag("netmonitor", :access_level => "0", :description => "NetworkMonitor")
  Profile.find_or_create_by_internal_tag("laptop_register", :access_level => "0", :description => "LaptopRegister")
  Profile.find_or_create_by_internal_tag("education_team", :access_level => "0", :description => "EducationTeam")
  Profile.find_or_create_by_internal_tag("visitor", :access_level => "0", :description => "Visitante")
  Profile.find_or_create_by_internal_tag("lobbiest", :access_level => "0", :description => "Receptor")
  Profile.find_or_create_by_internal_tag("default", :access_level => "0", :description => "defecto")
end

PlaceType.transaction do
  PlaceType.find_or_create_by_internal_tag("country", :name => "Pais")
  PlaceType.find_or_create_by_internal_tag("state", :name => "Departamento")
  PlaceType.find_or_create_by_internal_tag("city", :name => "Ciudad")
  PlaceType.find_or_create_by_internal_tag("school", :name => "Escuela")
  PlaceType.find_or_create_by_internal_tag("first_grade", :name => "Primer Grado")
  PlaceType.find_or_create_by_internal_tag("second_grade", :name => "Segundo Grado")
  PlaceType.find_or_create_by_internal_tag("third_grade", :name => "Tercer Grado")
  PlaceType.find_or_create_by_internal_tag("fourth_grade", :name => "Cuarto Grado")
  PlaceType.find_or_create_by_internal_tag("fifth_grade", :name => "Quinto Grado")
  PlaceType.find_or_create_by_internal_tag("sixth_grade", :name => "Sexto Grado")
  PlaceType.find_or_create_by_internal_tag("section", :name => "Seccion")
  PlaceType.find_or_create_by_internal_tag("shift", :name => "Turno")
  PlaceType.find_or_create_by_internal_tag("special", :name => "Educacion Especial")
  PlaceType.find_or_create_by_internal_tag("kinder", :name => "Preescolar")
  PlaceType.find_or_create_by_internal_tag("institution", :name => "Institucion")
  PlaceType.find_or_create_by_internal_tag("seventh_grade", :name => "Septimo grado")
  PlaceType.find_or_create_by_internal_tag("eighth_grade", :name => "Octavo grado")
  PlaceType.find_or_create_by_internal_tag("ninth_grade", :name => "Noveno grado")
  PlaceType.find_or_create_by_internal_tag("root", :name => "Root")
end

Status.transaction do
  Status.find_or_create_by_internal_tag("dead", :abbrev => "DOA", :description => "Dead on arrival")
  Status.find_or_create_by_internal_tag("deactivated", :abbrev => "D", :description => "En desuso")
  Status.find_or_create_by_internal_tag("activated", :abbrev => "U", :description => "En uso")
  Status.find_or_create_by_internal_tag("on_repair", :abbrev => "ER", :description => "En reparacion")
  Status.find_or_create_by_internal_tag("repaired", :abbrev => "R", :description => "Reparado")
  Status.find_or_create_by_internal_tag("stolen", :abbrev => "S", :description => "Robado")
  Status.find_or_create_by_internal_tag("lost", :abbrev => "L", :description => "Perdido")
  Status.find_or_create_by_internal_tag("broken", :abbrev => "B", :description => "Roto")
  Status.find_or_create_by_internal_tag("ripped", :abbrev => "RIP", :description => "Desensamblado")
end

PartMovementType.transaction do
  PartMovementType.find_or_create_by_internal_tag("new_part_in", :name => "Entrada por compra", :direction => true)
  PartMovementType.find_or_create_by_internal_tag("part_replacement_out", :name => "Salida como repuesto", :direction => false)
  PartMovementType.find_or_create_by_internal_tag("part_transfered_out", :name => "Salida por transferencia", :direction => false)
  PartMovementType.find_or_create_by_internal_tag("part_transfered_in", :name => "Entrada por transferencia", :direction => true)
end

# INITIAL SETTINGS/ACCOUNTS

if !Place.exists?
  root_type = PlaceType.find_by_internal_tag("root")
  root_place = Place.create(:name => "Rootland", :description => "Root System Place", :place_type_id => root_type.id)

  Node.create(:name => "RootLand", :lat => "-25.289453059491", :lng => "-57.5725463032722", :node_type_id => "1", :place_id => "1", :zoom => 19)
  Person.create(:name => "System", :lastname => "Root", :id_document => "0", :email => "sistema@paraguayeduca.org")

  devel_profile = Profile.find_by_internal_tag("developer")
  Perform.create(:person_id => Person.first.id, :place_id => root_place.id, :profile_id => devel_profile.id)
  User.find_or_create_by_usuario("admin", :password => Digest::SHA1.hexdigest("admin"), :person_id => 1)
end

DefaultValue.find_or_create_by_key("google_api_url", :value => "http://www.google.com/jsapi?key=")
DefaultValue.find_or_create_by_key("google_api_key", :value => "ABCDEFG")
DefaultValue.find_or_create_by_key("lang", :value => "es")

# FIXES FOR EXISTING DATA
require './db/existing_data_fixes.rb'
