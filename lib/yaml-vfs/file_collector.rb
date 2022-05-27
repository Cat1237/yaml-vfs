# frozen_string_literal: true

require 'set'

module VFS
  HEADER_FILES_EXTENSIONS = %w[.h .hh .hpp .ipp .tpp .hxx .def .inl .inc].freeze
  VFS_FILES_EXTENSIONS = %w[.yaml .yml .json].freeze
  # vfs file collector entry
  class FileCollectorEntry
    attr_reader :real_path, :virtual_path

    def initialize(real_path, virtual_path)
      raise ArgumentError, 'real_path or virtual_path must set' if real_path.nil? || virtual_path.empty?

      @real_path = Pathname(real_path)
      @virtual_path = Pathname(virtual_path)
    end

    def self.entrys_from_framework(framework_path, public_headers, private_headers, real_modules)
      entrys = {}
      entrys['Headers'] = public_headers unless public_headers.empty?
      entrys['PrivateHeaders'] = private_headers unless private_headers.empty?
      entrys['Modules'] = real_modules unless real_modules.empty?

      entrys.flat_map do |key, values|
        values.map do |path|
          v_p = File.join(framework_path, key, File.basename(path))
          new(path, v_p)
        end
      end
    end

    def self.entrys_from_framework_dir(framework_path, real_header_dir, real_modules_dir)
      raise ArgumentError, 'real_header must set and exist' unless File.exist?(real_header_dir || '')
      raise ArgumentError, 'real_modules must set and exist' unless File.exist?(real_header_dir || '')

      real_header_dir = File.join(real_header_dir, '**', '*')
      real_headers = Pathname.glob(real_header_dir).select { |file| HEADER_FILES_EXTENSIONS.include?(file.extname) }
      real_modules = Pathname(real_modules_dir).glob('module*.modulemap') || []
      entrys_from_framework(framework_path, real_headers, real_modules)
    end

    def self.entrys_from_target(target_path, public_headers, private_headers)
      entrys = {}
      entrys['Headers'] = public_headers unless public_headers.empty?
      entrys['PrivateHeaders'] = private_headers unless private_headers.empty?

      entrys.flat_map do |key, values|
        values.map do |path|
          v_p = File.join(target_path, key, File.basename(path))
          new(path, v_p)
        end
      end
    end

    def self.entrys_from_target_dir(target_path, public_dir, private_dir)
      headers = lambda do |dir|
        unless dir.nil? && File.exist?(dir)
          Pathname.glob(File.join(dir, '**', '*')).select do |file|
            HEADER_FILES_EXTENSIONS.include?(file.extname)
          end
        end
      end
      private_headers = headers.call(private_dir) || []
      public_headers = headers.call(public_dir) || []
      entrys_from_target(target_path, public_headers, private_headers)
    end
  end

  # vfs gen
  class FileCollector
    EMPTY_VFS_FILE = '{"case-sensitive":"false","roots":[],"version":0}'
    private_constant :EMPTY_VFS_FILE
    def initialize(entrys)
      @entrys = entrys || []
      @vfs_writer = YAMLVFSWriter.new
    end

    def write_mapping(name)
      stream = add_write_file
      path = Pathname(name).expand_path
      unless VFS_FILES_EXTENSIONS.include?(File.extname(path))
        path.mkpath unless path.exist?
        path = path.join('all-product-headers.yaml')
      end
      update_changed_file(path, stream)
    end

    private

    def update_changed_file(path, contents)
      if path.exist?
        content_stream = StringIO.new(contents)
        identical = File.open(path, 'rb') { |f| FileUtils.compare_stream(f, content_stream) }
        return if identical
      end
      path.dirname.mkpath
      File.open(path, 'w') { |f| f.write(contents) }
    end

    def add_write_file
      return EMPTY_VFS_FILE if @entrys.empty?

      @entrys.each { |entry| @vfs_writer.add_file_mapping(entry.virtual_path, entry.real_path) }
      @vfs_writer.case_sensitive = false
      @vfs_writer.write
    end
  end
end
