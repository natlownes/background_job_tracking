require 'delayed_job_active_record'

class Delayed::Backend::ActiveRecord::Job
  has_many :delayed_job_trackings, :dependent => :destroy, :foreign_key => :delayed_job_id
end

