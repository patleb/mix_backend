require 'rubygems/package'
require 'colorize'
require 'dotiw'
require 'open3'
require 'optparse'
require 'ext_ruby'
require 'ext_rake/configuration'
require 'ext_rake/engine' if defined? Rails
require 'mix_notifier'

module ActiveTask
  autoload :Base, 'ext_rake/active_task/base'
end

module ExtRake
  module Pg
    autoload :Psql,      'tasks/ext_rake/pg/psql'
    autoload :Rescuable, 'tasks/ext_rake/pg/rescuable'
  end

  module Vpn
    autoload :Connect, 'tasks/ext_rake/vpn/connect'
  end
end
