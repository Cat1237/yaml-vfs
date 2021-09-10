# frozen_string_literal: true

require 'set'

module VFS
  HEADER_FILES_EXTENSIONS = %w[.h .hh .hpp .ipp .tpp .hxx .def .inl .inc].freeze

  # vfs file collector entry
  class FileCollectorEntry

    attr_reader :framework_path, :real_modules, :real_headers

    def self.new_from_real_headers_dir(framework_path, real_modules_dir, real_header_dir)
      raise ArgumentError, 'real_header_dir must set and exist' if real_header_dir.nil? || !real_header_dir.exist?
      raise ArgumentError, 'real_modules_dir must set and exist' if real_modules_dir.nil? || !real_modules_dir.exist?

      files = Pathname.glob(Pathname(real_header_dir).join('**').join('*')).select do |file|
        HEADER_FILES_EXTENSIONS.include?(file.extname)
      end
      real_modules = Pathname(real_modules_dir).glob('module*.modulemap')
      new(framework_path, real_modules, files)
    end

    def initialize(framework_path, real_modules, real_headers)
      raise ArgumentError, 'framework_path must set' if framework_path.nil?
      raise ArgumentError, 'real_modules and real_headers must set' if real_modules.empty?

      @real_headers = real_headers
      @framework_path = Pathname(framework_path)
      @real_modules = real_modules
    end
  end

  # vfs gen
  class FileCollector
    def initialize(entry)
      raise ArgumentError, 'entry must not empty' if entry.empty?

      @entry = entry
      @vfs_writer = YAMLVFSWriter.new
    end

    def write_mapping(name)
      add_write_file
      @vfs_writer.case_sensitive = false
      path = Pathname(name).expand_path
      path = path.join('all-product-headers.yaml') if path.directory?
      stream = @vfs_writer.write
      path.dirname.mkpath
      File.open(path, 'w') { |f| f.write(stream) }
    end

    private

    def add_write_file
      wirte_f = lambda { |framework_path, dir, files|
        return if dir.empty?

        paths = framework_path.join(dir)
        files.each do |file|
          path = paths.join(file.basename)
          @vfs_writer.add_file_mapping(path, file)
        end
      }
      @entry.each do |entry|
        wirte_f.call(entry.framework_path, 'Headers', entry.real_headers)
        wirte_f.call(entry.framework_path, 'Modules', entry.real_modules)
      end
    end
  end
end
