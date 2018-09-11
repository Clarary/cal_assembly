.386 
.model flat,stdcall 
option casemap:none 
include \masm32\include\windows.inc 
include \masm32\include\user32.inc 
include \masm32\include\kernel32.inc 
include \masm32\include\gdi32.inc 
includelib \masm32\lib\user32.lib 
includelib \masm32\lib\kernel32.lib 
includelib \masm32\lib\gdi32.lib 
include C:\masm32\include\shell32.inc 
includelib C:\masm32\lib\shell32.lib 

RGB macro red,green,blue 
        xor eax,eax 
        mov ah,blue 
        shl eax,8 
        mov ah,green 
        mov al,red 
endm 

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
addf proto :HWND
subf proto :HWND
mulf proto :HWND
divf proto :HWND
clear proto
errorf proto :DWORD,:DWORD
checkchara proto
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.DATA                                  ; initialized data 
ClassName db "SimpleWinClass",0        ; the name of our window class
ButtonClassName db "button",0 
EditClassName db "edit",0 
AppName db "简易计算器",0              ; the name of our window
MenuName  db "FirstMenu",0             ; menu name
IntroText db "Help",0
IntroName db "A simple calculator",0DH,0
jia db "+",0
jian db "-",0
cheng db "*",0
chu db "/",0
jia_ db "=",0
jian_ db "=",0
cheng_ db "=",0
chu_ db "=",0
titletext db "A simple calculator",0
szURL db "https://github.com/Clarary/",0 
szOpen db "open",0 
errorName db "Error!",0
errorText1 db "Error!character input!",0
errorText2 db "Error!Divide 0 error!",0
errorText3 db "There is no input!",0
buffer1 dd 32 dup(20H),0          ; buffer to store the text retrieved from the edit box1
buffer2 dd 32 dup(20H),0          ; buffer to store the text retrieved from the edit box2
;------------------------------------------------------------------------------------------------------
.DATA?                       ; Uninitialized data 
hInstance HINSTANCE ?        ; Instance handle of our program 
CommandLine LPSTR ? 
hMenu HMENU ? 
hwndButton1 HWND ? 
hwndButton2 HWND ? 
hwndButton3 HWND ? 
hwndButton4 HWND ? 
hwndEdita1 HWND ? 
hwndEdita2 HWND ? 
hwndEditb1 HWND ? 
hwndEditb2 HWND ? 
hwndEditc1 HWND ? 
hwndEditc2 HWND ? 
hwndEditd1 HWND ? 
hwndEditd2 HWND ? 
hwndEditar HWND ? 
hwndEditbr HWND ? 
hwndEditcr HWND ? 
hwndEditdr HWND ? 
bufferr dd 32 dup(?)        ; buffer to store the result
bool1 dd ?
bool2 dd ?
;------------------------------------------------------------------------------------------------------
.const 
ButtonID_1 equ 21                             ; The control ID of the button control 
ButtonID_2 equ 22
ButtonID_3 equ 23
ButtonID_4 equ 24
IDM_INTRO equ 1 
IDM_GIT equ 2
IDM_CLEAR equ 3
IDM_EXIT equ 4
EditIDa1 equ 1
EditIDa2 equ 2
EditIDb1 equ 3
EditIDb2 equ 4
EditIDc1 equ 5
EditIDc2 equ 6
EditIDd1 equ 7
EditIDd2 equ 8
EditIDar equ 9
EditIDbr equ 10
EditIDcr equ 11
EditIDdr equ 12
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.CODE                                        ; Here begins our code 
start: 
invoke GetModuleHandle, NULL                 ; get the instance handle of our program. 
                                             ; Under Win32, hmodule==hinstance mov hInstance,eax 
mov hInstance,eax 
invoke GetCommandLine                        ; get the command line. You don't have to call this function IF 
                                             ; your program doesn't process the command line. 
mov CommandLine,eax 
invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT      ; call the main function 
invoke ExitProcess, eax                      ; quit our program. The exit code is returned in eax from WinMain.
;------------------------------------------------------------------------------------------------------
WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX                      ; create local variables on stack 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    mov   wc.cbSize,SIZEOF WNDCLASSEX        ; fill values in members of wc 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInstance 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_WINDOW+1 
    mov   wc.lpszMenuName,offset MenuName 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke LoadMenu, hInst, OFFSET MenuName 
	mov   hMenu, eax 
    invoke RegisterClassEx, addr wc          ; register our window class 
    invoke CreateWindowEx,NULL,\ 
                ADDR ClassName,\ 
                ADDR AppName,\ 
                WS_OVERLAPPEDWINDOW,\ 
                10,\                         ; X
                10,\                         ; Y
                450,\                        ; nWidth
                300,\                        ; nHeight
                NULL,\ 
				hMenu,\
                hInst,\ 
                NULL 
    mov   hwnd,eax 
    invoke ShowWindow, hwnd,CmdShow          ; display our window on desktop 
    invoke UpdateWindow, hwnd                ; refresh the client area

    .WHILE TRUE                              ; Enter message loop 
                invoke GetMessage, ADDR msg,NULL,0,0 
                .BREAK .IF (!eax) 
                invoke TranslateMessage, ADDR msg 
                invoke DispatchMessage, ADDR msg 
   .ENDW 
    mov     eax,msg.wParam                   ; return exit code in eax 
    ret 
WinMain endp 
;------------------------------------------------------------------------------------------------------
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
	LOCAL hdc:HDC
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL rect1:RECT
    LOCAL rect2:RECT
    LOCAL rect3:RECT
    LOCAL rect4:RECT
    .IF uMsg==WM_DESTROY                          ; if the user closes our window 
        invoke PostQuitMessage,NULL               ; quit our application
    .ELSEIF uMsg==WM_CREATE
    	;8 input editbox
    	invoke CreateWindowEx,WS_EX_CLIENTEDGE, \ 
                        ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT\ 
                        or ES_AUTOHSCROLL,\ 
                        50,50,80,25,hWnd,EditIDa1,hInstance,NULL 
        mov  hwndEdita1,eax 
        invoke SetFocus, hwndEdita1
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, \ 
                        ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT\ 
                        or ES_AUTOHSCROLL,\ 
                        150,50,80,25,hWnd,EditIDa2,hInstance,NULL 
        mov  hwndEdita2,eax
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, \ 
                        ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT\ 
                        or ES_AUTOHSCROLL,\ 
                        50,90,80,25,hWnd,EditIDb1,hInstance,NULL 
        mov  hwndEditb1,eax
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, \ 
                        ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT\ 
                        or ES_AUTOHSCROLL,\ 
                        150,90,80,25,hWnd,EditIDb2,hInstance,NULL 
        mov  hwndEditb2,eax
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, \ 
                        ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT\ 
                        or ES_AUTOHSCROLL,\ 
                        50,130,80,25,hWnd,EditIDc1,hInstance,NULL 
        mov  hwndEditc1,eax
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, \ 
                        ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT\ 
                        or ES_AUTOHSCROLL,\ 
                        150,130,80,25,hWnd,EditIDc2,hInstance,NULL 
        mov  hwndEditc2,eax
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, \ 
                        ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT\ 
                        or ES_AUTOHSCROLL,\ 
                        50,170,80,25,hWnd,EditIDd1,hInstance,NULL 
        mov  hwndEditd1,eax
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, \ 
                        ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT\ 
                        or ES_AUTOHSCROLL,\ 
                        150,170,80,25,hWnd,EditIDd2,hInstance,NULL 
        mov  hwndEditd2,eax  
        ;4 result editbox
    	invoke CreateWindowEx,WS_EX_CLIENTEDGE, \ 
                        ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or WS_DISABLED or ES_LEFT\ 
                        or ES_AUTOHSCROLL,\ 
                        300,50,80,25,hWnd,EditIDar,hInstance,NULL 
        mov  hwndEditar,eax 
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, \ 
                        ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or WS_DISABLED or ES_LEFT\ 
                        or ES_AUTOHSCROLL,\ 
                        300,90,80,25,hWnd,EditIDbr,hInstance,NULL 
        mov  hwndEditbr,eax
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, \ 
                        ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or WS_DISABLED or ES_LEFT\ 
                        or ES_AUTOHSCROLL,\ 
                        300,130,80,25,hWnd,EditIDcr,hInstance,NULL 
        mov  hwndEditcr,eax
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, \ 
                        ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or WS_DISABLED or ES_LEFT\ 
                        or ES_AUTOHSCROLL,\ 
                        300,170,80,25,hWnd,EditIDdr,hInstance,NULL 
        mov  hwndEditdr,eax        
    	;+-*/ 4buttons
    	invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR jia_,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        250,50,40,25,hWnd,ButtonID_1,hInstance,NULL 
        mov  hwndButton1,eax 
    	invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR jian_,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        250,90,40,25,hWnd,ButtonID_2,hInstance,NULL 
        mov  hwndButton2,eax
    	invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR cheng_,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        250,130,40,25,hWnd,ButtonID_3,hInstance,NULL 
        mov  hwndButton3,eax 
        invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR chu_,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        250,170,40,25,hWnd,ButtonID_4,hInstance,NULL 
        mov  hwndButton4,eax 
    .ELSEIF uMsg==WM_COMMAND 
        mov eax,wParam 
        .IF lParam==0                              ;the menu command
            .IF ax==IDM_INTRO
	            invoke MessageBox,NULL,ADDR IntroName,ADDR IntroText,MB_OK
            .ELSEIF ax==IDM_GIT
                invoke ShellExecute,NULL,addr szOpen,addr szURL,NULL,NULL,SW_SHOWNORMAL
            .ELSEIF ax==IDM_CLEAR
                invoke clear
            .ELSEIF  ax==IDM_EXIT
                invoke DestroyWindow,hWnd 
            .ENDIF 
        .ELSE                                      ;the button command
            .IF ax==ButtonID_1
                ;do something
                	invoke addf,hWnd
                nop
            .ENDIF
            .IF ax==ButtonID_2
                ;do something
                	invoke subf,hWnd
                nop
            .ENDIF 
            .IF ax==ButtonID_3
                ;do something
                	invoke mulf,hWnd
                nop
            .ENDIF 
            .IF ax==ButtonID_4
                ;do something
                	invoke divf,hWnd
                nop
            .ENDIF
        .ENDIF 
    .ELSEIF uMsg==WM_PAINT 
       invoke BeginPaint,hWnd, ADDR ps 
        mov    hdc,eax
        ;+
        RGB 255,0,0                               ;the color of the text
		invoke SetTextColor,hdc,eax
		RGB 255,255,255                            ;the color of the background
		invoke SetBkColor,hdc,eax
        invoke GetClientRect,hWnd, ADDR rect1
        sub    rect1.top,120 
        sub    rect1.left,150
        invoke DrawText, hdc,ADDR jia,-1, ADDR rect1, \ 
                DT_SINGLELINE or DT_CENTER or DT_VCENTER 
        ;-
        RGB 180,180,0                              ;the color of the text
		invoke SetTextColor,hdc,eax
		RGB 255,255,255                            ;the color of the background
		invoke SetBkColor,hdc,eax
        invoke GetClientRect,hWnd, ADDR rect2
        sub    rect2.top,40 
        sub    rect2.left,150
        invoke DrawText, hdc,ADDR jian,-1, ADDR rect2, \ 
                DT_SINGLELINE or DT_CENTER or DT_VCENTER 
        ;*
        RGB 0,0,255                                ;the color of the text
		invoke SetTextColor,hdc,eax
		RGB 255,255,255                            ;the color of the background
		invoke SetBkColor,hdc,eax
        invoke GetClientRect,hWnd, ADDR rect3
        add    rect3.top,40
        sub    rect3.left,150 
        invoke DrawText, hdc,ADDR cheng,-1, ADDR rect3, \ 
                DT_SINGLELINE or DT_CENTER or DT_VCENTER 
        ;/
        RGB 0,255,0                                ;the color of the text
		invoke SetTextColor,hdc,eax
		RGB 255,255,255                            ;the color of the background
		invoke SetBkColor,hdc,eax
        invoke GetClientRect,hWnd, ADDR rect4
        add    rect4.top,120
        sub    rect4.left,150
        invoke DrawText, hdc,ADDR chu,-1, ADDR rect4, \ 
                DT_SINGLELINE or DT_CENTER or DT_VCENTER 
        ;title
        ;/
        RGB 0,255,0                                ;the color of the text
		invoke SetTextColor,hdc,eax
		RGB 255,255,255                            ;the color of the background
		invoke SetBkColor,hdc,eax
        invoke GetClientRect,hWnd, ADDR rect
        sub    rect.top,180
        invoke DrawText, hdc,ADDR titletext,-1, ADDR rect, \ 
                DT_SINGLELINE or DT_CENTER or DT_VCENTER 
        invoke EndPaint,hWnd, ADDR ps 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam; Default message processing 
        ret 
    .ENDIF 
    xor eax,eax 
    ret 
WndProc endp
;------------------------------------------------------------------------------------------------------
addf proc hWnd:HWND
    LOCAL num1:DWORD
    LOCAL num2:DWORD
    LOCAL len1:DWORD
    LOCAL len2:DWORD
	PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH ESI
    PUSH EDI
    invoke GetWindowTextLength,hwndEdita1
    .IF eax==0
    	invoke errorf,addr errorText3,addr errorName
    	ret
    .endif
    ADD eax,1
    MOV len1,eax
    invoke GetWindowTextLength,hwndEdita2
    .IF eax==0
    	invoke errorf,addr errorText3,addr errorName
    	ret
    .endif
    ADD eax,1
    MOV len2,eax
    invoke GetWindowText,hwndEdita1,ADDR buffer1,len1 ;get the first num
    invoke GetWindowText,hwndEdita2,ADDR buffer2,len2 ;get the second num
    ;transfer and save to eax and ebx
    invoke checkchara
    .IF edx==-1
    	je re                ;error return
    .ENDIF
    invoke GetDlgItemInt,hWnd,EditIDa1,bool1,FALSE ;get the first num
    mov num1,eax
    invoke GetDlgItemInt,hWnd,EditIDa2,bool2,FALSE ;get the second num
    ;transfer and save to eax and ebx
    mov num2,eax
    add eax,num1
    mov num1,eax
    invoke SetDlgItemInt,hWnd,EditIDar,num1,FALSE
re:
	POP EDI
	POP ESI
	POP EDX
    POP ECX
    POP EBX
    POP EAX
	ret
addf endp
;------------------------------------------------------------------------------------------------------
subf proc hWnd:HWND
	LOCAL num1:DWORD
    LOCAL num2:DWORD
    LOCAL len1:DWORD
    LOCAL len2:DWORD
	PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH ESI
    PUSH EDI
    invoke GetWindowTextLength,hwndEditb1
    .IF eax==0
    	invoke errorf,addr errorText3,addr errorName
    	ret
    .endif
    ADD eax,1
    MOV len1,eax
    invoke GetWindowTextLength,hwndEditb2
    .IF eax==0
    	invoke errorf,addr errorText3,addr errorName
    	ret
    .endif
    ADD eax,1
    MOV len2,eax
    invoke GetWindowText,hwndEditb1,ADDR buffer1,len1 ;get the first num
    invoke GetWindowText,hwndEditb2,ADDR buffer2,len2 ;get the second num
    ;transfer and save to eax and ebx
    invoke checkchara
    .IF edx==-1
    	je re                ;error return
    .ENDIF
    invoke GetDlgItemInt,hWnd,EditIDb1,bool1,FALSE ;get the first num
    mov num1,eax
    invoke GetDlgItemInt,hWnd,EditIDb2,bool2,FALSE ;get the second num
    ;transfer and save to eax and ebx
    mov num2,eax
    mov eax,num1
    sub eax,num2
    mov num1,eax
    invoke SetDlgItemInt,hWnd,EditIDbr,num1,TRUE
re:
	POP EDI
	POP ESI
	POP EDX
    POP ECX
    POP EBX
    POP EAX
	ret
subf endp
;------------------------------------------------------------------------------------------------------
mulf proc hWnd:HWND
	LOCAL num1:DWORD
    LOCAL num2:DWORD
    LOCAL len1:DWORD
    LOCAL len2:DWORD
	PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH ESI
    PUSH EDI
    invoke GetWindowTextLength,hwndEditc1
    .IF eax==0
    	invoke errorf,addr errorText3,addr errorName
    	ret
    .endif
    ADD eax,1
    MOV len1,eax
    invoke GetWindowTextLength,hwndEditc2
    .IF eax==0
    	invoke errorf,addr errorText3,addr errorName
    	ret
    .endif
    ADD eax,1
    MOV len2,eax
    invoke GetWindowText,hwndEditc1,ADDR buffer1,len1 ;get the first num
    invoke GetWindowText,hwndEditc2,ADDR buffer2,len2 ;get the second num
    ;transfer and save to eax and ebx
    invoke checkchara
    .IF edx==-1
    	je re                ;error return
    .ENDIF
    invoke GetDlgItemInt,hWnd,EditIDc1,bool1,FALSE ;get the first num
    mov num1,eax
    invoke GetDlgItemInt,hWnd,EditIDc2,bool2,FALSE ;get the second num
    ;transfer and save to eax and ebx
    mov num2,eax
    mov eax,num1
    mul num2
    mov num1,eax
    invoke SetDlgItemInt,hWnd,EditIDcr,num1,TRUE
re:
	POP EDI
	POP ESI
	POP EDX
    POP ECX
    POP EBX
    POP EAX
	ret
mulf endp
;------------------------------------------------------------------------------------------------------
divf proc hWnd:HWND
	LOCAL num1:DWORD
    LOCAL num2:DWORD
    LOCAL len1:DWORD
    LOCAL len2:DWORD
	PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH ESI
    PUSH EDI
    invoke GetWindowTextLength,hwndEditd1
    .IF eax==0
    	invoke errorf,addr errorText3,addr errorName
    	ret
    .endif
    ADD eax,1
    MOV len1,eax
    invoke GetWindowTextLength,hwndEditd2
    .IF eax==0
    	invoke errorf,addr errorText3,addr errorName
    	ret
    .endif
    ADD eax,1
    MOV len2,eax
    invoke GetWindowText,hwndEditd1,ADDR buffer1,len1 ;get the first num
    invoke GetWindowText,hwndEditd2,ADDR buffer2,len2 ;get the second num
    ;transfer and save to eax and ebx
    invoke checkchara
    .IF edx==-1
    	je re                ;error return
    .ENDIF
    invoke GetDlgItemInt,hWnd,EditIDd1,bool1,FALSE ;get the first num
    mov num1,eax
    invoke GetDlgItemInt,hWnd,EditIDd2,bool2,FALSE ;get the second num
    mov num2,eax
    .IF eax==0
    	invoke errorf,addr errorText2,addr errorName ;divide 0
    	ret
    .endif
    mov eax,num1
    mov ebx,num2
    xor edx,edx
    div ebx
    mov num1,eax
    invoke SetDlgItemInt,hWnd,EditIDdr,num1,TRUE
re:
	POP EDI
	POP ESI
	POP EDX
    POP ECX
    POP EBX
    POP EAX
	ret
divf endp
;------------------------------------------------------------------------------------------------------
checkchara proc
	XOR esi,esi
lop1:
    MOV ecx,buffer1[esi*4 ]
    cmp ecx,0
    jz next
    cmp ecx,20H
    jz next
    mov al,cl
    sub al,30h ;-30将ASCII转为对应数
    jb err ;小于0，则不是有效字符，要求重新输入
    cmp al,9
    ja err
    add esi,1
    jmp lop1
err:
	invoke errorf,addr errorText1,addr errorName
	mov edx,-1
	ret
next:
	XOR esi,esi
lop2:
	MOV ecx,buffer2[esi*4]
    cmp ecx,0
    jz next2
    cmp ecx,20H
    jz next2
    mov al,cl
    sub al,30H
    jb err ;小于0，则不是有效字符，要求重新输入
    cmp al,9
    ja err
    add esi,1
    jmp lop2
next2:
	ret       ;return,check finished
checkchara endp
;------------------------------------------------------------------------------------------------------
clear proc                            ;clear all
	invoke SetWindowText,hwndEdita1,NULL
	invoke SetWindowText,hwndEdita2,NULL
	invoke SetWindowText,hwndEditb1,NULL
	invoke SetWindowText,hwndEditb2,NULL
	invoke SetWindowText,hwndEditc1,NULL
	invoke SetWindowText,hwndEditc2,NULL
	invoke SetWindowText,hwndEditd1,NULL
	invoke SetWindowText,hwndEditd2,NULL
	invoke SetWindowText,hwndEditar,NULL
	invoke SetWindowText,hwndEditbr,NULL
	invoke SetWindowText,hwndEditcr,NULL
	invoke SetWindowText,hwndEditdr,NULL 
	ret
clear endp
;------------------------------------------------------------------------------------------------------
errorf proc ErrorName:DWORD,ErrorText:DWORD
	
	invoke MessageBox,NULL,ErrorName,ErrorText,MB_OK
	ret

errorf endp
;------------------------------------------------------------------------------------------------------
end start
code ends