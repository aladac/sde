# frozen_string_literal: true

describe SDE::MarketGroup do
  it 'loads market groups' do
    expect(described_class.count).to be > 2000
  end

  it 'has expected fields' do
    mg = described_class.find(described_class.ids.first)
    expect(mg).to be_a(described_class)
    expect(mg.name).to be_a(Hash)
    expect([true, false]).to include(mg.hasTypes)
  end
end
