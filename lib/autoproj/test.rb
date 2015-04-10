# simplecov must be loaded FIRST. Only the files required after it gets loaded
# will be profiled !!!
if ENV['TEST_ENABLE_COVERAGE'] == '1'
    begin
        require 'simplecov'
        SimpleCov.start
    rescue LoadError
        require 'dummy_project'
        Autoproj.warn "coverage is disabled because the 'simplecov' gem cannot be loaded"
    rescue Exception => e
        require 'dummy_project'
        Autoproj.warn "coverage is disabled: #{e.message}"
    end
end

require 'autoproj'
## Uncomment this to enable flexmock
require 'flexmock/test_unit'
require 'minitest/spec'

if ENV['TEST_ENABLE_PRY'] != '0'
    begin
        require 'pry'
    rescue Exception
        Autoproj.warn "debugging is disabled because the 'pry' gem cannot be loaded"
    end
end

module Autoproj
    # This module is the common setup for all tests
    #
    # It should be included in the toplevel describe blocks
    #
    # @example
    #   require 'rubylib/test'
    #   describe Autoproj do
    #     include Autoproj::SelfTest
    #   end
    #
    module SelfTest
        if defined? FlexMock
            include FlexMock::ArgumentTypes
            include FlexMock::MockContainer
        end

        def setup
            @tmpdir = Array.new
            super
        end

        def create_bootstrap
            dir = Dir.mktmpdir
            @tmpdir << dir
            require 'autoproj/ops/main_config_switcher'
            FileUtils.cp_r Ops::MainConfigSwitcher::MAIN_CONFIGURATION_TEMPLATE, File.join(dir, 'autoproj')
            Autoproj.root_dir = dir
            Autoproj.manifest = Manifest.load(File.join(dir, 'autoproj', 'manifest'))
        end

        def teardown
            if defined? FlexMock
                flexmock_teardown
            end
            super
            @tmpdir.each do |dir|
                FileUtils.remove_entry_secure dir
            end
            Autobuild::Package.clear
        end
    end
end

class Minitest::Test
    include Autoproj::SelfTest
end

