# frozen_string_literal: true

describe SDE::Types do
  describe 'LocalizedString' do
    it 'accepts a hash of language code to string' do
      type = SDE::Types::LocalizedString
      result = type.call({ 'en' => 'Hello', 'de' => 'Hallo' })
      expect(result).to eq({ 'en' => 'Hello', 'de' => 'Hallo' })
    end
  end
end
