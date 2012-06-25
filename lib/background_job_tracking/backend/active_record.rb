require 'delayed_job_active_record'

class Delayed::Backend::ActiveRecord::Job
  has_one :delayed_job_tracking, :dependent => :destroy, :foreign_key => :delayed_job_id
end

