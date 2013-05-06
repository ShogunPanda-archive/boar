# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require File.expand_path('../lib/boar/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = "boar"
  gem.version = Boar::Version::STRING
  gem.homepage = "http://github.com/ShogunPanda/boar"
  gem.summary = "A Rails engine to handle local static pages and downloads on the cloud."
  gem.description = "A Rails engine to handle local static pages and downloads on the cloud."
  gem.rubyforge_project = "boar"

  gem.authors = ["Shogun"]
  gem.email = ["shogun_panda@me.com"]

  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 1.9.3"

  gem.add_dependency("rails", ">= 3.2.12")
  gem.add_dependency("mustache", "~> 0.99.4")
  gem.add_dependency("mbrao", "~> 1.1.1")
  gem.add_dependency("redis", "~> 3.0.3")
  gem.add_dependency("oj", "~> 2.0.10")
  gem.add_dependency("elephas", "~> 3.0.0")
  gem.add_dependency("clavem", "~> 1.2.2")

  # Downloads gem
  gem.add_dependency("dropbox-sdk", "~> 1.5.1")
  gem.add_dependency("google-api-client", "~> 0.6.3")
  gem.add_dependency("aws-sdk", "~> 1.9.5")
end
