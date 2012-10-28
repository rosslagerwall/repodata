# Copyright (C) The repodata authors.
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

require 'open-uri'
require 'rexml/document'
require_relative 'xmlrepodumper'
require_relative 'sqlrepodumper'
require_relative 'indexrepodumper'
require_relative 'debrepodumper'
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
        if line =~ /repomd.xml$/
          line = line.split('/')[0..-3].join('/') + '/' + repomd_url(line)
        end

        if line =~ /.xml/
          urls << Repodata::XMLRepoDumper.new(line)
        elsif line =~ /Sources/
          urls << Repodata::DebRepoDumper.new(line)
        elsif line =~ /sqlite/
          urls << Repodata::SQLRepoDumper.new(line)
        elsif line =~ %r{/$}
          urls << Repodata::IndexRepoDumper.new(line)
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
