# Monkey-patch ActiveRecord to create the schema_migrations table with a
# shorter string limit, so that the column is small enough to use as a utf8mb4
# index.

module ActiveRecord
  module ConnectionAdapters
    module SchemaStatements

      alias_method :initialize_schema_migrations_table_original, :initialize_schema_migrations_table
      def initialize_schema_migrations_table
        ActiveRecord::ConnectionAdapters::Mysql2Adapter::NATIVE_DATABASE_TYPES[:string][:limit] = 100
        initialize_schema_migrations_table_original
        ActiveRecord::ConnectionAdapters::Mysql2Adapter::NATIVE_DATABASE_TYPES[:string][:limit] = 255
      end

    end
  end
end
