class AddLeaseExpiry < ActiveRecord::Migration
  class SchoolInfo < ActiveRecord::Base
  end

  def self.up
    add_column :school_infos, :lease_expiry, :date

    # Convert lease_duration from seconds into days
    SchoolInfo.all.each { |school|
      next if school.lease_duration.nil?
      school.lease_duration /= 3600 * 24
      school.save
    }
  end

  def self.down
    remove_column :school_infos, :lease_expiry
  end
end
