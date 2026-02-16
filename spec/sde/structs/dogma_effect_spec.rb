# frozen_string_literal: true

describe SDE::DogmaEffect do
  it 'loads dogma effects' do
    expect(described_class.count).to be > 3000
  end

  it 'has expected fields' do
    effect = described_class.find(described_class.ids.first)
    expect(effect).to be_a(described_class)
  end
end
