# Copyright (C) The repodata authors.
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

require 'open-uri'
require 'rexml/document'
require_relative 'suserepodumper'
require_relative 'suse2repodumper'
require_relative 'fedorarepodumper'
require_relative 'indexrepodumper'
require_relative 'debianrepodumper'
require_relative 'mageiarepodumper'
require_relative 'mandrivarepodumper'
require_relative 'archrepodumper'
require_relative 'slackwarerepodumper'
require_relative 'pclinuxosrepodumper'
require_relative 'gentoorepodumper'
require_relative 'lfsrepodumper'
require_relative 'jobqueue'

module Repodata

  class Runner
    def repomd_url(url)
      source = open(url) { |file| file.read }
      doc = REXML::Document.new source
      newurl = doc.elements["//data[@type='primary_db']/location/@href"]
      return newurl.to_s unless newurl.nil?

      newurl = doc.elements["//data[@type='primary']/location/@href"]
      return newurl.to_s unless newurl.nil?
    end

    def load_urls(config)
      urls = []

      IO.foreach(config) do |line|
        line.strip!
        if not line =~ /^url\./
            next
        end
        line = line[4..-1].split('=').collect { |e| e.strip! }
        type = line[0]
        url = line[1]

        if url =~ /repomd.xml$/
          url = url.split('/')[0..-3].join('/') + '/' + repomd_url(url)
        end

        if type == "fedora"
            urls << Repodata::FedoraRepoDumper.new(url)
        elsif type == "debian"
            urls << Repodata::DebianRepoDumper.new(url)
        elsif type == "mageia"
            urls << Repodata::MageiaRepoDumper.new(url)
        elsif type == "mandriva"
            urls << Repodata::MandrivaRepoDumper.new(url)
        elsif type == "suse"
            urls << Repodata::SuseRepoDumper.new(url)
        elsif type == "suse2"
            urls << Repodata::Suse2RepoDumper.new(url)
        elsif type == "index"
            urls << Repodata::IndexRepoDumper.new(url)
        elsif type == "arch"
            urls << Repodata::ArchRepoDumper.new(url)
        elsif type == "slackware"
            urls << Repodata::SlackwareRepoDumper.new(url)
        elsif type == "pclinuxos"
            urls << Repodata::PCLinuxOSRepoDumper.new(url)
        elsif type == "gentoo"
            urls << Repodata::GentooRepoDumper.new(url)
        elsif type == "lfs"
            urls << Repodata::LFSRepoDumper.new(url)
        end
      end
      return urls
    end

    def run
      urls = load_urls($*[0])
      task_queue = Repodata::JobQueue.new { |url| url.fetch_if_newer }
      urls.each { |url| task_queue << url }
      task_queue.finish
      task_queue.wait
      urls.each { |url| url.dump }
    end
  end
end
