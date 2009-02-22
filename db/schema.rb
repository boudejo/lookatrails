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

ActiveRecord::Schema.define(:version => 20090202101123) do

  create_table "accountcontactcards", :force => true do |t|
    t.string   "first_name",              :limit => 100, :default => ""
    t.string   "last_name",               :limit => 100, :default => ""
    t.integer  "accountcontactable_id"
    t.string   "accountcontactable_type"
    t.string   "address_line1",                          :default => ""
    t.string   "address_line2",                          :default => ""
    t.string   "address_nr",              :limit => 10,  :default => ""
    t.string   "address_bus",             :limit => 5,   :default => ""
    t.string   "address_postal",          :limit => 20,  :default => ""
    t.string   "address_place",                          :default => ""
    t.string   "address_country",         :limit => 100, :default => ""
    t.string   "email"
    t.string   "phone"
    t.string   "fax"
    t.string   "website"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  create_table "accounts", :force => true do |t|
    t.string   "vat_number",          :limit => 50, :default => ""
    t.string   "kvk_number",          :limit => 8,  :default => ""
    t.string   "bankaccount_number",  :limit => 50, :default => ""
    t.string   "iban_number",         :limit => 34, :default => ""
    t.string   "bic_number",          :limit => 11, :default => ""
    t.integer  "legaltype",           :limit => 2,  :default => 0,  :null => false
    t.text     "notes"
    t.integer  "contacts_count",                    :default => 0
    t.integer  "opportunities_count",               :default => 0
    t.integer  "projects_count",                    :default => 0
    t.integer  "documents_count",                   :default => 0
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  create_table "addresses", :force => true do |t|
    t.string   "label",            :limit => 50,  :default => "Home"
    t.boolean  "main",                            :default => false
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.string   "address_line1",                   :default => ""
    t.string   "address_line2",                   :default => ""
    t.string   "address_nr",       :limit => 10,  :default => ""
    t.string   "address_bus",      :limit => 5,   :default => ""
    t.string   "address_postal",   :limit => 20,  :default => ""
    t.string   "address_place",                   :default => ""
    t.string   "address_country",  :limit => 100, :default => ""
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  add_index "addresses", ["id", "addressable_id", "addressable_type"], :name => "index_addresses_on_id_and_addressable_id_and_addressable_type"

  create_table "calendar_entries", :force => true do |t|
    t.integer  "calendar_id"
    t.text     "summary"
    t.datetime "date",                                                  :null => false
    t.string   "status",      :limit => 100, :default => "unspecified", :null => false
    t.string   "kind",        :limit => 100, :default => "workday"
    t.text     "description"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  add_index "calendar_entries", ["id", "calendar_id"], :name => "index_calendar_entries_on_id_and_calendar_id"

  create_table "calendars", :force => true do |t|
    t.integer  "year",                    :default => 2009
    t.text     "description"
    t.integer  "calendar_entries_count",  :default => 0
    t.integer  "workday_count",           :default => 0
    t.integer  "general_leave_count",     :default => 0
    t.integer  "holiday_count",           :default => 0
    t.integer  "postponed_holiday_count", :default => 0
    t.integer  "event_special_day_count", :default => 0
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  add_index "calendars", ["id", "year"], :name => "index_calendars_on_id_and_year"

  create_table "cars", :force => true do |t|
    t.string   "license_plate",    :limit => 50
    t.integer  "employee_id"
    t.string   "employee_code",                                                 :default => ""
    t.string   "status",           :limit => 100,                               :default => "unassigned",          :null => false
    t.string   "prev_status",      :limit => 100,                               :default => "",                    :null => false
    t.datetime "status_change_at",                                              :default => '2009-02-22 18:38:07', :null => false
    t.string   "brand",            :limit => 100
    t.decimal  "budget",                          :precision => 6, :scale => 2
    t.date     "in_service_date"
    t.text     "notes"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  add_index "cars", ["license_plate"], :name => "index_cars_on_license_plate", :unique => true
  add_index "cars", ["id", "employee_id"], :name => "index_cars_on_id_and_employee_id"

  create_table "communications", :force => true do |t|
    t.string   "kind",                :limit => 100, :default => ""
    t.string   "label",               :limit => 50,  :default => ""
    t.string   "value",               :limit => 100, :default => ""
    t.string   "desc",                :limit => 100, :default => ""
    t.integer  "rank",                :limit => 3
    t.boolean  "deleteable",                         :default => false
    t.boolean  "editable",                           :default => true
    t.integer  "communicatable_id"
    t.string   "communicatable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contactcards", :force => true do |t|
    t.string   "first_name",       :limit => 100, :default => ""
    t.string   "last_name",        :limit => 100, :default => ""
    t.integer  "contactable_id"
    t.string   "contactable_type"
    t.string   "address_line1",                   :default => ""
    t.string   "address_line2",                   :default => ""
    t.string   "address_nr",       :limit => 10,  :default => ""
    t.string   "address_bus",      :limit => 5,   :default => ""
    t.string   "address_postal",   :limit => 20,  :default => ""
    t.string   "address_place",                   :default => ""
    t.string   "address_country",  :limit => 100, :default => ""
    t.string   "email"
    t.string   "phone"
    t.string   "fax"
    t.string   "website"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  add_index "contactcards", ["id", "contactable_id", "contactable_type"], :name => "index_contactcards_on_id_and_contactable_id_and_contactable_type"

  create_table "contacts", :force => true do |t|
    t.string   "function",            :limit => 100, :default => ""
    t.string   "department",          :limit => 100, :default => ""
    t.text     "notes"
    t.integer  "opportunities_count",                :default => 0
    t.integer  "projects_count",                     :default => 0
    t.integer  "documents_count",                    :default => 0
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  create_table "documents", :force => true do |t|
    t.integer  "documentable_id"
    t.string   "documentable_type"
    t.string   "document_file_name",    :default => ""
    t.string   "document_content_type", :default => ""
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.text     "notes"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  add_index "documents", ["id", "documentable_id", "documentable_type"], :name => "index_documents_on_id_and_documentable_id_and_documentable_type"

  create_table "employees", :force => true do |t|
    t.integer  "identity_id"
    t.string   "code",                 :limit => 3,   :default => ""
    t.string   "fullcode",             :limit => 9,   :default => ""
    t.string   "function",             :limit => 100, :default => "consultant"
    t.string   "joblevel",             :limit => 100, :default => "unspecified",         :null => false
    t.date     "date_in_service"
    t.date     "date_out_service"
    t.date     "date_oresys"
    t.string   "workshedule",          :limit => 100, :default => "fulltime",            :null => false
    t.string   "bank_account_number",  :limit => 100
    t.string   "status",               :limit => 100, :default => "not_active",          :null => false
    t.string   "prev_status",          :limit => 100, :default => "not_active",          :null => false
    t.datetime "status_change_at",                    :default => '2009-02-22 18:38:07', :null => false
    t.text     "status_notes"
    t.text     "notes"
    t.integer  "addresses_count",                     :default => 0
    t.integer  "communications_count",                :default => 0
    t.integer  "documents_count",                     :default => 0
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  add_index "employees", ["id", "code"], :name => "index_employees_on_id_and_code"
  add_index "employees", ["id", "status"], :name => "index_employees_on_id_and_status"
  add_index "employees", ["id", "code", "status"], :name => "index_employees_on_id_and_code_and_status"

  create_table "opportunities", :force => true do |t|
    t.string   "name",                                                           :default => ""
    t.integer  "account_id"
    t.integer  "bdm_id"
    t.integer  "contact_id"
    t.integer  "project_id"
    t.string   "status",           :limit => 100,                                :default => "pending",             :null => false
    t.string   "prev_status",      :limit => 100,                                :default => "",                    :null => false
    t.datetime "status_change_at",                                               :default => '2009-02-22 18:38:07', :null => false
    t.date     "start_date"
    t.date     "end_date"
    t.decimal  "daily_price",                     :precision => 10, :scale => 2, :default => 0.0
    t.string   "probability",                                                    :default => "25%",                 :null => false
    t.string   "costcenter",                                                     :default => "unspecified",         :null => false
    t.string   "billingmethod",    :limit => 100,                                :default => "unspecified",         :null => false
    t.decimal  "budget",                          :precision => 12, :scale => 2, :default => 0.0
    t.string   "option",           :limit => 100,                                :default => "option_1",            :null => false
    t.decimal  "perc_work",                       :precision => 5,  :scale => 2, :default => 100.0
    t.integer  "fte",                                                            :default => 1
    t.integer  "max_days",                                                       :default => 1
    t.text     "notes"
    t.integer  "documents_count",                                                :default => 0
    t.integer  "resources_count",                                                :default => 0
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  add_index "opportunities", ["id", "account_id"], :name => "index_opportunities_on_id_and_account_id"
  add_index "opportunities", ["id", "contact_id"], :name => "index_opportunities_on_id_and_contact_id"
  add_index "opportunities", ["id", "bdm_id"], :name => "index_opportunities_on_id_and_bdm_id"
  add_index "opportunities", ["id", "account_id", "contact_id"], :name => "index_opportunities_on_id_and_account_id_and_contact_id"
  add_index "opportunities", ["id", "account_id", "bdm_id"], :name => "index_opportunities_on_id_and_account_id_and_bdm_id"

  create_table "people", :force => true do |t|
    t.string   "first_name",            :limit => 100, :default => ""
    t.string   "last_name",             :limit => 100, :default => ""
    t.integer  "identity_id"
    t.string   "identity_type"
    t.string   "national_number",       :limit => 13,  :default => ""
    t.date     "date_of_birth"
    t.string   "place_of_birth",                       :default => ""
    t.string   "marital_status",        :limit => 100, :default => "unspecified", :null => false
    t.string   "partner",                              :default => "unkown"
    t.date     "date_of_birth_partner"
    t.integer  "children_accounted",    :limit => 2
    t.text     "notes"
    t.integer  "addresses_count",                      :default => 0
    t.integer  "communications_count",                 :default => 0
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  add_index "people", ["id", "identity_id", "identity_type"], :name => "index_people_on_id_and_identity_id_and_identity_type"

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "first_name", :limit => 100, :default => ""
    t.string   "last_name",  :limit => 100, :default => ""
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  add_index "profiles", ["id", "user_id"], :name => "index_profiles_on_id_and_user_id", :unique => true
  add_index "profiles", ["id", "deleted_at"], :name => "index_profiles_on_id_and_deleted_at"

  create_table "projects", :force => true do |t|
    t.string   "name",            :default => ""
    t.integer  "account_id"
    t.integer  "documents_count", :default => 0
    t.integer  "resources_count", :default => 0
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  add_index "projects", ["id", "account_id"], :name => "index_projects_on_id_and_account_id"

  create_table "recruitments", :force => true do |t|
    t.integer  "employee_id"
    t.string   "joblevel",         :limit => 100, :default => "unspecified",         :null => false
    t.string   "status",           :limit => 100, :default => "first_stage",         :null => false
    t.string   "prev_status",      :limit => 100, :default => "",                    :null => false
    t.datetime "status_change_at",                :default => '2009-02-22 18:38:07', :null => false
    t.string   "rejected_by",      :limit => 100, :default => "unspecified",         :null => false
    t.text     "notes"
    t.integer  "documents_count",                 :default => 0
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  add_index "recruitments", ["id", "status"], :name => "index_recruitments_on_id_and_status"

  create_table "resources", :force => true do |t|
    t.integer  "project_id"
    t.integer  "opportunity_id"
    t.integer  "employee_id"
    t.decimal  "day_price",                       :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "hour_price",                      :precision => 8, :scale => 2, :default => 0.0
    t.string   "status",           :limit => 100,                               :default => "shortlisted",         :null => false
    t.string   "prev_status",      :limit => 100,                               :default => "",                    :null => false
    t.datetime "status_change_at",                                              :default => '2009-02-22 18:38:07', :null => false
    t.text     "notes"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  add_index "resources", ["id", "project_id", "employee_id"], :name => "index_resources_on_id_and_project_id_and_employee_id"
  add_index "resources", ["id", "project_id"], :name => "index_resources_on_id_and_project_id"
  add_index "resources", ["id", "opportunity_id", "employee_id"], :name => "index_resources_on_id_and_opportunity_id_and_employee_id"
  add_index "resources", ["id", "opportunity_id"], :name => "index_resources_on_id_and_opportunity_id"

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id", "user_id"], :name => "index_roles_users_on_role_id_and_user_id"

  create_table "salaries", :force => true do |t|
    t.integer  "employee_id"
    t.decimal  "gross_salary",         :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "rep_allowance",        :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "group_insurance_perc", :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "car_budget",           :precision => 6,  :scale => 2, :default => 0.0
    t.decimal  "dkv",                  :precision => 6,  :scale => 2, :default => 0.0
    t.decimal  "grand_total",          :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "daily_cost",           :precision => 8,  :scale => 2, :default => 0.0
    t.boolean  "current",                                             :default => false
    t.text     "notes"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  add_index "salaries", ["id", "employee_id"], :name => "index_salaries_on_id_and_employee_id"

  create_table "timesheet_entries", :force => true do |t|
    t.integer  "timesheet_id"
    t.text     "summary"
    t.datetime "start",                                                  :null => false
    t.datetime "end"
    t.string   "status",       :limit => 100, :default => "unspecified", :null => false
    t.string   "kind",         :limit => 100, :default => "unspecified"
    t.text     "description"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  add_index "timesheet_entries", ["id", "timesheet_id"], :name => "index_timesheet_entries_on_id_and_timesheet_id"

  create_table "timesheets", :force => true do |t|
    t.integer  "employee_id"
    t.integer  "year",                    :default => 2009
    t.integer  "default_leave_days",      :default => 0
    t.integer  "extra_leave_days",        :default => 0
    t.text     "description"
    t.integer  "timesheet_entries_count", :default => 0
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
  end

  add_index "timesheets", ["id", "employee_id"], :name => "index_timesheets_on_id_and_employee_id"
  add_index "timesheets", ["id", "employee_id", "year"], :name => "index_timesheets_on_id_and_employee_id_and_year"

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                    :default => "passive"
    t.integer  "loginable_id"
    t.string   "loginable_type"
    t.datetime "deleted_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
    t.string   "password_reset_code"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["id", "deleted_at"], :name => "index_users_on_id_and_deleted_at"
  add_index "users", ["loginable_id", "loginable_type"], :name => "index_users_on_loginable_id_and_loginable_type"

end
