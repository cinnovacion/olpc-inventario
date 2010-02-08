class AddNodeUpEventType < ActiveRecord::Migration
  def self.up
    EventType.transaction do

      attribs = Hash.new
      attribs[:name] = "Nodo Arriba"
      attribs[:description] = "Un nodo de red entro en estado de actividad"
      attribs[:internal_tag] = "node_up"
      EventType.create(attribs)

      inc = [:event_type]
      cond = ["event_types.internal_tag in (?)",["node_down","node_up"]]
      Event.find(:all, :conditions => cond, :include => inc).each { |event|
        
        info = event.getHash
        node = Node.find_by_id(info["id"])
        if node
          node_type = node.node_type.getInternalTag
          node_nature = node_type.match("^server(|_down)$") ? "server" : node_type.match("^ap(|_down)$") ? "ap" : nil
          info.merge!({ :type => node_nature })
          event.setHash(info)
          event.save!
        end
      }

    end
  end

  def self.down
  end
end
