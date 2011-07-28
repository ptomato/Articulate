public class SemanticTransform 
{
	public async string process(string input) {
		string output, error_output;
		int status;
		yield Subprocess.run_with_input(
			{ "xsltproc", "--html", "html2semantic.xslt", "-", null },
			input, out output, out error_output, out status);
		printerr("Status: %d Errors: '%s'\n", status, error_output);
		return output;
	}
}
