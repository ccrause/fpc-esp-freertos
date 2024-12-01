unit pcnt_types;

interface

type
  Ppcnt_channel_level_action = ^Tpcnt_channel_level_action;
  Tpcnt_channel_level_action = (
    PCNT_CHANNEL_LEVEL_ACTION_KEEP,     // Keep current count mode
    PCNT_CHANNEL_LEVEL_ACTION_INVERSE,  // Invert current count mode (increase -> decrease, decrease -> increase)
    PCNT_CHANNEL_LEVEL_ACTION_HOLD);    // Hold current count value

  Ppcnt_channel_edge_action = ^Tpcnt_channel_edge_action;
  Tpcnt_channel_edge_action = (
    PCNT_CHANNEL_EDGE_ACTION_HOLD,
    PCNT_CHANNEL_EDGE_ACTION_INCREASE,
    PCNT_CHANNEL_EDGE_ACTION_DECREASE);

  Ppcnt_unit_count_sign = ^Tpcnt_unit_count_sign;
  Tpcnt_unit_count_sign = (
    PCNT_UNIT_COUNT_SIGN_ZERO_POS,
    PCNT_UNIT_COUNT_SIGN_ZERO_NEG,
    PCNT_UNIT_COUNT_SIGN_NEG,
    PCNT_UNIT_COUNT_SIGN_POS);

implementation

end.
