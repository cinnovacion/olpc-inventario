  
  #####
  # Application specific Data, (Non-trivial-data)
  #
  require "digest/sha1"

  root_place = create_if_not_exists(Place, {:id => "1", :name => "Rootland", :description => "Root System Place"})
  create_if_not_exists(Node, { :id => "1", :name => "RootLand", :lat => "-25.289453059491", :lng => "-57.5725463032722", :node_type_id => "1", :place_id => "1", :zoom => 19 })

  root_person = create_if_not_exists(Person, {:id => "1", :name => "System", :lastname => "Root", :id_document => "0", :email => "sistema@paraguayeduca.org" })

  devel_profile = Profile.find_by_internal_tag("developer")
  create_if_not_exists(Perform, { :id => "1", :person_id => root_person.id, :place_id => root_place.id, :profile_id => devel_profile.id })

  create_if_not_exists(User, { :id => "1", :usuario => "admin", :password =>  Digest::SHA1.hexdigest("admin"), :person_id => root_person.id})

  create_if_not_exists(DefaultValue, { :id => "1", :key => "google_api_url", :value => "http://www.google.com/jsapi?key=" })
  create_if_not_exists(DefaultValue, { :id => "2", :key => "google_api_key", :value => "ABCDEFG" })

