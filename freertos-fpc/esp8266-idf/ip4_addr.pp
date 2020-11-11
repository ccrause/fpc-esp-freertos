unit ip4_addr;

{$inline on}

interface

const
  IPADDR_NONE         = $ffffffff;
  IPADDR_LOOPBACK     = $7f000001;
  IPADDR_ANY          = $00000000;
  IPADDR_BROADCAST    = $ffffffff;
  IP_CLASSA_NET = $ff000000;
  IP_CLASSA_NSHIFT = 24;
  IP_CLASSA_HOST = $ffffffff and (not (IP_CLASSA_NET));
  IP_CLASSA_MAX = 128;
  IP_CLASSB_NET = $ffff0000;
  IP_CLASSB_NSHIFT = 16;
  IP_CLASSB_HOST = $ffffffff and (not (IP_CLASSB_NET));
  IP_CLASSB_MAX = 65536;
  IP_CLASSC_NET = $ffffff00;
  IP_CLASSC_NSHIFT = 8;
  IP_CLASSC_HOST = $ffffffff and (not (IP_CLASSC_NET));
  IP_CLASSD_NET = $f0000000;
  IP_CLASSD_NSHIFT = 28;
  IP_CLASSD_HOST = $0fffffff;
  IP_LOOPBACKNET = 127;

type
  Pip4_addr = ^Tip4_addr;
  Tip4_addr = record
    addr: uint32;
  end;

  Tip4_addr2 = packed record
    addrw: array[0..1] of uint16;
  end;

  Tnetif = record end;
  Pnetif = ^Tnetif;

// Utility function to convert an IP address of the form a.b.c.d to a 32 bit value
function IP4ToAddress(a, b, c, d: byte): uint32; inline;

function ip4_addr_isbroadcast_u32(addr: uint32; netif: Pnetif): byte; external;
function ipaddr_addr(cp: PChar): uint32; external;
function ip4addr_aton(cp: PChar; addr: Pip4_addr): longint; external;
function ip4addr_ntoa(addr: Pip4_addr): PChar; external;
function ip4addr_ntoa_r(addr: Pip4_addr; buf: PChar; buflen: longint): PChar;
  external;

// Ignore the macro's below for now
// Too much effort to hand translate and seem of little benefit to end users in FPC
{
function IP_CLASSA(a: longint): longint;
function IP_CLASSB(a: longint): longint;
function IP_CLASSC(a: longint): longint;
function IP_CLASSD(a: longint): longint;
function IP_MULTICAST(a: longint): longint;
function IP_EXPERIMENTAL(a: longint): longint;
function IP_BADCLASS(a: longint): longint;

(* error
#define IP4_ADDR(ipaddr, a,b,c,d)  (ipaddr)->addr = PP_HTONL(LWIP_MAKEU32(a,b,c,d))
in define line 120 *)

{$ifndef IPADDR2_COPY}
procedure IPADDR2_COPY(var dest, src: Tip4_addr);
{$endif}

procedure ip4_addr_copy(var dest, src: Tip4_addr);
function ip4_addr_set(dest, src: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_set_zero(ipaddr: longint): longint;


{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_set_any(ipaddr: longint): longint;


{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_set_loopback(ipaddr: longint): longint;


{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_isloopback(ipaddr: longint): longint;


{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_set_hton(dest, src: longint): longint;


{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_set_u32(dest_ipaddr, src_u32: longint): longint;


{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_get_u32(src_ipaddr: longint): longint;


(* error
#define ip4_addr_get_network(target, host, netmask) do { ((target)->addr = ((host)->addr) & ((netmask)->addr)); } while(0
in declaration at line 154 *)
(* error
#define ip4_addr_get_network(target, host, netmask) do { ((target)->addr = ((host)->addr) & ((netmask)->addr)); } while(0


in define line 167 *)
{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_cmp(addr1, addr2: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_isany_val(addr1: longint): longint;

(* error
#define ip4_addr_isany(addr1) ((addr1) == NULL || ip4_addr_isany_val(*(addr1)))
in define line 171 *)
{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_isbroadcast(addr1, netif: longint): longint;
*)

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip_addr_netmask_valid(netmask: longint): longint;

function ip4_addr_netmask_valid(netmask: uint32): byte; external;
{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_ismulticast(addr1: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_islinklocal(addr1: longint): longint;

(* error
  LWIP_DEBUGF(debug, ("%" U16_F ".%" U16_F ".%" U16_F ".%" U16_F, a, b, c, d))
in define line 184 *)
{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_debug_print(debug, ipaddr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_debug_print_val(debug, ipaddr: longint): longint;


(* Const before type ignored *)
(* error 
#define ip4_addr1(ipaddr) (((const u8_t* )(&(ipaddr)->addr))[0])
in define line 199 *)
(* Const before type ignored *)
(* error 
#define ip4_addr2(ipaddr) (((const u8_t* )(&(ipaddr)->addr))[1])
in define line 200 *)
(* Const before type ignored *)
(* error 
#define ip4_addr3(ipaddr) (((const u8_t* )(&(ipaddr)->addr))[2])
in define line 201 *)
(* Const before type ignored *)
(* error
#define ip4_addr4(ipaddr) (((const u8_t* )(&(ipaddr)->addr))[3])
in define line 202 *)

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function ip4_addr1_16(ipaddr: longint): Tu16_t;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function ip4_addr2_16(ipaddr: longint): Tu16_t;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function ip4_addr3_16(ipaddr: longint): Tu16_t;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function ip4_addr4_16(ipaddr: longint): Tu16_t;

const
  IP4ADDR_STRLEN_MAX = 16;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }

function ip_ntoa(ipaddr: longint): longint;
}


implementation

function IP4ToAddress(a, b, c, d: byte): uint32; inline;
begin
  result := (uint32(d) shl 24) or (uint32(c) shl 16) or (uint32(b) shl 8) or a;
end;

{
function IP_CLASSA(a: longint): longint;
begin
  IP_CLASSA := (a and $80000000) = 0;
end;

function IP_CLASSB(a: longint): longint;
begin
  IP_CLASSB := (a and $c0000000) = $80000000;
end;

function IP_CLASSC(a: longint): longint;
begin
  IP_CLASSC := (a and $e0000000) = $c0000000;
end;

function IP_CLASSD(a: longint): longint;
begin
  IP_CLASSD := (a and $f0000000) = $e0000000;
end;

function IP_MULTICAST(a: longint): longint;
begin
  IP_MULTICAST := IP_CLASSD(a);
end;

function IP_EXPERIMENTAL(a: longint): longint;
begin
  IP_EXPERIMENTAL := (a and $f0000000) = $f0000000;
end;

function IP_BADCLASS(a: longint): longint;
begin
  IP_BADCLASS := (a and $f0000000) = $f0000000;
end;

procedure IPADDR2_COPY(dest, src: Tip4_addr);
begin
  SMEMCPY(dest, src, sizeof(ip4_addr_t));
end;

function ip4_addr_copy(dest, src: longint): longint;
begin
  dest.addr := src.add);
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_set(dest, src: longint): longint;
var
  if_local1: longint;
  (* result types are not known *)
begin
  if NULL then
    if_local1 := 0
  else
    if_local1 := src^.addr;
  ip4_addr_set := (dest^.addr) = (src = (if_local1));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_set_zero(ipaddr: longint): longint;
begin
  ip4_addr_set_zero := (ipaddr^.addr) = 0;
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_set_any(ipaddr: longint): longint;
begin
  ip4_addr_set_any := (ipaddr^.addr) = IPADDR_ANY;
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_set_loopback(ipaddr: longint): longint;
begin
  ip4_addr_set_loopback := (ipaddr^.addr) = (PP_HTONL(IPADDR_LOOPBACK));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_isloopback(ipaddr: longint): longint;
begin
  ip4_addr_isloopback := ((ipaddr^.addr) and (PP_HTONL(IP_CLASSA_NET))) =
    (PP_HTONL((uint32(IP_LOOPBACKNET)) shl 24));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_set_hton(dest, src: longint): longint;
var
  if_local1: longint;
  (* result types are not known *)
begin
  if NULL then
    if_local1 := 0
  else
    if_local1 := lwip_htonl(src^.addr);
  ip4_addr_set_hton := (dest^.addr) = (src = (if_local1));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_set_u32(dest_ipaddr, src_u32: longint): longint;
begin
  ip4_addr_set_u32 := (dest_ipaddr^.addr) = src_u32;
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_get_u32(src_ipaddr: longint): longint;
begin
  ip4_addr_get_u32 := src_ipaddr^.addr;
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_cmp(addr1, addr2: longint): longint;
begin
  ip4_addr_cmp := (addr1^.addr) = (addr2^.addr);
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_isany_val(addr1: longint): longint;
begin
  ip4_addr_isany_val := (addr1.addr) = IPADDR_ANY;
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_isbroadcast(addr1, netif: longint): longint;
begin
  ip4_addr_isbroadcast := ip4_addr_isbroadcast_u32(addr1^.addr, netif);
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip_addr_netmask_valid(netmask: longint): longint;
begin
  ip_addr_netmask_valid := ip4_addr_netmask_valid(netmask^.addr);
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_ismulticast(addr1: longint): longint;
begin
  ip4_addr_ismulticast := ((addr1^.addr) and (PP_HTONL($f0000000))) =
    (PP_HTONL($e0000000));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_islinklocal(addr1: longint): longint;
begin
  ip4_addr_islinklocal := ((addr1^.addr) and (PP_HTONL($ffff0000))) =
    (PP_HTONL($a9fe0000));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_debug_print(debug, ipaddr: longint): longint;
var
  if_local1, if_local2, if_local3, if_local4: longint;
  (* result types are not known *)
begin
  ip4_addr_debug_print := ip4_addr_debug_print_parts(
    debug, Tu16_t(ipaddr <> (if_local1)), Tu16_t(ipaddr <> (if_local2)), Tu16_t(ipaddr <>
    (if_local3)), Tu16_t(ipaddr <> (if_local4)));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip4_addr_debug_print_val(debug, ipaddr: longint): longint;
begin
  ip4_addr_debug_print_val :=
    ip4_addr_debug_print_parts(debug, ip4_addr1_16(@(ipaddr)), ip4_addr2_16(
    @(ipaddr)), ip4_addr3_16(@(ipaddr)), ip4_addr4_16(@(ipaddr)));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function ip4_addr1_16(ipaddr: longint): Tu16_t;
begin
  ip4_addr1_16 := Tu16_t(ip4_addr1(ipaddr));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function ip4_addr2_16(ipaddr: longint): Tu16_t;
begin
  ip4_addr2_16 := Tu16_t(ip4_addr2(ipaddr));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function ip4_addr3_16(ipaddr: longint): Tu16_t;
begin
  ip4_addr3_16 := Tu16_t(ip4_addr3(ipaddr));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function ip4_addr4_16(ipaddr: longint): Tu16_t;
begin
  ip4_addr4_16 := Tu16_t(ip4_addr4(ipaddr));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip_ntoa(ipaddr: longint): longint;
begin
  ip_ntoa := ipaddr_ntoa(ipaddr);
end;

}
end.
