unit list;

{$include freertosconfig.inc}

interface

uses
  projdefs, portmacro, portable;

type
  PList = ^TList;
  PListItem = ^TListItem;
  TListItem = record
    {$if defined(configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES) and (configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES = 1)}
	    xListItemIntegrityValue1: TTickType;
    {$endif}
	  xItemValue: TTickType;
	  pxNext: PListItem;
	  pxPrevious: PListItem;
	  pvOwner: pointer;
	  pxContainer: PList;
    {$if defined(configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES) and (configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES = 1)}
	    xListItemIntegrityValue2: TTickType;
    {$endif}
  end;

  TMiniListItem = record
    {$if defined(configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES) and (configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES = 1)}
      xListItemIntegrityValue1: TTickType;
    {$endif}
    xItemValue: TTickType;
	  pxNext: PListItem;
	  pxPrevious: PListItem;
  end;

  TList = record
    {$if defined(configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES) and (configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES = 1)}
      xListItemIntegrityValue1: TTickType;
    {$endif}
	  uxNumberOfItems: TUBaseType;
	  pxIndex: PListItem;
	  xListEnd: TMiniListItem;
    {$if defined(configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES) and (configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES = 1)}
      xListItemIntegrityValue2: TTickType;
    {$endif}
  end;

procedure vListInitialise(pxList: PList); external;
procedure vListInitialiseItem(pxItem: PListItem); external;
procedure vListInsert(pxList: PList; pxNewListItem: PListItem); external;
procedure vListInsertEnd(pxList: PList; pxNewListItem: PListItem); external;
function uxListRemove(pxItemToRemove: PListItem): TUBaseType; external;

implementation

end.

