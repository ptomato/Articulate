public class SemanticTransform 
{
	private static bool append_output(IOChannel source, IOCondition condition, StringBuilder builder) {
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

	public async string process(string input) {
		int stdin, stdout, stderr, status = 0;
		Pid child_pid;
		
		// Start the xsltproc process
		try {
			Process.spawn_async_with_pipes(null,
				{ "xsltproc", "--html", "html2semantic.xslt", "-", null }, 
				null, SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD, null,
				out child_pid, out stdin, out stdout, out stderr);
		} catch(Error e) {
			warning("Error starting subprocess: %s", e.message);
			return "";
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
			status = code;
			process.callback();
		});
		yield;
		Process.close_pid(child_pid);

		printerr("Status: %d Errors: '%s'\n", Process.exit_status(status), stderr_output.str);

		return stdout_output.str;
	}
}
