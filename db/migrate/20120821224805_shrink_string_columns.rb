class ShrinkStringColumns < ActiveRecord::Migration
  def self.up
    # Some of these columns are used in indexes.
    # When we use utf8 we can't store 255-character fields in indexes.
    # So shrink them to 100 which is a more sensible size.
    change_column "audits", "auditable_type", :string, :limit => 100
    change_column "audits", "user_type", :string, :limit => 100
    change_column "audits", "username", :string, :limit => 100
    change_column "audits", "action", :string, :limit => 100
    change_column "audits", "association_type", :string, :limit => 100
    change_column "sessions", "session_id", :string, :limit => 100
    change_column "schema_migrations", "version", :string, :limit => 100
  end

  def self.down
  end
end
