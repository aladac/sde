# Plan: Move SDE data generation to `gem install` time

## Goal
Ship the gem without the 82MB of pre-built data and generated struct files. Instead, download the SDE YAML, convert to msgpack, and generate struct definitions automatically when the user runs `gem install eve-sde`.

## Mechanism: Rubygems Native Extension (`extconf.rb`)

Rubygems supports running code at install time via the `extensions` field. We use `extconf.rb` to generate a `Makefile` whose `all` target runs a Ruby build script that performs the full data pipeline.

**Flow:**
1. `gem install eve-sde` installs dependencies first (dry-struct, msgpack, etc.)
2. Rubygems runs `ruby ext/eve_sde/extconf.rb` → generates `Makefile`
3. Rubygems runs `make` → invokes `build.rb` with the gem root path
4. `build.rb` downloads SDE YAML, converts to msgpack.gz, generates structs
5. Data lands in `GEM_DIR/sde/`, structs in `GEM_DIR/lib/eve/sde/structs/`
6. No changes needed to `lib/eve/sde.rb` — paths are already correct

## Files to Create

### `ext/eve_sde/extconf.rb`
- Determines gem root directory from `__dir__`
- Writes a `Makefile` with an `all` target that calls `build.rb`
- Uses `RbConfig.ruby` for the correct Ruby interpreter path

### `ext/eve_sde/build.rb`
- Accepts gem root as `ARGV[0]`
- Adds `gem_root/lib` to `$LOAD_PATH`
- Requires `EVE::SDE::Downloader`, `Dumper`, `StructGenerator`
- Runs the full pipeline: download → dump → generate_structs
- Cleans up temp files (zip, extracted YAML) after completion
- Uses the same SDE URL currently in `lib/tasks/sde.rake`

## Files to Modify

### `eve-sde.gemspec`
- Add: `spec.extensions = ['ext/eve_sde/extconf.rb']`
- Exclude `sde/` and `lib/eve/sde/structs/` from `spec.files` (add to reject list)
- The `ext/` directory is auto-included via `git ls-files`

### `.gitignore`
- Add `/sde/` to stop tracking the 82MB data directory

## Git Cleanup
- `git rm -r --cached sde/` to untrack the data files (keeps local copies)
- `git rm -r --cached lib/eve/sde/structs/` to untrack struct files (already in .gitignore but still tracked)

## No Changes Needed
- `lib/eve/sde.rb` — `data_path` already resolves to `../../sde` relative to `__dir__`, which works for both development and installed gem
- `lib/eve/sde/base.rb` — unchanged
- `lib/tasks/sde.rake` — kept for development workflow
- `lib/eve/sde/downloader.rb`, `dumper.rb`, `struct_generator.rb` — unchanged

## Verification
1. `ruby -e "require 'eve/sde'; puts EVE::SDE::Type.count"` after `gem install` should load data
2. `rake sde:update` still works for development
3. `gem build eve-sde.gemspec` produces a small gem (no data/struct files)
4. Data files exist in gem install dir after installation
