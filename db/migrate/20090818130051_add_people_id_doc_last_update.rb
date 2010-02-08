class AddPeopleIdDocLastUpdate < ActiveRecord::Migration
  def self.up

    add_column :people, :id_document_created_at, :date, :default => nil

    Person.reset_column_information

    Person.find(:all).each { |person|
      person.id_document_created_at = person.created_at.to_date if person.hasValidIdDoc?
      person.save
    }

  end

  def self.down

    remove_column :people, :id_document_created_at

  end
end
