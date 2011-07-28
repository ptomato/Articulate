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

	public string process(string input) {
		int stdin, stdout, stderr, status;
		Pid child_pid;
		var stdout_output = new StringBuilder();
		var stderr_output = new StringBuilder();
		
		// Start the xsltproc process
		try {
			Process.spawn_async_with_pipes(null, {
				"xsltproc",
				"--html",
				"html2semantic.xslt",
				"-",
				null
			}, null, SpawnFlags.SEARCH_PATH, null,
			out child_pid, out stdin, out stdout, out stderr);
		} catch(Error e) {
			warning("Error starting subprocess: %s", e.message);
			return "";
		}
		var stdout_channel = new IOChannel.unix_new(stdout);
		stdout_channel.add_watch(IOCondition.IN | IOCondition.PRI, 
			(s, c) => { return append_output(s, c, stdout_output); });
		var stderr_channel = new IOChannel.unix_new(stderr);
		stderr_channel.add_watch(IOCondition.IN | IOCondition.PRI,
			(s, c) => { return append_output(s, c, stderr_output); });
		
		if(Posix.write(stdin, input, input.length) == -1) {
			warning("Error writing to subprocess: %s", Posix.strerror(Posix.errno));
		}
		Posix.waitpid(child_pid, out status, 0);
		
		printerr("%s\n", stderr_output.str);
		
		return stdout_output.str;
	}
}
