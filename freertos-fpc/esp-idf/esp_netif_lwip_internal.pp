unit esp_netif_lwip_internal;

interface

uses
  esp_err, esp_netif_ppp;

// Copied from lwip/netif.h
const
  NETIF_MAX_HWADDR_LEN = 6;

type
  Terr = int8;  // defined in lwip/err.h
  Tnetif = record end;
  Pnetif = ^Tnetif;

  Pesp_netif_netstack_lwip_vanilla_config = ^Tesp_netif_netstack_lwip_vanilla_config;
  Tesp_netif_netstack_lwip_vanilla_config = record
    init_fn: function(para1: Pnetif): Terr; cdecl;
    input_fn: procedure(netif: pointer; buffer: pointer; len: Tsize;
        eb: pointer); cdecl;
  end;

  Pesp_netif_netstack_lwip_ppp_config = ^Tesp_netif_netstack_lwip_ppp_config;
  Tesp_netif_netstack_lwip_ppp_config = record
    input_fn: procedure(netif: pointer; buffer: pointer; len: Tsize;
        eb: pointer); cdecl;
    ppp_events: Tesp_netif_ppp_config;
  end;

  Tesp_netif_netstack_config = record
    case boolean of
      False: (lwip: Tesp_netif_netstack_lwip_vanilla_config);
      True: (lwip_ppp: Tesp_netif_netstack_lwip_ppp_config);
  end;
  Pesp_netif_netstack_config = ^Tesp_netif_netstack_config;

  Pesp_netif = ^Tesp_netif_obj;
  Pesp_netif_api_msg = ^Tesp_netif_api_msg;
  Tesp_netif_api_fn = function(msg: Pesp_netif_api_msg): int32;
  Tesp_netif_api_msg = record
    type_: int32;
    ret: int32;
    api_fn: Tesp_netif_api_fn;
    esp_netif: Pesp_netif;
    Data: pointer;
  end;

  Pesp_netif_ip_lost_timer_s = ^Tesp_netif_ip_lost_timer_s;
  Tesp_netif_ip_lost_timer_s = record
    timer_running: longbool;
  end;
  Tesp_netif_ip_lost_timer = Tesp_netif_ip_lost_timer_s;
  Pesp_netif_ip_lost_timer = ^Tesp_netif_ip_lost_timer;
  Tlwip_ppp_ctx = record end;
  Plwip_ppp_ctx = ^Tlwip_ppp_ctx;

  //Pesp_netif_obj = ^Tesp_netif_obj;
  Tesp_netif_obj = record
    mac: array[0..(NETIF_MAX_HWADDR_LEN) - 1] of byte;
    // Break dependency cycle by using typeless pointers:
    ip_info: pointer; //Pesp_netif_ip_info_t;
    ip_info_old: pointer; //Pesp_netif_ip_info_t;
    lwip_netif: pointer; //Pnetif;
    lwip_ppp_ctx: Plwip_ppp_ctx;
    lwip_init_fn: function(para1: Pnetif): Terr; cdecl;
    lwip_input_fn: procedure(input_netif_handle: pointer; buffer: pointer;
        len: Tsize; eb: pointer); cdecl;
    netif_handle: pointer;
    is_ppp_netif: longbool;
    driver_handle: pointer;
    driver_transmit: function(h: pointer; buffer: pointer;
        len: Tsize): Tesp_err; cdecl;
    driver_free_rx_buffer: procedure(h: pointer; buffer: pointer); cdecl;
    dhcpc_status: longint; //Tesp_netif_dhcp_status_t;
    dhcps_status: longint; //Tesp_netif_dhcp_status_t;
    timer_running: longbool;
    get_ip_event: longint; //Tip_event_t;
    lost_ip_event: longint; //Tip_event_t;
    flags: longint; //Tesp_netif_flags_t;
    hostname: PChar;
    if_key: PChar;
    if_desc: PChar;
    route_prio: int32;
  end;


implementation


end.
