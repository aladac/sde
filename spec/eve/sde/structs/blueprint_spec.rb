# frozen_string_literal: true

RSpec.describe EVE::SDE::Blueprint do
  it "loads blueprints" do
    expect(described_class.count).to be > 5000
  end

  it "has activities hash and type ID" do
    bp = described_class.find(described_class.ids.first)
    expect(bp).to be_a(described_class)
    expect(bp.activities).to be_a(Hash)
    expect(bp.blueprintTypeID).to be_a(Integer)
    expect(bp.maxProductionLimit).to be_a(Integer)
  end
end
