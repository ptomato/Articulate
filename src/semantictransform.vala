public class SemanticTransform 
{
	public string process(string input)
	throws IOError
	{
		Exslt.register_all();

		var document = Html.parse_doc(input);
		var stylesheet = Xslt.parse_stylesheet_file("html2semantic.xslt");
		var result = stylesheet->apply(document, {});

		if(result == null)
			throw new IOError.FAILED("Error applying stylesheet to HTML");

		string output;
		int length;
		int res = stylesheet->save_result_to_string(out output, out length, result);

		if(res == -1)
			throw new IOError.FAILED("Error saving result to string");

		return output;
	}
}
