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
      IO.foreach(@actual_fn) do |line|
        match = /href=".+?.src.rpm"/.match(line)
        puts(match[0][6..-10]) if match
      end
    end
  end
end
