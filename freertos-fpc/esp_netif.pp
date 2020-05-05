unit esp_netif;

{$include sdkconfig.inc}
{$linklib esp_netif, static}

interface

uses
  esp_err, esp_netif_types, esp_event_base, esp_netif_ppp, esp_netif_ip_addr;

type
  Pesp_ip4_addr_t = Pesp_ip4_addr;
  Pesp_ip6_addr_t = Pesp_ip6_addr;
  Pesp_netif_config_t = Pesp_netif_config;
  Pesp_netif_driver_ifconfig_t = Pesp_netif_driver_ifconfig;
  Pesp_netif_t = Tesp_netif_t;

function esp_netif_init: Tesp_err_t; cdecl; external;

function esp_netif_deinit: Tesp_err_t; cdecl; external;

function esp_netif_new(esp_netif_config: Pesp_netif_config_t): Pesp_netif_t;
  cdecl; external;

procedure esp_netif_destroy(esp_netif: Pesp_netif_t); cdecl; external;

function esp_netif_set_driver_config(esp_netif: Pesp_netif_t;
  driver_config: Pesp_netif_driver_ifconfig_t): Tesp_err_t; cdecl; external;

function esp_netif_attach(esp_netif: Pesp_netif_t;
  driver_handle: Tesp_netif_iodriver_handle): Tesp_err_t; cdecl; external;

function esp_netif_receive(esp_netif: Pesp_netif_t; buffer: pointer;
  len: Tsize_t; eb: pointer): Tesp_err_t; cdecl; external;

procedure esp_netif_action_start(esp_netif: pointer; base: Tesp_event_base_t;
  event_id: int32; Data: pointer); cdecl; external;

procedure esp_netif_action_stop(esp_netif: pointer; base: Tesp_event_base_t;
  event_id: int32; Data: pointer); cdecl; external;

procedure esp_netif_action_connected(esp_netif: pointer; base: Tesp_event_base_t;
  event_id: int32; Data: pointer); cdecl; external;

procedure esp_netif_action_disconnected(esp_netif: pointer;
  base: Tesp_event_base_t; event_id: int32; Data: pointer); cdecl; external;

procedure esp_netif_action_got_ip(esp_netif: pointer; base: Tesp_event_base_t;
  event_id: int32; Data: pointer); cdecl; external;

function esp_netif_set_mac(esp_netif: Pesp_netif_t; mac: Pbyte): Tesp_err_t;
  cdecl; external;

function esp_netif_set_hostname(esp_netif: Pesp_netif_t; hostname: PChar): Tesp_err_t;
  cdecl; external;

function esp_netif_get_hostname(esp_netif: Pesp_netif_t; hostname: PPChar): Tesp_err_t;
  cdecl; external;

function esp_netif_is_netif_up(esp_netif: Pesp_netif_t): longbool; cdecl; external;

function esp_netif_get_ip_info(esp_netif: Pesp_netif_t;
  ip_info: Pesp_netif_ip_info_t): Tesp_err_t; cdecl; external;

function esp_netif_get_old_ip_info(esp_netif: Pesp_netif_t;
  ip_info: Pesp_netif_ip_info_t): Tesp_err_t; cdecl; external;

function esp_netif_set_ip_info(esp_netif: Pesp_netif_t;
  ip_info: Pesp_netif_ip_info_t): Tesp_err_t; cdecl; external;

function esp_netif_set_old_ip_info(esp_netif: Pesp_netif_t;
  ip_info: Pesp_netif_ip_info_t): Tesp_err_t; cdecl; external;

function esp_netif_get_netif_impl_index(esp_netif: Pesp_netif_t): int32; cdecl; external;

function esp_netif_dhcps_option(esp_netif: Pesp_netif_t;
  opt_op: Tesp_netif_dhcp_option_mode_t; opt_id: Tesp_netif_dhcp_option_id_t;
  opt_val: pointer; opt_len: uint32): Tesp_err_t; cdecl; external;

function esp_netif_dhcpc_option(esp_netif: Pesp_netif_t;
  opt_op: Tesp_netif_dhcp_option_mode_t; opt_id: Tesp_netif_dhcp_option_id_t;
  opt_val: pointer; opt_len: uint32): Tesp_err_t; cdecl; external;

function esp_netif_dhcpc_start(esp_netif: Pesp_netif_t): Tesp_err_t; cdecl; external;

function esp_netif_dhcpc_stop(esp_netif: Pesp_netif_t): Tesp_err_t; cdecl; external;

function esp_netif_dhcpc_get_status(esp_netif: Pesp_netif_t;
  status: Pesp_netif_dhcp_status_t): Tesp_err_t; cdecl; external;

function esp_netif_dhcps_get_status(esp_netif: Pesp_netif_t;
  status: Pesp_netif_dhcp_status_t): Tesp_err_t; cdecl; external;

function esp_netif_dhcps_start(esp_netif: Pesp_netif_t): Tesp_err_t; cdecl; external;

function esp_netif_dhcps_stop(esp_netif: Pesp_netif_t): Tesp_err_t; cdecl; external;

function esp_netif_set_dns_info(esp_netif: Pesp_netif_t;
  _type: Tesp_netif_dns_type_t; dns: Pesp_netif_dns_info_t): Tesp_err_t; cdecl; external;

function esp_netif_get_dns_info(esp_netif: Pesp_netif_t;
  _type: Tesp_netif_dns_type_t; dns: Pesp_netif_dns_info_t): Tesp_err_t; cdecl; external;

function esp_netif_create_ip6_linklocal(esp_netif: Pesp_netif_t): Tesp_err_t;
  cdecl; external;

function esp_netif_get_ip6_linklocal(esp_netif: Pesp_netif_t;
  if_ip6: Pesp_ip6_addr_t): Tesp_err_t; cdecl; external;

function esp_netif_get_ip6_global(esp_netif: Pesp_netif_t;
  if_ip6: Pesp_ip6_addr_t): Tesp_err_t; cdecl; external;

procedure esp_netif_set_ip4_addr(addr: Pesp_ip4_addr_t; a: byte;
  b: byte; c: byte; d: byte); cdecl; external;

function esp_ip4addr_ntoa(addr: Pesp_ip4_addr_t; buf: PChar; buflen: int32): PChar;
  cdecl; external;

function esp_ip4addr_aton(addr: PChar): uint32; cdecl; external;

function esp_netif_get_io_driver(esp_netif: Pesp_netif_t): Tesp_netif_iodriver_handle;
  cdecl; external;

function esp_netif_get_handle_from_ifkey(if_key: PChar): Pesp_netif_t; cdecl; external;

function esp_netif_get_flags(esp_netif: Pesp_netif_t): Tesp_netif_flags_t;
  cdecl; external;

function esp_netif_get_ifkey(esp_netif: Pesp_netif_t): PChar; cdecl; external;

function esp_netif_get_desc(esp_netif: Pesp_netif_t): PChar; cdecl; external;

function esp_netif_get_event_id(esp_netif: Pesp_netif_t;
  event_type: Tesp_netif_ip_event_type_t): int32; cdecl; external;

function esp_netif_next(esp_netif: Pesp_netif_t): Pesp_netif_t; cdecl; external;

function esp_netif_get_nr_of_ifs: Tsize_t; cdecl; external;

function esp_netif_ppp_set_auth(netif: Pesp_netif_t; authtype: Tesp_netif_auth_type_t;
  user: pchar; passwd: pchar): Tesp_err_t; cdecl; external;

function esp_netif_ppp_set_params(netif: Pesp_netif_t;
  config: Pesp_netif_ppp_config_t): Tesp_err_t; cdecl; external;

implementation

end.
