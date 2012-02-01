[CCode (cheader_filename = "curl/curl.h")]
namespace Curl {
	[CCode (cname = "CURL_GLOBAL_SSL")]
	public const long GLOBAL_SSL;
	[CCode (cname = "CURL_GLOBAL_WIN32")]
	public const long GLOBAL_WIN32;
	[CCode (cname = "CURL_GLOBAL_ALL")]
	public const long GLOBAL_ALL;
	[CCode (cname = "CURL_GLOBAL_NOTHING")]
	public const long GLOBAL_NOTHING;
	[CCode (cname = "CURL_GLOBAL_DEFAULT")]
	public const int GLOBAL_DEFAULT;
	public Curl.Code global_init (long flags);
	public Curl.Code global_init_mem (long flags, Curl.MallocCallback m, Curl.FreeCallback f, Curl.ReallocCallback r, Curl.StrdupCallback s, Curl.CallocCallback c);
	public static void global_cleanup ();
	[CCode (cname = "CURL", cprefix = "curl_easy_", unref_function = "curl_easy_cleanup")]
	public class EasyHandle {
		[CCode (cname = "curl_easy_init")]
		public EasyHandle ();
		[PrintfFormat]
		public Curl.Code setopt (Curl.Option option, ...);
		public Curl.Code perform ();
		[PrintfFormat]
		public Curl.Code getinfo (Curl.Info info, ...);
		public Curl.EasyHandle duphandle ();
		public void reset ();
		public Curl.Code recv (void *buffer, size_t buflen, out size_t n);
		public Curl.Code send (void *buffer, size_t buflen, out size_t n);
		public string escape (string @string, int length);
		public string unescape (string @string, int length, out int outlength);
		[CCode (has_target = false)]
		public delegate int SocketCallback (Curl.Socket s, int what, void* userp, void *socketp);
	}
	[CCode (cname = "CURLcode", cprefix = "CURLE_")]
	public enum Code {
		OK,
		UNSUPPORTED_PROTOCOL,
		FAILED_INIT,
		URL_MALFORMAT,
		COULDNT_RESOLVE_PROXY,
		COULDNT_RESOLVE_HOST,
		COULDNT_CONNECT,
		FTP_WEIRD_SERVER_REPLY,
		REMOTE_ACCESS_DENIED,
		FTP_WEIRD_PASS_REPLY,
		FTP_WEIRD_PASV_REPLY,
		FTP_WEIRD_227_FORMAT,
		FTP_CANT_GET_HOST,
		FTP_COULDNT_SET_TYPE,
		PARTIAL_FILE,
		FTP_COULDNT_RETR_FILE,
		QUOTE_ERROR,
		HTTP_RETURNED_ERROR,
		WRITE_ERROR,
		UPLOAD_FAILED,
		READ_ERROR,
		OUT_OF_MEMORY,
		OPERATION_TIMEDOUT,
		FTP_PORT_FAILED,
		FTP_COULDNT_USE_REST,
		RANGE_ERROR,
		HTTP_POST_ERROR,
		SSL_CONNECT_ERROR,
		BAD_DOWNLOAD_RESUME,
		FILE_COULDNT_READ_FILE,
		LDAP_CANNOT_BIND,
		LDAP_SEARCH_FAILED,
		FUNCTION_NOT_FOUND,
		ABORTED_BY_CALLBACK,
		BAD_FUNCTION_ARGUMENT,
		INTERFACE_FAILED,
		TOO_MANY_REDIRECTS,
		UNKNOWN_TELNET_OPTION,
		TELNET_OPTION_SYNTAX,
		PEER_FAILED_VERIFICATION,
		GOT_NOTHING,
		SSL_ENGINE_NOTFOUND,
		SSL_ENGINE_SETFAILED,
		SEND_ERROR,
		RECV_ERROR,
		SSL_CERTPROBLEM,
		SSL_CIPHER,
		SSL_CACERT,
		BAD_CONTENT_ENCODING,
		LDAP_INVALID_URL,
		FILESIZE_EXCEEDED,
		USE_SSL_FAILED,
		SEND_FAIL_REWIND,
		SSL_ENGINE_INITFAILED,
		LOGIN_DENIED,
		TFTP_NOTFOUND,
		TFTP_PERM,
		REMOTE_DISK_FULL,
		TFTP_ILLEGAL,
		TFTP_UNKNOWNID,
		REMOTE_FILE_EXISTS,
		TFTP_NOSUCHUSER,
		CONV_FAILED,
		CONV_REQD,
		SSL_CACERT_BADFILE,
		REMOTE_FILE_NOT_FOUND,
		SSH,
		SSL_SHUTDOWN_FAILED,
		AGAIN,
		SSL_CRL_BADFILE,
		SSL_ISSUER_ERROR,
		[CCode (cname = "CURL_LAST")]
		LAST
	}
	[CCode (name = "CURLoption", cprefix = "CURLOPT_")]
	public enum Option {
		FILE,
		URL,
		PORT,
		PROXY,
		USERPWD,
		PROXYUSERPWD,
		RANGE,
		INFILE,
		WRITEDATA,
		READDATA,
		ERRORBUFFER,
		WRITEFUNCTION,
		READFUNCTION,
		TIMEOUT,
		INFILESIZE,
		POSTFIELDS,
		REFERER,
		FTPPORT,
		USERAGENT,
		LOW_SPEED_LIMIT,
		LOW_SPEED_TIME,
		RESUME_FROM,
		COOKIE,
		HTTPHEADER,
		HTTPPOST,	// struct HTTPPost
		SSLCERT,
		KEYPASSWD,
		CRLF,
		QUOTE,
		WRITEHEADER,
		HEADERDATA,
		COOKIEFILE,
		SSLVERSION,
		TIMECONDITION,
		TIMEVALUE,
		CUSTOMREQUEST,
		STDERR,
		POSTQUOTE,
		WRITEINFO,
		VERBOSE,
		HEADER,
		NOPROGRESS,
		NOBODY,
		FAILONERROR,
		UPLOAD,
		POST,
		DIRLISTONLY,
		APPEND,
		NETRC,
		FOLLOWLOCATION,
		TRANSFERTEXT,
		PUT,
		PROGRESSFUNCTION,
		PROGRESSDATA,
		AUTOREFERER,
		PROXYPORT,
		POSTFIELDSIZE,
		HTTPPROXYTUNNEL,
		INTERFACE,
		KRBLEVEL,
		SSL_VERIFYPEER,
		CAINFO,
		MAXREDIRS,
		FILETIME,
		TELNETOPTIONS,
		MAXCONNECTS,
		CLOSEPOLICY,
		FRESH_CONNECT,
		FORBID_REUSE,
		RANDOM_FILE,
		EGDSOCKET,
		CONNECTTIMEOUT,
		HEADERFUNCTION,
		HTTPGET,
		SSL_VERIFYHOST,
		COOKIEJAR,
		SSL_CIPHER_LIST,
		HTTP_VERSION,
		FTP_USE_EPSV,
		SSLCERTTYPE,
		SSLKEY,
		SSLKEYTYPE,
		SSLENGINE,
		SSLENGINE_DEFAULT,
		DNS_USE_GLOBAL_CACHE,
		DNS_CACHE_TIMEOUT,
		PREQUOTE,
		DEBUGFUNCTION,
		DEBUGDATA,
		COOKIESESSION,
		CAPATH,
		BUFFERSIZE,
		NOSIGNAL,
		SHARE,
		PROXYTYPE ,
		ENCODING,
		PRIVATE,
		HTTP200ALIASES,
		UNRESTRICTED_AUTH,
		FTP_USE_EPRT,
		HTTPAUTH,
		SSL_CTX_FUNCTION,
		SSL_CTX_DATA,
		FTP_CREATE_MISSING_DIRS,
		PROXYAUTH,
		FTP_RESPONSE_TIMEOUT,
		IPRESOLVE,
		MAXFILESIZE,
		INFILESIZE_LARGE,
		RESUME_FROM_LARGE,
		MAXFILESIZE_LARGE,
		NETRC_FILE,
		USE_SSL,
		POSTFIELDSIZE_LARGE,
		TCP_NODELAY,
		FTPSSLAUTH,
		IOCTLFUNCTION,
		IOCTLDATA,
		FTP_ACCOUNT,
		COOKIELIST,
		IGNORE_CONTENT_LENGTH,
		FTP_SKIP_PASV_IP,
		FTP_FILEMETHOD,
		LOCALPORT,
		LOCALPORTRANGE,
		CONNECT_ONLY,
		CONV_FROM_NETWORK_FUNCTION,
		CONV_TO_NETWORK_FUNCTION,
		CONV_FROM_UTF8_FUNCTION,
		MAX_SEND_SPEED_LARGE,
		MAX_RECV_SPEED_LARGE,
		FTP_ALTERNATIVE_TO_USER,
		SOCKOPTFUNCTION,
		SOCKOPTDATA,
		SSL_SESSIONID_CACHE,
		SSH_AUTH_TYPES,
		SSH_PUBLIC_KEYFILE,
		SSH_PRIVATE_KEYFILE,
		FTP_SSL_CCC,
		TIMEOUT_MS,
		CONNECTTIMEOUT_MS,
		HTTP_TRANSFER_DECODING,
		HTTP_CONTENT_DECODING,
		NEW_FILE_PERMS,
		NEW_DIRECTORY_PERMS,
		POSTREDIR,
		SSH_HOST_PUBLIC_KEY_MD5,
		OPENSOCKETFUNCTION,
		OPENSOCKETDATA,
		COPYPOSTFIELDS,
		PROXY_TRANSFER_MODE,
		SEEKFUNCTION,
		SEEKDATA,
		CRLFILE,
		ISSUERCERT,
		ADDRESS_SCOPE,
		CERTINFO,
		USERNAME,
		PASSWORD,
		PROXYUSERNAME,
		PROXYPASSWORD,
		NOPROXY,
		TFTP_BLKSIZE,
		SOCKS5_GSSAPI_SERVICE,
		SOCKS5_GSSAPI_NEC,
		PROTOCOLS,
		REDIR_PROTOCOLS,
		SSH_KNOWNHOSTS,
		SSH_KEYFUNCTION,
		SSH_KEYDATA,
		LASTENTRY
	}
	[CCode (name = "CURLINFO", cprefix = "CURLINFO_")]
	public enum Info {
		STRING,
		LONG,
		DOUBLE,
		SLIST,
		EFFECTIVE_URL,
		RESPONSE_CODE,
		TOTAL_TIME,
		NAMELOOKUP_TIME,
		CONNECT_TIME,
		PRETRANSFER_TIME,
		SIZE_UPLOAD,
		SIZE_DOWNLOAD,
		SPEED_DOWNLOAD,
		SPEED_UPLOAD,
		HEADER_SIZE,
		REQUEST_SIZE,
		SSL_VERIFYRESULT,
		FILETIME,
		CONTENT_LENGTH_DOWNLOAD,
		CONTENT_LENGTH_UPLOAD,
		STARTTRANSFER_TIME,
		CONTENT_TYPE,
		REDIRECT_TIME,
		REDIRECT_COUNT,
		PRIVATE,
		HTTP_CONNECTCODE,
		HTTPAUTH_AVAIL,
		PROXYAUTH_AVAIL,
		OS_ERRNO,
		NUM_CONNECTS,
		SSL_ENGINES,
		COOKIELIST,
		LASTSOCKET,
		FTP_ENTRY_PATH,
		REDIRECT_URL,
		PRIMARY_IP,
		APPCONNECT_TIME,
		CERTINFO,
		CONDITION_UNMET,
		LASTONE
	}
	[CCode (cname = "curl_progress_callback")]
	public delegate int ProgressCallback (void* clientp, double dltotal, double dlnow, double ultotal, double ulnow);
	[CCode (cname = "CURL_WRITEFUNC_PAUSE")]
	public const size_t WRITEFUNC_PAUSE;
	[CCode (cname = "curl_write_callback")]
	public delegate size_t WriteCallback (char* buffer, size_t size, size_t nitems, void *outstream);
	[CCode (cname = "CURL_SEEKFUNC_OK")]
	public const int SEEKFUNC_OK;
	[CCode (cname = "CURL_SEEKFUNC_FAIL")]
	public const int SEEKFUNC_FAIL;
	[CCode (cname = "CURL_SEEKFUNC_CANTSEEK")]
	public const int SEEKFUNC_CANTSEEK;
	[Ccode (cname = "curl_seek_callback")]
	public delegate int SeekCallback (void* instream, Curl.Offset offset, int origin);
	[CCode (cname = "CURL_READFUNC_ABORT")]
	public const size_t READFUNC_ABORT;
	[CCode (cname = "CURL_READFUNC_PAUSE")]
	public const size_t READFUNC_PAUSE;
	[CCode (cname = "curl_read_callback")]
	public delegate size_t ReadCallback (char* buffer, size_t size, size_t nitems, void *instream);
	[CCode (cname = "curlsocktype", cprefix = "CURLSOCKTYPE_")]
	public enum SocketType {
		IPCXN,
		LAST
	}
	[CCode (cname = "curl_sockopt_callback")]
	public delegate size_t SockoptCallback (void* clientp, Curl.Socket curlfd, Curl.SocketType purpose);
	[CCode (cname = "curlioerr", cprefix = "CURLIOE_")]
	public enum IOError {
		OK,
		UNKNOWNCMD,
		FAILRESTART,
		LAST
	}
	[CCode (cname = "curliocmd", cprefix = "CURLIOCMD_")]
	public enum IOCmd {
		NOP,
		RESTARTREAD,
		LAST
	}
	[CCode (cname = "curl_ioctl_callback")]
	public delegate Curl.IOError IoctlCallback (Curl.EasyHandle handle, int cmd, void* clientp);
	[CCode (cname = "curl_malloc_callback")]
	public delegate void* MallocCallback (size_t size);
	[CCode (cname = "curl_free_callback")]
	public delegate void FreeCallback (void* ptr);
	[CCode (cname = "curl_realloc_callback")]
	public delegate void* ReallocCallback (void* ptr, size_t size);
	[CCode (cname = "curl_strdup_callback")]
	public delegate string StrdupCallback (string str);
	[CCode (cname = "curl_calloc_callback")]
	public delegate void* CallocCallback (size_t nmemb, size_t size);
	[CCode (cname = "curl_infotype", cprefix = "CURLINFO_")]
	public enum InfoType {
		TEXT,
		HEADER_IN,
		HEADER_OUT,
		DATA_IN,
		DATA_OUT,
		SSL_DATA_IN,
		SSL_DATA_OUT
	}
	[CCode (cname = "curl_debug_callback")]
	public delegate int DebugCallback (Curl.EasyHandle handle, Curl.InfoType type, [CCode (array_length_type = "size_t")] char[] data, void* userptr);
	[CCode (cname = "curl_conv_callback")]
	public delegate Curl.Code ConvCallback ([CCode (array_length_type = "size_t")] char[] buffer);
	[CCode (cname = "curl_ssl_ctx_callback")]
	public delegate Curl.Code SSLCtxCallback (Curl.EasyHandle curl, void* ssl_ctx, void* userptr);
	[CCode (cname = "curl_proxytype", cprefix = "CURLPROXY_")]
	public enum ProxyType {
		HTTP,
		HTTP_1_0,
		SOCKS4,
		SOCKS5,
		SOCKS4A,
		SOCKS5_HOSTNAME
	}
	namespace AuthType {
		[CCode (cname = "CURLAUTH_NONE")]
		public const int NONE;
		[CCode (cname = "CURLAUTH_BASIC")]
		public const int BASIC;
		[CCode (cname = "CURLAUTH_DIGEST")]
		public const int DIGEST;
		[CCode (cname = "CURLAUTH_GSSNEGOTIATE")]
		public const int GSSNEGOTIATE;
		[CCode (cname = "CURLAUTH_NTLM")]
		public const int NTLM;
		[CCode (cname = "CURLAUTH_DIGEST_IE")]
		public const int DIGEST_IE;
		[CCode (cname = "CURLAUTH_ANY")]
		public const int ANY;
		[CCode (cname = "CURLAUTH_ANYSAFE")]
		public const int ANYSAFE;
	}
	namespace SSHAuthType {
		[CCode (cname = "CURLSSH_AUTH_ANY")]
		public const int ANY;
		[CCode (cname = "CURLSSH_AUTH_NONE")]
		public const int NONE;
		[CCode (cname = "CURLSSH_AUTH_PUBLICKEY")]
		public const int PUBLICKEY;
		[CCode (cname = "CURLSSH_AUTH_PASSWORD")]
		public const int PASSWORD;
		[CCode (cname = "CURLSSH_AUTH_HOST")]
		public const int HOST;
		[CCode (cname = "CURLSSH_AUTH_KEYBOARD")]
		public const int KEYBOARD;
		[CCode (cname = "CURLSSH_AUTH_DEFAULT")]
		public const int DEFAULT;
	}
	public const int ERROR_SIZE;
	[CCode (cname = "curl_usessl", cprefix = "CURLUSESSL_")]
	public enum UseSSL {
		NONE,
		TRY,
		CONTROL,
		ALL
	}
	[CCode (cname = "curl_ftpccc", cprefix = "CURLFTPSSL_")]
	enum FTPSSL {
		CCC_NONE,
		CCC_PASSIVE,
		CCC_ACTIVE
	}
	[CCode (cname = "curl_ftpauth", cprefix = "CURLFTPAUTH_")]
	enum FTPAuthType {
		DEFAULT,
		SSL,
		TLS
	}
	[CCode (cname = "curl_ftpcreatedir", cprefix = "CURLFTP_CREATE_DIR_")]
	enum FTPCreateDir {
		NONE,
		[CCode (cname = "CURLFTP_CREATE_DIR")]
		CREATE,
		RETRY
	}
	[CCode (cname = "curl_ftpmethod", cprefix = "CURLFTPMETHOD_")]
	enum FTPMethod {
		DEFAULT,
		MULTICWD,
		NOCWD,
		SINGLECWD
	}
	namespace Proto {
		[CCode (cname = "CURLPROTO_HTTP")]
		public const int HTTP;
		[CCode (cname = "CURLPROTO_HTTPS")]
		public const int HTTPS;
		[CCode (cname = "CURLPROTO_FTP")]
		public const int FTP;
		[CCode (cname = "CURLPROTO_FTPS")]
		public const int FTPS;
		[CCode (cname = "CURLPROTO_SCP")]
		public const int SCP;
		[CCode (cname = "CURLPROTO_SFTP")]
		public const int SFTP;
		[CCode (cname = "CURLPROTO_TELNET")]
		public const int TELNET;
		[CCode (cname = "CURLPROTO_LDAP")]
		public const int LDAP;
		[CCode (cname = "CURLPROTO_LDAPS")]
		public const int LDAPS;
		[CCode (cname = "CURLPROTO_DICT")]
		public const int DICT;
		[CCode (cname = "CURLPROTO_FILE")]
		public const int FILE;
		[CCode (cname = "CURLPROTO_TFTP")]
		public const int TFTP;
		[CCode (cname = "CURLPROTO_ALL")]
		public const int ALL;
	}
	public const int IPRESOLVE_WHATEVER;
	public const int IPRESOLVE_V4;
	public const int IPRESOLVE_V6;
	public const int REDIR_GET_ALL;
	public const int REDIR_POST_301;
	public const int REDIR_POST_302;
	public const int REDIR_POST_ALL;
	[CCode (cname = "curl_TimeCond", cprefix = "CURL_TIMECOND_")]
	public enum TimeCond {
		NONE,
		IFMODSINCE,
		IFUNMODSINCE,
		LASTMOD
	}
	[CCode (cname = "CURLformoption", cprefix = "CURLFORM_")]
	public enum FormOption {
		COPYNAME,
		PTRNAME,
		NAMELENGTH,
		COPYCONTENTS,
		PTRCONTENTS,
		CONTENTSLENGTH,
		FILECONTENT,
		ARRAY,
		OBSOLETE,
		FILE,
		BUFFER,
		BUFFERPTR,
		BUFFERLENGTH,
		CONTENTTYPE,
		CONTENTHEADER,
		FILENAME,
		END,
		OBSOLETE2,
		STREAM
	}
	[CCode (cname = "struct curl_forms")]
	public struct Forms {
		public Curl.FormOption option;
		public string value;
	}
	[CCode (cname = "CURLFORMcode", cprefix = "CURL_FORMADD_")]
	public enum FormCode {
		OK,
		MEMORY,
		OPTION_TWICE,
		NULL,
		UNKNOWN_OPTION,
		INCOMPLETE,
		ILLEGAL_ARRAY,
		DISABLED
	}
	public Curl.FormCode formadd (ref Curl.HTTPPost httppost, ref Curl.HTTPPost last_post, ...);
	[CCode (cname = "curl_formget_callback")]
	public delegate size_t FormgetCallback (void* arg, [CCode (array_size_type = "size_t")] char[] buf);
	public int formget (Curl.HTTPPost form, void* arg, Curl.FormgetCallback append);
	public unowned string version ();
	public void free (void* p);
	[Compact]
	[CCode (cname = "struct curl_slist", cprefix = "curl_slist_", free_function = "curl_slist_free_all")]
	public class SList {
		public char* data;
		public Curl.SList next;
		public SList append (string data);
	}
	[CCode (cname = "CURLMcode", cprefix = "CURLM_")]
	public enum MultiCode {
		CALL_MULTI_PERFORM,
		CALL_MULTI_SOCKET,
		OK,
		BAD_HANDLE,
		BAD_EASY_HANDLE,
		OUT_OF_MEMORY,
		INTERNAL_ERROR,
		BAD_SOCKET,
		UNKNOWN_OPTION
	}
	[CCode (cname = "CURLMSG", cprefix = "CURLMSG_")]
	public enum MessageType {
		NONE,
		DONE
	}
	[CCode (cname = "CURLMsg")]
	public struct Message {
		public Curl.MessageType msg;
		public Curl.EasyHandle easy_handle;
		[CCode (cname = "data.whatever")]
		public void* whatever;
		[CCode (cname = "data.result")]
		public Curl.Code result;
	}
	[CCode (cname = "CURLM", cprefix = "curl_multi_", destroy_function = "curl_multi_cleanup")]
	public class MultiHandle {
		[CCode (cname = "curl_multi_init")]
		public MultiHandle ();
		public Curl.MultiCode add_handle (Curl.EasyHandle curl_handle);
		public Curl.MultiCode remove_handle (Curl.EasyHandle curl_handle);
		public Curl.MultiCode fdset (Posix.fd_set? read_fd_set, Posix.fd_set? write_fd_set, Posix.fd_set? exc_fd_set, out int max_fd);
		public Curl.MultiCode perform (out int running_handles);
		public unowned Curl.Message info_read (out int msgs_in_queue);
		public unowned string strerror (Curl.MultiCode code);
		public Curl.MultiCode socket_action (Curl.Socket s, int ev_bitmask, out int running_handles);
		public Curl.MultiCode socket_all (out int running_handles);
		public Curl.MultiCode timeout (out long milliseconds);
		[Printf]
		public Curl.MultiCode setopt (Curl.MultiOption option, ...);
		public Curl.MultiCode assign (Curl.Socket sockfd, void* sockp);
		[CCode (has_target = false)]
		public delegate int TimerCallback (long timeout_ms, void* userp);
	}
	[SimpleType]
	[CCode (cname = "curl_socket_t")]
	public struct Socket {
	}
	[SimpleType]
	[CCode (cname = "curl_off_t")]
	public struct Offset {
	}
	[CCode (cname = "CURL_SOCKET_BAD")]
	public const Curl.Socket SOCKET_BAD;
	[CCode (cname = "CURL_POLL_NONE")]
	public const int POLL_NONE;
	[CCode (cname = "CURL_POLL_IN")]
	public const int POLL_IN;
	[CCode (cname = "CURL_POLL_OUT")]
	public const int POLL_OUT;
	[CCode (cname = "CURL_POLL_INOUT")]
	public const int POLL_INOUT;
	[CCode (cname = "CURL_POLL_REMOVE")]
	public const int POLL_REMOVE;
	[CCode (cname = "CURL_SOCKET_TIMEOUT")]
	public const int SOCKET_TIMEOUT;
	[CCode (cname = "CURL_CSELECT_IN")]
	public const int CSELECT_IN;
	[CCode (cname = "CURL_CSELECT_OUT")]
	public const int CSELECT_OUT;
	[CCode (cname = "CURL_CSELECT_ERR")]
	public const int CSELECT_ERR;
	[CCode (cname = "CURLMoption")]
	public enum MultiOption {
		SOCKETFUNCTION,
		SOCKETDATA,
		PIPELINING,
		TIMERFUNCTION,
		TIMERDATA,
		MAXCONNECTS
	}
	[Compact]
	[CCode (cname = "curl_httppost", unref_function = "curl_formfree")]
	public class HTTPPost {
		public Curl.HTTPPost next;
		[CCode (array_length_cname = "namelength", array_length_type = "long")]
		public weak char[] name;
		[CCode (array_length_cname = "contentslength", array_length_type = "long")]
		public weak char[] contents;
		[CCode (array_length_cname = "bufferlength", array_length_type = "long")]
		public weak char[] buffer;
		public string contenttype;
		public Curl.SList contentheader;
		public Curl.HTTPPost more;
		public long flags;
		public string showfilename;
		public void* userp;
		[CCode (cname = "HTTPPOST_FILENAME")]
		public const long FILENAME;
		[CCode (cname = "HTTPPOST_READFILE")]
		public const long READFILE;
		[CCode (cname = "HTTPPOST_PTRCONTENTS")]
		public const long PTRCONTENTS;
		[CCode (cname = "HTTPPOST_BUFFER")]
		public const long BUFFER;
		[CCode (cname = "HTTPPOST_PTRBUFFER")]
		public const long PTRBUFFER;
		[CCode (cname = "HTTPPOST_CALLBACK")]
		public const long CALLBACK;
	}
	[CCode (cname = "LIBCURL_COPYRIGHT")]
	public const string COPYRIGHT;
	[CCode (cname = "LIBCURL_VERSION")]
	public const string VERSION;
	[CCode (cname = "LIBCURL_VERSION_MAJOR")]
	public const int VERSION_MAJOR;
	[CCode (cname = "LIBCURL_VERSION_MINOR")]
	public const int VERSION_MINOR;
	[CCode (cname = "LIBCURL_VERSION_PATCH")]
	public const int VERSION_PATCH;
	[CCode (cname = "LIBCURL_VERSION_NUM")]
	public const int VERSION_NUM;
	[CCode (cname = "LIBCURL_TIMESTAMP")]
	public const string TIMESTAMP;
}
