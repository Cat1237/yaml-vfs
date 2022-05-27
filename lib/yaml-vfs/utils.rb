# frozen_string_literal: false

module VFS
  # A collection of utility functions used throughout vfs.
  module Utils
    def self.traversal_component?(component)
      component.each_filename.include?('.') || component.each_filename.include?('..')
    end
  end
end

String.class_eval do
  def indent(count, char = ' ')
    gsub(/([^\n]*)(\n|$)/) do
      last_iteration = (Regexp.last_match(1) == '' && Regexp.last_match(2) == '')
      line = ''
      line << (char * count) unless last_iteration
      line << Regexp.last_match(1)
      line << Regexp.last_match(2)
      line
    end
  end
end
