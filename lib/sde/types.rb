# frozen_string_literal: true

require 'dry-types'

module SDE
  module Types
    include Dry.Types()

    LocalizedString = Types::Hash.map(Types::String, Types::String)
  end
end
