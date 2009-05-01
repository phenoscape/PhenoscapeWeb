#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby

## FIXME this is one of three files two of which are nearly identical
## and all of which contain a hard-coded path name that will only work
## for MacOSX server. If they can be removed they should be.

require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)

# If you're using RubyGems and mod_ruby, this require should be changed to an absolute path one, like:
# "/usr/local/lib/ruby/gems/1.8/gems/rails-0.8.0/lib/dispatcher" -- otherwise performance is severely impaired
require "dispatcher"

ADDITIONAL_LOAD_PATHS.reverse.each { |dir| $:.unshift(dir) if File.directory?(dir) } if defined?(Apache::RubyRun)
Dispatcher.dispatch
