#
# We add a column 'internal_tag' to be able to programatically (independently of 
# the user given description) fetch movement types
#
# We normalize old cases deleting and recreating them..
#

class AddInternalTagColumn < ActiveRecord::Migration

  def self.up
    add_column :movement_types, :internal_tag, :string, :limit => 100
    
    MovementType.transaction do         
      MovementType.find(:all).each { |i| i.destroy } 
    end
    
    mov_types = [
                 { :description => "Reparacion - Verificacion", :internal_tag => "reparacion" },
                 { :description => "Reparacion Finalizada - Devolucion Propietario", 
                   :internal_tag => "reparacion_finalizada" },
                 { :description => "Verificacion Finalizada - Devolucion Propietario", 
                   :internal_tag => "verificacion_finalizada" },
                 { :description => "Uso Desarrollador", :internal_tag => "uso_desarrollador" },
                 { :description => "Prestamo", :internal_tag => "prestamo" },
                 { :description => "Devolucion", :internal_tag => "devolucion" },
                 { :description => "Entrega Docente", :internal_tag => "entrega_docente" },
                 { :description => "Entrega Alumno", :internal_tag => "entrega_alumno" },
                 { :description => "Entrega Formador", :internal_tag => "entrega_formador" },
                 { :description => "Devolucion Problema Técnico en Entrega", 
                   :internal_tag => "devolucion_problema_tecnico_entrega" }
                ]
    
    
    MovementType.create!(mov_types)

  end

  def self.down
    remove_column :movement_types, :internal_tag
  end

end
