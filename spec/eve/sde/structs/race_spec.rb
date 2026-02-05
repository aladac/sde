# frozen_string_literal: true

RSpec.describe EVE::SDE::Race do
  it "loads races" do
    expect(described_class.count).to be > 0
  end

  it "has expected fields" do
    race = described_class.find(described_class.ids.first)
    expect(race).to be_a(described_class)
    expect(race.name).to be_a(Hash)
  end
end
