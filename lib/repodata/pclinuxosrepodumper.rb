# Copyright (C) The repodata authors.
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

require_relative 'repodumper'

module Repodata
  class PCLinuxOSRepoDumper < RepoDumper
    private
    def dump_imp
      header_magic = "\x8E\xAD\xE8\x01".b
      while true
        header = @file.read(16)
        break if header.nil?
        raise TypeError if header[0..3] != header_magic

        _, n, len = header[4..-1].unpack('NNN')

        pos = [-1, -1, -1]
        epochpos = -1
        (1..n).each do
          index = @file.read(16)
          tag, dtype, offset, dcount = index.unpack('NNNN')
          pos[tag - 1000] = offset if tag >= 1000 and tag <= 1002
          epochpos = offset if tag == 1003
        end

        data = @file.read(len)
        output = ['', '', '']
        pos.each_index { |i| output[i] = data[pos[i]..-1].unpack('Z*')[0] unless pos[i] == -1 }
        epoch = if epochpos == -1 then 0 else data[epochpos..-1].unpack('N')[0] end
        puts "#{output[0]},#{epoch},#{output[1]},#{output[2]}"
      end
    end
  end
end
