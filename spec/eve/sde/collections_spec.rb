# frozen_string_literal: true

RSpec.describe "All collections" do
  EVE::SDE.registry.each do |const_name, basename|
    describe "#{const_name} (#{basename})" do
      let(:klass) { EVE::SDE.const_get(const_name) }

      it "loads data" do
        expect(klass.count).to be > 0
      end

      it "returns IDs" do
        expect(klass.ids).to be_an(Array)
        expect(klass.ids).not_to be_empty
      end

      it "has raw data for the first entry" do
        raw = klass.data[klass.ids.first]
        expect(raw).not_to be_nil
      end
    end
  end
end
