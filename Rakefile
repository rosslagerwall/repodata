require 'rubygems/package_task'

spec = Gem::Specification.new do |s| 
  s.name       = "repodata"
  s.summary    = "Get distro package names and versions"
  s.description= File.read(File.join(File.dirname(__FILE__), 'README'))
  s.requirements = []
  s.version     = "0.0.1"
  s.author      = "Ross Lagerwall"
  s.email       = "rosslagerwall@gmail.com"
  s.homepage    = "http://github.com/rosslagerwall/repodata"
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>=1.9'
  s.files       = Dir['**/**']
  s.executables = [ 'repodata' ]
  s.test_files  = Dir["test/test*.rb"]
  s.has_rdoc    = false
  s.add_dependency('sqlite3', '>= 1.3.3')
end
 
Gem::PackageTask.new(spec).define
