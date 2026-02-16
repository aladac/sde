# frozen_string_literal: true

require 'zlib'
require 'msgpack'

module SDE
  module Base
    attr_reader :source

    def data
      @data ||= Zlib::GzipReader.open(source.to_s) { |gz| MessagePack.unpack(gz.read) }
    end

    def find(id)
      raw = data[id]
      return nil unless raw

      struct? ? new(raw) : raw
    end

    def all
      @all ||= struct? ? data.transform_values { |v| new(v) } : data
    end

    def ids
      data.keys
    end

    def count
      data.size
    end

    private

    def struct?
      ancestors.include?(Dry::Struct)
    end
  end
end
