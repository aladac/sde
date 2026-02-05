# frozen_string_literal: true

RSpec.describe EVE::SDE::Faction do
  it "loads all factions" do
    expect(described_class.count).to eq(27)
  end

  it "returns struct instances from find" do
    faction = described_class.find(described_class.ids.first)
    expect(faction).to be_a(described_class)
  end

  it "has expected attributes" do
    faction = described_class.find(500_001)
    expect(faction.name).to be_a(Hash)
    expect(faction.name["en"]).to be_a(String)
    expect(faction.iconID).to be_a(Integer)
    expect(faction.memberRaces).to be_an(Array)
    expect(faction.sizeFactor).to be_a(Float)
    expect(faction.solarSystemID).to be_a(Integer)
  end
end
