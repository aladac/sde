# frozen_string_literal: true

RSpec.describe EVE::SDE::NpcCorporation do
  it "loads NPC corporations" do
    expect(described_class.count).to be > 280
  end

  it "has expected fields" do
    corp = described_class.find(described_class.ids.first)
    expect(corp).to be_a(described_class)
    expect(corp.name).to be_a(Hash)
  end
end
