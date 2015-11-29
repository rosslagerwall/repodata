# Copyright (C) The repodata authors.
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

require_relative 'repodumper'

module Repodata
  class IndexRepoDumper < RepoDumper
    protected
    def parse_filename_from_url
      @filename = @url.split('/')[3..-1].join('/')
      @filename << "index.html"
    end

    def dump_imp
      @file.each do |line|
        match = /href=".+?.src.rpm"/.match(line)
        if match
          fn = match[0][6..-10].split('-')
          puts(fn[0..-3].join('-') + ',,' + fn[-2] + ',' + fn[-1])
        end
      end
    end
  end
end
