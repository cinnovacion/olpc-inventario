# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091001211021) do

  create_table "activations", :force => true do |t|
    t.date    "created_at"
    t.date    "date_activated_at"
    t.time    "time_activated_at"
    t.string  "comment"
    t.integer "laptop_id"
    t.integer "person_activated_id"
  end

  add_index "activations", ["laptop_id"], :name => "activations_laptop_id_fk"
  add_index "activations", ["person_activated_id"], :name => "activations_person_activated_id_fk"

  create_table "answers", :force => true do |t|
    t.integer "quiz_id"
    t.integer "person_id"
    t.date    "created_at"
    t.date    "answered_at"
  end

  add_index "answers", ["person_id"], :name => "answers_person_id_fk"
  add_index "answers", ["quiz_id"], :name => "answers_quiz_id_fk"

  create_table "bank_deposits", :force => true do |t|
    t.integer "problem_solution_id"
    t.string  "deposit",             :limit => 100
    t.float   "amount",                             :default => 0.0
    t.date    "created_at"
    t.date    "deposited_at"
    t.string  "bank",                :limit => 100
  end

  add_index "bank_deposits", ["problem_solution_id"], :name => "bank_deposits_problem_solution_id_fk"

  create_table "batteries", :force => true do |t|
    t.string  "serial_number",       :limit => 100
    t.date    "created_at"
    t.integer "owner_id"
    t.integer "shipment_arrival_id"
    t.string  "box_serial_number",   :limit => 100
    t.integer "box_id"
    t.integer "status_id"
  end

  add_index "batteries", ["box_id"], :name => "batteries_box_id_fk"
  add_index "batteries", ["owner_id"], :name => "batteries_owner_id_fk"
  add_index "batteries", ["shipment_arrival_id"], :name => "batteries_shipment_arrival_id_fk"
  add_index "batteries", ["status_id"], :name => "batteries_status_id_fk"

  create_table "box_movement_details", :force => true do |t|
    t.integer "box_movement_id"
    t.integer "box_id"
  end

  add_index "box_movement_details", ["box_id"], :name => "box_movement_details_box_id_fk"
  add_index "box_movement_details", ["box_movement_id"], :name => "box_movement_details_box_movement_id_fk"

  create_table "box_movements", :force => true do |t|
    t.date    "created_at"
    t.date    "date_moved_at"
    t.time    "time_moved_at"
    t.integer "src_place_id"
    t.integer "src_person_id"
    t.integer "dst_place_id"
    t.integer "dst_person_id"
    t.integer "authorized_person_id"
  end

  add_index "box_movements", ["authorized_person_id"], :name => "box_movements_authorized_person_id_fk"
  add_index "box_movements", ["dst_person_id"], :name => "box_movements_dst_person_id_fk"
  add_index "box_movements", ["dst_place_id"], :name => "box_movements_dst_place_id_fk"
  add_index "box_movements", ["src_person_id"], :name => "box_movements_src_person_id_fk"
  add_index "box_movements", ["src_place_id"], :name => "box_movements_src_place_id_fk"

  create_table "boxes", :force => true do |t|
    t.integer "shipment_id"
    t.integer "place_id"
    t.string  "serial_number", :limit => 100
  end

  add_index "boxes", ["place_id"], :name => "boxes_place_id_fk"
  add_index "boxes", ["shipment_id"], :name => "boxes_shipment_id_fk"

  create_table "chargers", :force => true do |t|
    t.string  "serial_number",       :limit => 100
    t.date    "created_at"
    t.integer "owner_id"
    t.integer "shipment_arrival_id"
    t.string  "box_serial_number",   :limit => 100
    t.integer "box_id"
    t.integer "status_id"
  end

  add_index "chargers", ["box_id"], :name => "chargers_box_id_fk"
  add_index "chargers", ["owner_id"], :name => "chargers_owner_id_fk"
  add_index "chargers", ["shipment_arrival_id"], :name => "chargers_shipment_arrival_id_fk"
  add_index "chargers", ["status_id"], :name => "chargers_status_id_fk"

  create_table "choices", :force => true do |t|
    t.integer "answer_id"
    t.integer "question_id"
    t.integer "option_id"
    t.string  "comment"
  end

  add_index "choices", ["answer_id"], :name => "choices_answer_id_fk"
  add_index "choices", ["option_id"], :name => "choices_option_id_fk"
  add_index "choices", ["question_id"], :name => "choices_question_id_fk"

  create_table "controllers", :force => true do |t|
    t.string "name", :limit => 100
  end

  create_table "copia", :force => true do |t|
    t.string  "serial_number",       :limit => 100
    t.date    "created_at"
    t.string  "build_version",       :limit => 100
    t.integer "model_id"
    t.integer "shipment_arrival_id"
    t.integer "activation_id"
    t.integer "owner_id"
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

  create_table "laptop_configs", :force => true do |t|
    t.string "key",           :limit => 100
    t.string "value",         :limit => 100
    t.string "description",   :limit => 100
    t.string "resource_name", :limit => 100
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
    t.string  "build_version",        :limit => 100
    t.integer "model_id"
    t.integer "shipment_arrival_id"
    t.integer "owner_id"
    t.string  "box_serial_number",    :limit => 100
    t.integer "box_id"
    t.integer "status_id"
    t.string  "uuid"
    t.boolean "registered",                          :default => false
    t.date    "last_activation_date"
  end

  add_index "laptops", ["box_id"], :name => "laptops_box_id_fk"
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

  create_table "movement_details", :force => true do |t|
    t.integer "movement_id"
    t.integer "laptop_id"
    t.integer "battery_id"
    t.integer "charger_id"
    t.string  "description",   :limit => 100
    t.string  "serial_number", :limit => 100
    t.boolean "returned",                     :default => false
  end

  add_index "movement_details", ["battery_id"], :name => "movement_details_battery_id_fk"
  add_index "movement_details", ["charger_id"], :name => "movement_details_charger_id_fk"
  add_index "movement_details", ["laptop_id"], :name => "movement_details_laptop_id_fk"
  add_index "movement_details", ["movement_id"], :name => "movement_details_movement_id_fk"

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
  end

  add_index "movements", ["destination_person_id"], :name => "movements_destination_person_id_fk"
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

  create_table "options", :force => true do |t|
    t.string  "option"
    t.boolean "correct",     :default => false
    t.integer "question_id"
  end

  add_index "options", ["question_id"], :name => "options_question_id_fk"

  create_table "part_types", :force => true do |t|
    t.string  "description"
    t.string  "internal_tag", :limit => 100
    t.integer "cost"
  end

  create_table "parts", :force => true do |t|
    t.integer "status_id"
    t.integer "owner_id"
    t.integer "part_type_id"
    t.integer "laptop_id"
    t.integer "battery_id"
    t.integer "charger_id"
    t.string  "on_device_serial", :limit => 100
  end

  add_index "parts", ["battery_id"], :name => "parts_battery_id_fk"
  add_index "parts", ["charger_id"], :name => "parts_charger_id_fk"
  add_index "parts", ["laptop_id"], :name => "parts_laptop_id_fk"
  add_index "parts", ["owner_id"], :name => "parts_owner_id_fk"
  add_index "parts", ["part_type_id"], :name => "parts_part_type_id_fk"
  add_index "parts", ["status_id"], :name => "parts_status_id_fk"

  create_table "people", :force => true do |t|
    t.date    "created_at"
    t.string  "name",                   :limit => 100
    t.string  "lastname",               :limit => 100
    t.string  "id_document",            :limit => 100
    t.date    "birth_date"
    t.string  "phone",                  :limit => 100
    t.string  "cell_phone",             :limit => 100
    t.string  "email",                  :limit => 100
    t.integer "place_id"
    t.string  "position",               :limit => 50
    t.string  "school_name",            :limit => 50
    t.integer "image_id"
    t.string  "barcode"
    t.date    "id_document_created_at"
  end

  add_index "people", ["image_id"], :name => "people_image_id_fk"
  add_index "people", ["place_id"], :name => "people_place_id_fk"

  create_table "people_profiles", :id => false, :force => true do |t|
    t.integer "person_id"
    t.integer "profile_id"
  end

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
    t.integer "src_part_id"
    t.integer "dst_part_id"
    t.string  "comment"
    t.integer "problem_report_id"
    t.integer "solution_type_id"
  end

  add_index "problem_solutions", ["dst_part_id"], :name => "problem_solutions_dst_part_id_fk"
  add_index "problem_solutions", ["solution_type_id"], :name => "problem_solutions_solution_type_id_fk"
  add_index "problem_solutions", ["solved_by_person_id"], :name => "problem_solutions_solved_by_person_id_fk"
  add_index "problem_solutions", ["src_part_id"], :name => "problem_solutions_src_part_id_fk"

  create_table "problem_types", :force => true do |t|
    t.string "description"
    t.string "internal_tag",  :limit => 100
    t.string "name",          :limit => 100
    t.string "extended_info"
  end

  create_table "profiles", :force => true do |t|
    t.string  "description"
    t.string  "internal_tag", :limit => 100
    t.integer "access_level",                :default => 0
  end

  create_table "questions", :force => true do |t|
    t.string  "question"
    t.integer "quiz_id"
  end

  add_index "questions", ["quiz_id"], :name => "questions_quiz_id_fk"

  create_table "quizzes", :force => true do |t|
    t.string  "title"
    t.date    "created_at"
    t.integer "person_id"
  end

  add_index "quizzes", ["person_id"], :name => "quizzes_person_id_fk"

  create_table "relationships", :force => true do |t|
    t.integer "person_id"
    t.integer "to_person_id"
    t.integer "profile_id"
  end

  add_index "relationships", ["person_id"], :name => "relationships_person_id_fk"
  add_index "relationships", ["profile_id"], :name => "relationships_profile_id_fk"
  add_index "relationships", ["to_person_id"], :name => "relationships_to_person_id_fk"

  create_table "school_infos", :force => true do |t|
    t.integer "place_id"
    t.integer "lease_duration"
    t.string  "server_hostname"
    t.string  "wan_ip_address"
    t.string  "wan_netmask"
    t.string  "wan_gateway"
  end

  add_index "school_infos", ["place_id"], :name => "school_infos_place_id_fk"

  create_table "section_details", :force => true do |t|
    t.integer "lot_id"
    t.integer "place_id"
  end

  add_index "section_details", ["lot_id"], :name => "section_details_lot_id_fk"
  add_index "section_details", ["place_id"], :name => "section_details_place_id_fk"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
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

  create_table "solution_types", :force => true do |t|
    t.string  "name",          :limit => 100
    t.string  "description"
    t.string  "extended_info"
    t.string  "internal_tag",  :limit => 100
    t.integer "part_type_id"
  end

  add_index "solution_types", ["part_type_id"], :name => "solution_types_part_type_id_fk"

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

  create_table "teaches", :force => true do |t|
    t.integer "person_id"
    t.integer "place_id"
  end

  create_table "users", :force => true do |t|
    t.string  "usuario",   :limit => 40
    t.string  "clave",     :limit => 40
    t.integer "person_id"
  end

  add_index "users", ["person_id"], :name => "users_person_id_fk"

  # This would normally be created by ActiveRecord, in
  # initialize_schema_migrations_table
  # However, AR creates the version field with a 255 character limit, which
  # we can't use as an index when running as utf8mb4. Create it with a shorter
  # length.
  create_table "schema_migrations", :force => true do |t|
    t.string :version, :null => false, :limit => 100
  end

  add_index "schema_migrations", :version, :unique => true, :name => "unique_schema_migrations"

end
