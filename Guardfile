guard :minitest do
  watch(%r{^test/(.*)_test.rb$})          { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^lib/.*\.rb$})                 { |m| "test/spy_test.rb" }
  watch(%r{^test/test_helper\.rb$})       { 'test' }
end
