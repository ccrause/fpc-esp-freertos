program testexit;

{$include freertosconfig.inc}
{$inline on}

uses
  esp_sleep, esp_system, portmacro;

var
  // Test of -device isa-debug-exit
  // This requires that isa-debug-exit must be part of the supported devices
  // Use: write exit code to specified register
  // Register address defaults to $501, see:
  // https://github.com/qemu/qemu/blob/7adfbea8fd1efce36019a0c2f198ca73be9d3f18/hw/misc/debugexit.c#L58
  // The port address can be changed with the command line option: -device isa-debug-exit,iobase=0xf4,iosize=0x04
  exit_register: word absolute $501;  // Default isa-debug-exit register

// Register locations   a2 a3 a4 a5
function _simcall(const a, b, c, d: uint32): uint32; assembler;
asm
  simcall
  {$ifdef FPC_ABI_WINDOWED}
    mov a10, a2
  {$endif}
end;

  procedure qemu_exit(const exitcode: uint32); assembler; noreturn;
  asm
    mov  a3, a2   // copy exitcode value into a3
    movi a2, 1    // set a2 to 1 - exit request
    simcall
  end;

var
  ret: uint32;
  c: char;

begin
  writeln('Testing return of exit values from  qemu for ESP32.');
  writeln('The exit code can be inspected as follows after termination of qemu:');
  writeln('Linux (bash): echo $?');
  writeln('Linux (C shell): echo $status');
  writeln('Windows: echo %errorlevel%');
  writeln;
  writeln('Select one of the following numbers to test the particular exit method:');
  writeln('1 - Call simcall with exit code 13 (require -semihosting option for qemu). * Works');
  writeln('2 - Call esp_reboot (require -no-reboot option for qemu). * Works but exit code = 0');
  writeln('3 - Call deep sleep with no wake-up source. Doesn''t work, just goes to sleep.' );
  writeln('4 - Write to isa-debug-exit register (require -device isa-debug-exit support). * Doesn''t work as there isn''t an ISA bus');
  writeln;

  write('Enter a number: ');
  repeat
    c := #0;
    read(c);
    case c of
      #0, #255: ;// do nothing
      '1':
      begin
        writeln('Calling simcall with exit code 13');
        //ret := _simcall(1, 13, 0, 0);
        qemu_exit(11);
        writeln('Something unexpected happened - simcall returned with value:', ret);
      end;

      '2':
      begin
        // Start qemu with the option -no-reboot to exit when rebooting
        writeln('Reboot');
        esp_restart;
      end;

      '3':
      begin
        // Call deep sleep with no wakeup source set
        writeln('Calling deep sleep');
        esp_sleep_disable_wakeup_source(ESP_SLEEP_WAKEUP_ALL);
        portENTER_CRITICAL;
        esp_deep_sleep_start;
        portEXIT_CRITICAL; // Not supposed to get here, but I like the symmetry
      end;

      '4':
      begin
        // Start qemu with the option -no-reboot to exit when rebooting
        writeln('Write 13 to isa-debug-exit register (@ $', HexStr(@exit_register),')');
        exit_register := 13;
      end;
    else
      writeln('Unexpected character code: $', HexStr(word(c), 2));
    end;
  until false;
end.
