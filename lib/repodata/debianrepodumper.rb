# Copyright (C) The repodata authors.
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

require_relative 'repodumper'

module Repodata
  class DebianRepoDumper < RepoDumper
    private
    def dump_imp
      @file.each do |line|
        begin
          print(line.strip[9..-1] + ',') if line =~ /^Package:/
          if line =~ /^Version:/
            line = line.strip[9..-1]

            if line =~ /:/
              # try parse epoch
              line = line.split(':')
              epoch = Integer(line[0]).to_s rescue ''
              print(epoch + ',')
              if epoch == ''
                line = line.join(':')
              else
                line = line[1..-1].join(':')
              end
            else
              print(',')
            end

            line = line.split('-')
            if line.length > 1
              puts(line[0..-2].join('-') + ',' + line[-1])
            else
              puts(line[0] + ',')
            end
          end
        rescue ArgumentError
          # sometimes conatins invalid UTF-8 bytes, ignore
        end
      end
    end
  end
end
