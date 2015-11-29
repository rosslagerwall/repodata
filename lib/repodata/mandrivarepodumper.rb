# Copyright (C) The repodata authors.
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

require 'rexml/streamlistener'
require_relative 'repodumper'

module Repodata
  class MandrivaRepoDumper < RepoDumper
    private
    def dump_imp
      @file.each do |line|
        begin
          if line =~ /^@info@/
            line = line.split('@')[2]
            line = line[0..-5].split('-')
            puts(line[0..-3].join('-') + ',,' + line[-2] + ',' + line[-1])
          end
        rescue ArgumentError
          # sometimes conatins invalid UTF-8 bytes, ignore
        end
      end
    end
  end
end
