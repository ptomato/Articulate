public class SemanticTransform 
{
	private string italic_class = "c1";
	private string subscript_class = "c2";
	private string superscript_class = "c3";

	public string process(string input)
	throws IOError
	{
		// Peek in the CSS to see which classes represent italics, subscript,
		// and superscript
		MatchInfo info;
		try {
			var css_regex = new Regex("""<style type="text/css">(.*)</style>""");
			if(css_regex.match(input, 0, out info)) {
				var css = info.fetch(1);
				var class_regex = new Regex("""\.(c[0-9]){(.*?)}""");

				class_regex.match(css, 0, out info);
				while(info.matches()) {
					var type = info.fetch(2);
					if(type == "font-style:italic")
						italic_class = info.fetch(1);
					else if("vertical-align:sub" in type)
						subscript_class = info.fetch(1);
					else if("vertical-align:super" in type)
						superscript_class = info.fetch(1);
					info.next();
				}
			}
		} catch(Error e) { } // ignore error

		Exslt.register_all();

		var document = Html.parse_doc(input);
		var stylesheet = Xslt.parse_stylesheet_file("html2semantic.xslt");
		var result = stylesheet->apply(document, {
			"italic-class", @"'$italic_class'",
			"subscript-class", @"'$subscript_class'",
			"superscript-class", @"'$superscript_class'"
		});

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
