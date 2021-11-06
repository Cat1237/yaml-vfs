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
      entrys = []
      unless public_headers.empty?
        entrys += public_headers.map do |header|
          v_p = File.join(framework_path, 'Headers', File.basename(header))
          new(header, v_p)
        end
      end
      unless private_headers.empty?
        entrys += private_headers.map do |header|
          v_p = File.join(framework_path, 'PrivateHeaders', File.basename(header))
          new(header, v_p)
        end
      end
      unless real_modules.empty?
        entrys += real_modules.map do |m|
          v_p = File.join(framework_path, 'Modules', File.basename(m))
          new(m, v_p)
        end
      end
      entrys
    end

    def self.entrys_from_framework_dir(framework_path, real_header_dir, real_modules_dir)
      raise ArgumentError, 'real_header must set and exist' if real_header_dir.nil? || !File.exist?(real_header_dir)
      raise ArgumentError, 'real_modules must set and exist' if real_header_dir.nil? || !File.exist?(real_header_dir)

      real_header_dir = File.join(real_header_dir, '**', '*')
      real_headers = Pathname.glob(real_header_dir).select { |file| HEADER_FILES_EXTENSIONS.include?(file.extname) }
      real_modules = Pathname(real_modules_dir).glob('module*.modulemap') || []
      entrys_from_framework(framework_path, real_headers, real_modules)
    end

    def self.entrys_from_target(target_path, public_headers, private_headers)
      entrys = []
      unless private_headers.empty?
        entrys += private_headers.map do |header|
          v_p = File.join(target_path, 'PrivateHeaders', File.basename(header))
          new(header, v_p)
        end
      end
      unless public_headers.empty?
        entrys += public_headers.map do |header|
          v_p = File.join(target_path, 'Headers', File.basename(header))
          new(header, v_p)
        end
      end
      entrys
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
    def initialize(entrys)
      @entrys = entrys || []
      @vfs_writer = YAMLVFSWriter.new
    end

    def write_mapping(name)
      add_write_file
      @vfs_writer.case_sensitive = false
      path = Pathname(name).expand_path
      unless VFS_FILES_EXTENSIONS.include?(File.extname(path))
        path.mkpath unless path.exist?
        path = path.join('all-product-headers.yaml')
      end
      stream = @vfs_writer.write
      File.open(path, 'w') { |f| f.write(stream) }
    end

    private

    def add_write_file
      @entrys.each do |entry|
        @vfs_writer.add_file_mapping(entry.virtual_path, entry.real_path)
      end
    end
  end
end
