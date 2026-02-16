# frozen_string_literal: true

require 'pathname'
require_relative '../sde'
require_relative '../sde/downloader'
require_relative '../sde/dumper'
require_relative '../sde/struct_generator'

SDE_DIR = Pathname.new('./sde')
SDE_YAML_URL = 'https://developers.eveonline.com/static-data/tranquility/eve-online-static-data-3193062-yaml.zip'
YAML_DIR = Pathname.new('./tmp/sde_yaml')

namespace :sde do
  desc 'Download SDE YAML zip from EVE developers'
  task :download do
    SDE::Downloader.new(url: SDE_YAML_URL, zip_path: './tmp/sde.zip', extract_to: YAML_DIR).call
  end

  desc 'Dump SDE YAML files to compressed Marshal format'
  task :dump do
    SDE::Dumper.new(yaml_dir: YAML_DIR, sde_dir: SDE_DIR).call
  end

  desc 'Generate dry-struct definitions from marshal data'
  task :generate_structs do
    SDE::StructGenerator.new(sde_dir: SDE_DIR, output_dir: 'lib/sde/structs').call
  end

  desc 'Download, dump, and generate structs'
  task update: %i[download dump generate_structs]
end
