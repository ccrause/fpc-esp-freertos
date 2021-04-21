unit dhcpserver;

{$include sdkconfig.inc}

interface

uses
  ip_addr, ip4_addr;

const
  DHCPS_COARSE_TIMER_SECS = 1;
  DHCPS_MAX_LEASE = $64;
  DHCPS_LEASE_TIME_DEF = 120;
  DHCPS_LEASE_UNIT = CONFIG_LWIP_DHCPS_LEASE_UNIT;

type
  Pdhcps_state = ^Tdhcps_state;
  Tdhcps_state = record
    state: int16;
  end;

  Pdhcps_msg = ^Tdhcps_msg;
  Tdhcps_msg = record
    op: byte;
    htype: byte;
    hlen: byte;
    hops: byte;
    xid: array[0..3] of byte;
    secs: uint16;
    flags: uint16;
    ciaddr: array[0..3] of byte;
    yiaddr: array[0..3] of byte;
    siaddr: array[0..3] of byte;
    giaddr: array[0..3] of byte;
    chaddr: array[0..15] of byte;
    sname: array[0..63] of byte;
    afile: array[0..127] of byte;
    options: array[0..311] of byte;
  end;

  Pdhcps_lease_t = ^Tdhcps_lease;
  Tdhcps_lease = record
    enable: longbool;
    start_ip: Tip4_addr;
    end_ip: Tip4_addr;
  end;

  Tdhcps_offer_option = (OFFER_START = $00, OFFER_ROUTER = $01, OFFER_DNS = $02,
    OFFER_END);

  Pdhcps_pool = ^Tdhcps_pool;
  Tdhcps_pool = record
    ip: Tip4_addr;
    mac: array[0..5] of byte;
    lease_timer: uint32;
  end;

  Pdhcps_time = ^Tdhcps_time;
  Tdhcps_time = uint32;

  Pdhcps_offer = ^Tdhcps_offer;
  Tdhcps_offer = byte;

  Pdhcps_options = ^Tdhcps_options;
  Tdhcps_options = record
    dhcps_offer: Tdhcps_offer;
    dhcps_dns: Tdhcps_offer;
    dhcps_time: Tdhcps_time;
    dhcps_poll: Tdhcps_lease;
  end;

  TClientIP = array[0..3] of byte;
  Tdhcps_cb = procedure (client_ip: TClientIP);
{
(* error
static inline bool dhcps_router_enabled (dhcps_offer_t offer)
 in declarator_list *)

(* error
static inline bool dhcps_dns_enabled (dhcps_offer_t offer)
 in declarator_list *)

(* error
void dhcps_start(struct netif *netif, ip4_addr_t ip);
(* error
void dhcps_start(struct netif *netif, ip4_addr_t ip);
 in declarator_list *)
}
procedure dhcps_stop(netif: Pnetif); external;
function dhcps_option_info(op_id: byte; opt_len: uint32): pointer; external;
procedure dhcps_set_option_info(op_id: byte; opt_info: pointer;
  opt_len: uint32); external;
function dhcp_search_ip_on_mac(mac: byte; ip: Pip4_addr): longbool; external;
procedure dhcps_dns_setserver(dnsserver: Pip_addr); external;
function dhcps_dns_getserver: Tip4_addr; external;
procedure dhcps_set_new_lease_cb(cb: Tdhcps_cb); external;
procedure dhcps_coarse_tmr; external;

implementation

end.
