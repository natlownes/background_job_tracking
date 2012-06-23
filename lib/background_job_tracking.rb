require "background_job_tracking/config"
require 'background_job_tracking/delayed_job_tracking'
require 'background_job_tracking/backend/active_record'

require 'active_support/concern'
require 'active_record/callbacks'

module BackgroundJobTracking
  module Trackable
    extend  ActiveSupport::Concern

    module ClassMethods
      def background_job_tracking(opts={})
        opts[:if] ||= Proc.new {|db_object| true }
        config = BackgroundJobTracking::Config.new(opts)
        #
        #
        #
        #background_job_tracking :on => :after_create,
          #:method_name => :schedule_first_rating_email_and_reminder,
          #:if  => Proc.new {|e| e.initiative.rating_has_begun },
          ## destroys all jobs by associated method name and reschedules
          #:update_if => Proc.new {|o| o.start_date_changed? }
        #
        #
        #
        create_callback_method_for_job_create(config)
        add_callback_method_for_job_create_to_callbacks(config)
        if config.options[:update_if]
          create_callback_method_for_destroy_and_reschedule_on_update(config)
          add_callback_method_for_job_destroy_and_reschedule_on_update(config)
        end
      end

      def has_background_job_tracking(opts={})
        opts[:class_name] ||= "::Delayed::Job"
        opts[:dependent]  ||= :destroy
        @background_job_class = opts[:class_name].constantize

        has_many :delayed_job_trackings, :as => :job_owner
        has_many :delayed_jobs, :through => :delayed_job_trackings, :class_name => opts[:class_name], :dependent => opts[:dependent]
      end

      def background_job_class
        @background_job_class
      end
      
      private

      def create_callback_method_for_job_create(config)
        class_eval %{
          def #{config.job_creation_method_name.to_s}
            user_defined_method_name  = :#{config.method_name_to_run.to_s}
            job                       = send(:#{config.method_name_to_run.to_s})

            if job.class == self.class.background_job_class
              create_delayed_job_tracking_for_method_name_and_job(user_defined_method_name, job)
            end
          end
        }
      end

      def add_callback_method_for_job_create_to_callbacks(config)
        self.send(config.callback_to_use, config.job_creation_method_name, :if => config.options[:if]) 
      end

      def create_callback_method_for_destroy_and_reschedule_on_update(config)
        class_eval %{
          def #{config.job_rescheduling_method_name.to_s}
            destroy_jobs_created_by_method_name(:'#{config.method_name_to_run}')
            destroy_delayed_job_trackings_created_by_method_name(:'#{config.method_name_to_run}')

            # reschedule
            send(:#{config.job_creation_method_name.to_s})
          end
        }
      end

      def add_callback_method_for_job_destroy_and_reschedule_on_update(config)
        after_update(config.job_rescheduling_method_name, :if => config.options[:update_if])
      end
    end #class methods

    included do
      include ActiveRecord::Callbacks
    end

    private

    def create_delayed_job_tracking_for_method_name_and_job(method_name, job)
      self.delayed_job_trackings.create(:created_by_method_name => method_name.to_s, :delayed_job => job)
    end

    def destroy_jobs_created_by_method_name(method_name)
      jobs = get_jobs_created_by_method_name(method_name)
      self.class.background_job_class.destroy(jobs) unless jobs.empty?
    end

    def get_delayed_job_trackings_created_by_method_name(method_name)
      self.delayed_job_trackings.includes(:delayed_job).where(:'delayed_job_trackings.created_by_method_name' => method_name)
    end

    def destroy_delayed_job_trackings_created_by_method_name(method_name)
      trackings = get_delayed_job_trackings_created_by_method_name(method_name)
      DelayedJobTracking.destroy(trackings) unless trackings.empty?
    end

    def get_jobs_created_by_method_name(method_name)
      get_delayed_job_trackings_created_by_method_name(method_name).map(&:delayed_job).compact
    end
  end
end
