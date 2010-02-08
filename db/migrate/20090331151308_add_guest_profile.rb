class AddGuestProfile < ActiveRecord::Migration
  def self.up
    permissions = []
    permissions.push({ "name" => "People", "methods" => [ "search", "do_search","search_options", "new" ] } )
    permissions.push({ "name" => "Laptops", "methods" => [ "search", "do_search","search_options", "new" ] } )
    permissions.push({ "name" => "Places", "methods" => [ "search", "do_search","search_options", "new" ] } )

    attribs = Hash.new
    attribs[:description] = "Invitado"
    attribs[:internal_tag] = "guest"

    Profile.register(attribs, permissions)
  end

  def self.down
    Profile.delete(Profile.find_by_internal_tag("guest"))
  end
end
