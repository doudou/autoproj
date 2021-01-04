require 'autoproj'
require 'autoproj/ops/cached_env'
require 'autoproj/ops/which'
require 'autoproj/ops/watch'

module Autoproj
    module CLI
        class Which
            def initialize
                @root_dir = Autoproj.find_workspace_dir
                if !@root_dir
                    require 'autoproj/workspace'
                    # Will do all sorts of error reporting,
                    # or may be able to resolve
                    @root_dir = Workspace.default.root_dir
                end
            end

            def load_cached_env
                env = Ops.load_cached_env(@root_dir)
                return if !env

                Autobuild::Environment.
                    environment_from_export(env, ENV)
            end

            def run(cmd, use_cached_env: Ops.watch_running?(@root_dir))
                if use_cached_env
                    env = load_cached_env
                end

                if !env
                    require 'autoproj'
                    require 'autoproj/cli/inspection_tool'
                    ws = Workspace.from_dir(@root_dir)
                    loader = InspectionTool.new(ws)
                    loader.initialize_and_load
                    loader.finalize_setup(Array.new)
                    env = ws.full_env.resolved_env
                end

                path = env['PATH'].split(File::PATH_SEPARATOR)
                puts Ops.which(cmd, path_entries: path)
            rescue ExecutableNotFound => e
                require 'autoproj' # make sure everything is available for error reporting
                raise CLIInvalidArguments, e.message, e.backtrace
            rescue Exception
                require 'autoproj' # make sure everything is available for error reporting
                raise
            end
        end
    end
end
