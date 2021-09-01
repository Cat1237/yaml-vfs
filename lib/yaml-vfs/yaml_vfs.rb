# frozen_string_literal: true

require 'pathname'
require 'json'

module VFS
  # A general purpose pseudo-structure.
  # @abstract
  class YAMLVFSEntry
    attr_reader :v_path, :r_path

    def directory?
      @directory
    end

    def initialize(v_path, r_path, directory: false)
      @v_path = v_path
      @r_path = r_path
      @directory = directory
    end
  end

  # YAMLVFSWriter class.
  # @see https://llvm.org/doxygen/classllvm_1_1vfs_1_1YAMLVFSWriter.html
  # @abstract
  class YAMLVFSWriter
    attr_reader :mappings, :overlay_relative, :overlay_dir, :dir_stack
    attr_accessor :case_sensitive, :use_external_names

    def overlay_dir=(overlay_dir)
      @overlay_relative = true
      @overlay_dir = overlay_dir
    end

    def initialize
      @mappings = []
    end

    def add_entry(virtual_path, real_path, is_directory)
      raise ArgumentError, 'virtual path not absolute' unless virtual_path.absolute?
      raise ArgumentError, 'real path not absolute' unless real_path.absolute?
      raise ArgumentError, 'path traversal is not supported' if Utils.traversal_component?(virtual_path)

      mappings << YAMLVFSEntry.new(virtual_path, real_path, directory: is_directory)
    end

    def add_file_mapping(virtual_path, real_path)
      add_entry(virtual_path, real_path, false)
    end

    def add_directory_mapping(virtual_path, real_path)
      add_entry(virtual_path, real_path, true)
    end

    def write
      @mappings.sort_by! { |p| p.v_path.to_s }
      JSONWriter.new.write(@mappings, @use_external_names, @case_sensitive, @overlay_relative, @overlay_dir)
    end
  end

  # JSONWriter class.
  # @see https://llvm.org/doxygen/VirtualFileSystem_8cpp_source.html
  # @abstract
  class JSONWriter
    attr_reader :dir_stack

    def write(entries, use_external_names, case_sensitive, overlay_relative, overlay_dir)
      use_overlay_relative = write_yaml_header(use_external_names, case_sensitive, overlay_relative, overlay_dir)
      unless entries.empty?
        current_dir_empty = write_root_entry(entries, use_overlay_relative, overlay_dir)
        entries.drop(1).reduce(current_dir_empty) do |empty, entry|
          dir = entry.directory? ? entry.v_path : entry.v_path.dirname
          start_directory_or_return(dir, empty, use_overlay_relative, overlay_dir, entry)
        end
      end
      write_yaml_footer(entries)
    end

    def initialize
      @dir_stack = []
    end

    private

    def dir_indent
      @dir_stack.length * 4
    end

    def file_indent
      (@dir_stack.length + 1) * 4
    end

    def contained_in?(parent, path)
      path.ascend { |p| break true if parent == p } || false
    end

    def contained_part(parent, path)
      raise ArgumentError if parent.nil?
      raise ArgumentError unless contained_in?(parent, path)

      path.relative_path_from(parent)
    end

    def start_directory(path)
      name = @dir_stack.empty? ? path : contained_part(@dir_stack.last, path)
      @dir_stack << path
      indent = dir_indent
      @stream += "{\n".indent(indent)
      @stream += "'type': 'directory',\n".indent(indent + 2)
      @stream += "'name': \"#{name}\",\n".indent(indent + 2)
      @stream += "'contents': [\n".indent(indent + 2)
    end

    def end_directory
      indent = dir_indent
      @stream += "]\n".indent(indent + 2)
      @stream += '}'.indent(indent)
      @dir_stack.pop
    end

    def write_entry(v_path, r_path)
      indent = file_indent
      @stream += "{\n".indent(indent)
      @stream += "'type': 'file',\n".indent(indent + 2)
      @stream += "'name': \"#{v_path}\",\n".indent(indent + 2)
      @stream += "'external-contents': \"#{r_path}\"\n".indent(indent + 2)
      @stream += '}'.indent(file_indent)
    end

    def overlay_dir_sub_rpath(use, overlay_dir, rpath)
      if use
        raise ArgumentError, 'Overlay dir must be contained in RPath' unless rpath.fnmatch?("#{overlay_dir}*")

        rpath = rpath.relative_path_from(overlay_dir).expand_path
      end
      rpath
    end

    def write_yaml_header(use_external_names, case_sensitive, overlay_relative, _overlay_dir)
      @stream = "{\n  'version': 0,\n"
      @stream += "  'case-sensitive': '#{case_sensitive}',\n" unless case_sensitive.nil?
      @stream += "  'use-external-names': '#{use_external_names}',\n" unless use_external_names.nil?
      use_overlay_relative = !overlay_relative.nil?
      @stream += "  'overlay_relative': '#{overlay_relative}',\n" if use_overlay_relative
      @stream += "  'roots': [\n"
      use_overlay_relative
    end

    def write_yaml_footer(entries)
      unless entries.empty?
        until @dir_stack.empty?
          @stream += "\n"
          end_directory
        end
        @stream += "\n"
      end
      @stream += "  ]\n}\n"
      @stream
    end

    def write_root_entry(entries, use_overlay_relative, overlay_dir)
      return true if entries.empty?

      f_entry = entries.first
      start_directory(f_entry.directory? ? f_entry.v_path : f_entry.v_path.dirname)
      current_dir_empty = f_entry.directory?
      use_overlay_relative_and_write_entry(use_overlay_relative, overlay_dir, current_dir_empty, f_entry)
    end

    def until_end_directory(dir)
      dir_popped_from_stack = false
      until @dir_stack.empty? || contained_in?(@dir_stack.last, dir)
        @stream += "\n"
        end_directory
        dir_popped_from_stack = true
      end
      dir_popped_from_stack
    end

    def use_overlay_relative_and_write_entry(use_overlay_relative, overlay_dir, current_dir_empty, entry)
      rpath = overlay_dir_sub_rpath(use_overlay_relative, overlay_dir, entry.r_path)
      unless entry.directory?
        write_entry(entry.v_path.basename, rpath)
        current_dir_empty = false
      end
      current_dir_empty
    end

    def start_directory_or_return(dir, current_dir_empty, use_overlay_relative, overlay_dir, entry)
      if dir == @dir_stack.last
        @stream += ",\n" unless current_dir_empty
      else
        @stream += ",\n" if until_end_directory(dir) || !current_dir_empty
        start_directory(dir)
        current_dir_empty = true
      end
      use_overlay_relative_and_write_entry(use_overlay_relative, overlay_dir, current_dir_empty, entry)
    end
  end
end
