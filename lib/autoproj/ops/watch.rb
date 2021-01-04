module Autoproj
    module Ops
        def self.watch_marker_path(root_dir)
            File.join(root_dir, '.autoproj', 'watch')
        end

        def self.watch_running?(root_dir)
            io = File.open(watch_marker_path(root_dir))
            !io.flock(File::LOCK_EX | File::LOCK_NB)
        rescue Errno::ENOENT
            false
        ensure
            io.close if io
        end

        class WatchAlreadyRunning < RuntimeError; end

        def self.watch_create_marker(root_dir)
            io = File.open(watch_marker_path(root_dir), 'a+')
            if !io.flock(File::LOCK_EX | File::LOCK_NB)
                raise WatchAlreadyRunning, "autoproj watch is already running as PID #{io.read.strip}"
            end

            io.truncate(0)
            io.puts Process.pid
            io.flush
        rescue Exception
            io.close if io
            raise
        end

        def self.watch_cleanup_marker(io)
            FileUtils.rm_f io.path
            io.close
        end
    end
end
