# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "pathname"
require "yaml"
require "fileutils"
require "zlib"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

task default: %i[spec standard]

SDE_DIR = Pathname.new("./sde")
SDE_YAML_URL = "https://developers.eveonline.com/static-data/tranquility/eve-online-static-data-3193062-yaml.zip"
YAML_DIR = Pathname.new("./tmp/sde_yaml")

namespace :sde do
  desc "Download SDE YAML zip from EVE developers"
  task :download do
    require "net/http"
    require "uri"

    zip_path = Pathname.new("./tmp/sde.zip")
    FileUtils.mkdir_p(zip_path.dirname)
    FileUtils.mkdir_p(YAML_DIR)

    puts "Downloading #{SDE_YAML_URL}..."
    uri = URI(SDE_YAML_URL)

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new(uri)
      http.request(request) do |response|
        case response
        when Net::HTTPRedirection
          uri = URI(response["location"])
          raise "Redirect to #{uri} — re-run or update URL"
        when Net::HTTPSuccess
          download_with_progress(response, zip_path)
        else
          abort "Download failed: #{response.code} #{response.message}"
        end
      end
    end

    puts "Extracting to #{YAML_DIR}..."
    system("unzip", "-o", "-q", zip_path.to_s, "-d", YAML_DIR.to_s) || abort("unzip failed")
    puts "Done. YAML files in #{YAML_DIR}"
  end

  desc "Dump SDE YAML files to compressed Marshal format"
  task :dump do
    require "benchmark"

    abort "No YAML files at #{YAML_DIR}. Run `rake sde:download` first." unless YAML_DIR.exist?
    FileUtils.mkdir_p(SDE_DIR)

    yaml_files = Dir[YAML_DIR.join("**/*.yaml")].sort
    total_yaml = 0
    total_gz = 0
    written = 0
    skipped = []

    yaml_files.each do |yaml_path|
      basename = File.basename(yaml_path, ".yaml")
      data = nil
      yt = Benchmark.realtime { data = YAML.load_file(yaml_path) }

      unless data.is_a?(Hash) && data.keys.first.is_a?(Integer)
        skipped << basename
        next
      end

      gz_path = SDE_DIR.join("#{basename}.marshal.gz")
      Zlib::GzipWriter.open(gz_path.to_s) { |gz| gz.write(Marshal.dump(data)) }
      written += 1

      yaml_size = File.size(yaml_path)
      gz_size = File.size(gz_path)
      total_yaml += yaml_size
      total_gz += gz_size

      puts "%-35s %8s → %8s (%2d%%)  parsed in %6.0fms" % [
        basename,
        "#{(yaml_size / 1024.0).round}K",
        "#{(gz_size / 1024.0).round}K",
        (gz_size * 100.0 / yaml_size).round,
        yt * 1000
      ]
    end

    puts
    puts "Skipped (non-integer keys): #{skipped.join(", ")}" if skipped.any?
    puts "Total: #{(total_yaml / 1048576.0).round(1)}MB YAML → #{(total_gz / 1048576.0).round(1)}MB Marshal.gz"
    puts "Wrote #{written} files to #{SDE_DIR}"
  end

  desc "Generate dry-struct definitions from marshal data"
  task :generate_structs do
    require_relative "lib/eve/sde"
    require_relative "lib/eve/sde/struct_generator"

    EVE::SDE::StructGenerator.new(
      sde_dir: SDE_DIR,
      output_dir: "lib/eve/sde/structs"
    ).call
  end

  desc "Download, dump, and generate structs"
  task update: %i[download dump generate_structs]
end

def download_with_progress(response, path)
  total = response["content-length"]&.to_i
  downloaded = 0

  File.open(path, "wb") do |f|
    response.read_body do |chunk|
      f.write(chunk)
      downloaded += chunk.size
      if total
        print "\r  #{(downloaded * 100.0 / total).round(1)}% (#{(downloaded / 1048576.0).round(1)}MB)"
      else
        print "\r  #{(downloaded / 1048576.0).round(1)}MB"
      end
    end
  end
  puts
end
