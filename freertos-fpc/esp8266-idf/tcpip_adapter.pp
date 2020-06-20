unit tcpip_adapter;

{$linklib tcpip_adapter, static}
{$include sdkconfig.inc}
{$macro on}

interface

uses
  esp_wifi_types, ip_addr, ip4_addr,
  dhcpserver, esp_err, esp_interface;

{$define CONFIG_TCPIP_LWIP := 1}
{$define CONFIG_DHCP_STA_LIST := 1}
{$define TCPIP_ADAPTER_IPV6 := 0} // no IPv6

{$if CONFIG_TCPIP_LWIP = 1}

const
  IPSTR = '%d.%d.%d.%d';
  IPV6STR = '%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x';

type
  Ptcpip_adapter_ip_info = ^Ttcpip_adapter_ip_info;
  Ttcpip_adapter_ip_info = record
    ip: Tip4_addr;
    netmask: Tip4_addr;
    gw: Tip4_addr;
  end;
{$if TCPIP_ADAPTER_IPV6}
  Ptcpip_adapter_ip6_info = ^Ttcpip_adapter_ip6_info;
  Ttcpip_adapter_ip6_info = record
    ip: Tip6_addr;
  end;
{$else}
  Ptcpip_adapter_ip6_info = ^Ttcpip_adapter_ip6_info;
  Ttcpip_adapter_ip6_info = record
    ip: record
      addr: array[0..3] of uint32;
    end;
  end;
{$endif}

  Ptcpip_adapter_dhcps_lease = ^Ttcpip_adapter_dhcps_lease;
  Ttcpip_adapter_dhcps_lease = Tdhcps_lease;

{$if CONFIG_DHCP_STA_LIST}
type
  Ptcpip_adapter_sta_info = ^Ttcpip_adapter_sta_info;
  Ttcpip_adapter_sta_info = record
    mac: array[0..5] of byte;
    ip: Tip4_addr;
  end;

  Ptcpip_adapter_sta_list = ^Ttcpip_adapter_sta_list;
  Ttcpip_adapter_sta_list = record
    sta: array[0..(ESP_WIFI_MAX_CONN_NUM) - 1] of Ttcpip_adapter_sta_info;
    num: longint;
  end;
{$endif}
{$endif}

const
  ESP_ERR_TCPIP_ADAPTER_BASE = $5000;
  ESP_ERR_TCPIP_ADAPTER_INVALID_PARAMS        = ESP_ERR_TCPIP_ADAPTER_BASE + $01;
  ESP_ERR_TCPIP_ADAPTER_IF_NOT_READY          = ESP_ERR_TCPIP_ADAPTER_BASE + $02;
  ESP_ERR_TCPIP_ADAPTER_DHCPC_START_FAILED    = ESP_ERR_TCPIP_ADAPTER_BASE + $03;
  ESP_ERR_TCPIP_ADAPTER_DHCP_ALREADY_STARTED  = ESP_ERR_TCPIP_ADAPTER_BASE + $04;
  ESP_ERR_TCPIP_ADAPTER_DHCP_ALREADY_STOPPED  = ESP_ERR_TCPIP_ADAPTER_BASE + $05;
  ESP_ERR_TCPIP_ADAPTER_NO_MEM                = ESP_ERR_TCPIP_ADAPTER_BASE + $06;
  ESP_ERR_TCPIP_ADAPTER_DHCP_NOT_STOPPED      = ESP_ERR_TCPIP_ADAPTER_BASE + $07;

type
  Ptcpip_adapter_if = ^Ttcpip_adapter_if;
  Ttcpip_adapter_if = (TCPIP_ADAPTER_IF_STA = 0, TCPIP_ADAPTER_IF_AP,
    TCPIP_ADAPTER_IF_ETH, TCPIP_ADAPTER_IF_MAX);

  Ptcpip_adapter_dns_type = ^Ttcpip_adapter_dns_type;
  Ttcpip_adapter_dns_type = (TCPIP_ADAPTER_DNS_MAIN = 0, TCPIP_ADAPTER_DNS_BACKUP,
    TCPIP_ADAPTER_DNS_FALLBACK, TCPIP_ADAPTER_DNS_MAX);

  Ptcpip_adapter_dns_info = ^Ttcpip_adapter_dns_info;
  Ttcpip_adapter_dns_info = record
    ip: Tip_addr;
  end;

  Ptcpip_adapter_dhcp_status = ^Ttcpip_adapter_dhcp_status;
  Ttcpip_adapter_dhcp_status = (TCPIP_ADAPTER_DHCP_INIT =
    0, TCPIP_ADAPTER_DHCP_STARTED,
    TCPIP_ADAPTER_DHCP_STOPPED, TCPIP_ADAPTER_DHCP_STATUS_MAX);

  Ptcpip_adapter_option_mode = ^Ttcpip_adapter_option_mode;
  Ttcpip_adapter_option_mode = (TCPIP_ADAPTER_OP_START = 0, TCPIP_ADAPTER_OP_SET,
    TCPIP_ADAPTER_OP_GET, TCPIP_ADAPTER_OP_MAX);

  Ptcpip_adapter_option_id = ^Ttcpip_adapter_option_id;
  Ttcpip_adapter_option_id = (TCPIP_ADAPTER_DOMAIN_NAME_SERVER = 6,
    TCPIP_ADAPTER_ROUTER_SOLICITATION_ADDRESS = 32,
    TCPIP_ADAPTER_REQUESTED_IP_ADDRESS = 50,
    TCPIP_ADAPTER_IP_ADDRESS_LEASE_TIME = 51,
    TCPIP_ADAPTER_IP_REQUEST_RETRY_TIME = 52);

  Ptcpip_adapter_api_msg_s = ^Ttcpip_adapter_api_msg_s;
  //Ttcpip_adapter_api_msg_s = record
  //  {undefined structure}
  //end;

  Ttcpip_adapter_api_fn = function(msg: Ptcpip_adapter_api_msg_s): longint;

  //Ptcpip_adapter_api_msg_s = ^Ttcpip_adapter_api_msg_s;
  Ttcpip_adapter_api_msg_s = record
    _type: longint;
    ret: longint;
    api_fn: Ttcpip_adapter_api_fn;
    tcpip_if: Ttcpip_adapter_if;
    ip_info: Ptcpip_adapter_ip_info;
    mac: pbyte;
    Data: pointer;
  end;
  Ttcpip_adapter_api_msg = Ttcpip_adapter_api_msg_s;
  Ptcpip_adapter_api_msg = ^Ttcpip_adapter_api_msg;

  Ptcpip_adapter_dns_param_s = ^Ttcpip_adapter_dns_param_s;
  Ttcpip_adapter_dns_param_s = record
    dns_type: Ttcpip_adapter_dns_type;
    dns_info: Ptcpip_adapter_dns_info;
  end;
  Ttcpip_adapter_dns_param = Ttcpip_adapter_dns_param_s;
  Ptcpip_adapter_dns_param = ^Ttcpip_adapter_dns_param;

const
  TCPIP_ADAPTER_TRHEAD_SAFE = 1;
  TCPIP_ADAPTER_IPC_LOCAL = 0;
  TCPIP_ADAPTER_IPC_REMOTE = 1;

type
  Ptcpip_adatper_ip_lost_timer_s = ^Ttcpip_adatper_ip_lost_timer_s;
  Ttcpip_adatper_ip_lost_timer_s = record
    timer_running: longbool;
  end;
  Ttcpip_adapter_ip_lost_timer = Ttcpip_adatper_ip_lost_timer_s;
  Ptcpip_adapter_ip_lost_timer = ^Ttcpip_adapter_ip_lost_timer;

procedure tcpip_adapter_init; external;
function tcpip_adapter_start(tcpip_if: Ttcpip_adapter_if; mac: pbyte;
  ip_info: Ptcpip_adapter_ip_info): Tesp_err; external;
function tcpip_adapter_stop(tcpip_if: Ttcpip_adapter_if): Tesp_err; external;
function tcpip_adapter_up(tcpip_if: Ttcpip_adapter_if): Tesp_err; external;
function tcpip_adapter_down(tcpip_if: Ttcpip_adapter_if): Tesp_err; external;
function tcpip_adapter_get_ip_info(tcpip_if: Ttcpip_adapter_if;
  ip_info: Ptcpip_adapter_ip_info): Tesp_err; external;
function tcpip_adapter_set_ip_info(tcpip_if: Ttcpip_adapter_if;
  ip_info: Ptcpip_adapter_ip_info): Tesp_err; external;
function tcpip_adapter_set_dns_info(tcpip_if: Ttcpip_adapter_if;
  _type: Ttcpip_adapter_dns_type; dns: Ptcpip_adapter_dns_info): Tesp_err;
  external;
function tcpip_adapter_get_dns_info(tcpip_if: Ttcpip_adapter_if;
  _type: Ttcpip_adapter_dns_type; dns: Ptcpip_adapter_dns_info): Tesp_err;
  external;
function tcpip_adapter_get_old_ip_info(tcpip_if: Ttcpip_adapter_if;
  ip_info: Ptcpip_adapter_ip_info): Tesp_err; external;
function tcpip_adapter_set_old_ip_info(tcpip_if: Ttcpip_adapter_if;
  ip_info: Ptcpip_adapter_ip_info): Tesp_err; external;
function tcpip_adapter_create_ip6_linklocal(tcpip_if: Ttcpip_adapter_if): Tesp_err;
  external;

{$if TCPIP_ADAPTER_IPV6}
function tcpip_adapter_get_ip6_linklocal(tcpip_if: Ttcpip_adapter_if;
  if_ip6: Pip6_addr_t): Tesp_err; external;
{$endif}

{$if 0}
function tcpip_adapter_get_mac(tcpip_if: Ttcpip_adapter_if_t;
  mac: pbyte): Tesp_err; external;
function tcpip_adapter_set_mac(tcpip_if: Ttcpip_adapter_if_t;
  mac: pbyte): Tesp_err; external;
{$endif}

function tcpip_adapter_dhcps_get_status(tcpip_if: Ttcpip_adapter_if;
  status: Ptcpip_adapter_dhcp_status): Tesp_err; external;
function tcpip_adapter_dhcps_option(opt_op: Ttcpip_adapter_option_mode;
  opt_id: Ttcpip_adapter_option_id; opt_val: pointer; opt_len: uint32): Tesp_err;
  external;
function tcpip_adapter_dhcps_start(tcpip_if: Ttcpip_adapter_if): Tesp_err;
  external;
function tcpip_adapter_dhcps_stop(tcpip_if: Ttcpip_adapter_if): Tesp_err;
  external;
function tcpip_adapter_dhcpc_get_status(tcpip_if: Ttcpip_adapter_if;
  status: Ptcpip_adapter_dhcp_status): Tesp_err; external;
function tcpip_adapter_dhcpc_option(opt_op: Ttcpip_adapter_option_mode;
  opt_id: Ttcpip_adapter_option_id; opt_val: pointer; opt_len: uint32): Tesp_err;
  external;
function tcpip_adapter_dhcpc_start(tcpip_if: Ttcpip_adapter_if): Tesp_err;
  external;
function tcpip_adapter_dhcpc_stop(tcpip_if: Ttcpip_adapter_if): Tesp_err;
  external;
function tcpip_adapter_eth_input(buffer: pointer; len: uint16;
  eb: pointer): Tesp_err; external;
function tcpip_adapter_sta_input(buffer: pointer; len: uint16;
  eb: pointer): Tesp_err; external;
function tcpip_adapter_ap_input(buffer: pointer; len: uint16;
  eb: pointer): Tesp_err; external;
function tcpip_adapter_get_esp_if(dev: pointer): Tesp_interface; external;
function tcpip_adapter_get_sta_list(wifi_sta_list: Pwifi_sta_list;
  tcpip_sta_list: Ptcpip_adapter_sta_list): Tesp_err; external;

const
  TCPIP_HOSTNAME_MAX_SIZE = 32;

function tcpip_adapter_set_hostname(tcpip_if: Ttcpip_adapter_if;
  hostname: PChar): Tesp_err; external;
function tcpip_adapter_get_hostname(tcpip_if: Ttcpip_adapter_if;
  hostname: PPchar): Tesp_err; external;
function tcpip_adapter_get_netif(tcpip_if: Ttcpip_adapter_if;
  netif: Ppointer): Tesp_err; external;
function tcpip_adapter_is_netif_up(tcpip_if: Ttcpip_adapter_if): longbool; external;

implementation

end.
