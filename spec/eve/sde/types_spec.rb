# frozen_string_literal: true

RSpec.describe EVE::SDE::Types do
  describe "LocalizedString" do
    it "accepts a hash of language code to string" do
      type = EVE::SDE::Types::LocalizedString
      result = type.call({"en" => "Hello", "de" => "Hallo"})
      expect(result).to eq({"en" => "Hello", "de" => "Hallo"})
    end
  end
end
