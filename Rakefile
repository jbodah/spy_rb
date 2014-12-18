require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*test.rb']
  t.verbose = true
end

task :default => [:test]

desc 'rm all *.gem files'
task :clean do
  require 'fileutils'
  FileUtils.rm Dir.glob('*.gem')
end

desc 'build gem'
task :build do
  gemspec = Dir.glob('*.gemspec').first
  system "gem build #{gemspec}"
end

desc 'build gem and push it to rubygems'
task :deploy => [:clean, :build] do
  gem = Dir.glob('*.gem')
  system "gem push #{gem}"
end

task :change_version do
  version_file = 'lib/spy/version.rb'
  text = File.read(version_file).gsub(/[\d\.]+/, ENV['TO'])
  File.open(version_file, 'w') {|f| f.puts text}
end
