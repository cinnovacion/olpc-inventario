class AddBarCodePeople < ActiveRecord::Migration
  def self.up
    add_column :people, :barcode, :string, :limit => 255
    Person.transaction do
      Person.find(:all).each { |person|
        person.generateBarCode if person.profiles.map { |profile| profile.internal_tag }.include?("student")
      }
    end
  end

  def self.down
    remove_column :people, :barcode
  end
end
