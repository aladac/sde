# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'standard/rake'

RSpec::Core::RakeTask.new(:spec)

task default: %i[spec standard]

Dir[File.join(__dir__, 'lib/tasks/**/*.rake')].each { |f| load f }
