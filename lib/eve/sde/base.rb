# frozen_string_literal: true

require "zlib"

module EVE
  module SDE
    class Base
      class << self
        attr_reader :source
        attr_accessor :struct_class

        def data
          @data ||= Zlib::GzipReader.open(source.to_s) { |gz| Marshal.load(gz.read) }
        end

        def find(id)
          raw = data[id]
          return nil unless raw
          wrap(raw)
        end

        def all
          @all_wrapped ||= if struct_class
            data.transform_values { |v| wrap(v) }
          else
            data
          end
        end

        def ids
          data.keys
        end

        def count
          data.size
        end

        private

        def wrap(hash)
          struct_class ? struct_class.new(hash) : hash
        end
      end
    end
  end
end
