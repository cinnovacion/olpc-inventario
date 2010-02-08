class RenameStatusUsed < ActiveRecord::Migration
  def self.up
    [["used","En uso"],["broken","Roto"]].each { |status_def|
      status = Status.find_by_internal_tag(status_def[0])
      if status
	status.description = status_def[1]
	status.save
      end
    }
  end

  def self.down
  end
end
