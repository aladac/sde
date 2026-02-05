# frozen_string_literal: true

require "yaml"
require "zlib"
require "benchmark"
require "fileutils"

class EVE::SDE::Dumper
  def initialize(yaml_dir:, sde_dir:)
    @yaml_dir = Pathname.new(yaml_dir)
    @sde_dir = Pathname.new(sde_dir)
  end

  def call
    abort "No YAML files at #{@yaml_dir}. Run `rake sde:download` first." unless @yaml_dir.exist?
    FileUtils.mkdir_p(@sde_dir)

    yaml_files = Dir[@yaml_dir.join("**/*.yaml")].sort
    stats = {yaml: 0, gz: 0, written: 0, skipped: []}

    yaml_files.each { |path| dump_one(path, stats) }
    print_summary(stats)
  end

  private

  def dump_one(yaml_path, stats)
    basename = File.basename(yaml_path, ".yaml")
    data = nil
    elapsed = Benchmark.realtime { data = YAML.load_file(yaml_path) }

    unless data.is_a?(Hash) && data.keys.first.is_a?(Integer)
      stats[:skipped] << basename
      return
    end

    gz_path = @sde_dir.join("#{basename}.marshal.gz")
    Zlib::GzipWriter.open(gz_path.to_s) { |gz| gz.write(Marshal.dump(data)) }
    stats[:written] += 1

    yaml_size = File.size(yaml_path)
    gz_size = File.size(gz_path)
    stats[:yaml] += yaml_size
    stats[:gz] += gz_size

    puts "%-35s %8s → %8s (%2d%%)  parsed in %6.0fms" % [
      basename,
      "#{(yaml_size / 1024.0).round}K",
      "#{(gz_size / 1024.0).round}K",
      (gz_size * 100.0 / yaml_size).round,
      elapsed * 1000
    ]
  end

  def print_summary(stats)
    puts
    puts "Skipped (non-integer keys): #{stats[:skipped].join(", ")}" if stats[:skipped].any?
    puts "Total: #{mb(stats[:yaml])}MB YAML → #{mb(stats[:gz])}MB Marshal.gz"
    puts "Wrote #{stats[:written]} files to #{@sde_dir}"
  end

  def mb(bytes)
    (bytes / 1_048_576.0).round(1)
  end
end
