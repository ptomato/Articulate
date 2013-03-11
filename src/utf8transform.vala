using Gee;

public class UTF8Transform
{
	private struct transform {
		public unichar orig;
		public string latex;
	}
	private static const transform[] table = {
		{ 0x0025, "\\%" },
		{ 0x00A0, " " }, // non-breaking space
		// Unfortunately, Google Docs inserts spurious &nbsp;s in the downloaded
		// HTML. Just use regular LaTeX backslash-space in your source document.
		{ 0x00B0, "\\mbox{\\textdegree}" }, // degree sign
		{ 0x00B1, "\\pm " },
		{ 0x00BD, "\\mbox{$\\frac{1}{2}$}" }, // vulgar fraction one-half
		{ 0x00D7, "\\times " }, // multiplication sign
		{ 0x00E9, "\\'{e}" }, // latin small letter e with acute

		{ 0x0393, "\\Gamma " },
		{ 0x0394, "\\Delta " },
		{ 0x0398, "\\Theta " },
		{ 0x039B, "\\Lambda " },
		{ 0x039E, "\\Xi " },
		{ 0x03A0, "\\Pi " },
		{ 0x03A3, "\\Sigma " },
		{ 0x03A6, "\\Phi " },
		{ 0x03A7, "\\Chi " },
		{ 0x03A8, "\\Psi " },
		{ 0x03A9, "\\Omega " },
		
		{ 0x03B1, "\\alpha " },
		{ 0x03B2, "\\beta " },
		{ 0x03B3, "\\gamma " },
		{ 0x03B4, "\\delta " },
		{ 0x03B5, "\\epsilon " },
		{ 0x03B6, "\\zeta " },
		{ 0x03B7, "\\eta " },
		{ 0x03B8, "\\theta " },
		{ 0x03B9, "\\iota " },
		{ 0x03BA, "\\kappa " },
		{ 0x03BB, "\\lambda " },
		{ 0x03BC, "\\mu " },
		{ 0x03BD, "\\nu " },
		{ 0x03BE, "\\xi " },
		{ 0x03BF, "\\omicron " },
		{ 0x03C0, "\\pi " },
		{ 0x03C1, "\\rho " },
		{ 0x03C2, "\\varsigma " },
		{ 0x03C3, "\\sigma " },
		{ 0x03C4, "\\tau " },
		{ 0x03C5, "\\upsilon " },
		{ 0x03C6, "\\varphi " }, // see Unicode Technical Report #25
		{ 0x03C7, "\\chi " },
		{ 0x03C8, "\\psi " },
		{ 0x03C9, "\\omega " },
		{ 0x03D5, "\\phi " },
		
		{ 0x2000, "\\qquad " }, // en quad (1/2 em x 4 = 2 em)
		{ 0x2003, "\\quad " }, // em space
		{ 0x2004, "\\ " }, // three-per-em space
		{ 0x2006, "\\," }, // six-per-em space
		{ 0x2012, "--" }, // figure dash
		{ 0x2013, "--" }, // en dash
		{ 0x2014, "---" }, // em dash
		{ 0x2018, "`" }, // left single quote
		{ 0x2019, "'" }, // right single quote
		{ 0x201C, "``" }, // left double quote
		{ 0x201D, "''" }, // right double quote
		{ 0x2032, "'" }, // prime
		{ 0x2033, "''" }, // double prime
		{ 0x205F, "\\:" }, // medium mathematical space (4/18 em)
		{ 0x207A, "$^+$" }, // text mode, superscript plus
		{ 0x2081, "$_1$" }, // text mode, subscript one
		{ 0x2082, "$_2$" }, // text mode, subscript two
		{ 0x2083, "$_3$" }, // text mode, subscript three
		{ 0x2084, "$_4$" }, // text mode, subscript four

		{ 0x210F, "\\hbar " },
		{ 0x2192, "\\to " }, // rightwards arrow
		{ 0x21D2, "\\implies " }, // rightwards double arrow

		{ 0x2202, "\\partial " }, // partial differential
		{ 0x220F, "\\prod " }, // n-ary product
		{ 0x2211, "\\sum " }, // n-ary summation
		{ 0x2212, "-" }, // math mode, minus sign
		{ 0x221A, "\\sqrt " },
		{ 0x221D, "\\propto " },
		{ 0x221E, "\\infty" }, // infinity
		{ 0x2245, "\\cong" }, // approximately equal to
		{ 0x2248, "\\approx " }, // almost equal to
		{ 0x226A, "\\ll " }, // much less-than
		{ 0x226B, "\\gg " }, // much greater-than
		{ 0x22A5, "\\perp " }, // up tack

		{ 0x23B7, "\\sqrt " }, // radical symbol bottom

		// Use ornamental delimiters for paired LaTeX versions?
		{ 0x2768, "\\left(" }, // medium left parenthesis ornament
		{ 0x2769, "\\right)" }, // medium right parenthesis ornament

		// Use Unicode full-width delimiters for paired LaTeX versions?
		{ 0xFF08, "\\left(" },
		{ 0xFF09, "\\right)" },
		{ 0xFF3B, "\\left[" },
		{ 0xFF3D, "\\right]" },
		{ 0xFF5B, "\\left\\{" },
		{ 0xFF5D, "\\right\\}" }
	};
		
	public static string process(string input, HashMap<string, File> image_list)
	throws RegexError
	{
		image_list.clear();

		string output = input;
		foreach(var pair in table) {
			output = output.replace(pair.orig.to_string(), pair.latex);
		}
		
		var quantity_regex = /(?P<quantity>[0-9]+(?:\.[0-9]+)?) (?P<unit>[dcmµn]m)/;
		output = quantity_regex.replace_eval(output, -1, 0, 0, (info, builder) => {
			var quantity = info.fetch_named("quantity");
			var unit = info.fetch_named("unit");
			if(unit == "µm")
				unit = "\\micro m";
			builder.append(@"$$$quantity\\unit{$unit}$$");
			return false; // continue replacement process
		});

		var image_regex = new Regex("""(?P<part1>\\begin{figure}.*?\\includegraphics(\[.*?\])?{)(?P<uri>.*?)(?P<part2>}.*?\\label{(?P<label>.*?)}.*?\\end{figure})""", RegexCompileFlags.DOTALL);
		output = image_regex.replace_eval(output, -1, 0, 0, (info, builder) => {
			var uri = info.fetch_named("uri");
			var label = info.fetch_named("label");
			var part1 = info.fetch_named("part1");
			var part2 = info.fetch_named("part2");
			var file = File.new_for_uri(uri);
			image_list.set(label, file);
			builder.append(@"$part1$label$part2");
			return false; // continue
		});

		return output;
	}
}
