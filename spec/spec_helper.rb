if !defined?(Rails)
  module ::Rails
    def self.root
      File.expand_path('.')
    end

    def self.logger
      STDOUT
    end
  end
end

Bundler.require(:default, :development)

require 'active_record'
require 'background_job_tracking'
require 'nulldb_rspec'
require 'nulldb/rails'

include NullDB::RSpec::NullifiedDatabase

