# Copyright (C) The repodata authors.
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

require 'rexml/streamlistener'
require_relative 'repodumper'

module Repodata
  module Mageia
    class PkgXMLStreamListener
      include REXML::StreamListener

      def tag_start(name, attrs)
        if name == 'info'
          fn = attrs['fn'][0..-5].split('-')
          puts(fn[0..-3].join('-') + ',,' + fn[-2] + ',' + fn[-1])
        end
      end
    end
  end

  class MageiaRepoDumper < RepoDumper
    protected
    def dump_imp
      REXML::Document.parse_stream(@file, Mageia::PkgXMLStreamListener.new)
    end
  end
end
