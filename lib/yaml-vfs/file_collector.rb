# frozen_string_literal: true

require 'set'
require 'yaml-vfs/yaml_vfs'

module VFS
  # vfs gen
  class FileCollector
    HEADER_FILES_EXTENSIONS = %w[.h .hh .hpp .ipp .tpp .hxx .def .inl .inc].freeze

    attr_reader :framework_path, :real_modules_dir, :real_headers

    def self.new_from_real_headers_dir(framework_path, real_header_dir, real_modules_dir)
      raise ArgumentError, 'real_header_dir must set and exist' if real_header_dir.nil? || !real_header_dir.exist?

      files = Pathname.glob(real_header_dir.join('**').join('*')).select do |file|
        HEADER_FILES_EXTENSIONS.include?(file.extname)
      end
      new(framework_path, real_modules_dir, files)
    end

    def initialize(framework_path, real_modules_dir, real_headers)
      @seen = Set.new
      @vfs_writer = YAMLVFSWriter.new
      @real_headers = real_headers
      @framework_path = framework_path
      @real_modules_dir = real_modules_dir
    end

    def write_mapping(name)
      raise ArgumentError, 'framework_path must set' if @framework_path.nil?
      raise ArgumentError, 'real_headers or real_header_dir one of them must set' if @real_headers.empty?

      add_write_file
      @vfs_writer.case_sensitive = false
      path = name.expand_path
      path = path.join('all-product-headers.yaml') if path.directory?
      stream = @vfs_writer.write
      File.open(path, 'w') { |f| f.write(stream) }
    end

    private

    def add_write_file
      wirte_f = lambda { |dir, files|
        paths = @framework_path.join(dir)
        files.each do |file|
          path = paths.join(file.basename)
          @vfs_writer.add_file_mapping(path, file)
        end
      }
      wirte_f.call('Headers', @real_headers) unless @real_headers.empty?
      wirte_f.call('Modules', real_modules_dir.glob('*.modulemap')) unless @real_modules_dir.nil?
    end
  end
end
