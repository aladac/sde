# frozen_string_literal: true

require "eve/sde/struct_generator"

RSpec.describe EVE::SDE::StructGenerator do
  let(:tmpdir) { Dir.mktmpdir("eve-sde-test") }

  after { FileUtils.rm_rf(tmpdir) }

  it "aborts when no msgpack.gz files exist" do
    gen = described_class.new(sde_dir: "/nonexistent", output_dir: tmpdir)
    expect { gen.call }.to raise_error(SystemExit)
  end

  it "generates struct files from msgpack.gz data" do
    sde_dir = File.join(tmpdir, "sde")
    output_dir = File.join(tmpdir, "structs")
    FileUtils.mkdir_p(sde_dir)

    data = {
      1 => {"name" => {"en" => "Alpha", "de" => "Alpha"}, "value" => 42, "active" => true},
      2 => {"name" => {"en" => "Beta", "de" => "Beta"}, "value" => 99, "active" => false, "tags" => [1, 2, 3]}
    }

    gz_path = File.join(sde_dir, "test_items.msgpack.gz")
    Zlib::GzipWriter.open(gz_path) { |gz| gz.write(MessagePack.pack(data)) }

    gen = described_class.new(sde_dir: sde_dir, output_dir: output_dir)
    gen.call

    struct_files = Dir[File.join(output_dir, "*.rb")]
    expect(struct_files.size).to eq(1)

    content = File.read(struct_files.first)
    expect(content).to include("class EVE::SDE::TestItem < Dry::Struct")
    expect(content).to include("attribute :name,")
    expect(content).to include("attribute :value,")
    expect(content).to include("attribute :active,")
    expect(content).to include("LocalizedString")
    expect(content).to include("Integer")
    expect(content).to include("Bool")
    expect(content).to include("optional")
  end

  describe "type classification" do
    let(:sde_dir) { File.join(tmpdir, "sde") }
    let(:output_dir) { File.join(tmpdir, "structs") }

    before { FileUtils.mkdir_p(sde_dir) }

    def generate_struct(data, basename = "test_things")
      gz_path = File.join(sde_dir, "#{basename}.msgpack.gz")
      Zlib::GzipWriter.open(gz_path) { |gz| gz.write(MessagePack.pack(data)) }
      gen = described_class.new(sde_dir: sde_dir, output_dir: output_dir)
      gen.call
      Dir[File.join(output_dir, "*.rb")].map { |f| File.read(f) }.first
    end

    it "classifies Float values" do
      content = generate_struct({1 => {"ratio" => 3.14}})
      expect(content).to include("Float")
    end

    it "classifies String values" do
      content = generate_struct({1 => {"label" => "hello"}})
      expect(content).to include("String")
    end

    it "classifies arrays of strings" do
      content = generate_struct({1 => {"tags" => %w[a b c]}})
      expect(content).to include("Array.of")
      expect(content).to include("String")
    end

    it "classifies arrays of hashes" do
      content = generate_struct({1 => {"items" => [{"a" => 1}, {"b" => 2}]}})
      expect(content).to include("Array.of")
      expect(content).to include("Hash")
    end

    it "classifies empty arrays as Array" do
      content = generate_struct({1 => {"items" => []}})
      expect(content).to include("Types::Array")
    end

    it "classifies mixed arrays as Array" do
      content = generate_struct({1 => {"items" => [1, "two", 3.0]}})
      expect(content).to include("Types::Array")
      expect(content).not_to include("Array.of")
    end

    it "classifies nil-only values as optional Any" do
      content = generate_struct({1 => {"field" => nil}, 2 => {"field" => nil}})
      expect(content).to include("Any")
      expect(content).to include("optional")
    end

    it "classifies Hash values (non-localized)" do
      content = generate_struct({1 => {"meta" => {"foo" => "bar"}}})
      expect(content).to include("Types::Hash")
    end

    it "handles mixed types falling back to Any" do
      content = generate_struct({1 => {"val" => 42}, 2 => {"val" => "hello"}})
      expect(content).to include("Any")
    end

    it "handles numeric string keys in attributes" do
      content = generate_struct({1 => {"0" => [1, 2], "1" => [3, 4]}})
      expect(content).to include(':"0"')
      expect(content).to include(':"1"')
    end

    it "marks attributes missing from some entries as optional" do
      content = generate_struct({
        1 => {"required" => 1, "optional_field" => 2},
        2 => {"required" => 3}
      })
      expect(content).to include("attribute :required, EVE::SDE::Types::Integer\n")
      expect(content).to include("optional_field")
      expect(content).to include("optional")
    end

    it "skips entries that are not hashes" do
      content = generate_struct({1 => "not a hash", 2 => {"name" => "ok"}})
      expect(content).to include("attribute :name")
    end

    it "classifies arrays of floats (including integers in float arrays)" do
      content = generate_struct({1 => {"values" => [1.0, 2, 3.5]}})
      expect(content).to include("Array.of")
      expect(content).to include("Float")
    end
  end
end
