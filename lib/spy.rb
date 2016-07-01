require 'spy/version'
require 'spy/api'

# Top-level module that implements the Spy::API
#
# Spy::API was pulled out to make it easy to create multiple
# different modules that implement Spy::API (which effectively
# namespaces the spies)
module Spy
  extend API
end
