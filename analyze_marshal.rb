#!/usr/bin/env ruby

require 'marshal'

def inspect_value(value, indent = 0)
  prefix = "  " * indent
  case value
  when Hash
    "Hash with keys: #{value.keys.map(&:inspect).join(', ')}"
  when Array
    if value.empty?
      "Array (empty)"
    else
      first = value.first
      "Array (#{value.length} items) - first item: #{first.class}"
    end
  else
    value.class.to_s
  end
end

def analyze_file(filepath)
  return unless File.exist?(filepath)
  
  puts "\n" + "="*80
  puts "File: #{File.basename(filepath)}"
  puts "="*80
  
  data = Marshal.load(File.binread(filepath))
  
  unless data.is_a?(Hash)
    puts "ERROR: Top-level structure is #{data.class}, not Hash"
    return
  end
  
  puts "Top-level: Hash with #{data.length} entries"
  puts "ID types in keys: #{data.keys.map(&:class).uniq.inspect}"
  
  # Get first entry
  first_id, first_entry = data.first
  
  unless first_entry.is_a?(Hash)
    puts "ERROR: First entry is #{first_entry.class}, not Hash"
    return
  end
  
  puts "\nFirst entry (ID: #{first_id}):"
  puts "  Keys: #{first_entry.keys.inspect}"
  
  first_entry.each do |key, value|
    case value
    when Hash
      puts "  #{key}: Hash"
      puts "    Keys: #{value.keys.inspect}"
      value.each do |k, v|
        puts "    #{k}: #{inspect_value(v, 0)}"
      end
    when Array
      puts "  #{key}: Array (#{value.length} items)"
      unless value.empty?
        first_item = value.first
        if first_item.is_a?(Hash)
          puts "    First item: Hash with keys #{first_item.keys.inspect}"
          first_item.each do |k, v|
            puts "      #{k}: #{inspect_value(v, 0)}"
          end
        else
          puts "    First item: #{first_item.class}"
        end
      end
    else
      puts "  #{key}: #{value.class}"
    end
  end
rescue => e
  puts "ERROR: #{e.message}"
  puts e.backtrace.first(5).map { |line| "  #{line}" }
end

files = [
  'sde/types.marshal',
  'sde/blueprints.marshal',
  'sde/dogmaAttributes.marshal',
  'sde/dogmaEffects.marshal',
  'sde/mapSolarSystems.marshal',
  'sde/groups.marshal',
  'sde/categories.marshal',
  'sde/races.marshal',
  'sde/factions.marshal',
  'sde/npcCorporations.marshal',
  'sde/icons.marshal',
  'sde/typeBonus.marshal',
  'sde/typeDogma.marshal',
  'sde/typeMaterials.marshal',
  'sde/marketGroups.marshal',
  'sde/certificates.marshal',
  'sde/skins.marshal',
  'sde/agentTypes.marshal',
  'sde/ancestries.marshal'
]

files.each { |file| analyze_file(file) }

puts "\n" + "="*80
puts "Analysis complete"
puts "="*80
