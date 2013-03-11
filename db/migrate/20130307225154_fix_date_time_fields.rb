class FixDateTimeFields < ActiveRecord::Migration
  def up
    # Fold various timestamp fields (where separated into time and date)
    # into a single datetime field, named created_at so that Rails automatically
    # sets it.

    add_column :assignments, :created_at, :datetime
    sql = 'UPDATE assignments SET created_at=concat(date_assigned, " ", time_assigned)'
    ActiveRecord::Base.connection.execute(sql)
    remove_column :assignments, :date_assigned
    remove_column :assignments, :time_assigned

    change_column :movements, :created_at, :datetime
    sql = 'UPDATE movements SET created_at=concat(date_moved_at, " ", time_moved_at)'
    ActiveRecord::Base.connection.execute(sql)
    remove_column :movements, :date_moved_at
    remove_column :movements, :time_moved_at

    add_column :status_changes, :created_at, :datetime
    sql = 'UPDATE status_changes SET created_at=concat(date_created_at, " ", time_created_at)'
    ActiveRecord::Base.connection.execute(sql)
    remove_column :status_changes, :date_created_at
    remove_column :status_changes, :time_created_at

    rename_column :nodes, :last_update_at, :updated_at
  end

  def down
    raise "Can't reverse"
  end
end
