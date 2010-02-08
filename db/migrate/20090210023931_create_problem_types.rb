class CreateProblemTypes < ActiveRecord::Migration
  def self.up
    create_table :problem_types do |t|
      t.string :description, :limit => 255
      t.string :internal_tag, :limit => 100
    end

    ProblemType.transaction do
      ProblemType.create!({:description => "Cambio de pantalla", :internal_tag => "screen_change"})
      ProblemType.create!({:description => "Cambio de teclado", :internal_tag => "keyboard_change"})
      ProblemType.create!({:description => "Re-instalacion de actividades", :internal_tag => "activities_reinstall"})
      ProblemType.create!({:description => "Re-instalacion de sistema operativo", :internal_tag => "so_reinstall"})
    end

  end

  def self.down
    drop_table :problem_types
  end
end
