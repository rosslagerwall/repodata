# Copyright (C) The repodata authors.
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

require_relative 'repodumper'

module Repodata
  class LFSRepoDumper < RepoDumper
    private
    def dump_imp
      @file.each do |line|
        begin
          line.rstrip!
          next if line =~ /\.patch$/

          last = line.rindex('/')
          next if last.nil?
          line = line[last + 1..-1]

          line = line[0..-$&.length - 1] if line =~ /\.(bz2|xz|lzma|gz)$/
          line = line[0..-$&.length - 1] if line =~ /\.tar$/
          line = line[0..-$&.length - 1] if line =~ /\.zip$/
          line = line[0..-$&.length - 1] if line =~ /\.tgz$/

          last = line.rindex('-')
          next if last.nil?
          version = line[last + 1..-1]
          line = line[0..last - 1]

          puts "#{line},,#{version},"
        end
      end
    end
  end
end
