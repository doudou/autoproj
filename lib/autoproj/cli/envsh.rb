require 'autoproj/cli/inspection_tool'
module Autoproj
    module CLI
        class Envsh < InspectionTool
            def validate_options(args, options = Hash.new)
                _, options = super(args, options)
                [options]
            end

            def run(**options)
                initialize_and_load
                shell_helpers = options.fetch(:shell_helpers, ws.config.shell_helpers?)
                finalize_setup(Array.new)
                export_env_sh(shell_helpers: shell_helpers)
            end
        end
    end
end
