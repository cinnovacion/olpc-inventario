class CreateSchoolInfos < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :school_infos do |t|
      t.integer  :place_id
      t.integer  :lease_duration
      t.string  :server_hostname, :limit => 255
      t.string  :wan_ip_address, :limit => 255
      t.string  :wan_netmask, :limit => 255
      t.string  :wan_gateway, :limit => 255
    end
    self.createConstraint("school_infos", "place_id", "places")
  end

  def self.down
    self.removeConstraint("school_infos", "place_id")
    drop_table :school_infos
  end
end
