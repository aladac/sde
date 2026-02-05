# frozen_string_literal: true

describe SDE::MapRegion do
  it "loads regions" do
    expect(described_class.count).to eq(113)
  end

  it "has expected attributes" do
    region = described_class.find(described_class.ids.first)
    expect(region).to be_a(described_class)
    expect(region.name).to be_a(Hash)
    expect(region.constellationIDs).to be_an(Array)
  end
end
