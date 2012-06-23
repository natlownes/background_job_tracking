require 'active_record'

class DelayedJobTracking < ActiveRecord::Base
  belongs_to :delayed_job, :class_name => "::Delayed::Job"
  belongs_to :job_owner, :polymorphic => true
end

