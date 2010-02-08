class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.string :description, :limit => 255
      t.string :internal_tag, :limit => 100
    end

  Profile.transaction do
    Profile.create!({:description => "Desarrollador", :internal_tag => "developer"})
    Profile.create!({:description => "Administrador", :internal_tag => "root"})
    Profile.create!({:description => "Tecnico", :internal_tag => "technician"})
    Profile.create!({:description => "Formador", :internal_tag => "educator"})
    Profile.create!({:description => "Maestro", :internal_tag => "teacher"})
    Profile.create!({:description => "Voluntario", :internal_tag => "volunteer"})
    Profile.create!({:description => "Estudiante", :internal_tag => "student"})
  end

  end

  def self.down
    drop_table :profiles
  end
end
