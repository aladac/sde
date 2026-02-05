# frozen_string_literal: true

describe SDE do
  describe "VERSION" do
    it "is a semantic version string" do
      expect(SDE::VERSION).to match(/\A\d+\.\d+\.\d+/)
    end
  end

  describe ".data_path" do
    it "returns a Pathname to the sde directory" do
      expect(SDE.data_path).to be_a(Pathname)
      expect(SDE.data_path.to_s).to end_with("sde")
    end
  end

  describe ".data_path=" do
    around do |example|
      original = SDE.data_path
      example.run
      SDE.data_path = original
    end

    it "sets a custom data path" do
      SDE.data_path = "/tmp/custom_sde"
      expect(SDE.data_path).to eq(Pathname.new("/tmp/custom_sde"))
    end

    it "resets the registry when path changes" do
      SDE.registry # ensure cached
      SDE.data_path = "/tmp/empty_sde"
      expect(SDE.instance_variable_get(:@registry)).to be_nil
    end
  end

  describe ".registry" do
    subject(:registry) { SDE.registry }

    it "returns a Hash" do
      expect(registry).to be_a(Hash)
    end

    it "discovers all 53 data collections" do
      expect(registry.size).to eq(53)
    end

    it "maps symbol constant names to file basenames" do
      expect(registry[:Type]).to eq("types")
      expect(registry[:Faction]).to eq("factions")
      expect(registry[:MapSolarSystem]).to eq("map_solar_systems")
      expect(registry[:Blueprint]).to eq("blueprints")
    end

    it "singularizes plural basenames" do
      expect(registry.keys).to include(:Type, :Faction, :Race, :Category)
      expect(registry.keys).not_to include(:Types, :Factions, :Races, :Categories)
    end
  end

  describe ".const_missing" do
    it "auto-loads known constants from the registry" do
      expect(SDE::AgentType).to be_a(Class)
    end

    it "extends loaded classes with Base" do
      expect(SDE::AgentType).to respond_to(:find)
      expect(SDE::AgentType).to respond_to(:all)
      expect(SDE::AgentType).to respond_to(:ids)
      expect(SDE::AgentType).to respond_to(:count)
      expect(SDE::AgentType).to respond_to(:data)
    end

    it "raises NameError for unknown constants" do
      expect { SDE::NonExistentThing }.to raise_error(NameError)
    end
  end

  describe ".preload!" do
    it "loads all registry constants" do
      SDE.preload!
      SDE.registry.each_key do |name|
        expect(SDE.const_defined?(name)).to be(true), "Expected #{name} to be defined"
      end
    end
  end
end
