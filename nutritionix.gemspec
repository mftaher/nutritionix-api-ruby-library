# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nutritionix/version'

Gem::Specification.new do |spec|
  spec.name          = "nutritionix"
  spec.version       = Nutritionix::VERSION
  spec.authors       = ["Fazle Taher"]
  spec.email         = ["ftaher@gmail.com"]
  spec.description   = %q{Nutritionix API ruby wrapper}
  spec.summary       = %q{ruby gem for nutritionix API}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

end
