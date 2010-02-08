class AddLobbiestProfile < ActiveRecord::Migration
  def self.up
    Profile.transaction do
      Profile.create({ :description => "Receptor", :internal_tag => "lobbiest", :has_data_scope => false })
    end
  end

  def self.down
  end
end
