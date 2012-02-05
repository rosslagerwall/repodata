require_relative 'repodumper'

module Repodata
  class DebRepoDumper < RepoDumper
    private
    def dump_imp
      IO.foreach(@actual_fn) do |line|
        begin
          print(line.strip[9..-1] + '_') if line =~ /^Package:/
          puts(line.strip[9..-1]) if line =~ /^Version:/
        rescue ArgumentError
          # sometimes conatins invalid UTF-8 bytes, ignore
        end
      end
    end
  end
end
