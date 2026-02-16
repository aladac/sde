# frozen_string_literal: true

describe SDE::DogmaAttribute do
  it 'loads dogma attributes' do
    expect(described_class.count).to be > 2800
  end

  it 'has expected fields' do
    attr = described_class.find(described_class.ids.first)
    expect(attr).to be_a(described_class)
    expect(attr.name).to be_a(String).or be_a(Hash)
  end
end
