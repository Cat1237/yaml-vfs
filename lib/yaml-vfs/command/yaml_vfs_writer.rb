# frozen_string_literal: true

module VFS
  class Command
    # vfs yaml file gen cmd
    class Framework < Command
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

        entrys = VFS::FileCollectorEntry.entrys_from_framework_dir(@framework_path, @real_header_dir, @real_modules_dir)
        VFS::FileCollector.new(entrys).write_mapping(@output_path)
      end
    end
    class Target < Command
      # summary
      self.summary = 'Virtual the target public and private headers, and map to real path'

      self.description = <<-DESC
        Gen VFS Yaml file. To map target virtual path to real path.
      DESC

      self.arguments = [
        # target_p, public_header, private_header
        CLAide::Argument.new('--target-path', true),
        CLAide::Argument.new('--public-headers-dir', true),
        CLAide::Argument.new('--private-headers-dir', true),
        CLAide::Argument.new('--output-path', false)
      ]

      def initialize(argv)
        super

        target_path = argv.option('target-path')
        @target_path = Pathname(target_path) unless target_path.nil?
        public_headers_dir = argv.option('public-headers-dir')
        @public_headers_dir = Pathname(public_headers_dir) unless public_headers_dir.nil?
        private_headers_dir = argv.option('private-headers-dir')
        @private_headers_dir = Pathname(private_headers_dir) unless private_headers_dir.nil?
        output_path = argv.option('output-path')
        @output_path = output_path.nil? ? Pathname('.') : Pathname(output_path)
      end

      def validate!
        super
        help! 'must set --target-path' if @target_path.nil?
        help! 'must set --public-headers-dir' if @public_headers_dir.nil?
        help! 'must set --private-headers-dir' if @private_headers_dir.nil?
      end

      # help
      def self.options
        [
          ['--target-pathh=<path>', 'target path'],
          ['--public-headers-dir=<path>', 'real public headers path'],
          ['--private-headers-dir=<path>', 'real private headers path'],
          ['--output-path=<path>', 'vfs yaml file output path']
        ].concat(super)
      end

      def run
        require 'yaml_vfs'

        entrys = VFS::FileCollectorEntry.entrys_from_target_dir(@target_path, @public_headers_dir, @private_headers_dir)
        VFS::FileCollector.new(entrys).write_mapping(@output_path)
      end
    end
  end
end
