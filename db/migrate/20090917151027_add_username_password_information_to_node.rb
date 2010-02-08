class AddUsernamePasswordInformationToNode < ActiveRecord::Migration
  def self.up

    add_column :nodes, :username, :string, :limit => 100
    add_column :nodes, :password, :string, :limit => 100
    add_column :nodes, :information, :text

    Node.reset_column_information

    default_username = ""
    default_password = ""

    inc = [:node_type]
    cond = ["node_types.internal_tag in (?)", ["ap", "ap_down"]]
    Node.find(:all, :conditions => cond, :include => inc).each { |node|

      node.username = default_username
      node.password = default_password
      node.information = {}.to_json
      node.save!
    }

  end

  def self.down

    remove_column :nodes, :username
    remove_column :nodes, :password
    remove_column :nodes, :information
  end
end
