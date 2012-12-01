class PlaceDependency < ActiveRecord::Base
  belongs_to :descendant, :class_name => "Place", :foreign_key => :descendant_id
  belongs_to :ancestor, :class_name => "Place", :foreign_key => :ancestor_id

  attr_accessible :descendant, :descendant_id
  attr_accessible :ancestor, :ancestor_id

  ###
  # Creates all dependencies for the descendant_place
  def self.register_dependencies(descendant_place)
    
    descendant_id = descendant_place.id

    # Every place has a dependency with its own
    ancestors_ids = descendant_place.calcAncestorsIds.push(descendant_id)
    ancestors_ids.each { |ancestor_id|
      
      PlaceDependency.create({ :descendant_id => descendant_id, :ancestor_id => ancestor_id })
    }

  end

  ###
  # When a place dependency its modified, all the sub tree must be updated
  def self.update_dependencies(descendant_place, new_parent_place)

    old_ancestors_ids = descendant_place.ancestors.map { |ancestor| ancestor.id }
    new_ancestors_ids = new_parent_place.ancestors.map { |ancestor| ancestor.id }.push(descendant_place.id)
    descendants_ids = descendant_place.descendants.map { |descendant| descendant.id }

    # Deleting old dependencies
    cond = [" descendant_id in (?) and ancestor_id in (?) ", descendants_ids, old_ancestors_ids]
    deprecated_dependencies = PlaceDependency.find(:all, :conditions => cond)
    PlaceDependency.destroy(deprecated_dependencies)

    # Adding new depedencies
    descendants_ids.each { |descendant_id|
      new_ancestors_ids.each { |ancestor_id|
        PlaceDependency.create({ :descendant_id => descendant_id, :ancestor_id => ancestor_id })
      }
    }

  end

  ###
  # When a place its remove, all its dependencies must be deleted
  def self.unregister_dependencies(descendant_place)

    cond = [" descendant_id = ? ", descendant_place]
    tobe_destroyed = PlaceDependency.find(:all, :conditions => cond)
    PlaceDependency.destroy(tobe_destroyed)

  end


  ###
  # In case of emergency brake the glass
  def self.set_family_tree_in_situ(place)

    place.ancestors_ids = (place.ancestors.collect(&:id) - [place.id]).to_json
    place.descendants_ids = (place.descendants.collect(&:id) - [place.id]).to_json 

  end

  def self.please_fix_it

    Place.send(:with_exclusive_scope) do

      Place.transaction do

        # We get rid of all of the corrupt dependency table.
        PlaceDependency.all.each { |dep| dep.destroy }

        # We create it from scratch
        Place.all.each { |place| PlaceDependency.register_dependencies(place) }

        # We update in situ fields
        Place.all.each { |place| 
          PlaceDependency.set_family_tree_in_situ(place)
          place.save
        }
      end
    end
    true
  end

  def self.check

    Place.send(:with_exclusive_scope) do

      Place.all.each { |place|

        calculated_ancestors_ids = place.calcAncestorsIds
        calculated_descendants_ids = place.calcDescendantsIds

        raise "1" if (calculated_ancestors_ids + [place.id]) - place.ancestors.collect(&:id) != []
        raise "2" if place.ancestors.collect(&:id) - (calculated_ancestors_ids + [place.id]) != []

        raise "3" if (calculated_descendants_ids + [place.id]) - place.descendants.collect(&:id) != []
        raise "4" if place.descendants.collect(&:id) - (calculated_descendants_ids + [place.id]) != []

        raise "5" if calculated_ancestors_ids - place.getAncestorsIds != []
        raise "6" if place.getAncestorsIds - calculated_ancestors_ids != []

        raise "7" if calculated_descendants_ids - place.getDescendantsIds != []
        raise "8" if place.getDescendantsIds - calculated_descendants_ids != []

      }
    end

    return true
  end

end
