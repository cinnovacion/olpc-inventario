# -*- coding: utf-8 -*-
  
  #####
  #  Basic methods
  #
  def create_if_not_exists(tClass, attrHash)

    object = tClass.find_by_id(attrHash[:id])
    if !object

      object = tClass.new
      attrHash.keys.each { |key|
   
        object.send("#{key}=", attrHash[key])
      }

      object.save!
    end

    object
  end


	######
	#  Seeding Data
	#	
	EventType.transaction do

		create_if_not_exists(EventType, {:name => "Laptop Robada", :internal_tag => "stolen_laptop_activity", :id => "1", :description => "Se detecto el intento de activacion de una de las laptops robadas en el School Server"})
		create_if_not_exists(EventType, {:name => "Nodo Caido", :internal_tag => "node_down", :id => "2", :description => "Un nodo entro en estado de inactividad"})
		create_if_not_exists(EventType, {:name => "Nodo Arriba", :internal_tag => "node_up", :id => "3", :description => "Un nodo de red entro en estado de actividad"})
	end

	LaptopConfig.transaction do

		create_if_not_exists(LaptopConfig, {:id => "1", :value => "767", :resource_name => "", :description => "Version SO", :key => "build_version"})
		create_if_not_exists(LaptopConfig, {:id => "2", :value => "1", :resource_name => "", :description => "Modelo", :key => "model_id"})
		create_if_not_exists(LaptopConfig, {:id => "3", :value => "1", :resource_name => "", :description => "Cargamento", :key => "shipment_id"})
		create_if_not_exists(LaptopConfig, {:id => "4", :value => "3", :resource_name => "personas", :description => "En manos de", :key => "person_id"})
		create_if_not_exists(LaptopConfig, {:id => "5", :value => "3", :resource_name => "", :description => "Localidad", :key => "place_id"})
	end

	Model.transaction do

		create_if_not_exists(Model, {:name => "XO-1", :created_at => "2008-10-27", :id => "1", :description => "Estas son las primeras XOs, de material rugoso, verde y blanca"})
		create_if_not_exists(Model, {:name => "XO-2", :created_at => "2008-11-10", :id => "2", :description => "Esta va a estar disponible en el 2009"})
		create_if_not_exists(Model, {:name => "XO-1 (B2)", :created_at => "2009-09-23", :id => "3", :description => "Modelos de laptop lisa"})
		create_if_not_exists(Model, {:name => "XO-1.5", :created_at => "2010-07-23", :id => "4", :description => "XO-1.5 laptop con VIA CPU"})
		create_if_not_exists(Model, {:name => "XO-1.75", :created_at => "2010-07-23", :id => "5", :description => "XO-1.75 laptop con ARM CPU"})
		create_if_not_exists(Model, {:name => "XO-3", :created_at => "2010-07-23", :id => "6", :description => "XO-3 tablet"})
	end

	MovementType.transaction do

		create_if_not_exists(MovementType, {:internal_tag => "reparacion", :id => "6", :description => "Reparacion o Verificacion", :is_delivery => "false"})
		create_if_not_exists(MovementType, {:internal_tag => "reparacion_finalizada", :id => "7", :description => "Reparacion Finalizada - Devolucion Propietario", :is_delivery => "false"})
		create_if_not_exists(MovementType, {:internal_tag => "verificacion_finalizada", :id => "8", :description => "Verificacion Finalizada - Devolucion Propietario", :is_delivery => "false"})
		create_if_not_exists(MovementType, {:internal_tag => "uso_desarrollador", :id => "9", :description => "Uso Desarrollador", :is_delivery => "true"})
		create_if_not_exists(MovementType, {:internal_tag => "prestamo", :id => "10", :description => "Prestamo", :is_delivery => "true"})
		create_if_not_exists(MovementType, {:internal_tag => "devolucion", :id => "11", :description => "Devolucion", :is_delivery => "false"})
		create_if_not_exists(MovementType, {:internal_tag => "entrega_docente", :id => "12", :description => "Entrega Docente", :is_delivery => "true"})
		create_if_not_exists(MovementType, {:internal_tag => "entrega_alumno", :id => "13", :description => "Entrega Alumno", :is_delivery => "true"})
		create_if_not_exists(MovementType, {:internal_tag => "entrega_formador", :id => "14", :description => "Entrega Formador", :is_delivery => "true"})
		create_if_not_exists(MovementType, {:internal_tag => "devolucion_problema_tecnico_entrega", :id => "15", :description => "Devolucion Problema Técnico en Entrega", :is_delivery => "false"})
		create_if_not_exists(MovementType, {:internal_tag => "transfer", :id => "16", :description => "Transferencia", :is_delivery => "false"})
	end

	NodeType.transaction do

		create_if_not_exists(NodeType, {:name => "Centro", :internal_tag => "center", :id => "1", :description => "Indica el punto inicial en el cual se enfoca el mapa."})
		create_if_not_exists(NodeType, {:name => "Access Point", :internal_tag => "ap", :id => "2", :description => "Punto de accesso a red inalambrica."})
		create_if_not_exists(NodeType, {:name => "Servidor", :internal_tag => "server", :id => "3", :description => "Servidor de la escuela."})
		create_if_not_exists(NodeType, {:name => "Torre", :internal_tag => "tower", :id => "4", :description => "Torre del ISP para distribucion wimax."})
		create_if_not_exists(NodeType, {:name => "Access Point Abajo", :internal_tag => "ap_down", :id => "5", :description => "Access Point que actualmente no esta en servicio."})
		create_if_not_exists(NodeType, {:name => "Servidor Abajo", :internal_tag => "server_down", :id => "6", :description => "Servidor de la escuela que actualmente no esta en servicio."})
	end

	Notification.transaction do

		create_if_not_exists(Notification, {:name => "Problema reportado", :internal_tag => "problem_report", :id => "1", :description => "Un problema ha sido reportado", :active => "true"})
		create_if_not_exists(Notification, {:name => "Problema Solucionado", :internal_tag => "problem_solution", :id => "2", :description => "Un problema ha sido solucionado", :active => "true"})
		create_if_not_exists(Notification, {:name => "Nodo Abajo", :internal_tag => "node_down", :id => "3", :description => "Un Nodo ha dejado de funcionar", :active => "true"})
		create_if_not_exists(Notification, {:name => "Nodo Arriba", :internal_tag => "node_up", :id => "4", :description => "Un Nodo ha vuelto a funcionar", :active => "true"})
	end

	PartType.transaction do

		create_if_not_exists(PartType, {:cost => "", :internal_tag => "laptop", :id => "1", :description => "Laptop"})
		create_if_not_exists(PartType, {:cost => "", :internal_tag => "battery", :id => "2", :description => "Bateria"})
		create_if_not_exists(PartType, {:cost => "", :internal_tag => "charger", :id => "3", :description => "Cargador"})
		create_if_not_exists(PartType, {:cost => "", :internal_tag => "screen", :id => "4", :description => "Pantalla"})
		create_if_not_exists(PartType, {:cost => "", :internal_tag => "keyboard", :id => "5", :description => "Teclado"})
		create_if_not_exists(PartType, {:cost => "", :internal_tag => "antenna", :id => "6", :description => "Antena"})
	end

	Profile.transaction do

		create_if_not_exists(Profile, {:access_level => "600", :internal_tag => "developer", :id => "1", :description => "Desarrollador"})
		create_if_not_exists(Profile, {:access_level => "500", :internal_tag => "root", :id => "2", :description => "Administrador"})
		create_if_not_exists(Profile, {:access_level => "300", :internal_tag => "technician", :id => "3", :description => "Tecnico"})
		create_if_not_exists(Profile, {:access_level => "0", :internal_tag => "educator", :id => "4", :description => "Formador"})
		create_if_not_exists(Profile, {:access_level => "200", :internal_tag => "teacher", :id => "5", :description => "Maestro"})
		create_if_not_exists(Profile, {:access_level => "0", :internal_tag => "volunteer", :id => "6", :description => "Voluntario"})
		create_if_not_exists(Profile, {:access_level => "100", :internal_tag => "student", :id => "7", :description => "Estudiante"})
		create_if_not_exists(Profile, {:access_level => "300", :internal_tag => "director", :id => "8", :description => "Director"})
		create_if_not_exists(Profile, {:access_level => "0", :internal_tag => "electric_technician", :id => "9", :description => "Electricista"})
		create_if_not_exists(Profile, {:access_level => "0", :internal_tag => "guardian", :id => "10", :description => "Custodio"})
		create_if_not_exists(Profile, {:access_level => "0", :internal_tag => "guest", :id => "12", :description => "Invitado"})
		create_if_not_exists(Profile, {:access_level => "0", :internal_tag => "extern_system", :id => "13", :description => "Extern System"})
		create_if_not_exists(Profile, {:access_level => "0", :internal_tag => "network_control", :id => "14", :description => "NetworkControl"})
		create_if_not_exists(Profile, {:access_level => "0", :internal_tag => "netmonitor", :id => "15", :description => "NetworkMonitor"})
		create_if_not_exists(Profile, {:access_level => "0", :internal_tag => "laptop_register", :id => "16", :description => "LaptopRegister"})
		create_if_not_exists(Profile, {:access_level => "0", :internal_tag => "education_team", :id => "17", :description => "EducationTeam"})
		create_if_not_exists(Profile, {:access_level => "0", :internal_tag => "visitor", :id => "18", :description => "Visitante"})
		create_if_not_exists(Profile, {:access_level => "0", :internal_tag => "lobbiest", :id => "19", :description => "Receptor"})
		create_if_not_exists(Profile, {:access_level => "0", :internal_tag => "default", :id => "20", :description => "defecto"})
	end

	PlaceType.transaction do

		create_if_not_exists(PlaceType, {:name => "Pais", :internal_tag => "country", :id => "1"})
		create_if_not_exists(PlaceType, {:name => "Departamento", :internal_tag => "state", :id => "2"})
		create_if_not_exists(PlaceType, {:name => "Ciudad", :internal_tag => "city", :id => "3"})
		create_if_not_exists(PlaceType, {:name => "Escuela", :internal_tag => "school", :id => "4"})
		create_if_not_exists(PlaceType, {:name => "Primer Grado", :internal_tag => "first_grade", :id => "5"})
		create_if_not_exists(PlaceType, {:name => "Segundo Grado", :internal_tag => "second_grade", :id => "6"})
		create_if_not_exists(PlaceType, {:name => "Tercer Grado", :internal_tag => "third_grade", :id => "7"})
		create_if_not_exists(PlaceType, {:name => "Cuarto Grado", :internal_tag => "fourth_grade", :id => "8"})
		create_if_not_exists(PlaceType, {:name => "Quinto Grado", :internal_tag => "fifth_grade", :id => "9"})
		create_if_not_exists(PlaceType, {:name => "Sexto Grado", :internal_tag => "sixth_grade", :id => "10"})
		create_if_not_exists(PlaceType, {:name => "Seccion", :internal_tag => "section", :id => "11"})
		create_if_not_exists(PlaceType, {:name => "Turno", :internal_tag => "shift", :id => "12"})
		create_if_not_exists(PlaceType, {:name => "Educacion Especial", :internal_tag => "special", :id => "13"})
		create_if_not_exists(PlaceType, {:name => "Preescolar", :internal_tag => "kinder", :id => "14"})
		create_if_not_exists(PlaceType, {:name => "Institucion", :internal_tag => "institution", :id => "15"})
		create_if_not_exists(PlaceType, {:name => "Septimo grado", :internal_tag => "seventh_grade", :id => "16"})
		create_if_not_exists(PlaceType, {:name => "Octavo grado", :internal_tag => "eighth_grade", :id => "17"})
		create_if_not_exists(PlaceType, {:name => "Noveno grado", :internal_tag => "ninth_grade", :id => "18"})
		create_if_not_exists(PlaceType, {:name => "Root", :internal_tag => "root", :id => "19"})
	end

	Status.transaction do

		create_if_not_exists(Status, {:internal_tag => "dead", :abbrev => "DOA", :id => "1", :description => "Dead on arrival"})
		create_if_not_exists(Status, {:internal_tag => "deactivated", :abbrev => "DA", :id => "2", :description => "Desactivado"})
		create_if_not_exists(Status, {:internal_tag => "activated", :abbrev => "A", :id => "3", :description => "Activado"})
		create_if_not_exists(Status, {:internal_tag => "on_repair", :abbrev => "ER", :id => "4", :description => "En reparacion"})
		create_if_not_exists(Status, {:internal_tag => "repaired", :abbrev => "R", :id => "5", :description => "Reparado"})
		create_if_not_exists(Status, {:internal_tag => "stolen", :abbrev => "S", :id => "6", :description => "Robado"})
		create_if_not_exists(Status, {:internal_tag => "stolen_deactivated", :abbrev => "SDA", :id => "7", :description => "Robado Desactivado"})
		create_if_not_exists(Status, {:internal_tag => "lost", :abbrev => "L", :id => "8", :description => "Perdido"})
		create_if_not_exists(Status, {:internal_tag => "lost_deactivated", :abbrev => "LDA", :id => "9", :description => "Perdido Desactivado"})
		create_if_not_exists(Status, {:internal_tag => "available", :abbrev => "AV", :id => "10", :description => "Disponible"})
		create_if_not_exists(Status, {:internal_tag => "used", :abbrev => "US", :id => "11", :description => "En uso"})
		create_if_not_exists(Status, {:internal_tag => "broken", :abbrev => "B", :id => "12", :description => "Roto"})
		create_if_not_exists(Status, {:internal_tag => "ripped", :abbrev => "RIP", :id => "13", :description => "Desensamblado"})
	end

  PartMovementType.transaction do
  
    create_if_not_exists(PartMovementType, {:name => "Entrada por compra", :internal_tag => "new_part_in", :direction => true})
    create_if_not_exists(PartMovementType, {:name => "Salida como repuesto", :internal_tag => "part_replacement_out", :direction => false})
    create_if_not_exists(PartMovementType, {:name => "Salida por transferencia", :internal_tag => "part_transfered_out", :direction => false})
    create_if_not_exists(PartMovementType, {:name => "Entrada por transferencia", :internal_tag => "part_transfered_in", :direction => true})
  end
  
  #####
  # Application specific Data, (Non-trivial-data)
  #
  require "digest/sha1"

  root_place = create_if_not_exists(Place, {:id => "1", :name => "Rootland", :description => "Root System Place", :place_type_id => "19"})
  create_if_not_exists(Node, { :id => "1", :name => "RootLand", :lat => "-25.289453059491", :lng => "-57.5725463032722", :node_type_id => "1", :place_id => "1", :zoom => 19 })

  root_person = create_if_not_exists(Person, {:id => "1", :name => "System", :lastname => "Root", :id_document => "0", :email => "sistema@paraguayeduca.org" })

  devel_profile = Profile.find_by_internal_tag("developer")
  create_if_not_exists(Perform, { :id => "1", :person_id => root_person.id, :place_id => root_place.id, :profile_id => devel_profile.id })

  create_if_not_exists(User, { :id => "1", :usuario => "admin", :password =>  Digest::SHA1.hexdigest("admin"), :person_id => root_person.id})

  create_if_not_exists(DefaultValue, { :id => "1", :key => "google_api_url", :value => "http://www.google.com/jsapi?key=" })
  create_if_not_exists(DefaultValue, { :id => "2", :key => "google_api_key", :value => "ABCDEFG" })
  create_if_not_exists(DefaultValue, { :id => "3", :key => "lang", :value => "es" })

