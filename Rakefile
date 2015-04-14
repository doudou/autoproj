require 'utilrb/rake_common'
$LOAD_PATH.unshift File.join(Dir.pwd, 'lib')

task 'default'
Utilrb::Rake.hoe do
    namespace 'dist' do
        Hoe.spec 'autoproj' do
            self.developer "Rock Core Developers", "rock-dev@dfki.de"

            self.urls = ["http://rock-robotics.org/documentation/autoproj"]
            self.group_name = 'autobuild'
            self.summary = 'Easy installation and management of sets of software packages'
            self.description = "autoproj is a manager for sets of software packages. It allows the user to import and build packages from source, still using the underlying distribution's native package manager for software that is available on it."
            self.email = "rock-dev@dfki.de"

            self.spec_extras[:required_ruby_version] = ">= 1.9.2"

            license 'BSD'

            extra_deps << 
                ['autobuild',   '~> 1.9', '>= 1.9.0'] <<
                ['utilrb', '~> 2.0', '>= 2.0.0'] <<
                ['highline', '~> 1.7', '>= 1.7.0']
        end
    end
end

namespace 'dist' do
    desc "generate the bootstrap script"
    task 'bootstrap' do
        require 'yaml'
        build_option_code = File.read(File.join(Dir.pwd, 'lib', 'autoproj', 'build_option.rb'))
        config_code = File.read(File.join(Dir.pwd, 'lib', 'autoproj', 'configuration.rb'))
        osdeps_code = File.read(File.join(Dir.pwd, 'lib', 'autoproj', 'osdeps.rb'))
        system_code = File.read(File.join(Dir.pwd, 'lib', 'autoproj', 'system.rb'))
        osdeps_defaults = File.read(File.join(Dir.pwd, 'lib', 'autoproj', 'default.osdeps'))
        require 'autobuild'
        tools_code = File.read(File.join(Autobuild::LIB_DIR, 'autobuild', 'tools.rb'))
        # Filter rubygems dependencies from the OSdeps default. They will be
        # installed at first build
        osdeps = YAML.load(osdeps_defaults)
        osdeps.delete_if do |name, content|
            if content.respond_to?(:delete)
                content.delete('gem')
                content.empty?
            else
                content == 'gem'
            end
        end
        osdeps_defaults = YAML.dump(osdeps)
        # Since we are using gsub to replace the content in the bootstrap file,
        # we have to quote all \
        [osdeps_code, system_code, osdeps_defaults, tools_code].each do |text|
            text.gsub! /\\/, '\\\\\\\\'
        end

        bootstrap_code = File.read(File.join(Dir.pwd, 'bin', 'autoproj_bootstrap.in')).
            gsub('BUILD_OPTION_CODE', build_option_code).
            gsub('CONFIG_CODE', config_code).
            gsub('OSDEPS_CODE', osdeps_code).
            gsub('SYSTEM_CODE', system_code).
            gsub('OSDEPS_DEFAULTS', osdeps_defaults).
            gsub('TOOLS_CODE', tools_code)
        File.open(File.join(Dir.pwd, 'bin', 'autoproj_bootstrap'), 'w') do |io|
            io.write bootstrap_code
        end
    end
end
file 'bin/autoproj_bootstrap' => 'dist:bootstrap'

Utilrb::Rake.rdoc do
    task 'doc' => 'doc:all'
    task 'clobber_docs' => 'doc:clobber'
    task 'redocs' do
        Rake::Task['doc:clobber'].invoke
        Rake::Task['doc'].invoke
    end

    namespace 'doc' do
        task 'all' => %w{api}
        task 'clobber' => 'clobber_api'
        RDoc::Task.new("api") do |rdoc|
            rdoc.rdoc_dir = 'doc'
            rdoc.title    = "autoproj"
            rdoc.options << '--show-hash'
            rdoc.rdoc_files.include('lib/**/*.rb')
        end
    end
end


