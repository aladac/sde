# frozen_string_literal: true

RSpec.describe EVE::SDE::Base do
  let(:type_class) { EVE::SDE::Type }

  describe "#data" do
    it "returns a Hash of raw data keyed by integer ID" do
      data = type_class.data
      expect(data).to be_a(Hash)
      expect(data.keys.first).to be_a(Integer)
    end

    it "caches the loaded data" do
      expect(type_class.data).to equal(type_class.data)
    end
  end

  describe "#source" do
    it "returns the path to the msgpack.gz file" do
      expect(type_class.source.to_s).to end_with("types.msgpack.gz")
    end
  end

  describe "#find" do
    context "with a struct-backed class" do
      it "returns a Dry::Struct instance" do
        result = type_class.find(34)
        expect(result).to be_a(Dry::Struct)
      end

      it "returns nil for an unknown ID" do
        expect(type_class.find(-999_999)).to be_nil
      end
    end
  end

  describe "#all" do
    it "returns a Hash of ID => struct instances for struct classes" do
      all = type_class.all
      expect(all).to be_a(Hash)
      expect(all.values.first).to be_a(Dry::Struct)
    end

    it "caches the wrapped collection" do
      expect(type_class.all).to equal(type_class.all)
    end
  end

  describe "#ids" do
    it "returns an array of all IDs" do
      ids = type_class.ids
      expect(ids).to be_an(Array)
      expect(ids).to include(34)
    end
  end

  describe "#count" do
    it "returns the number of entries" do
      expect(type_class.count).to be > 50_000
    end
  end
end
