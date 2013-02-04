# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gdm/version'

Gem::Specification.new do |gem|
  gem.name          = "gdm"
  gem.version       = GDM::VERSION
  gem.authors       = ["Dan Weinand"]
  gem.email         = ["dweinand@gmail.com"]
  gem.description   = %q{Ruby client for Plex's G'day Mate (GDM) autodiscovery mechanism}
  gem.summary       = %q{Ruby client for Plex's G'day Mate (GDM) autodiscovery mechanism}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
