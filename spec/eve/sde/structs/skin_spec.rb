# frozen_string_literal: true

RSpec.describe EVE::SDE::Skin do
  it "loads skins" do
    expect(described_class.count).to be > 6000
  end

  it "has expected fields" do
    skin = described_class.find(described_class.ids.first)
    expect(skin).to be_a(described_class)
    expect(skin.skinMaterialID).to be_a(Integer)
  end
end
