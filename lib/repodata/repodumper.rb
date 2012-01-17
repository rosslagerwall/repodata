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

      open(@filename, 'w') do |io|
        io.write(res.body)
      end if res.is_a?(Net::HTTPSuccess)
      if res.is_a?(Net::HTTPSuccess) and not res['Last-Modified'].nil?
        File.utime(File.atime(@filename),
                   Time.httpdate(res['Last-Modified']), @filename)
      end
    end

    def dump
      decompress
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
    def decompress
      if @filename =~ /\.bz2$/
        file = Tempfile.new('repodata')
        file.close
        # hack until ruby 1.9+ has a decent bz2 implementation
        system("bzcat #{@filename} > #{file.path}")
        @actual_fn = file.path
      elsif @filename =~ /\.gz$/
        file = Tempfile.new('repodata')
        Zlib::GzipReader.open(@filename) do |gz|
          file.write(gz.read)
        end
        file.close
        @actual_fn = file.path
      else
        @actual_fn = @filename
      end
    end

    def cleanup
      if @filename =~ /\.bz2$/
        File.unlink(@actual_fn)
      elsif @filename =~ /\.gz$/
        File.unlink(@actual_fn)
      end
    end

    def fetch_loop
      parse_filename_from_url
      uri = URI(@url)
      req = Net::HTTP::Get.new(uri.request_uri)
      if File.exists?(@filename)
      file = File.stat(@filename)
        req['If-Modified-Since'] = file.mtime.httpdate
      end
      res = Net::HTTP.start(uri.host, uri.port) { |http| http.request(req) }
      if res.is_a?(Net::HTTPNotModified)
        return res
      elsif res.is_a?(Net::HTTPRedirection)
        @url = res['location']
        return fetch_loop
      else
        return res
      end
    end

    attr_reader :actual_fn
    attr_reader :filename
    attr_reader :url
  end
end
