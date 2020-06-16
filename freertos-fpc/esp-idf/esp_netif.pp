unit esp_netif;

{$include sdkconfig.inc}
{$linklib esp_netif, static}

interface

uses
  esp_err, esp_netif_types, esp_event_base, esp_netif_ppp, esp_netif_ip_addr;

type
  //Pesp_ip4_addr_t = Pesp_ip4_addr;
  //Pesp_ip6_addr_t = Pesp_ip6_addr;
  //Pesp_netif_config_t = Pesp_netif_config;
  //Pesp_netif_driver_ifconfig_t = Pesp_netif_driver_ifconfig;
  Pesp_netif = ^Tesp_netif;

function esp_netif_init: Tesp_err; cdecl; external;

function esp_netif_deinit: Tesp_err; cdecl; external;

function esp_netif_new(esp_netif_config: Pesp_netif_config): Pesp_netif;
  cdecl; external;

procedure esp_netif_destroy(esp_netif: Pesp_netif); cdecl; external;

function esp_netif_set_driver_config(esp_netif: Pesp_netif;
  driver_config: Pesp_netif_driver_ifconfig): Tesp_err; cdecl; external;

function esp_netif_attach(esp_netif: Pesp_netif;
  driver_handle: Tesp_netif_iodriver_handle): Tesp_err; cdecl; external;

function esp_netif_receive(esp_netif: Pesp_netif; buffer: pointer;
  len: Tsize; eb: pointer): Tesp_err; cdecl; external;

procedure esp_netif_action_start(esp_netif: pointer; base: Tesp_event_base;
  event_id: int32; Data: pointer); cdecl; external;

procedure esp_netif_action_stop(esp_netif: pointer; base: Tesp_event_base;
  event_id: int32; Data: pointer); cdecl; external;

procedure esp_netif_action_connected(esp_netif: pointer; base: Tesp_event_base;
  event_id: int32; Data: pointer); cdecl; external;

procedure esp_netif_action_disconnected(esp_netif: pointer;
  base: Tesp_event_base; event_id: int32; Data: pointer); cdecl; external;

procedure esp_netif_action_got_ip(esp_netif: pointer; base: Tesp_event_base;
  event_id: int32; Data: pointer); cdecl; external;

function esp_netif_set_mac(esp_netif: Pesp_netif; mac: Pbyte): Tesp_err;
  cdecl; external;

function esp_netif_set_hostname(esp_netif: Pesp_netif; hostname: PChar): Tesp_err;
  cdecl; external;

function esp_netif_get_hostname(esp_netif: Pesp_netif; hostname: PPChar): Tesp_err;
  cdecl; external;

function esp_netif_is_netif_up(esp_netif: Pesp_netif): longbool; cdecl; external;

function esp_netif_get_ip_info(esp_netif: Pesp_netif;
  ip_info: Pesp_netif_ip_info): Tesp_err; cdecl; external;

function esp_netif_get_old_ip_info(esp_netif: Pesp_netif;
  ip_info: Pesp_netif_ip_info): Tesp_err; cdecl; external;

function esp_netif_set_ip_info(esp_netif: Pesp_netif;
  ip_info: Pesp_netif_ip_info): Tesp_err; cdecl; external;

function esp_netif_set_old_ip_info(esp_netif: Pesp_netif;
  ip_info: Pesp_netif_ip_info): Tesp_err; cdecl; external;

function esp_netif_get_netif_impl_index(esp_netif: Pesp_netif): int32; cdecl; external;

function esp_netif_dhcps_option(esp_netif: Pesp_netif;
  opt_op: Tesp_netif_dhcp_option_mode; opt_id: Tesp_netif_dhcp_option_id;
  opt_val: pointer; opt_len: uint32): Tesp_err; cdecl; external;

function esp_netif_dhcpc_option(esp_netif: Pesp_netif;
  opt_op: Tesp_netif_dhcp_option_mode; opt_id: Tesp_netif_dhcp_option_id;
  opt_val: pointer; opt_len: uint32): Tesp_err; cdecl; external;

function esp_netif_dhcpc_start(esp_netif: Pesp_netif): Tesp_err; cdecl; external;

function esp_netif_dhcpc_stop(esp_netif: Pesp_netif): Tesp_err; cdecl; external;

function esp_netif_dhcpc_get_status(esp_netif: Pesp_netif;
  status: Pesp_netif_dhcp_status): Tesp_err; cdecl; external;

function esp_netif_dhcps_get_status(esp_netif: Pesp_netif;
  status: Pesp_netif_dhcp_status): Tesp_err; cdecl; external;

function esp_netif_dhcps_start(esp_netif: Pesp_netif): Tesp_err; cdecl; external;

function esp_netif_dhcps_stop(esp_netif: Pesp_netif): Tesp_err; cdecl; external;

function esp_netif_set_dns_info(esp_netif: Pesp_netif;
  _type: Tesp_netif_dns_type; dns: Pesp_netif_dns_info): Tesp_err; cdecl; external;

function esp_netif_get_dns_info(esp_netif: Pesp_netif;
  _type: Tesp_netif_dns_type; dns: Pesp_netif_dns_info): Tesp_err; cdecl; external;

function esp_netif_create_ip6_linklocal(esp_netif: Pesp_netif): Tesp_err;
  cdecl; external;

function esp_netif_get_ip6_linklocal(esp_netif: Pesp_netif;
  if_ip6: Pesp_ip6_addr): Tesp_err; cdecl; external;

function esp_netif_get_ip6_global(esp_netif: Pesp_netif;
  if_ip6: Pesp_ip6_addr): Tesp_err; cdecl; external;

procedure esp_netif_set_ip4_addr(addr: Pesp_ip4_addr; a: byte;
  b: byte; c: byte; d: byte); cdecl; external;

function esp_ip4addr_ntoa(addr: Pesp_ip4_addr; buf: PChar; buflen: int32): PChar;
  cdecl; external;

function esp_ip4addr_aton(addr: PChar): uint32; cdecl; external;

function esp_netif_get_io_driver(esp_netif: Pesp_netif): Tesp_netif_iodriver_handle;
  cdecl; external;

function esp_netif_get_handle_from_ifkey(if_key: PChar): Pesp_netif; cdecl; external;

function esp_netif_get_flags(esp_netif: Pesp_netif): Tesp_netif_flags_t;
  cdecl; external;

function esp_netif_get_ifkey(esp_netif: Pesp_netif): PChar; cdecl; external;

function esp_netif_get_desc(esp_netif: Pesp_netif): PChar; cdecl; external;

function esp_netif_get_event_id(esp_netif: Pesp_netif;
  event_type: Tesp_netif_ip_event_type): int32; cdecl; external;

function esp_netif_next(esp_netif: Pesp_netif): Pesp_netif; cdecl; external;

function esp_netif_get_nr_of_ifs: Tsize; cdecl; external;

function esp_netif_ppp_set_auth(netif: Pesp_netif; authtype: Tesp_netif_auth_type;
  user: pchar; passwd: pchar): Tesp_err; cdecl; external;

function esp_netif_ppp_set_params(netif: Pesp_netif;
  config: Pesp_netif_ppp_config): Tesp_err; cdecl; external;

implementation

end.
