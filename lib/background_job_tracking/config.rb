module BackgroundJobTracking
  class Config
    # wrapper for options passed to
    # background_job_tracking class method
    attr_accessor :options
    def initialize(opts={})
      check_for_required_arguments(opts)
      @options = opts
    end
    
    def job_creation_method_name
      self.class.job_creation_method_name_for_method(self.options[:method_name])
    end

    def job_rescheduling_method_name
      self.class.job_rescheduling_method_name_for_method(self.options[:method_name])
    end

    def method_name_to_run
      # the method the user will implement
      self.options[:method_name].to_sym
    end

    def callback_to_use
      # which activerecord::callback to use
      self.options[:on]
    end

    def self.job_creation_method_name_for_method(name)
      name = generated_callback_method_name_prefix + name.to_s
      name.to_sym
    end

    def self.job_rescheduling_method_name_for_method(name)
      name = generated_rescheduling_callback_method_name_prefix + name.to_s
      name.to_sym
    end

    private

    def check_for_required_arguments(opts)
      raise ArgumentError("option :on required for background_job_tracking") unless opts[:on]
      raise ArgumentError("option :method_name required for background_job_tracking") unless opts[:method_name]
      warn "not going to update jobs on changes for #{opts[:method_name]}" unless opts[:update_if]
    end

    def self.generated_callback_method_name_prefix
      "background_job_creation_tracking_callback_for_"
    end

    def self.generated_rescheduling_callback_method_name_prefix
      # this method should destroy all jobs
      # and re-run the generated callback method 
      # to re-track the jobs
      #
      # won't be run unless update_if exists
      "reschedule_background_job_for_"
    end
  end
end
