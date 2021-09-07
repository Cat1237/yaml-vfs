# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/lib/yaml_vfs"

Gem::Specification.new do |spec|
  spec.name          = 'yaml-vfs'
  spec.version       = VFS::VERSION
  spec.authors       = ['Cat1237']
  spec.email         = ['wangson1237@outlook.com']

  spec.summary       = 'A gem which can gen VFS YAML file.'
  spec.description   = %(
    `vfs yamlwriter` lets you create clang opt "-ivfsoverlay" ymal file,  map virtual path to real path.
  ).strip.gsub(/\s+/, ' ')
  spec.homepage      = 'https://github.com/Cat1237/yaml-vfs'
  spec.license       = 'MIT'
  spec.files         = %w[README.md LICENSE] + Dir['lib/**/*.rb']
  spec.executables   = %w[vfs]
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'coveralls', '~> 0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_runtime_dependency 'claide',         '>= 1.0.2', '< 2.0'
  spec.add_runtime_dependency 'colored2',       '~> 3.1'
  spec.required_ruby_version = '>= 2.5'
end
