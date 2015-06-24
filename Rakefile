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

desc 'install local gem'
task :install_local do
  gem = Dir.glob('*.gem').first
  system "gem install #{gem} --local"
end

desc 'build gem and push it to rubygems'
task :deploy => [:clean, :build] do
  gem = Dir.glob('*.gem').first
  system "gem push #{gem}"
end

desc 'runs through entire deploy process'
task :full_deploy => [:test, :change_version] do
  system "git push && git push --tags"
  Rake::Task['deploy'].invoke
end

task :change_version do
  raise "Version required: ENV['TO']" unless ENV['TO']

  puts 'Checking for existing tag'
  raise "Tag '#{ENV['TO']}' already exists!" unless `git tag -l $TO`.empty?

  puts "Updating version.rb to '#{ENV['TO']}'"
  version_file = 'lib/spy/version.rb'
  before_text = File.read(version_file)
  text = before_text.gsub(/[\d\.]+/, ENV['TO'])
  raise "Aborting: Version didn't change" if text == before_text
  File.open(version_file, 'w') {|f| f.puts text}

  puts 'Committing version.rb'
  exit(1) unless system "git add lib/spy/version.rb"
  exit(1) unless system "git commit -m 'bump to version #{ENV['TO']}'"
  exit(1) unless system "git tag #{ENV['TO']}"

  puts "Tag '#{ENV['TO']}' generated. Don't forget to push --tags! :)"
end
