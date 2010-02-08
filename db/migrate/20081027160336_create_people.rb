class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.date :created_at
      t.string :name , :limit => 100
      t.string :lastname , :limit => 100
      t.string :id_document , :limit => 100
      t.date :birth_date
      t.string :phone , :limit => 100
      t.string :cell_phone , :limit => 100
      t.string :email , :limit => 100
      t.integer :place_id
    end
  end

  def self.down
    drop_table :people
  end
end
