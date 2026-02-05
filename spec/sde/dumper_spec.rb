# frozen_string_literal: true

describe SDE::Dumper do
  let(:tmpdir) { Dir.mktmpdir("eve-sde-test") }

  after { FileUtils.rm_rf(tmpdir) }

  it "aborts when yaml_dir does not exist" do
    dumper = described_class.new(yaml_dir: "/nonexistent", sde_dir: tmpdir)
    expect { dumper.call }.to raise_error(SystemExit)
  end

  it "skips YAML files with non-integer keys" do
    yaml_dir = File.join(tmpdir, "yaml")
    sde_dir = File.join(tmpdir, "sde")
    FileUtils.mkdir_p(yaml_dir)

    File.write(File.join(yaml_dir, "stringKeys.yaml"), {"foo" => "bar", "baz" => "qux"}.to_yaml)

    dumper = described_class.new(yaml_dir: yaml_dir, sde_dir: sde_dir)
    dumper.call

    expect(Dir[File.join(sde_dir, "*.msgpack.gz")]).to be_empty
  end

  it "converts YAML with integer keys to msgpack.gz" do
    yaml_dir = File.join(tmpdir, "yaml")
    sde_dir = File.join(tmpdir, "sde")
    FileUtils.mkdir_p(yaml_dir)

    data = {1 => {"name" => "Alpha"}, 2 => {"name" => "Beta"}}
    File.write(File.join(yaml_dir, "testItems.yaml"), data.to_yaml)

    dumper = described_class.new(yaml_dir: yaml_dir, sde_dir: sde_dir)
    dumper.call

    gz_files = Dir[File.join(sde_dir, "*.msgpack.gz")]
    expect(gz_files.size).to eq(1)
    expect(gz_files.first).to end_with("test_items.msgpack.gz")

    loaded = Zlib::GzipReader.open(gz_files.first) { |gz| MessagePack.unpack(gz.read) }
    expect(loaded[1]["name"]).to eq("Alpha")
    expect(loaded[2]["name"]).to eq("Beta")
  end
end
