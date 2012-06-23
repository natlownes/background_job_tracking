# example schema - also used by nulldb for tests
ActiveRecord::Schema.define(:version => 1) do
  create_table "background_job_test" do |t|
  end

  create_table "delayed_job_trackings", :force => true do |t|
    t.integer  "delayed_job_id"
    t.integer  "job_owner_id"
    t.string   "job_owner_type"
    t.string   "created_by_method_name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",                         :default => 0
    t.integer  "attempts",                         :default => 0
    t.text     "handler",    :limit => 2147483647
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"
end


