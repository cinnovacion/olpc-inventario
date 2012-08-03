class SimplifyEntregaMovementTypes < ActiveRecord::Migration
  def self.up
    # Having 3 entrega movement types (student, docente, formador) was
    # not necessary (the person type is a separate entity from the movement).
    # Simplify all these into a single "Entrega" type, still with the internal
    # tag "entrega_alumno" for now.

    entrega_type = MovementType.find_by_internal_tag("entrega_alumno")

    mt = MovementType.find_by_internal_tag("entrega_docente")
    if mt
      Movement.find_all_by_movement_type_id(mt.id).each { |movement|
        movement.movement_type_id = entrega_type.id
        movement.save!
      }
      mt.destroy
    end

    mt = MovementType.find_by_internal_tag("entrega_formador")
    if mt
      Movement.find_all_by_movement_type_id(mt.id).each { |movement|
        movement.movement_type_id = entrega_type.id
        movement.save!
      }
      mt.destroy
    end

    entrega_type.description = "Entrega"
    entrega_type.save!
  end

  def self.down
  end
end
