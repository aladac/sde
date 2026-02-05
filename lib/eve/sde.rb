# frozen_string_literal: true

require "pathname"
require "dry-struct"
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

    def self.registry
      @registry ||= build_registry
    end

    def self.const_missing(name)
      name = name.to_sym
      basename = registry[name]
      return super unless basename

      marshal_file = data_path.join("#{basename}.msgpack.gz")
      return super unless marshal_file.exist?

      struct_file = inflector.underscore(name.to_s)
      begin
        require_relative "sde/structs/#{struct_file}"
      rescue LoadError
        const_set(name, Class.new)
      end

      klass = const_get(name)
      klass.extend(Base)
      klass.instance_variable_set(:@source, marshal_file)
      klass
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
        Dir[data_path.join("*.msgpack.gz")].each do |path|
          basename = File.basename(path, ".msgpack.gz")
          const_name = inflector.camelize(inflector.singularize(basename)).to_sym
          reg[const_name] = basename
        end
        reg
      end
    end
  end
end
