// Taken from sha1.c in a libREST version newer than 0.6.1

public const int SHA1_BLOCK_SIZE = 64;
public const int SHA1_LENGTH = 20;

/*
 * hmac_sha1:
 * @key: The key
 * @message: The message
 *
 * Given the key and message, compute the HMAC-SHA1 hash and return the base-64
 * encoding of it.  This is very geared towards OAuth, and as such both key and
 * message must be NULL-terminated strings, and the result is base-64 encoded.
 */
public string hmac_sha1(string key, string message)
{
	var checksum = new Checksum(ChecksumType.SHA1);
	string real_key;
	var ipad = new uchar[SHA1_BLOCK_SIZE];
	var opad = new uchar[SHA1_BLOCK_SIZE];
	var inner = new uchar[SHA1_LENGTH];
	size_t key_length;

	// If the key is longer than the block size, hash it first
	if(key.length > SHA1_BLOCK_SIZE) {
		var new_key = new uchar[SHA1_LENGTH];

		key_length = new_key.length;

		checksum.update((uchar[])key, key.length);
		checksum.get_digest(new_key, ref key_length);
		//checksum.reset();

		real_key = (string)Memory.dup(new_key, (uint)key_length);
	} else {
		real_key = key.dup();
		key_length = key.length;
	}

	// Sanity check the length
	assert(key_length <= SHA1_BLOCK_SIZE);

	// Protect against use of the provided key by NULLing it
	key = null;

	// Stage 1
	Memory.set(ipad, 0, ipad.length);
	Memory.set(opad, 0, opad.length);

	Memory.copy(ipad, real_key, key_length);
	Memory.copy(opad, real_key, key_length);

	// Stage 2 and 5
	for(int i = 0; i < ipad.length; i++) {
		ipad[i] ^= 0x36;
		opad[i] ^= 0x5C;
	}

	// Stage 3 and 4
	checksum.update(ipad, ipad.length);
	checksum.update(message.data, message.length);
	size_t inner_length = inner.length;
	checksum.get_digest(inner, ref inner_length);
	//checksum.reset();

	// Stage 6 and 7
	checksum.update(opad, opad.length);
	checksum.update(inner, inner_length);

	var digest = checksum.get_string();

	return Base64.encode(digest.data);
}

