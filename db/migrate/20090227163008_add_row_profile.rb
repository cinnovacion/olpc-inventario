class AddRowProfile < ActiveRecord::Migration
  def self.up
    Profile.transaction do
      Profile.create!({ :description => "Director", :internal_tag => "director" })
      Profile.create!({ :description => "Electricista", :internal_tag => "electric_technician" })
      Profile.create!({ :description => "Custodio", :internal_tag => "guardian" })
    end
  end

  def self.down
  end
end
