class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :usuario, :limit => 40
      t.string :clave, :limit => 40
    end
  end

  def self.down
    drop_table :users
  end
end
