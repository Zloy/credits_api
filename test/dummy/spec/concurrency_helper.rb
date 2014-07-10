# Helper method to fork a process with proper database connection.
# This only works on *nix OSes as it relies on pipes to serialize and re-raise exception
# to parent process.
def fork_with_new_connection(config, klass = ActiveRecord::Base)
  readme, writeme = IO.pipe

  pid = Process.fork do
    value = nil
    begin
      klass.establish_connection(config)
      yield
    rescue => e
      value = e
      writeme.write Marshal.dump(value)
      readme.close
      writeme.close
    ensure
      klass.remove_connection
    end

    # Prevent rspec from autorunning in child process
    at_exit { exit! }
  end

  writeme.close
  Process.waitpid(pid)

  content = readme.read
  if content.size > 0 && exception = Marshal.load(content)
    raise exception
  end

  readme.close
end
