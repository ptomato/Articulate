using Gtk;

public class OptionsDialog : Dialog
{
	private SourceView code_view;
	private SourceBuffer buffer;

	public string preamble_code { owned get {
		return buffer.text;
	} set {
		buffer.text = value;
	}}
	
	public OptionsDialog() {
		var frame = new Frame("<b>Preamble code</b>");
		(frame.label_widget as Label).use_markup = true;
		frame.shadow_type = ShadowType.NONE;

		var alignment = new Alignment(0, 0, 1, 1);
		alignment.left_padding = 12;

		code_view = new SourceView();
		code_view.set_size_request(400, 300);
		buffer = code_view.buffer as SourceBuffer;
		var lmanager = SourceLanguageManager.get_default();
		buffer.language = lmanager.get_language("latex");

		var close = new Button.from_stock(Stock.CLOSE);
		
		alignment.add(code_view);
		frame.add(alignment);
		(get_content_area() as Box).pack_start(frame);
		add_action_widget(close, ResponseType.CLOSE);
		
		get_content_area().show_all();
		get_action_area().show_all();
		
		title = "Document Options";

		// Connect signals
		buffer.changed.connect(() => { notify_property("preamble-code"); });
	}
}
