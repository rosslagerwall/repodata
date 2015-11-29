# Copyright (C) The repodata authors.
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

require_relative 'repodumper'

module Repodata
  class SlackwareRepoDumper < RepoDumper
    protected
    def dump_imp
      @file.each do |line|
        begin
          if line =~ /^PACKAGE NAME:  /
            line = line.strip[15..-5].split('-')
            puts "#{line[0..-4].join('-')},,#{line[-3]},#{line[-1]}"
          end
        rescue ArgumentError
          # sometimes conatins invalid UTF-8 bytes, ignore
        end
      end
    end
  end
end
