class AddMovementTypeMovementHeader < ActiveRecord::Migration
  def self.up
    add_column :movements, :movement_type_id, :integer

    # normalize data
    Movement.find(:all, :include => [:movement_details]).each { |m|
      m.movement_type_id = m.movement_details[0].movement_type_id
      m.save!
    }

  end

  def self.down
    remove_column :movements, :movement_type_id
  end

end
