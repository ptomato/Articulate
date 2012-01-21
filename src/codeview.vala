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
	
	public SourceLanguage get_language() {
		var lmanager = SourceLanguageManager.get_default();
		switch(this) {
			case RAW_HTML:
				return lmanager.get_language("html");
			case SEMANTIC_XML:
				return lmanager.get_language("xml");
			default:
				return lmanager.get_language("latex");
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
	private SourceView code_view;
	private InfoBar info_bar;
	private Label info_label;
	// Content
	private SourceBuffer content;
	private string code[5];
	public string html_code { 
		get {
			return code[Repr.RAW_HTML];
		}
		set {
			code[Repr.RAW_HTML] = value;
			var transform = new SemanticTransform();
			transform.process.begin(code[Repr.RAW_HTML], (obj, res) => {
				try {
					xml_code = transform.process.end(res);
				} catch(IOError e) {
					display_error(e.message);
				}
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
			var transform = new LaTeXTransform();
			transform.process.begin(code[Repr.SEMANTIC_XML], (obj, res) => {
				try {
					latex_code_utf8_inserts = transform.process.end(res);
				} catch(IOError e) {
					display_error(e.message);
				}
			});
			if(stage_selector.active == Repr.SEMANTIC_XML)
				content.text = code[Repr.SEMANTIC_XML];
		}
	}
	public string latex_code_utf8_inserts {
		get {
			return code[Repr.LATEX_UTF8_INSERTS];
		}
		set {
			code[Repr.LATEX_UTF8_INSERTS] = value;
			if(stage_selector.active == Repr.LATEX_UTF8_INSERTS)
				content.text = code[Repr.LATEX_UTF8_INSERTS];
		}
	}
	public string latex_code_utf8;
	public string latex_code;
	
	// SIGNAL HANDLERS
	
	[CCode (instance_pos = -1)]
	public void on_stage_selector_changed(ComboBox source) {
		content.text = code[source.active];
		content.language = ((Repr)source.active).get_language();
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
		code_view = new SourceView();
		code_view.wrap_mode = WrapMode.CHAR;
		content = code_view.buffer as SourceBuffer;
		content.language = Repr.RAW_HTML.get_language();
		var smanager = SourceStyleSchemeManager.get_default();
		content.style_scheme = smanager.get_scheme("tango");
		
		info_bar = new InfoBar();
		info_bar.no_show_all = true;
		info_label = new Label("");
		info_label.show();

		// Put widgets together
		scrollwin.add(code_view);
		(info_bar.get_content_area() as Container).add(info_label);
		this.pack_start(info_bar, false, false);
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

	public void display_error(string text) {
		info_bar.message_type = MessageType.ERROR;
		info_label.label = text;
		info_bar.show();
		info_bar.close.connect(() => { hide(); });
	}
}

