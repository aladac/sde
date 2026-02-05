# frozen_string_literal: true

describe SDE::Category do
  it "loads categories" do
    expect(described_class.count).to be > 40
  end

  it "has expected fields" do
    cat = described_class.find(described_class.ids.first)
    expect(cat).to be_a(described_class)
    expect(cat.name).to be_a(Hash)
    expect([true, false]).to include(cat.published)
  end
end
