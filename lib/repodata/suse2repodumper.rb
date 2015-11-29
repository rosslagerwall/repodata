# Copyright (C) The repodata authors.
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

require_relative 'repodumper'

module Repodata
  class Suse2RepoDumper < RepoDumper
    private
    def dump_imp
      @file.each do |line|
        begin
          if line =~ /^=Pkg:.* src$/
            line = line.split(' ')
            puts(line[1] + ',,' + line[2] + ',' + line[3])
          end
        end
      end
    end
  end
end
