# Copyright (C) The repodata authors.
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

require 'sqlite3'
require 'tempfile'
require_relative 'repodumper'

module Repodata
  class FedoraRepoDumper < RepoDumper
    protected
    def dump_imp
      file_contents = @file.read
      tmpfile = Tempfile.new('repodata')
      tmpfile.write(file_contents)
      tmpfile.flush

      SQLite3::Database.open(tmpfile.path) do |db|
        db.execute('SELECT name,epoch,version,release FROM packages') do |row|
          puts("#{row[0]},#{row[1]},#{row[2]},#{row[3]}")
        end
      end

      tmpfile.close!
    end
  end
end
