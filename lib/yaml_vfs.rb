# frozen_string_literal: true

# The primary namespace for yaml-vfs.
module VFS
  require 'pathname'
  require 'claide'

  class PlainInformative < StandardError
    include CLAide::InformativeError
  end

  # Informative
  class Informative < PlainInformative
    def message
      super !~ /\[!\]/ ? "[!] #{super}\n".red : super
    end
  end

  require_relative 'yaml-vfs/version'
  require_relative 'yaml-vfs/utils'


  autoload :FileCollector, 'yaml-vfs/file_collector'
  autoload :Command, 'yaml-vfs/command'
end
