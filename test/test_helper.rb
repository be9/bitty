require 'rubygems'
require 'test/unit'
require 'context'
require 'matchy'
require 'active_support'
require 'active_record'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'bitty'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :dbfile => 'test.sqlite3')

#class Test::Unit::TestCase
#end

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
