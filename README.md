# BackgroundJobTracking

ActiveRecord extension to allow tracking and rescheduling of Delayed Job jobs on object creation / update.

Sometimes you'll schedule background jobs to run at a certain time based on a value in one of your models, and if that value changes, you'll want to reschedule those jobs.  This plugin provides a common interface for that.

Assumes that you're using Delayed Job and ActiveRecord.

## Installation

Add this line to your application's Gemfile:

    gem 'background_job_tracking'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install background_job_tracking

You'll also need your database to have a `delayed_job_trackings` table, the details of which are in the included `db/schema.rb`.

## Usage

The use case for this is if you schedule background jobs at a certain time
based on the value of a property on an object - like if you have a buncha emails that will
go out at a date in the future, which stored as a property on your object.

If that property is updated, the emails you've scheduled to go out in the background
are no longer valid; you'll want them to go out on the updated date of the object.

### Assumptions

* You'll want associated jobs to be destroyed when you destroy an object.
* You'll want delayed_job_trackings to be destroyed when a Delayed::Job is destroyed - a dependent: :destroy is added to `Delayed::Backend::ActiveRecord::Job`.
* If you want a background job to be tracked, the method you implement (see `:schedule_long_running_thing` in the example below) must return an instance of `Delayed::Backend::ActiveRecord::Job`

**Example:**

    class ::BackgroundJobTest < ActiveRecord::Base
      include ::BackgroundJobTracking::Trackable
      
      # this sets up the associations
      has_background_job_tracking

      background_job_tracking :on => :after_create,
        :method_name => :schedule_long_running_thing,
        :update_if   => Proc.new {|bjt| bjt.needs_updated? }
      #
      # this says:
      # after create, run the :schedule_long_running_thing
      # method 
      # 
      # on after_update, in the event that the object :needs_updated?
      # destroy the job returned by the schedule_long_running_thing
      # method and reschedule it by calling :schedule_long_running_thing, 
      # which will track the new job
      #

      def schedule_long_running_thing
        # to track a job, this method must return an instance of Delayed::Backend::ActiveRecord::Job, or whatever your backend class is)
        # if it doesn't return an object of that class, it won't be tracked 
        self.delay(:run_at => Date.tomorrow).do_some_long_running_thing
      end

      def do_some_long_running_thing
        sleep 100
      end

      def needs_updated?
        true
      end
    end

## TODO

* Murder deprecation warnings coming out of using nulldb during test runs.
* Same for error message about AR connection in rspec after block.
* Migration generator?

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
