using Gtk;

/* Enumeration for intermediate representations of the document */
public enum Repr {
	RAW_HTML,
	SEMANTIC_XML,
	LATEX_UTF8_INSERTS,
	LATEX_UTF8,
	FINAL_LATEX;

	public string to_string() {
		switch(this) {
			case RAW_HTML:
				return "Raw HTML from Google Docs";
			case SEMANTIC_XML:
				return "Semantic XML";
			case LATEX_UTF8_INSERTS:
				return "LaTeX with UTF-8 and inserts";
			case LATEX_UTF8:
				return "LaTeX with UTF-8";
			case FINAL_LATEX:
				return "LaTeX code";
			default:
				assert_not_reached();
		}
	}

	public static Repr[] all() {
		return { RAW_HTML, SEMANTIC_XML, LATEX_UTF8_INSERTS, LATEX_UTF8, FINAL_LATEX };
	}
}

public class CodeView : VBox
{
	// Widget pointers
	private ComboBox stage_selector;
	private TextView code_view;
	// Content
	private TextBuffer content;
	private string code[5];
	public string html_code { 
		get {
			return code[Repr.RAW_HTML];
		}
		set {
			code[Repr.RAW_HTML] = value;
			var transform = new SemanticTransform();
			transform.process.begin(code[Repr.RAW_HTML], (obj, res) => {
				xml_code = transform.process.end(res);
			});
			if(stage_selector.active == Repr.RAW_HTML)
				content.text = code[Repr.RAW_HTML];
		}
	}
	public string xml_code { 
		get {
			return code[Repr.RAW_HTML];
		}
		set {
			code[Repr.SEMANTIC_XML] = value;
			if(stage_selector.active == Repr.SEMANTIC_XML)
				content.text = code[Repr.SEMANTIC_XML];
		}
	}
	public string latex_code_utf8_inserts;
	public string latex_code_utf8;
	public string latex_code;
	
	// SIGNAL HANDLERS
	
	[CCode (instance_pos = -1)]
	public void on_stage_selector_changed(ComboBox source) {
		content.text = code[source.active];
	}
	
	// CONSTRUCTOR
	
	public CodeView() {
		// Construct the combo box values from the enum
		stage_selector = new ComboBox.text();
		foreach(Repr repr in Repr.all())
			stage_selector.append_text(repr.to_string());
		stage_selector.active = Repr.RAW_HTML;
		stage_selector.changed.connect(on_stage_selector_changed);
		
		var scrollwin = new ScrolledWindow(null, null);
		code_view = new TextView();
		code_view.wrap_mode = WrapMode.CHAR;
		content = code_view.buffer;
		
		// Put widgets together
		scrollwin.add(code_view);
		this.pack_start(stage_selector, false, false);
		this.pack_start(scrollwin);
	}
	
	// METHODS
	
	public void clear_code() {
		foreach(Repr repr in Repr.all())
			code[repr] = "";
	}
	
	public void show_code(Repr repr) {
		stage_selector.active = repr;
	}
}

