# SDE

Ruby library for EVE Online's Static Data Export. Provides typed structs and lazy-loading access to all 53 SDE data collections via compressed MessagePack files.

## Installation

Add to your Gemfile:

```ruby
gem "sde"
```

Or install directly:

```bash
gem install sde
```

## Usage

```ruby
require "sde"

# Look up a type by ID
tritanium = SDE::Type.find(34)
tritanium.name["en"]   # => "Tritanium"
tritanium.groupID      # => 18
tritanium.volume       # => 0.01

# Browse all entries
SDE::Faction.count     # => 52
SDE::Faction.ids       # => [500001, 500002, ...]
SDE::Faction.all       # => {500001 => #<SDE::Faction ...>, ...}

# Collections are auto-discovered and lazy-loaded
SDE.registry.keys      # => [:AgentType, :Blueprint, :Category, :Type, ...]
SDE.preload!           # force-load all 53 collections
```

Each collection exposes the same interface via `SDE::Base`:

| Method  | Returns                             |
|---------|-------------------------------------|
| `.find(id)` | Single struct instance or `nil` |
| `.all`       | `Hash{Integer => struct}`      |
| `.ids`       | `Array[Integer]`               |
| `.count`     | `Integer`                      |
| `.data`      | Raw `Hash` from MessagePack    |

## Data pipeline

Rake tasks to download, convert, and generate struct definitions from the official SDE YAML export:

```bash
rake sde:download         # Download SDE YAML zip
rake sde:dump             # Convert YAML to msgpack.gz
rake sde:generate_structs # Generate Dry::Struct definitions
rake sde:update           # Run all three steps
```

## Development

```bash
bin/setup       # Install dependencies
bundle exec rspec # Run tests (240 examples)
bin/console     # Interactive console with SDE loaded
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aladac/eve-sde.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
