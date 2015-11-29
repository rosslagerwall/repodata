# Copyright (C) The repodata authors.
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

require 'net/http'
require 'fileutils'
require 'time'
require 'tempfile'

module Repodata
  class RepoDumper
    def initialize(url)
      @url = url
      parse_filename_from_url
    end

    def fetch_if_newer
      res = fetch_loop

      make_dirs

      open(@filename, 'w') do |io|
        io.write(res.body)
      end if res.is_a?(Net::HTTPSuccess)
      if res.is_a?(Net::HTTPSuccess) and not res['Last-Modified'].nil?
        File.utime(File.atime(@filename),
                   Time.httpdate(res['Last-Modified']), @filename)
      end
    end

    def dump
      open_file
      dump_imp
      cleanup
    end

    protected
    def parse_filename_from_url
      @filename = @url.split('/')[3..-1].join('/')
    end

    def make_dirs
      dirs = @url.split('/')[3..-2].join('/')
      FileUtils.mkdir_p(dirs)
    end

    private
    def open_file
      @remove_path = nil
      if @filename =~ /\.bz2$/
        file = Tempfile.new('repodata')
        path = file.path
        file.close!
        system("bzcat #{@filename} > #{path}")
        @file = File.new(path)
        @remove_path = path
      elsif @filename =~ /\.lzma$/
        file = Tempfile.new('repodata')
        path = file.path
        file.close!
        if not system("lzcat #{@filename} > #{path} 2> /dev/null")
          system("xzcat #{@filename} > #{path}")
        end
        @file = File.new(path)
        @remove_path = path
      elsif @filename =~ /\.xz$/
        file = Tempfile.new('repodata')
        path = file.path
        file.close!
        system("xzcat #{@filename} > #{path}")
        @file = File.new(path)
        @remove_path = path
      elsif @filename =~ /\.[cg]z$/
        @file = Zlib::GzipReader.open(@filename)
      else
        @file = File.new(@filename)
      end
    end

    def cleanup
      @file.close
      File.unlink(@remove_path) if @remove_path
    end

    def fetch_loop
      parse_filename_from_url
      uri = URI(@url)
      req = Net::HTTP::Get.new(uri.request_uri)
      if File.exists?(@filename)
      file = File.stat(@filename)
        req['If-Modified-Since'] = file.mtime.httpdate
      end
      res = Net::HTTP.start(uri.host, uri.port,
                            :use_ssl => uri.scheme == 'https') do |http|
        http.request(req)
      end
      if res.is_a?(Net::HTTPNotModified)
        return res
      elsif res.is_a?(Net::HTTPRedirection)
        @url = res['location']
        return fetch_loop
      else
        return res
      end
    end

    attr_reader :file
    attr_reader :filename
    attr_reader :url
  end
end
