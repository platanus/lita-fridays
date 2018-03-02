Gem::Specification.new do |spec|
  spec.name          = "lita-fridays"
  spec.version       = "0.1.0"
  spec.authors       = ["Óscar Estay"]
  spec.email         = ["oscar@platan.us"]
  spec.description   = "Manages the office presentations (currently held on fridays)"
  spec.summary       = ""
  spec.homepage      = ""
  spec.license       = ""
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.7"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
  spec.add_development_dependency "rufus-scheduler"
end
