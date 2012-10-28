# Copyright (C) The repodata authors.
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

require 'rexml/streamlistener'
require_relative 'repodumper'

module Repodata
  class PkgXMLStreamListener
    include REXML::StreamListener

    def initialize
      @state = 0
    end

    def tag_start(name, attrs)
      if name == 'package'
        @state = 1
      elsif name == 'name'
        @state = 2
        @pname = ''
      elsif name == 'arch'
        @state = 3
        @arch = ''
      elsif name == 'version'
        @version = "#{attrs['ver']}-#{attrs['rel']}"
      end
    end

    def tag_end(name)
      if @state == 2
        @state = 1
      elsif @state == 3
        @state = 1
      elsif @state == 1
        @state = 0
        puts("#{@pname}-#{@version}") if @arch == 'src'
      end
    end

    def text(text)
      if @state == 2
        @pname << text.strip
      elsif @state == 3
        @arch << text.strip
      end
    end
  end

  class XMLRepoDumper < RepoDumper
    protected
    def dump_imp
      REXML::Document.parse_stream(File.new(@actual_fn),
                                   PkgXMLStreamListener.new)
    end
  end
end
