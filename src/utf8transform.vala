public class UTF8Transform
{
	private struct transform {
		public unichar orig;
		public string latex;
	}
	private const transform[] table = {
		{ 0x0393, "\\Gamma" },
		{ 0x0394, "\\Delta" },
		{ 0x0398, "\\Theta" },
		{ 0x039B, "\\Lambda" },
		{ 0x039E, "\\Xi" },
		{ 0x03A0, "\\Pi" },
		{ 0x03A3, "\\Sigma" },
		{ 0x03A6, "\\Phi" },
		{ 0x03A7, "\\Chi" },
		{ 0x03A8, "\\Psi" },
		{ 0x03A9, "\\Omega" },
		
		{ 0x03B1, "\\alpha" },
		{ 0x03B2, "\\beta" },
		{ 0x03B3, "\\gamma" },
		{ 0x03B4, "\\delta" },
		{ 0x03B5, "\\epsilon" },
		{ 0x03B6, "\\zeta" },
		{ 0x03B7, "\\eta" },
		{ 0x03B8, "\\theta" },
		{ 0x03B9, "\\iota" },
		{ 0x03BA, "\\kappa" },
		{ 0x03BB, "\\lambda" },
		{ 0x03BC, "\\mu" },
		{ 0x03BD, "\\nu" },
		{ 0x03BE, "\\xi" },
		{ 0x03BF, "\\omicron" },
		{ 0x03C0, "\\pi" },
		{ 0x03C1, "\\rho" },
		{ 0x03C2, "\\varsigma" },
		{ 0x03C3, "\\sigma" },
		{ 0x03C4, "\\tau" },
		{ 0x03C5, "\\upsilon" },
		{ 0x03C6, "\\phi" },
		{ 0x03C7, "\\chi" },
		{ 0x03C8, "\\psi" },
		{ 0x03C9, "\\omega" },
		
		{ 0x221A, "\\sqrt" },
		{ 0x221D, "\\propto" },
		{ 0x2248, "\\approx" }
	};
		
	public string process(string input)
	throws RegexError
	{
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

		return output;
	}
}
