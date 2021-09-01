# frozen_string_literal: true

# The primary namespace for VFS.
module VFS
  require 'colored2'
  require 'claide'
  # The primary Command for VFS.
  class Command < CLAide::Command
    require 'yaml-vfs/command/yaml_vfs_writer'

    self.abstract_command = false
    self.command = 'vfs'
    self.version = VERSION
    self.description = 'VFS lets you create clang "-ivfsoverlay" ymal file,  map virtual path to real path.'
    self.plugin_prefixes = %w[claide yaml_vfs_writer]

    def initialize(argv)
      super
      return if ansi_output?

      Colored2.disable!
      String.send(:define_method, :colorize) { |string, _| string }
    end
  end
end
