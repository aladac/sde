# frozen_string_literal: true

require "pathname"
require "dry/inflector"

require_relative "sde/version"
require_relative "sde/types"
require_relative "sde/base"

module EVE
  module SDE
    class Error < StandardError; end

    def self.data_path
      @data_path ||= Pathname.new(__dir__).join("../..", "sde")
    end

    def self.data_path=(path)
      @data_path = Pathname.new(path)
      @registry = nil
    end

    # Map singular const name → plural marshal.gz basename
    # e.g. :Type => "types", :Faction => "factions", :AgentType => "agentTypes"
    def self.registry
      @registry ||= build_registry
    end

    def self.const_missing(name)
      basename = registry[name]

      if basename
        marshal_file = data_path.join("#{basename}.marshal.gz")
        if marshal_file.exist?
          klass = Class.new(Base)
          klass.instance_variable_set(:@source, marshal_file)
          const_set(name, klass)

          # Auto-require matching struct file
          begin
            require_relative "sde/structs/#{basename}"
          rescue LoadError
            # No struct defined — raw hash access
          end

          klass
        else
          super
        end
      else
        super
      end
    end

    def self.preload!
      registry.each_key do |const_name|
        const_missing(const_name) unless const_defined?(const_name)
      end
    end

    class << self
      private

      def inflector
        @inflector ||= Dry::Inflector.new
      end

      def build_registry
        reg = {}
        Dir[data_path.join("*.marshal.gz")].each do |path|
          basename = File.basename(path, ".marshal.gz")
          const_name = inflector.camelize(inflector.singularize(basename)).to_sym
          reg[const_name] = basename
        end
        reg
      end
    end
  end
end
