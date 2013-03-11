app_config_file = File.join(Rails.root, "config", "inventario.yml")
if File.exists?(app_config_file)
  APP_CONFIG = YAML.load_file(app_config_file)
else
  APP_CONFIG = {}
end

# Defaults
APP_CONFIG["name"] = 'OLPC Inventario' if APP_CONFIG["name"].nil?
APP_CONFIG["enable_movement_type_checking"] = true if APP_CONFIG["enable_movement_type_checking"].nil?
APP_CONFIG["repairs_require_deposits"] = true if APP_CONFIG["repairs_require_deposits"].nil?
APP_CONFIG["overpack_boxes"] = false if APP_CONFIG["overpack_boxes"].nil?

# FIXME: its hard to make timezone stick if set outside of application.rb
# Copy over some activesupport initializer code to make this work.
# Looks like this won't be needed in Rails 4.
if APP_CONFIG["timezone"].present?
  Rails.application.config.time_zone = APP_CONFIG["timezone"]
  Time.zone = APP_CONFIG["timezone"]
  Time.zone_default = Time.find_zone!(Rails.application.config.time_zone)
end
