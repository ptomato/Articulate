public class LaTeXTransform 
{
	public static string process(string input, string preamble)
	throws IOError
	{
		var document = Xml.Parser.parse_doc(input);
		var stylesheet = Xslt.parse_stylesheet_file("semantic2latex.xslt");
		var result = stylesheet->apply(document, {
			"preamble-commands", @"'$preamble'"
		});

		if(result == null)
			throw new IOError.FAILED("Error applying stylesheet to XML");

		string output;
		int length;
		int res = stylesheet->save_result_to_string(out output, out length, result);

		if(res == -1)
			throw new IOError.FAILED("Error saving result to string");

		return output;
	}
}
