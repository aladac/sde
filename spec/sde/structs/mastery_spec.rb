# frozen_string_literal: true

describe SDE::Mastery do
  it 'loads mastery data' do
    expect(described_class.count).to be > 400
  end

  it 'has raw data with numeric keys for mastery levels' do
    raw = described_class.data[described_class.ids.first]
    expect(raw).to be_a(Hash)
    expect(raw.keys).to include(0, 1, 2, 3, 4)
  end
end
