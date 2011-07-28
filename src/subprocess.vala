namespace Subprocess
{
	private bool append_output(IOChannel source, IOCondition condition, StringBuilder builder) {
		string text;
		size_t length;
		try {
			source.read_to_end(out text, out length);
		} catch(Error e) {
			warning("Error reading from subprocess: %s", e.message);
			return false;
		}
		builder.append(text);
		return true;
	}
	
	public async void run_with_input(string[] argv, string input, out string output, out string error_output, out int status) {
		int stdin, stdout, stderr, _status = 0;
		Pid child_pid;
		
		// Start the subprocess
		try {
			Process.spawn_async_with_pipes(null, argv, null, 
				SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD, null,
				out child_pid, out stdin, out stdout, out stderr);
		} catch(Error e) {
			warning("Error starting subprocess: %s", e.message);
			return;
		}

		// Set up I/O channels
		var stdout_channel = new IOChannel.unix_new(stdout);
		var stdout_output = new StringBuilder();
		stdout_channel.add_watch(IOCondition.IN | IOCondition.PRI, 
			(s, c) => append_output(s, c, stdout_output));

		var stderr_channel = new IOChannel.unix_new(stderr);
		var stderr_output = new StringBuilder();
		stderr_channel.add_watch(IOCondition.IN | IOCondition.PRI,
			(s, c) => append_output(s, c, stderr_output));

		// Write the HTML code to the xsltproc's stdin
		if(Posix.write(stdin, input, input.length) == -1) {
			warning("Error writing to subprocess: %s", Posix.strerror(Posix.errno));
		}
		Posix.close(stdin);

		// Wait for xsltproc to finish
		ChildWatch.add(child_pid, (pid, code) => {
			_status = Process.exit_status(code);
			run_with_input.callback();
		});
		yield;
		Process.close_pid(child_pid);

		status = _status;
		output = stdout_output.str;
		error_output = stderr_output.str;
	}
}
