# Copyright (C) The repodata authors.
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

require 'fileutils'

module Repodata
  class ArchRepoDumper
    def initialize(url)
      @url = url
    end

    def fetch_if_newer
      FileUtils.mkdir_p("arch")
      Dir.chdir("arch") do
        system("rsync -mrtv --no-motd --delete-after --no-p --no-o --no-g #{@url} . 2>&1 > /dev/null")
      end
    end

    def dump
      Dir["arch/*/*"].each do |repo|
        next if repo =~ /staging|testing|unstable|multilib/

        Dir.foreach(repo) do |pkg|
          next if pkg == '.' or pkg == '..'

          pkgbuild = File.join(repo, pkg, 'PKGBUILD')
          cmd = "source #{pkgbuild}
                 echo ${pkgname[@]}
                 echo ${pkgbase[@]}
                 echo $epoch
                 echo $pkgver
                 echo $pkgrel"
          res = `bash -c '#{cmd}'`.split("\n").map(&:strip)
          pkgname = res[1] # use pkgbase if it exists
          pkgname = res[0] if pkgname == '' # otherwise use pkgname
          pkgname = pkg if pkgname =~ / / # use dirname if pkgname is an array
          puts "#{pkgname},#{res[2]},#{res[3]},#{res[4]}"
        end
      end
    end

    attr_reader :url
  end
end
