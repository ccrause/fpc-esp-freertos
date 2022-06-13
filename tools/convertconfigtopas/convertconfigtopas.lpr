program convertconfigtopas;

{  Program to convert esp-idf and esp8266-rtos-sdk config files (sdkconfig) to
   corresponding Pascal defines in an include file (sdkconfig.inc).
}

uses
  classes, sysutils;

procedure addHeader(const SL: TSTringList);
begin
  SL.Add('{$macro on}');
  SL.Add('{');
  SL.Add('* Automatically generated file. DO NOT EDIT.');
  SL.Add('* Espressif IoT Development Framework (ESP-IDF) Configuration Header');
  SL.Add('}');
  SL.Add('');
end;

procedure convertToDefine(const input, output: TStringList);
var
  i, j, v: integer;
  s, tmp: string;
begin
  for i := 0 to input.Count-1 do
  begin
    s := input[i];
    if not ((length(s) = 0) or (s[1] = '#')) then
    begin
      j := pos('=', s);
      if j < length(s) then
      begin
        tmp := copy(s, j + 1, length(s));
        s := '{$define ' + copy(s, 1, j-1) + ' := ';

        if tmp = 'y' then
          s := s + 'true}'
        else if tmp = 'n' then
          s := s + 'false}'
        else if pos('0x', tmp) > 0 then
        begin
          tmp := StringReplace(tmp, '0x', '$', [rfIgnoreCase]);
          s := s + tmp + '}';
        end
        else if pos('"', tmp) > 0 then
        begin
          tmp := StringReplace(tmp, '"', '''', [rfReplaceAll, rfIgnoreCase]);
          s := s + tmp + '}';
        end
        else
        begin
          val(tmp, v, j);
          if j = 0 then
            s := s + tmp + '}'
          else
            writeln('Error: not sure how to handle value "', tmp, '"');
        end;
        output.Add(s);
      end
      else
        writeln('Line ', i, ': Cannot have "=" at end');
    end;
  end;
end;

var
  inputFile, outputFile: TStringList;
  param1: string;
  fileOK: boolean;

begin
  // First parameter should be path + file name to sdkconfig.
  // If not, assume sdkconfig is located in current folder.
  if (ParamCount = 1) then
    param1 := ParamStr(1)
  else
    param1 := 'sdkconfig';

  fileOK := FileExists(param1);
  if not fileOK then
  begin
    param1 := IncludeTrailingPathDelimiter(param1) + 'sdkconfig';
    fileOK := FileExists(param1);
  end;

  if not fileOK then
    writeln('File "sdkconfig" not found. Please specify full path to sdkconfig file to be converted.')
  else
  begin
    inputFile := TStringList.Create;
    inputFile.LoadFromFile(param1);

    outputFile := TStringList.Create;
    addHeader(outputFile);

    convertToDefine(inputFile, outputFile);
    outputFile.SaveToFile(param1+'.inc');
  end;
  inputFile.Free;
  outputFile.Free;
end.

