unit ip_addr;

{$macro on}

interface

uses
  ip4_addr, ip6_addr;

{$define LWIP_IPV4:=1}

type
  Tlwip_ip_addr_type = (IPADDR_TYPE_V4 = 0, IPADDR_TYPE_V6 = 6,
    IPADDR_TYPE_ANY = 46);

{$if defined(LWIP_IPV4) and defined(LWIP_IPV6)}
  Pip_addr = ^Tip_addr;
  Tip_addr = record
    u_addr: record
      case longint of
        0: (ip6: Tip6_addr);
        1: (ip4: Tip4_addr);
    end;
    _type: byte;
  end;
{$elseif defined(LWIP_IPV4)}
  Pip_addr = ^Tip_addr;
  Tip_addr = Tip4_addr;
{$else}
  Pip_addr = ^Tip_addr;
  Tip_addr = Tip6_addr;
{$endif}

const
  IPADDR_STRLEN_MAX = IP6ADDR_STRLEN_MAX;

var
  ip_addr_any_type : Tip_addr; cvar; external;
  ip_addr_any : Tip_addr; cvar; external;
  ip_addr_broadcast : Tip_addr; cvar; external;
  ip6_addr_any : Tip_addr; cvar; external;

function ipaddr_aton(cp: PChar; addr: Pip_addr): longint; cdecl; external;

// No convenience macros translated...

implementation

end.
