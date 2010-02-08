class SetScopeProfiles < ActiveRecord::Migration
  def self.up
    Profile.transaction do
      no_scope_profiles_tags = ["root","guest","extern_system","network_control","teacher","netmonitor","laptop_register"]
      cond_v = ["internal_tag in (?)", no_scope_profiles_tags]
      Profile.find(:all, :conditions => cond_v).each { |profile|
        profile.has_data_scope = false
        profile.save!
      }
    end
  end

  def self.down
  end
end
