# frozen_string_literal: true

describe SDE::Type do
  let(:tritanium) { described_class.find(34) }

  it "is a Dry::Struct" do
    expect(tritanium).to be_a(Dry::Struct)
  end

  it "has a localized name" do
    expect(tritanium.name).to be_a(Hash)
    expect(tritanium.name["en"]).to eq("Tritanium")
  end

  it "has groupID" do
    expect(tritanium.groupID).to eq(18)
  end

  it "has published flag" do
    expect(tritanium.published).to be true
  end

  it "has portionSize" do
    expect(tritanium.portionSize).to eq(1)
  end

  it "has volume" do
    expect(tritanium.volume).to eq(0.01)
  end

  it "handles optional attributes" do
    expect(tritanium.respond_to?(:factionID)).to be true
  end
end
