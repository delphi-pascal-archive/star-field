program stars;

uses
  windows, Messages;

const
 StarCount=1000;

type
 TStar=record
 X,Y,Z:integer;
 vx,vy,vc:integer;
end;

var
 hWnd:THandle;
 Msg:TMsg;
 Star:array[0..StarCount-1] of TStar;
 xcenter:integer;
 ycenter:integer;
 starsize:integer;

function StarProc(hWnd: THandle; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
 Result:=0; // default reply
 case msg of
  WM_SIZE   : begin
               xcenter:=(lparam and $ffff)  shr 1;
               ycenter:=(lparam shr 17);
               starsize:=xcenter+ycenter;
              end;
  WM_DESTROY: PostQuitMessage(0);
  else Result:=(DefWindowProc(hWnd, msg, wParam, lParam));
 end;
end;


Function RegisterMe:boolean;
 var
  wc:TWndClass;
 begin
  // Register the window class for my window
  wc.style :=  0;                      // Class style.
  wc.lpfnWndProc := @StarProc;         // Window procedure for this class.
  wc.cbClsExtra := 0;                  // No per-class extra data.
  wc.cbWndExtra := 0;                  // No per-window extra data.
  wc.hInstance := hInstance;           // Application that owns the class.
  wc.hIcon := 0;                       // no icon
  wc.hCursor := LoadCursor(0, IDC_ARROW); // defaut cursor
  wc.hbrBackground := GetStockObject(BLACK_BRUSH); // black screen
  wc.lpszMenuName := nil ;   // Name of menu resource in .RC file.
  wc.lpszClassName := 'StarWindow'; // Name used in call to CreateWindow.
  result:=(RegisterClass(wc)<>0);
 end;

Function StartMe:boolean;
 begin
  // Create a main window for this application instance.
  hWnd := CreateWindow(
        'StarWindow',    // registered class name
        'Sample StarField application',
        WS_OVERLAPPEDWINDOW,            // Window style.
        cw_usedefault,                  // Default horizontal position.
        cw_usedefault,                  // Default vertical position.
        cw_usedefault,                  // Default width.
        cw_usedefault,                  // Default height.
        0,                              // Overlapped windows have no parent.
        0,                              // Use the window class menu.
        hInstance,                      // This instance owns this window.
        nil                             // Pointer not needed.
    );
   StartMe:=(HWnd<>0);
 end;

Procedure InitStars;
 var
  s:integer;
 begin
  for s:=0 to StarCount-1 do
   With Star[s] do begin
    vx:=-1;
    vy:=-1;
    vc:=0;
    x:=(Random(2*xCenter)-xCenter) shl 7;
    y:=(Random(2*yCenter)-yCenter) shl 7;
    z:=s+1;
   end;
 end;

Procedure DrawStars;
 var
  DC:hDC;
  s:integer;
  c:integer;
 begin
  if (xcenter=0)or(ycenter=0) then exit;
  DC:=GetDC(HWnd);
  for s:=0 to StarCount-1 do
   with Star[s] do begin
    PatBlt(DC,vx,vy,vc,vc,BlackNess);
    vc:=starsize div z;
    vx:=x div z + xcenter - vc;
    vy:=y div z + ycenter - vc;
    PatBlt(DC,vx,vy,vc,vc,WhiteNess);
    dec(z,3);
    if z<1 then begin
     z:=StarCount;
     x:=(Random(2*xCenter)-xCenter) shl 7;
     y:=(Random(2*yCenter)-yCenter) shl 7;
    end;
   end;
  ReleaseDC(HWnd,DC);
 end;

begin
 If RegisterMe and StartMe then begin
   // Make the window visible; update its client area
    ShowWindow(hWnd, CmdShow);
    UpdateWindow(hWnd);
    InitStars;
    Repeat
     DrawStars;
     if PeekMessage(Msg,0,0,0,pm_remove) then begin
      TranslateMessage(msg);    // Translates virtual key codes.
      DispatchMessage(msg);     // Dispatches message to window.
     end;
    until Msg.Message=WM_QUIT;
end;

end.
