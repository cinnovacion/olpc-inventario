# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121201175153) do

  create_table "assignments", :force => true do |t|
    t.date    "date_assigned"
    t.time    "time_assigned"
    t.integer "source_person_id"
    t.integer "destination_person_id"
    t.integer "laptop_id"
    t.text    "comment"
  end

  add_index "assignments", ["destination_person_id"], :name => "assignments_destination_person_id_fk"
  add_index "assignments", ["laptop_id"], :name => "assignments_laptop_id_fk"
  add_index "assignments", ["source_person_id"], :name => "assignments_source_person_id_fk"

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type",  :limit => 100
    t.integer  "user_id"
    t.string   "user_type",       :limit => 100
    t.string   "username",        :limit => 100
    t.string   "action",          :limit => 100
    t.text     "audited_changes"
    t.integer  "version",                        :default => 0
    t.datetime "created_at"
    t.string   "comment"
    t.string   "remote_address"
    t.integer  "associated_id"
    t.string   "associated_type", :limit => 100
  end

  add_index "audits", ["associated_id", "associated_type"], :name => "associated_index"
  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "bank_deposits", :force => true do |t|
    t.integer "problem_solution_id"
    t.string  "deposit",             :limit => 100
    t.float   "amount",                             :default => 0.0
    t.date    "created_at"
    t.date    "deposited_at"
    t.string  "bank",                :limit => 100
  end

  add_index "bank_deposits", ["problem_solution_id"], :name => "bank_deposits_problem_solution_id_fk"

  create_table "controllers", :force => true do |t|
    t.string "name", :limit => 100
  end

  create_table "default_values", :force => true do |t|
    t.string "key",   :limit => 100
    t.text   "value"
  end

  create_table "event_types", :force => true do |t|
    t.string "name",         :limit => 100
    t.string "description"
    t.string "internal_tag", :limit => 100
  end

  create_table "events", :force => true do |t|
    t.integer  "event_type_id"
    t.datetime "created_at"
    t.string   "reporter_info", :limit => 100
    t.text     "extended_info"
    t.integer  "place_id"
  end

  add_index "events", ["place_id"], :name => "events_place_id_fk"

  create_table "images", :force => true do |t|
    t.date   "created_at"
    t.string "name",       :limit => 100
    t.binary "file",       :limit => 16777215
  end

  create_table "laptop_details", :force => true do |t|
    t.integer "section_detail_id"
    t.integer "person_id"
    t.integer "laptop_id"
  end

  add_index "laptop_details", ["laptop_id"], :name => "laptop_details_laptop_id_fk"
  add_index "laptop_details", ["person_id"], :name => "laptop_details_person_id_fk"
  add_index "laptop_details", ["section_detail_id"], :name => "laptop_details_section_detail_id_fk"

  create_table "laptops", :force => true do |t|
    t.string  "serial_number",        :limit => 100
    t.date    "created_at"
    t.integer "model_id"
    t.integer "shipment_arrival_id"
    t.integer "owner_id"
    t.integer "status_id"
    t.string  "uuid"
    t.boolean "registered",                          :default => false
    t.date    "last_activation_date"
    t.integer "assignee_id"
  end

  add_index "laptops", ["assignee_id"], :name => "laptops_assignee_id_fk"
  add_index "laptops", ["model_id"], :name => "laptops_model_id_fk"
  add_index "laptops", ["owner_id"], :name => "laptops_owner_id_fk"
  add_index "laptops", ["status_id"], :name => "laptops_status_id_fk"

  create_table "lots", :force => true do |t|
    t.date    "created_at"
    t.date    "delivery_date"
    t.integer "person_id"
    t.boolean "delivered"
    t.integer "boxes_number"
  end

  add_index "lots", ["person_id"], :name => "lots_person_id_fk"

  create_table "models", :force => true do |t|
    t.date   "created_at"
    t.string "name",        :limit => 100
    t.text   "description"
  end

  create_table "movement_types", :force => true do |t|
    t.string  "description"
    t.string  "internal_tag", :limit => 100
    t.boolean "is_delivery",                 :default => true
  end

  create_table "movements", :force => true do |t|
    t.date    "created_at"
    t.date    "date_moved_at"
    t.time    "time_moved_at"
    t.integer "responsible_person_id"
    t.integer "source_person_id"
    t.integer "destination_person_id"
    t.text    "comment"
    t.date    "return_date"
    t.integer "movement_type_id"
    t.integer "laptop_id"
    t.boolean "returned",              :default => false
  end

  add_index "movements", ["destination_person_id"], :name => "movements_destination_person_id_fk"
  add_index "movements", ["laptop_id"], :name => "index_movements_on_laptop_id"
  add_index "movements", ["movement_type_id"], :name => "movements_movement_type_id_fk"
  add_index "movements", ["responsible_person_id"], :name => "movements_responsible_person_id_fk"
  add_index "movements", ["source_person_id"], :name => "movements_source_person_id_fk"

  create_table "node_types", :force => true do |t|
    t.string  "name",         :limit => 100
    t.string  "description"
    t.string  "internal_tag", :limit => 100
    t.integer "image_id"
  end

  add_index "node_types", ["image_id"], :name => "node_types_image_id_fk"

  create_table "nodes", :force => true do |t|
    t.string   "name",                  :limit => 100
    t.string   "lat",                   :limit => 100
    t.string   "lng",                   :limit => 100
    t.integer  "node_type_id"
    t.integer  "place_id"
    t.integer  "zoom"
    t.datetime "last_update_at"
    t.string   "ip_address",            :limit => 100
    t.datetime "last_status_change_at"
    t.string   "height",                :limit => 100
    t.string   "username",              :limit => 100
    t.string   "password",              :limit => 100
    t.text     "information"
  end

  add_index "nodes", ["node_type_id"], :name => "nodes_node_type_id_fk"
  add_index "nodes", ["place_id"], :name => "nodes_place_id_fk"

  create_table "notification_subscribers", :force => true do |t|
    t.integer "notification_id"
    t.integer "person_id"
    t.date    "created_at"
  end

  add_index "notification_subscribers", ["notification_id"], :name => "notification_subscribers_notification_id_fk"
  add_index "notification_subscribers", ["person_id"], :name => "notification_subscribers_person_id_fk"

  create_table "notifications", :force => true do |t|
    t.string  "name",         :limit => 100
    t.string  "description"
    t.string  "internal_tag", :limit => 100
    t.boolean "active",                      :default => false
  end

  create_table "notifications_pools", :force => true do |t|
    t.integer "notification_id"
    t.text    "extended_data"
    t.boolean "sent",            :default => false
    t.integer "place_id"
  end

  add_index "notifications_pools", ["notification_id"], :name => "notifications_pools_notification_id_fk"
  add_index "notifications_pools", ["place_id"], :name => "notifications_pools_place_id_fk"

  create_table "part_movement_types", :force => true do |t|
    t.string  "name",         :limit => 100
    t.string  "description"
    t.string  "internal_tag", :limit => 100
    t.boolean "direction",                   :default => false
  end

  create_table "part_movements", :force => true do |t|
    t.integer  "part_movement_type_id"
    t.integer  "part_type_id"
    t.integer  "amount"
    t.integer  "place_id"
    t.integer  "person_id"
    t.datetime "created_at"
  end

  add_index "part_movements", ["part_movement_type_id"], :name => "part_movements_part_movement_type_id_fk"
  add_index "part_movements", ["part_type_id"], :name => "part_movements_part_type_id_fk"
  add_index "part_movements", ["person_id"], :name => "part_movements_person_id_fk"
  add_index "part_movements", ["place_id"], :name => "part_movements_place_id_fk"

  create_table "part_types", :force => true do |t|
    t.string  "description"
    t.string  "internal_tag", :limit => 100
    t.integer "cost"
  end

  create_table "people", :force => true do |t|
    t.date    "created_at"
    t.string  "name",                   :limit => 100
    t.string  "lastname",               :limit => 100
    t.string  "id_document",            :limit => 100
    t.date    "birth_date"
    t.string  "phone",                  :limit => 100
    t.string  "cell_phone",             :limit => 100
    t.string  "email",                  :limit => 100
    t.string  "position",               :limit => 50
    t.string  "school_name",            :limit => 50
    t.integer "image_id"
    t.string  "barcode"
    t.date    "id_document_created_at"
    t.string  "notes"
  end

  add_index "people", ["image_id"], :name => "people_image_id_fk"

  create_table "performs", :force => true do |t|
    t.integer "person_id"
    t.integer "place_id"
    t.integer "profile_id"
  end

  add_index "performs", ["person_id"], :name => "performs_person_id_fk"
  add_index "performs", ["place_id"], :name => "performs_place_id_fk"
  add_index "performs", ["profile_id"], :name => "performs_profile_id_fk"

  create_table "permissions", :force => true do |t|
    t.string  "name",          :limit => 100
    t.integer "controller_id"
  end

  add_index "permissions", ["controller_id"], :name => "permissions_controller_id_fk"

  create_table "permissions_profiles", :id => false, :force => true do |t|
    t.integer "permission_id"
    t.integer "profile_id"
  end

  create_table "place_dependencies", :force => true do |t|
    t.integer "descendant_id"
    t.integer "ancestor_id"
  end

  add_index "place_dependencies", ["ancestor_id"], :name => "place_dependencies_ancestor_id_fk"
  add_index "place_dependencies", ["descendant_id"], :name => "place_dependencies_descendant_id_fk"

  create_table "place_types", :force => true do |t|
    t.string "name",         :limit => 100
    t.string "internal_tag", :limit => 100
  end

  create_table "places", :force => true do |t|
    t.date    "created_at"
    t.string  "name",            :limit => 100
    t.text    "description"
    t.integer "place_id"
    t.integer "place_type_id"
    t.text    "ancestors_ids"
    t.text    "descendants_ids"
  end

  add_index "places", ["place_id"], :name => "places_place_id_fk"
  add_index "places", ["place_type_id"], :name => "places_place_type_id_fk"

  create_table "problem_reports", :force => true do |t|
    t.integer  "problem_type_id"
    t.integer  "person_id"
    t.integer  "laptop_id"
    t.date     "created_at"
    t.boolean  "solved",          :default => false
    t.string   "comment"
    t.datetime "solved_at"
    t.integer  "place_id"
    t.integer  "owner_id"
  end

  add_index "problem_reports", ["owner_id"], :name => "problem_reports_owner_id_fk"
  add_index "problem_reports", ["place_id"], :name => "problem_reports_place_id_fk"

  create_table "problem_solutions", :force => true do |t|
    t.date    "created_at"
    t.integer "solved_by_person_id"
    t.string  "comment"
    t.integer "problem_report_id"
    t.integer "solution_type_id"
  end

  add_index "problem_solutions", ["problem_report_id"], :name => "problem_solutions_problem_report_id_fk"
  add_index "problem_solutions", ["solution_type_id"], :name => "problem_solutions_solution_type_id_fk"
  add_index "problem_solutions", ["solved_by_person_id"], :name => "problem_solutions_solved_by_person_id_fk"

  create_table "problem_types", :force => true do |t|
    t.string  "description"
    t.string  "internal_tag",  :limit => 100
    t.string  "name",          :limit => 100
    t.string  "extended_info"
    t.boolean "is_hardware",                  :default => false
  end

  create_table "profiles", :force => true do |t|
    t.string  "description"
    t.string  "internal_tag", :limit => 100
    t.integer "access_level",                :default => 0
  end

  create_table "school_infos", :force => true do |t|
    t.integer "place_id"
    t.integer "lease_duration"
    t.string  "server_hostname"
    t.string  "wan_ip_address"
    t.string  "wan_netmask"
    t.string  "wan_gateway"
    t.date    "lease_expiry"
  end

  add_index "school_infos", ["place_id"], :name => "school_infos_place_id_fk"

  create_table "section_details", :force => true do |t|
    t.integer "lot_id"
    t.integer "place_id"
  end

  add_index "section_details", ["lot_id"], :name => "section_details_lot_id_fk"
  add_index "section_details", ["place_id"], :name => "section_details_place_id_fk"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :limit => 100
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shipments", :force => true do |t|
    t.date   "created_at"
    t.date   "arrived_at"
    t.string "comment",         :limit => 100
    t.string "shipment_number"
  end

  create_table "software_versions", :force => true do |t|
    t.string   "vhash",       :limit => 64
    t.string   "name",        :limit => 100
    t.text     "description"
    t.integer  "model_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "software_versions", ["model_id"], :name => "software_versions_model_id_fk"

  create_table "solution_type_part_types", :force => true do |t|
    t.integer "solution_type_id", :null => false
    t.integer "part_type_id",     :null => false
  end

  add_index "solution_type_part_types", ["part_type_id"], :name => "solution_type_part_types_part_type_id_fk"
  add_index "solution_type_part_types", ["solution_type_id"], :name => "solution_type_part_types_solution_type_id_fk"

  create_table "solution_types", :force => true do |t|
    t.string "name",          :limit => 100
    t.string "description"
    t.string "extended_info"
    t.string "internal_tag",  :limit => 100
  end

  create_table "status_changes", :force => true do |t|
    t.integer "previous_state_id"
    t.integer "new_state_id"
    t.integer "laptop_id"
    t.integer "battery_id"
    t.integer "charger_id"
    t.date    "date_created_at"
    t.time    "time_created_at"
  end

  add_index "status_changes", ["battery_id"], :name => "status_changes_battery_id_fk"
  add_index "status_changes", ["charger_id"], :name => "status_changes_charger_id_fk"
  add_index "status_changes", ["laptop_id"], :name => "status_changes_laptop_id_fk"
  add_index "status_changes", ["new_state_id"], :name => "status_changes_new_state_id_fk"
  add_index "status_changes", ["previous_state_id"], :name => "status_changes_previous_state_id_fk"

  create_table "statuses", :force => true do |t|
    t.string "description"
    t.string "abbrev",       :limit => 10
    t.string "internal_tag", :limit => 100
  end

  create_table "users", :force => true do |t|
    t.string  "usuario",   :limit => 40
    t.string  "clave",     :limit => 40
    t.integer "person_id"
  end

  add_index "users", ["person_id"], :name => "users_person_id_fk"

  add_foreign_key "assignments", "laptops", :name => "assignments_laptop_id_fk"
  add_foreign_key "assignments", "people", :name => "assignments_destination_person_id_fk", :column => "destination_person_id"
  add_foreign_key "assignments", "people", :name => "assignments_source_person_id_fk", :column => "source_person_id"

  add_foreign_key "bank_deposits", "problem_solutions", :name => "bank_deposits_problem_solution_id_fk"

  add_foreign_key "events", "places", :name => "events_place_id_fk"

  add_foreign_key "laptop_details", "laptops", :name => "laptop_details_laptop_id_fk"
  add_foreign_key "laptop_details", "people", :name => "laptop_details_person_id_fk"
  add_foreign_key "laptop_details", "section_details", :name => "laptop_details_section_detail_id_fk"

  add_foreign_key "laptops", "models", :name => "laptops_model_id_fk"
  add_foreign_key "laptops", "people", :name => "laptops_owner_id_fk", :column => "owner_id"
  add_foreign_key "laptops", "statuses", :name => "laptops_status_id_fk"

  add_foreign_key "lots", "people", :name => "lots_person_id_fk"

  add_foreign_key "movements", "laptops", :name => "movements_laptop_id_fk"
  add_foreign_key "movements", "movement_types", :name => "movements_movement_type_id_fk"
  add_foreign_key "movements", "people", :name => "movements_destination_person_id_fk", :column => "destination_person_id"
  add_foreign_key "movements", "people", :name => "movements_responsible_person_id_fk", :column => "responsible_person_id"
  add_foreign_key "movements", "people", :name => "movements_source_person_id_fk", :column => "source_person_id"

  add_foreign_key "node_types", "images", :name => "node_types_image_id_fk"

  add_foreign_key "nodes", "node_types", :name => "nodes_node_type_id_fk"
  add_foreign_key "nodes", "places", :name => "nodes_place_id_fk"

  add_foreign_key "notification_subscribers", "notifications", :name => "notification_subscribers_notification_id_fk"
  add_foreign_key "notification_subscribers", "people", :name => "notification_subscribers_person_id_fk"

  add_foreign_key "notifications_pools", "notifications", :name => "notifications_pools_notification_id_fk"
  add_foreign_key "notifications_pools", "places", :name => "notifications_pools_place_id_fk"

  add_foreign_key "part_movements", "part_movement_types", :name => "part_movements_part_movement_type_id_fk"
  add_foreign_key "part_movements", "part_types", :name => "part_movements_part_type_id_fk"
  add_foreign_key "part_movements", "people", :name => "part_movements_person_id_fk"
  add_foreign_key "part_movements", "places", :name => "part_movements_place_id_fk"

  add_foreign_key "people", "images", :name => "people_image_id_fk"

  add_foreign_key "performs", "people", :name => "performs_person_id_fk"
  add_foreign_key "performs", "places", :name => "performs_place_id_fk"
  add_foreign_key "performs", "profiles", :name => "performs_profile_id_fk"

  add_foreign_key "permissions", "controllers", :name => "permissions_controller_id_fk"

  add_foreign_key "place_dependencies", "places", :name => "place_dependencies_ancestor_id_fk", :column => "ancestor_id"
  add_foreign_key "place_dependencies", "places", :name => "place_dependencies_descendant_id_fk", :column => "descendant_id"

  add_foreign_key "places", "place_types", :name => "places_place_type_id_fk"
  add_foreign_key "places", "places", :name => "places_place_id_fk"

  add_foreign_key "problem_reports", "people", :name => "problem_reports_owner_id_fk", :column => "owner_id"
  add_foreign_key "problem_reports", "places", :name => "problem_reports_place_id_fk"

  add_foreign_key "problem_solutions", "people", :name => "problem_solutions_solved_by_person_id_fk", :column => "solved_by_person_id"
  add_foreign_key "problem_solutions", "problem_reports", :name => "problem_solutions_problem_report_id_fk"
  add_foreign_key "problem_solutions", "solution_types", :name => "problem_solutions_solution_type_id_fk"

  add_foreign_key "school_infos", "places", :name => "school_infos_place_id_fk"

  add_foreign_key "section_details", "lots", :name => "section_details_lot_id_fk"
  add_foreign_key "section_details", "places", :name => "section_details_place_id_fk"

  add_foreign_key "software_versions", "models", :name => "software_versions_model_id_fk"

  add_foreign_key "solution_type_part_types", "part_types", :name => "solution_type_part_types_part_type_id_fk"
  add_foreign_key "solution_type_part_types", "solution_types", :name => "solution_type_part_types_solution_type_id_fk"

  add_foreign_key "status_changes", "laptops", :name => "status_changes_laptop_id_fk"
  add_foreign_key "status_changes", "statuses", :name => "status_changes_new_state_id_fk", :column => "new_state_id"
  add_foreign_key "status_changes", "statuses", :name => "status_changes_previous_state_id_fk", :column => "previous_state_id"

  add_foreign_key "users", "people", :name => "users_person_id_fk"

end
