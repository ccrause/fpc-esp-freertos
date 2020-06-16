unit esp_wifi_crypto_types;

interface

const
  ESP_WIFI_CRYPTO_VERSION = $00000001;

type
  PUint32 = ^uint32;
  PInt32 = ^int32;
  Tsize = int32;

  Pesp_crypto_hash_alg = ^Tesp_crypto_hash_alg;
  Tesp_crypto_hash_alg = (ESP_CRYPTO_HASH_ALG_MD5, ESP_CRYPTO_HASH_ALG_SHA1,
    ESP_CRYPTO_HASH_ALG_HMAC_MD5, ESP_CRYPTO_HASH_ALG_HMAC_SHA1,
    ESP_CRYPTO_HASH_ALG_SHA256, ESP_CRYPTO_HASH_ALG_HMAC_SHA256);

  Pesp_crypto_cipher_alg = ^Tesp_crypto_cipher_alg;
  Tesp_crypto_cipher_alg = (ESP_CRYPTO_CIPHER_NULL, ESP_CRYPTO_CIPHER_ALG_AES,
    ESP_CRYPTO_CIPHER_ALG_3DES, ESP_CRYPTO_CIPHER_ALG_DES,
    ESP_CRYPTO_CIPHER_ALG_RC2, ESP_CRYPTO_CIPHER_ALG_RC4);

  Tesp_aes_128_encrypt = function(key: pchar; iv: pchar; Data: pchar;
    data_len: int32): int32; cdecl;

  Tesp_aes_128_decrypt = function(key: pchar; iv: pchar; Data: pchar;
    data_len: int32): int32; cdecl;

  Tesp_aes_wrap = function(kek: pchar; n: int32; plain: pchar;
    cipher: pchar): int32; cdecl;

  Tesp_aes_unwrap = function(kek: pchar; n: int32; cipher: pchar;
    plain: pchar): int32; cdecl;

  Tesp_hmac_sha256_vector = function(key: pchar; key_len: int32;
    num_elem: int32; addr: PChar; len: PInt32; mac: pchar): int32; cdecl;

  Tesp_sha256_prf = function(key: pchar; key_len: int32; _label: PChar;
    Data: pchar; data_len: int32; buf: pchar; buf_len: int32): int32; cdecl;

  Tesp_hmac_md5 = function(key: pchar; key_len: uint32; Data: pchar;
    data_len: uint32; mac: pchar): int32; cdecl;

  Tesp_hmac_md5_vector = function(key: pchar; key_len: uint32;
    num_elem: uint32; addr: PChar; len: PUint32; mac: pchar): int32; cdecl;

  Tesp_hmac_sha1 = function(key: pchar; key_len: uint32; Data: pchar;
    data_len: uint32; mac: pchar): int32; cdecl;

  Tesp_hmac_sha1_vector = function(key: pchar; key_len: uint32;
    num_elem: uint32; addr: PChar; len: PUint32; mac: pchar): int32; cdecl;

  Tesp_sha1_prf = function(key: pchar; key_len: uint32; _label: PChar;
    Data: pchar; data_len: uint32; buf: pchar; buf_len: uint32): int32; cdecl;

  Tesp_sha1_vector = function(num_elem: uint32; addr: PChar;
    len: PUint32; mac: pchar): int32; cdecl;

  Tesp_pbkdf2_sha1 = function(passphrase: PChar; ssid: PChar;
    ssid_len: uint32; iterations: int32; buf: pchar;
    buflen: uint32): int32; cdecl;

  Tesp_rc4_skip = function(key: pchar; keylen: uint32; skip: uint32;
    Data: pchar; data_len: uint32): int32; cdecl;

  Tesp_md5_vector = function(num_elem: uint32; addr: PChar; len: PUint32;
    mac: pchar): int32; cdecl;

  Tesp_aes_encrypt = procedure(ctx: pointer; plain: pchar; crypt: pchar); cdecl;

  Pesp_aes_encrypt_init = ^Tesp_aes_encrypt_init;
  Tesp_aes_encrypt_init = function(key: pchar; len: uint32): pointer; cdecl;

  Tesp_aes_encrypt_deinit = procedure(ctx: pointer); cdecl;

  Tesp_aes_decrypt = procedure(ctx: pointer; crypt: pchar; plain: pchar); cdecl;

  Pesp_aes_decrypt_init = ^Tesp_aes_decrypt_init;
  Tesp_aes_decrypt_init = function(key: pchar; len: uint32): pointer; cdecl;

  Tesp_aes_decrypt_deinit = procedure(ctx: pointer); cdecl;

  Tesp_omac1_aes_128 = function(key: PByte; Data: PByte;
    data_len: Tsize; mic: PByte): int32; cdecl;

  Pesp_ccmp_decrypt = ^Tesp_ccmp_decrypt;
  Tesp_ccmp_decrypt = function(tk: PByte; ieee80211_hdr: PByte;
    Data: PByte; data_len: Tsize; decrypted_len: PInt32): PByte; cdecl;

  Pesp_ccmp_encrypt = ^Tesp_ccmp_encrypt;
  Tesp_ccmp_encrypt = function(tk: PByte; frame: PByte; len: Tsize;
    hdrlen: Tsize; pn: PByte; keyid: int32;
    encrypted_len: PInt32): PByte; cdecl;

  Pwpa_crypto_funcs = ^Twpa_crypto_funcs;
  Twpa_crypto_funcs = record
    size: uint32;
    version: uint32;
    aes_wrap: Tesp_aes_wrap;
    aes_unwrap: Tesp_aes_unwrap;
    hmac_sha256_vector: Tesp_hmac_sha256_vector;
    sha256_prf: Tesp_sha256_prf;
    hmac_md5: Tesp_hmac_md5;
    hamc_md5_vector: Tesp_hmac_md5_vector;
    hmac_sha1: Tesp_hmac_sha1;
    hmac_sha1_vector: Tesp_hmac_sha1_vector;
    sha1_prf: Tesp_sha1_prf;
    sha1_vector: Tesp_sha1_vector;
    pbkdf2_sha1: Tesp_pbkdf2_sha1;
    rc4_skip: Tesp_rc4_skip;
    md5_vector: Tesp_md5_vector;
    aes_encrypt: Tesp_aes_encrypt;
    aes_encrypt_init: Tesp_aes_encrypt_init;
    aes_encrypt_deinit: Tesp_aes_encrypt_deinit;
    aes_decrypt: Tesp_aes_decrypt;
    aes_decrypt_init: Tesp_aes_decrypt_init;
    aes_decrypt_deinit: Tesp_aes_decrypt_deinit;
    omac1_aes_128: Tesp_omac1_aes_128;
    ccmp_decrypt: Tesp_ccmp_decrypt;
    ccmp_encrypt: Tesp_ccmp_encrypt;
  end;

  Pmesh_crypto_funcs = ^Tmesh_crypto_funcs;
  Tmesh_crypto_funcs = record
    aes_128_encrypt: Tesp_aes_128_encrypt;
    aes_128_decrypt: Tesp_aes_128_decrypt;
  end;

implementation

end.
