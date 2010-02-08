class AddNodesIps < ActiveRecord::Migration
  def self.up
    Node.transaction do
      include_v = [:node_type]
      cond_v = ["node_types.internal_tag in (?)", ["ap","ap_down"]]
      Node.find(:all, :conditions => cond_v, :include => include_v).each { |node|
        postfix =  node.name.split("-")[1]
        ip = (postfix and postfix.match(/\d/) and (1..254).include?(postfix.to_i)) ? "172.18.126.#{postfix.to_i.to_s}" : "Error"
        node.ip_address = ip
        node.save!
      }
    end
  end

  def self.down
  end
end
