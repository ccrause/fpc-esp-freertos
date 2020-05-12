unit esp_wifi_crypto_types;

interface

const
  ESP_WIFI_CRYPTO_VERSION = $00000001;

type
  PUint32 = ^uint32;
  PInt32 = ^int32;
  Tsize_t = int32;

  Pesp_crypto_hash_alg_t = ^Tesp_crypto_hash_alg_t;
  Tesp_crypto_hash_alg_t = (ESP_CRYPTO_HASH_ALG_MD5, ESP_CRYPTO_HASH_ALG_SHA1,
    ESP_CRYPTO_HASH_ALG_HMAC_MD5, ESP_CRYPTO_HASH_ALG_HMAC_SHA1,
    ESP_CRYPTO_HASH_ALG_SHA256, ESP_CRYPTO_HASH_ALG_HMAC_SHA256);

  Pesp_crypto_cipher_alg_t = ^Tesp_crypto_cipher_alg_t;
  Tesp_crypto_cipher_alg_t = (ESP_CRYPTO_CIPHER_NULL, ESP_CRYPTO_CIPHER_ALG_AES,
    ESP_CRYPTO_CIPHER_ALG_3DES, ESP_CRYPTO_CIPHER_ALG_DES,
    ESP_CRYPTO_CIPHER_ALG_RC2, ESP_CRYPTO_CIPHER_ALG_RC4);

  Tesp_aes_128_encrypt_t = function(key: pchar; iv: pchar; Data: pchar;
    data_len: int32): int32; cdecl;

  Tesp_aes_128_decrypt_t = function(key: pchar; iv: pchar; Data: pchar;
    data_len: int32): int32; cdecl;

  Tesp_aes_wrap_t = function(kek: pchar; n: int32; plain: pchar;
    cipher: pchar): int32; cdecl;

  Tesp_aes_unwrap_t = function(kek: pchar; n: int32; cipher: pchar;
    plain: pchar): int32; cdecl;

  Tesp_hmac_sha256_vector_t = function(key: pchar; key_len: int32;
    num_elem: int32; addr: PChar; len: PInt32; mac: pchar): int32; cdecl;

  Tesp_sha256_prf_t = function(key: pchar; key_len: int32; _label: PChar;
    Data: pchar; data_len: int32; buf: pchar; buf_len: int32): int32; cdecl;

  Tesp_hmac_md5_t = function(key: pchar; key_len: uint32; Data: pchar;
    data_len: uint32; mac: pchar): int32; cdecl;

  Tesp_hmac_md5_vector_t = function(key: pchar; key_len: uint32;
    num_elem: uint32; addr: PChar; len: PUint32; mac: pchar): int32; cdecl;

  Tesp_hmac_sha1_t = function(key: pchar; key_len: uint32; Data: pchar;
    data_len: uint32; mac: pchar): int32; cdecl;

  Tesp_hmac_sha1_vector_t = function(key: pchar; key_len: uint32;
    num_elem: uint32; addr: PChar; len: PUint32; mac: pchar): int32; cdecl;

  Tesp_sha1_prf_t = function(key: pchar; key_len: uint32; _label: PChar;
    Data: pchar; data_len: uint32; buf: pchar; buf_len: uint32): int32; cdecl;

  Tesp_sha1_vector_t = function(num_elem: uint32; addr: PChar;
    len: PUint32; mac: pchar): int32; cdecl;

  Tesp_pbkdf2_sha1_t = function(passphrase: PChar; ssid: PChar;
    ssid_len: uint32; iterations: int32; buf: pchar;
    buflen: uint32): int32; cdecl;

  Tesp_rc4_skip_t = function(key: pchar; keylen: uint32; skip: uint32;
    Data: pchar; data_len: uint32): int32; cdecl;

  Tesp_md5_vector_t = function(num_elem: uint32; addr: PChar; len: PUint32;
    mac: pchar): int32; cdecl;

  Tesp_aes_encrypt_t = procedure(ctx: pointer; plain: pchar; crypt: pchar); cdecl;

  Pesp_aes_encrypt_init_t = ^Tesp_aes_encrypt_init_t;
  Tesp_aes_encrypt_init_t = function(key: pchar; len: uint32): pointer; cdecl;

  Tesp_aes_encrypt_deinit_t = procedure(ctx: pointer); cdecl;

  Tesp_aes_decrypt_t = procedure(ctx: pointer; crypt: pchar; plain: pchar); cdecl;

  Pesp_aes_decrypt_init_t = ^Tesp_aes_decrypt_init_t;
  Tesp_aes_decrypt_init_t = function(key: pchar; len: uint32): pointer; cdecl;

  Tesp_aes_decrypt_deinit_t = procedure(ctx: pointer); cdecl;

  Tesp_omac1_aes_128_t = function(key: PByte; Data: PByte;
    data_len: Tsize_t; mic: PByte): int32; cdecl;

  Pesp_ccmp_decrypt_t = ^Tesp_ccmp_decrypt_t;
  Tesp_ccmp_decrypt_t = function(tk: PByte; ieee80211_hdr: PByte;
    Data: PByte; data_len: Tsize_t; decrypted_len: PInt32): PByte; cdecl;

  Pesp_ccmp_encrypt_t = ^Tesp_ccmp_encrypt_t;
  Tesp_ccmp_encrypt_t = function(tk: PByte; frame: PByte; len: Tsize_t;
    hdrlen: Tsize_t; pn: PByte; keyid: int32;
    encrypted_len: PInt32): PByte; cdecl;

  Pwpa_crypto_funcs_t = ^Twpa_crypto_funcs_t;
  Twpa_crypto_funcs_t = record
    size: uint32;
    version: uint32;
    aes_wrap: Tesp_aes_wrap_t;
    aes_unwrap: Tesp_aes_unwrap_t;
    hmac_sha256_vector: Tesp_hmac_sha256_vector_t;
    sha256_prf: Tesp_sha256_prf_t;
    hmac_md5: Tesp_hmac_md5_t;
    hamc_md5_vector: Tesp_hmac_md5_vector_t;
    hmac_sha1: Tesp_hmac_sha1_t;
    hmac_sha1_vector: Tesp_hmac_sha1_vector_t;
    sha1_prf: Tesp_sha1_prf_t;
    sha1_vector: Tesp_sha1_vector_t;
    pbkdf2_sha1: Tesp_pbkdf2_sha1_t;
    rc4_skip: Tesp_rc4_skip_t;
    md5_vector: Tesp_md5_vector_t;
    aes_encrypt: Tesp_aes_encrypt_t;
    aes_encrypt_init: Tesp_aes_encrypt_init_t;
    aes_encrypt_deinit: Tesp_aes_encrypt_deinit_t;
    aes_decrypt: Tesp_aes_decrypt_t;
    aes_decrypt_init: Tesp_aes_decrypt_init_t;
    aes_decrypt_deinit: Tesp_aes_decrypt_deinit_t;
    omac1_aes_128: Tesp_omac1_aes_128_t;
    ccmp_decrypt: Tesp_ccmp_decrypt_t;
    ccmp_encrypt: Tesp_ccmp_encrypt_t;
  end;

  Pmesh_crypto_funcs_t = ^Tmesh_crypto_funcs_t;
  Tmesh_crypto_funcs_t = record
    aes_128_encrypt: Tesp_aes_128_encrypt_t;
    aes_128_decrypt: Tesp_aes_128_decrypt_t;
  end;

implementation

end.
