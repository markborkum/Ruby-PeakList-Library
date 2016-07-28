Gem::Specification.new do |s|
  s.name        = 'peaklist'
  s.version     = '0.0.2'
  s.date        = '2016-07-27'
  s.summary     = 'peaklist'
  s.description = 'Data types and parser for PeakList.xml documents'
  s.authors     = ['Scott Howland', 'Mark Borkum']
  s.email       = 'scott.howland@pnnl.gov'
  s.files       = ['lib/bruker.rb']
  s.test_files  = Dir.glob('test/test_*.rb')
  s.homepage    = 'https://github.com/megultron/Ruby-PeakList-Library'
  s.license     = 'ECL-2.0'
  s.add_runtime_dependency 'nokogiri', ['>= 1.6']
end
