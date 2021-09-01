# frozen_string_literal: true

module VFS
  class Command
    # vfs yaml file gen cmd
    class YAMLWriter < Command
      # summary
      self.summary = 'Virtual the framework and modules dir, and map to real path'

      self.description = <<-DESC
        Gen VFS Yaml file. To map framework virtual path to real path.
      DESC

      self.arguments = [
        # framework_p, r_header, r_m
        CLAide::Argument.new('--framework-path', true),
        CLAide::Argument.new('--real-headers-dir', true),
        CLAide::Argument.new('--real-modules-dir', true),
        CLAide::Argument.new('--output-path', false)
      ]

      def initialize(argv)
        super
        framework_path = argv.option('framework-path')
        @framework_path = Pathname(framework_path) unless framework_path.nil?
        real_headers_dir = argv.option('real-headers-dir')
        @real_header_dir = Pathname(real_headers_dir) unless real_headers_dir.nil?
        real_modules_dir = argv.option('real-modules-dir')
        @real_modules_dir = Pathname(real_modules_dir) unless real_modules_dir.nil?
        output_path = argv.option('output-path')
        @output_path = output_path.nil? ? Pathname('.') : Pathname(output_path)
      end

      def validate!
        super
        help! 'must set framework_path' if @framework_path.nil?
        help! 'must set real_headers_dir' if @real_header_dir.nil?
        help! 'must set real_modules_dir' if @real_modules_dir.nil?
      end

      # help
      def self.options
        [
          ['--framework-path=<path>', 'framework path'],
          ['--real-headers-dir=<path>', 'real header path'],
          ['--real-modules-dir=<path>', 'real modules path'],
          ['--output-path=<path>', 'vfs yaml file output path']
        ].concat(super)
      end

      def run
        require 'yaml_vfs'

        VFS::FileCollector.new_from_real_headers_dir(@framework_path, @real_header_dir, @real_modules_dir).write_mapping(@output_path)
      end
    end
  end
end
