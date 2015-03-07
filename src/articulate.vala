public class Articulate
{
    // https://wiki.gnome.org/Projects/Vala/InputSamples
    private static string read_stdin()
    {
        var input = new StringBuilder();
        var buffer = new char[1024];
        while (!stdin.eof()) {
            string read_chunk = stdin.gets(buffer);
            if (read_chunk != null) {
                input.append (read_chunk);
            }
        }
        return input.str;
    }

    public static int main(string[] args)
    {
        Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain(Config.GETTEXT_PACKAGE);

        var html_code = read_stdin();
        var preamble_code = "";
        var file_list = new Gee.HashMap<string, File>();
        try {
            var xml_code = SemanticTransform.process(html_code);
            var latex_code_utf8 = LaTeXTransform.process(xml_code, preamble_code);
            var latex_code = UTF8Transform.process(latex_code_utf8, file_list);
            stdout.printf(latex_code);
        } catch (IOError e) {
            stderr.printf("Error applying XSLT transform:");
            stderr.printf(e.message);
            return 1;
        } catch (RegexError e) {
            stderr.printf("Error applying UTF8 transform regex:");
            stderr.printf(e.message);
            return 1;
        } catch (Error e) {
            stderr.printf(e.message);
            return 1;
        }
        return 0;
    }
}
