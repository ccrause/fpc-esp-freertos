unit eagle_soc;

{$include sdkconfig.inc}

interface

const
  BIT31 = $80000000;
  BIT30 = $40000000;
  BIT29 = $20000000;
  BIT28 = $10000000;
  BIT27 = $08000000;
  BIT26 = $04000000;
  BIT25 = $02000000;
  BIT24 = $01000000;
  BIT23 = $00800000;
  BIT22 = $00400000;
  BIT21 = $00200000;
  BIT20 = $00100000;
  BIT19 = $00080000;
  BIT18 = $00040000;
  BIT17 = $00020000;
  BIT16 = $00010000;
  BIT15 = $00008000;
  BIT14 = $00004000;
  BIT13 = $00002000;
  BIT12 = $00001000;
  BIT11 = $00000800;
  BIT10 = $00000400;
  BIT9 = $00000200;
  BIT8 = $00000100;
  BIT7 = $00000080;
  BIT6 = $00000040;
  BIT5 = $00000020;
  BIT4 = $00000010;
  BIT3 = $00000008;
  BIT2 = $00000004;
  BIT1 = $00000002;
  BIT0 = $00000001;
  CPU_CLK_FREQ = 80 * 1000000;       // unit: Hz
  APB_CLK_FREQ = CPU_CLK_FREQ;
  UART_CLK_FREQ = APB_CLK_FREQ;
  TIMER_CLK_FREQ = APB_CLK_FREQ shr 8;
  FREQ_1MHZ = 1000 * 1000;
  FREQ_1KHZ = 1000;
  CPU_FREQ_160MHZ = (160 * 1000) * 1000;
  CPU_FREQ_80MHz = (80 * 1000) * 1000;
  CPU_160M_TICKS_PRT_MS = CPU_FREQ_160MHZ / FREQ_1KHZ;
  CPU_80M_TICKS_PRT_MS = CPU_FREQ_80MHz / FREQ_1KHZ;
  CPU_160M_TICKS_PRT_US = CPU_FREQ_160MHZ / FREQ_1MHZ;
  CPU_80M_TICKS_PRT_US = CPU_FREQ_80MHz / FREQ_1MHZ;
  PERIPHS_DPORT_BASEADDR = $3ff00000;
  PERIPHS_RTC_BASEADDR = $60000700;
  HOST_INF_SEL = PERIPHS_DPORT_BASEADDR + $28;
  DPORT_LINK_DEVICE_SEL = $000000FF;
  DPORT_LINK_DEVICE_SEL_S = 8;
  DPORT_PERI_IO_SWAP = $000000FF;
  DPORT_PERI_IO_SWAP_S = 0;
  EDGE_INT_ENABLE_REG = PERIPHS_DPORT_BASEADDR + $04;
  DPORT_CTL_REG = PERIPHS_DPORT_BASEADDR + $14;
  DPORT_CTL_DOUBLE_CLK = BIT0;
  INT_ENA_WDEV = $3ff20c18;
  WDEV_COUNT_REG = $3ff20c00;
  PERIPHS_WDT_BASEADDR = $60000900;
  WDT_CTL_ADDRESS = 0;
  WDT_OP_ADDRESS = $4;
  WDT_OP_ND_ADDRESS = $8;
  WDT_RST_ADDRESS = $14;
  WDT_CTL_RSTLEN_MASK = $38;
  WDT_CTL_RSPMOD_MASK = $6;
  WDT_CTL_EN_MASK = $1;
  WDT_CTL_RSTLEN_LSB = $3;
  WDT_CTL_RSPMOD_LSB = $1;
  WDT_CTL_EN_LSB = 0;
  WDT_FEED_VALUE = $73;
  REG_RTC_BASE = PERIPHS_RTC_BASEADDR;
  RTC_SLP_VAL = REG_RTC_BASE + $004;
  RTC_SLP_CNT_VAL = REG_RTC_BASE + $01C;
  RTC_SCRATCH0 = REG_RTC_BASE + $030;
  RTC_SCRATCH1 = REG_RTC_BASE + $034;
  RTC_SCRATCH2 = REG_RTC_BASE + $038;
  RTC_SCRATCH3 = REG_RTC_BASE + $03C;
  RTC_GPIO_OUT = REG_RTC_BASE + $068;
  RTC_GPIO_ENABLE = REG_RTC_BASE + $074;
  RTC_GPIO_IN_DATA = REG_RTC_BASE + $08C;
  RTC_GPIO_CONF = REG_RTC_BASE + $090;
  PAD_XPD_DCDC_CONF = REG_RTC_BASE + $0A0;
  CACHE_FLASH_CTRL_REG = $3ff00000 + $0c;
  CACHE_READ_EN_BIT = BIT8;
  DRAM_BASE = $3FFE8000;
  DRAM_SIZE = 96 * 1024;
  IRAM_BASE = $40100000;
  IRAM_SIZE = CONFIG_SOC_IRAM_SIZE;
  FLASH_BASE = $40200000;
  FLASH_SIZE = (1 * 1024) * 1024;
  RTC_SYS_BASE = $60001000;
  RTC_SYS_SIZE = $200;
  RTC_USER_BASE = $60001200;
  RTC_USER_SIZE = $200;
  ROM_BASE = $40000000;
  ROM_SIZE = $10000;

implementation

end.