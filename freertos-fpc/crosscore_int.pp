unit crosscore_int;

interface

procedure esp_crosscore_int_init; cdecl; external;
procedure esp_crosscore_int_send_yield(core_id: int32); cdecl; external;
procedure esp_crosscore_int_send_freq_switch(core_id: int32); cdecl; external;

implementation

end.
