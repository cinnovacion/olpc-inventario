class CreateSoftwareVersions < ActiveRecord::Migration
  def self.up
    create_table :software_versions do |t|
      t.string :vhash, :limit => 64
      t.string :name, :limit => 100
      t.text :description
      t.references :model
      t.timestamps
    end
    add_foreign_key :software_versions, :models
    remove_column :laptops, :build_version
  end

  def self.down
    drop_table :software_versions
    add_column :laptops, :build_version, :string, :limit => 100
  end
end
