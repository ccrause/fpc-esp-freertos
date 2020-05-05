unit esp_netif_types;

interface

uses
  esp_err, esp_netif_ip_addr, esp_netif_lwip_internal, esp_event_base;

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
  Tesp_netif_t = Tesp_netif_obj;

  Pesp_netif_dns_type_t = ^Tesp_netif_dns_type_t;
  Tesp_netif_dns_type_t = (ESP_NETIF_DNS_MAIN = 0, ESP_NETIF_DNS_BACKUP,
    ESP_NETIF_DNS_FALLBACK, ESP_NETIF_DNS_MAX
    );

  Pesp_netif_dns_info_t = ^Tesp_netif_dns_info_t;
  Tesp_netif_dns_info_t = record
    ip: Tesp_ip_addr_t;
  end;

  Pesp_netif_dhcp_status_t = ^Tesp_netif_dhcp_status_t;
  Tesp_netif_dhcp_status_t = (ESP_NETIF_DHCP_INIT = 0, ESP_NETIF_DHCP_STARTED,
    ESP_NETIF_DHCP_STOPPED, ESP_NETIF_DHCP_STATUS_MAX);

  Pesp_netif_dhcp_option_mode_t = ^Tesp_netif_dhcp_option_mode_t;
  Tesp_netif_dhcp_option_mode_t = (ESP_NETIF_OP_START = 0, ESP_NETIF_OP_SET,
    ESP_NETIF_OP_GET, ESP_NETIF_OP_MAX);

  Pesp_netif_dhcp_option_id_t = ^Tesp_netif_dhcp_option_id_t;
  Tesp_netif_dhcp_option_id_t = (ESP_NETIF_DOMAIN_NAME_SERVER = 6,
    ESP_NETIF_ROUTER_SOLICITATION_ADDRESS = 32,
    ESP_NETIF_REQUESTED_IP_ADDRESS = 50,
    ESP_NETIF_IP_ADDRESS_LEASE_TIME = 51,
    ESP_NETIF_IP_REQUEST_RETRY_TIME = 52);

  Pip_event_t = ^Tip_event_t;
  Tip_event_t = (IP_EVENT_STA_GOT_IP, IP_EVENT_STA_LOST_IP,
    IP_EVENT_AP_STAIPASSIGNED, IP_EVENT_GOT_IP6,
    IP_EVENT_ETH_GOT_IP, IP_EVENT_PPP_GOT_IP,
    IP_EVENT_PPP_LOST_IP);

  Pesp_netif_ip_info_t = ^Tesp_netif_ip_info_t;
  Tesp_netif_ip_info_t = record
    ip: Tesp_ip4_addr_t;
    netmask: Tesp_ip4_addr_t;
    gw: Tesp_ip4_addr_t;
  end;

  Pesp_netif_ip6_info_t = ^Tesp_netif_ip6_info_t;
  Tesp_netif_ip6_info_t = record
    ip: Tesp_ip6_addr_t;
  end;

  Pip_event_got_ip_t = ^Tip_event_got_ip_t;
  Tip_event_got_ip_t = record
    if_index: int32;
    esp_netif: Pesp_netif_t;
    ip_info: Tesp_netif_ip_info_t;
    ip_changed: longbool;
  end;

  Pip_event_got_ip6_t = ^Tip_event_got_ip6_t;
  Tip_event_got_ip6_t = record
    if_index: int32;
    esp_netif: Pesp_netif_t;
    ip6_info: Tesp_netif_ip6_info_t;
  end;

  Pip_event_ap_staipassigned_t = ^Tip_event_ap_staipassigned_t;
  Tip_event_ap_staipassigned_t = record
    ip: Tesp_ip4_addr_t;
  end;

  Pesp_netif_flags = ^Tesp_netif_flags;
  Tesp_netif_flags = (ESP_NETIF_DHCP_CLIENT = 1 shl
    0, ESP_NETIF_DHCP_SERVER = 1 shl 1,
    ESP_NETIF_FLAG_AUTOUP = 1 shl 2, ESP_NETIF_FLAG_GARP = 1 shl 3,
    ESP_NETIF_FLAG_EVENT_IP_MODIFIED = 1 shl 4,
    ESP_NETIF_FLAG_IS_PPP = 1 shl 5);
  Tesp_netif_flags_t = Tesp_netif_flags;
  Pesp_netif_flags_t = ^Tesp_netif_flags_t;

  Pesp_netif_ip_event_type = ^Tesp_netif_ip_event_type;
  Tesp_netif_ip_event_type = (ESP_NETIF_IP_EVENT_GOT_IP =
    1, ESP_NETIF_IP_EVENT_LOST_IP = 2);
  Tesp_netif_ip_event_type_t = Tesp_netif_ip_event_type;
  Pesp_netif_ip_event_type_t = ^Tesp_netif_ip_event_type_t;

  Pesp_netif_inherent_config = ^Tesp_netif_inherent_config;
  Tesp_netif_inherent_config = record
    flags: Tesp_netif_flags_t;
    mac: array[0..5] of byte;
    ip_info: Pesp_netif_ip_info_t;
    get_ip_event: uint32;
    lost_ip_event: uint32;
    if_key: PChar;
    if_desc: PChar;
    route_prio: int32;
  end;
  Tesp_netif_inherent_config_t = Tesp_netif_inherent_config;
  Pesp_netif_inherent_config_t = ^Tesp_netif_inherent_config_t;
  //Tesp_netif_config_t = Tesp_netif_config;

  Pesp_netif_iodriver_handle = ^Tesp_netif_iodriver_handle;
  Tesp_netif_iodriver_handle = pointer;

  Pesp_netif_driver_base_s = ^Tesp_netif_driver_base_s;
  Tesp_netif_driver_base_s = record
    post_attach: function(netif: Pesp_netif_t;
        h: Tesp_netif_iodriver_handle): Tesp_err_t; cdecl;
    netif: Pesp_netif_t;
  end;
  Tesp_netif_driver_base_t = Tesp_netif_driver_base_s;
  Pesp_netif_driver_base_t = ^Tesp_netif_driver_base_t;

  Pesp_netif_driver_ifconfig = ^Tesp_netif_driver_ifconfig;
  Tesp_netif_driver_ifconfig = record
    handle: Tesp_netif_iodriver_handle;
    transmit: function(h: pointer; buffer: pointer; len: Tsize_t): Tesp_err_t; cdecl;
    driver_free_rx_buffer: procedure(h: pointer; buffer: pointer); cdecl;
  end;
  Tesp_netif_driver_ifconfig_t = Tesp_netif_driver_ifconfig;

  // Defined in esp_netif_lwip_internal
  Tesp_netif_netstack_config_t = Tesp_netif_netstack_config;

  Pesp_netif_config = ^Tesp_netif_config;
  Tesp_netif_config = record
    base: Pesp_netif_inherent_config_t;
    driver: Pesp_netif_driver_ifconfig;
    stack: Pesp_netif_netstack_config;
  end;

  Tesp_netif_receive_t = function(esp_netif: Pesp_netif_t;
    buffer: pointer; len: Tsize_t; eb: pointer): Tesp_err_t; cdecl;

var
  IP_EVENT : Tesp_event_base_t; cvar; external;

implementation

end.
