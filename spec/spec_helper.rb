$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minitest/spec'
require 'minitest/autorun'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |file| require file }
