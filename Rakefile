require 'rake'
require 'rake/rdoctask'

desc 'Generate documentation for Redmime Warbler plugin.'
Rake::RDocTask.new(:doc) do |doc|
  doc.rdoc_dir = 'doc'
  doc.title = 'Redmine Warbler'
  doc.options << '--line-numbers' << '--inline-source'
  doc.rdoc_files.include('README.rdoc')
  doc.rdoc_files.include('Changelog.rdoc')
  # doc.rdoc_files.include('lib/**/*.rb')
end
