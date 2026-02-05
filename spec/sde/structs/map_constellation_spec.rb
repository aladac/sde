# frozen_string_literal: true

describe SDE::MapConstellation do
  it "loads constellations" do
    expect(described_class.count).to be > 1100
  end

  it "has expected fields" do
    c = described_class.find(described_class.ids.first)
    expect(c).to be_a(described_class)
    expect(c.name).to be_a(Hash)
    expect(c.regionID).to be_a(Integer)
    expect(c.solarSystemIDs).to be_an(Array)
  end
end
