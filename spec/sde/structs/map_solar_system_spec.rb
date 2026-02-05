# frozen_string_literal: true

describe SDE::MapSolarSystem do
  it "loads solar systems" do
    expect(described_class.count).to eq(8437)
  end

  it "finds Jita" do
    jita = described_class.find(30_000_142)
    expect(jita).to be_a(described_class)
    expect(jita.name["en"]).to eq("Jita")
    expect(jita.securityStatus).to be_a(Float)
    expect(jita.regionID).to be_a(Integer)
    expect(jita.constellationID).to be_a(Integer)
  end

  it "handles optional array attributes" do
    jita = described_class.find(30_000_142)
    expect(jita.stargateIDs).to be_an(Array) if jita.stargateIDs
    expect(jita.planetIDs).to be_an(Array) if jita.planetIDs
  end
end
