class AddVisitorProfile < ActiveRecord::Migration
  def self.up
    Profile.transaction do
      Profile.create({ :description => "Visitante", :internal_tag => "visitor", :has_data_scope => true })
    end
  end

  def self.down
  end
end
