# Copyright (C) The repodata authors.
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

require 'fileutils'

module Repodata
  class GentooRepoDumper
    def initialize(url)
      @url = url
    end

    def fetch_if_newer
      FileUtils.mkdir_p("gentoo")
      Dir.chdir("gentoo") do
        system("rsync -mrtv --no-motd --delete-after --no-p --no-o --no-g #{@url} . 2>&1 > /dev/null")
      end
    end

    def dump
      Dir["gentoo/**/*"].each do |f|
        next if f !~ /\.ebuild$/
        next if f =~ /^gentoo\/virtual\//

        version = ''
        release = ''

        f = File.basename f[0..-8]
        release = $&[1..-1] if f =~ /-r[0-9]+/
        f = f[0..-release.length - 2] if release.length > 0
        last = f.rindex('-')
        version = f[last + 1..-1] unless last.nil?
        f = f[0..-version.length - 2] if version.length > 0
        puts "#{f},,#{version},#{release}"
      end
    end

    attr_reader :url
  end
end
