# frozen_string_literal: true

require "pathname"
require_relative "../eve/sde"
require_relative "../eve/sde/downloader"
require_relative "../eve/sde/dumper"
require_relative "../eve/sde/struct_generator"

SDE_DIR = Pathname.new("./sde")
SDE_YAML_URL = "https://developers.eveonline.com/static-data/tranquility/eve-online-static-data-3193062-yaml.zip"
YAML_DIR = Pathname.new("./tmp/sde_yaml")

namespace :sde do
  desc "Download SDE YAML zip from EVE developers"
  task :download do
    EVE::SDE::Downloader.new(url: SDE_YAML_URL, zip_path: "./tmp/sde.zip", extract_to: YAML_DIR).call
  end

  desc "Dump SDE YAML files to compressed Marshal format"
  task :dump do
    EVE::SDE::Dumper.new(yaml_dir: YAML_DIR, sde_dir: SDE_DIR).call
  end

  desc "Generate dry-struct definitions from marshal data"
  task :generate_structs do
    EVE::SDE::StructGenerator.new(sde_dir: SDE_DIR, output_dir: "lib/eve/sde/structs").call
  end

  desc "Download, dump, and generate structs"
  task update: %i[download dump generate_structs]
end
