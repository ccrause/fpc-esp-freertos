unit esp_netif_ip_addr;

{$include sdkconfig.inc}
{$inline on}

interface

const
  IPSTR = '%d.%d.%d.%d';
  IPV6STR = '%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x';
  ESP_IPADDR_TYPE_V4 = 0;
  ESP_IPADDR_TYPE_V6 = 6;
  ESP_IPADDR_TYPE_ANY = 46;

type
  Pesp_ip6_addr = ^Tesp_ip6_addr;
  Tesp_ip6_addr = record
    addr: array[0..3] of uint32;
    zone: byte;
  end;

  Pesp_ip4_addr = ^Tesp_ip4_addr;
  Tesp_ip4_addr = record
    addr: uint32;
  end;

  Pip_addr = ^Tip_addr;
  Tip_addr = record
    u_addr: record
      case longint of
        0: (ip6: Tesp_ip6_addr);
        1: (ip4: Tesp_ip4_addr);
    end;
    _type: byte;
  end;
  Tesp_ip_addr = Tip_addr;
  Pesp_ip_addr = ^Tesp_ip_addr;

// Utility function to convert an IP address of the form a.b.c.d to a 32 bit value
function IP4ToAddress(a, b, c, d: byte): uint32; inline;

{$if defined(BYTE_ORDER) and (BYTE_ORDER = BIG_ENDIAN)}
function esp_netif_htonl(x: longint): uint32;
{$else}
function esp_netif_htonl(x: longint): longint;
{$endif}

implementation

{$if defined(BYTE_ORDER) and (BYTE_ORDER = BIG_ENDIAN)}
function esp_netif_htonl(x : longint) : uint32;
begin
  esp_netif_htonl := uint32(x);
end;
{$else}

function IP4ToAddress(a, b, c, d: byte): uint32;
begin
  result := (uint32(d) shl 24) or (uint32(c) shl 16) or (uint32(b) shl 8) or a;
end;

function esp_netif_htonl(x : longint) : longint;
begin
  esp_netif_htonl := ((x and $000000ff) shl 24) or
                     ((x and $0000ff00) shl 8) or
                     ((x and $00ff0000) shr 8) or
                     ((x and $ff000000) shr 24);
end;
{$endif}

end.
