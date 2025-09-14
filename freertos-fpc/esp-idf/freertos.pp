unit freertos;

{$include freertosconfig.inc}
{$include portmacro_defs.inc}
{$linklib freertos, static}

interface

uses
  portmacro, portable;

type
  PxSTATIC_LIST_ITEM = ^TxSTATIC_LIST_ITEM;
  TxSTATIC_LIST_ITEM = record
    xDummy1: TTickType;
    pvDummy2: array[0..3] of pointer;
  end;
  TStaticListItem = TxSTATIC_LIST_ITEM ;

  PxSTATIC_MINI_LIST_ITEM = ^TxSTATIC_MINI_LIST_ITEM;
  TxSTATIC_MINI_LIST_ITEM = record
    xDummy1: TTickType;
    pvDummy2: array[0..1] of pointer;
  end;
  TStaticMiniListItem_t = TxSTATIC_MINI_LIST_ITEM;

  PxSTATIC_LIST = ^TxSTATIC_LIST;
  TxSTATIC_LIST = record
    uxDummy1: uint32;
    pvDummy2: pointer;
    xDummy3: TStaticMiniListItem_t;
  end;
  TStaticList = TxSTATIC_LIST;
  PStaticList_t = ^TStaticList;

type
  PxSTATIC_TCB = ^TxSTATIC_TCB;
  TxSTATIC_TCB = record
  end;
  TStaticTask = TxSTATIC_TCB;
  PStaticTask = ^TStaticTask;
  PPStaticTask = ^PStaticTask;

  PxSTATIC_QUEUE = ^TxSTATIC_QUEUE;
  TxSTATIC_QUEUE = record
    pvDummy1: array[0..2] of pointer;
    u: record
      case longint of
        0: (pvDummy2: pointer);
        1: (uxDummy2: uint32);
    end;
    xDummy3: array[0..1] of TStaticList;
    uxDummy4: array[0..2] of uint32;
    ucDummy6: byte;
    pvDummy7: pointer;
    uxDummy8: uint32;
    ucDummy9: byte;
    muxDummy: TportMUX_TYPE;
  end;
  TStaticQueue = TxSTATIC_QUEUE;
  PStaticQueue = ^TStaticQueue;
  PPStaticQueue = ^PStaticQueue;


  TStaticSemaphore = TStaticQueue;
  PStaticSemaphore = ^TStaticSemaphore;
  PPStaticSemaphore = ^PStaticSemaphore;

  PxSTATIC_EVENT_GROUP = ^TxSTATIC_EVENT_GROUP;
  TxSTATIC_EVENT_GROUP = record
    xDummy1: TTickType;
    xDummy2: TStaticList;
    uxDummy3: uint32;
    ucDummy4: byte;
    muxDummy: TportMUX_TYPE;
  end;
  TStaticEventGroup = TxSTATIC_EVENT_GROUP;
  PStaticEventGroup = ^TStaticEventGroup;

  PxSTATIC_TIMER = ^TxSTATIC_TIMER;
  TxSTATIC_TIMER = record
    pvDummy1: pointer;
    xDummy2: TStaticListItem;
    xDummy3: TTickType;
    uxDummy4: uint32;
    pvDummy5: array[0..1] of pointer;
    uxDummy6: uint32;
    ucDummy7: byte;
  end;
  TStaticTimer = TxSTATIC_TIMER;
  PStaticTimer = ^TStaticTimer;
  PPStaticTimer = ^PStaticTimer;

implementation

end.
