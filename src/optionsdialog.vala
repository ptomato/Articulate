using Gtk;

public class OptionsDialog : Dialog
{
	private SourceView code_view;
	private SourceBuffer buffer;

	public string preamble_code;
	
	public OptionsDialog() {
		var frame = new Frame("<b>Preamble code</b>");
		(frame.label_widget as Label).use_markup = true;
		frame.shadow = ShadowType.NONE;
		code_view = new SourceView();
		code_view.set_size_request(400, 300);
		buffer = code_view.get_buffer() as SourceBuffer;
		var close = new Button.from_stock(Stock.CLOSE);
		
		frame.add(code_view);
		(get_content_area() as Box).pack_start(frame);
		add_action_widget(close, ResponseType.CLOSE);
		
		get_content_area().show_all();
		get_action_area().show_all();
		
		title = "Document Options";
	}
}
