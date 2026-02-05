# frozen_string_literal: true

RSpec.describe EVE::SDE::Group do
  it "loads groups" do
    expect(described_class.count).to be > 1500
  end

  it "has expected fields" do
    group = described_class.find(described_class.ids.first)
    expect(group).to be_a(described_class)
    expect(group.name).to be_a(Hash)
    expect(group.categoryID).to be_a(Integer)
    expect([true, false]).to include(group.published)
  end
end
