unit esp_netif_types;

interface

uses
  esp_err, esp_netif_ip_addr, esp_netif_lwip_internal, esp_event_base,
  portmacro;

const
  ESP_ERR_ESP_NETIF_BASE = $5000;
  ESP_ERR_ESP_NETIF_INVALID_PARAMS = ESP_ERR_ESP_NETIF_BASE + $1;
  ESP_ERR_ESP_NETIF_IF_NOT_READY = ESP_ERR_ESP_NETIF_BASE + $2;
  ESP_ERR_ESP_NETIF_DHCPC_START_FAILED = ESP_ERR_ESP_NETIF_BASE + $3;
  ESP_ERR_ESP_NETIF_DHCP_ALREADY_STARTED = ESP_ERR_ESP_NETIF_BASE + $4;
  ESP_ERR_ESP_NETIF_DHCP_ALREADY_STOPPED = ESP_ERR_ESP_NETIF_BASE + $5;
  ESP_ERR_ESP_NETIF_NO_MEM = ESP_ERR_ESP_NETIF_BASE + $6;
  ESP_ERR_ESP_NETIF_DHCP_NOT_STOPPED = ESP_ERR_ESP_NETIF_BASE + $7;
  ESP_ERR_ESP_NETIF_DRIVER_ATTACH_FAILED = ESP_ERR_ESP_NETIF_BASE + $8;
  ESP_ERR_ESP_NETIF_INIT_FAILED = ESP_ERR_ESP_NETIF_BASE + $9;
  ESP_ERR_ESP_NETIF_DNS_NOT_CONFIGURED = ESP_ERR_ESP_NETIF_BASE + $A;

type
  Pesp_netif_obj = ^Tesp_netif_obj;
  Tesp_netif = Tesp_netif_obj;

  Pesp_netif_dns_type = ^Tesp_netif_dns_type;
  Tesp_netif_dns_type = (ESP_NETIF_DNS_MAIN = 0, ESP_NETIF_DNS_BACKUP,
    ESP_NETIF_DNS_FALLBACK, ESP_NETIF_DNS_MAX
    );

  Pesp_netif_dns_info = ^Tesp_netif_dns_info;
  Tesp_netif_dns_info = record
    ip: Tesp_ip_addr;
  end;

  Pesp_netif_dhcp_status = ^Tesp_netif_dhcp_status;
  Tesp_netif_dhcp_status = (ESP_NETIF_DHCP_INIT = 0, ESP_NETIF_DHCP_STARTED,
    ESP_NETIF_DHCP_STOPPED, ESP_NETIF_DHCP_STATUS_MAX);

  Pesp_netif_dhcp_option_mode = ^Tesp_netif_dhcp_option_mode;
  Tesp_netif_dhcp_option_mode = (ESP_NETIF_OP_START = 0, ESP_NETIF_OP_SET,
    ESP_NETIF_OP_GET, ESP_NETIF_OP_MAX);

  Pesp_netif_dhcp_option_id = ^Tesp_netif_dhcp_option_id;
  Tesp_netif_dhcp_option_id = (ESP_NETIF_DOMAIN_NAME_SERVER = 6,
    ESP_NETIF_ROUTER_SOLICITATION_ADDRESS = 32,
    ESP_NETIF_REQUESTED_IP_ADDRESS = 50,
    ESP_NETIF_IP_ADDRESS_LEASE_TIME = 51,
    ESP_NETIF_IP_REQUEST_RETRY_TIME = 52);

  Pip_event = ^Tip_event;
  Tip_event = (IP_EVENT_STA_GOT_IP, IP_EVENT_STA_LOST_IP,
    IP_EVENT_AP_STAIPASSIGNED, IP_EVENT_GOT_IP6,
    IP_EVENT_ETH_GOT_IP, IP_EVENT_PPP_GOT_IP,
    IP_EVENT_PPP_LOST_IP);

  Pesp_netif_ip_info = ^Tesp_netif_ip_info;
  Tesp_netif_ip_info = record
    ip: Tesp_ip4_addr;
    netmask: Tesp_ip4_addr;
    gw: Tesp_ip4_addr;
  end;

  Pesp_netif_ip6_info = ^Tesp_netif_ip6_info;
  Tesp_netif_ip6_info = record
    ip: Tesp_ip6_addr;
  end;

  Pip_event_got_ip = ^Tip_event_got_ip;
  Tip_event_got_ip = record
    if_index: int32;
    esp_netif: Pesp_netif;
    ip_info: Tesp_netif_ip_info;
    ip_changed: longbool;
  end;

  Pip_event_got_ip6 = ^Tip_event_got_ip6;
  Tip_event_got_ip6 = record
    if_index: int32;
    esp_netif: Pesp_netif;
    ip6_info: Tesp_netif_ip6_info;
  end;

  Pip_event_ap_staipassigned = ^Tip_event_ap_staipassigned;
  Tip_event_ap_staipassigned = record
    ip: Tesp_ip4_addr;
  end;

  Pesp_netif_flags = ^Tesp_netif_flags;
  Tesp_netif_flags = (ESP_NETIF_DHCP_CLIENT = 1 shl
    0, ESP_NETIF_DHCP_SERVER = 1 shl 1,
    ESP_NETIF_FLAG_AUTOUP = 1 shl 2, ESP_NETIF_FLAG_GARP = 1 shl 3,
    ESP_NETIF_FLAG_EVENT_IP_MODIFIED = 1 shl 4,
    ESP_NETIF_FLAG_IS_PPP = 1 shl 5);

  Pesp_netif_ip_event_type = ^Tesp_netif_ip_event_type;
  Tesp_netif_ip_event_type = (ESP_NETIF_IP_EVENT_GOT_IP =
    1, ESP_NETIF_IP_EVENT_LOST_IP = 2);

  Pesp_netif_inherent_config = ^Tesp_netif_inherent_config;
  Tesp_netif_inherent_config = record
    flags: Tesp_netif_flags;
    mac: array[0..5] of byte;
    ip_info: Pesp_netif_ip_info;
    get_ip_event: uint32;
    lost_ip_event: uint32;
    if_key: PChar;
    if_desc: PChar;
    route_prio: int32;
  end;

  Pesp_netif_iodriver_handle = ^Tesp_netif_iodriver_handle;
  Tesp_netif_iodriver_handle = pointer;

  // TODO: Perhaps no need to have type names ending in _s?
  Pesp_netif_driver_base_s = ^Tesp_netif_driver_base_s;
  Tesp_netif_driver_base_s = record
    post_attach: function(netif: Pesp_netif;
        h: Tesp_netif_iodriver_handle): Tesp_err;
    netif: Pesp_netif;
  end;
  Tesp_netif_driver_base = Tesp_netif_driver_base_s;
  Pesp_netif_driver_base = ^Tesp_netif_driver_base;

  Pesp_netif_driver_ifconfig = ^Tesp_netif_driver_ifconfig;
  Tesp_netif_driver_ifconfig = record
    handle: Tesp_netif_iodriver_handle;
    transmit: function(h: pointer; buffer: pointer; len: Tsize): Tesp_err;
    driver_free_rx_buffer: procedure(h: pointer; buffer: pointer);
  end;

  // Defined in esp_netif_lwip_internal
  //Tesp_netif_netstack_config = Tesp_netif_netstack_config;

  Pesp_netif_config = ^Tesp_netif_config;
  Tesp_netif_config = record
    base: Pesp_netif_inherent_config;
    driver: Pesp_netif_driver_ifconfig;
    stack: Pesp_netif_netstack_config;
  end;

  Tesp_netif_receive = function(esp_netif: Pesp_netif;
    buffer: pointer; len: Tsize; eb: pointer): Tesp_err;

var
  IP_EVENT : Tesp_event_base; cvar; external;

implementation

end.
