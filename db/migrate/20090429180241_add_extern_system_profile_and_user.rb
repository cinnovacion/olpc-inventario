class AddExternSystemProfileAndUser < ActiveRecord::Migration
  def self.up
    Profile.transaction do
      #For now we only need it to update the nodes from outside of the system.
      permissions = []
      permissions.push({ "name" => "Nodes", "methods" => [ "show", "up", "down"] })

      attribs = Hash.new
      attribs[:description] = "Extern System"
      attribs[:internal_tag] = "extern_system"

      Profile.register(attribs, permissions)
    end
  end

  def self.down
  end
end
