require 'coveralls'
Coveralls.wear!

require 'minitest/pride'
require 'minitest/autorun'
require 'minitest/spec'

require 'pippi'

if ENV['USE_PIPPI']
  Pippi::AutoRunner.new(:checkset => ENV['PIPPI_CHECKSET'] || "basic")
end
