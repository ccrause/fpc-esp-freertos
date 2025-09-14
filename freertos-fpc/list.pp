unit list;

{$macro on}
{$include freertosconfig.inc}

interface

uses
  portmacro;

type
  PList = ^TList;
  PListItem = ^TListItem;
  TListItem = record
    {$if declared(configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES) and (configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES = 1)}
      xListItemIntegrityValue1: TTickType;
    {$endif}
    xItemValue: TTickType;
    pxNext: PListItem;
    pxPrevious: PListItem;
    pvOwner: pointer;
    pxContainer: PList;
    {$if declared(configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES) and (configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES = 1)}
      xListItemIntegrityValue2: TTickType;
    {$endif}
  end;

  TMiniListItem = record
    {$if declared(configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES) and (configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES = 1)}
      xListItemIntegrityValue1: TTickType;
    {$endif}
    xItemValue: TTickType;
    pxNext: PListItem;
    pxPrevious: PListItem;
  end;

  TList = record
    {$if declared(configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES) and (configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES = 1)}
      xListItemIntegrityValue1: TTickType;
    {$endif}
    uxNumberOfItems: TUBaseType;
    pxIndex: PListItem;
    xListEnd: TMiniListItem;
    {$if declared(configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES) and (configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES = 1)}
      xListItemIntegrityValue2: TTickType;
    {$endif}
  end;

procedure vListInitialise(out pxList: TList); external;
procedure vListInitialiseItem(out pxItem: TListItem); external;
procedure vListInsert(pxList: PList; pxNewListItem: PListItem); external;
procedure vListInsertEnd(pxList: PList; pxNewListItem: PListItem); external;
function uxListRemove(pxItemToRemove: PListItem): TUBaseType; external;

implementation

end.

