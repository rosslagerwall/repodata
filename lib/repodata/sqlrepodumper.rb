# Copyright (C) The repodata authors.
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

require 'sqlite3'
require_relative 'repodumper'

module Repodata
  class SQLRepoDumper < RepoDumper
    protected
    def dump_imp
      SQLite3::Database.open(@actual_fn) do |db|
        db.execute('SELECT name,version,release,time_build ' +
                   'FROM packages') { |row| puts(row[0..-2].join('-')) }
      end
    end
  end
end
