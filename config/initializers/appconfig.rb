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
