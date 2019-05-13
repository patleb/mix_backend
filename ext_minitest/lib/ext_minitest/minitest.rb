### Documentation
# http://mattsears.com/articles/2011/12/10/minitest-quick-reference/
# http://docs.seattlerb.org/minitest/Minitest/Expectations.html

require 'minitest/spec'
require 'minitest/hooks'
require 'mocha/minitest'
require 'webmock/minitest'
require 'maxitest/threads'
require "maxitest/let_bang"
require "maxitest/let_all"
require "maxitest/pending"
require "maxitest/static_class_order"
require 'diffy'
require 'minitest/reporters'

Minitest::Reporters.use!

require 'ext_minitest/minitest/test'
require 'ext_minitest/minitest/spec'
require 'ext_minitest/minitest/assertions'

Minitest::UnexpectedError.class_eval do
  alias_method :old_message, :message
  def message
    old_message.split("\n").first(1).concat(backtrace).join("\n")
  end
end

require 'ext_minitest/patch/test_case'
