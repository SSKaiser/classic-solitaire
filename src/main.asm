; main.asm
; this game is a recreation of solitaire from IBM on dos but it is NOT a port : there's no source available for the original version.
; there are multiple display options on the IBM version. This one simply takes

bits 64
default rel

%include 'src\macros.inc'
;%include definitions.inc
%define u(x) __?utf16?__(x)

extern ExitProcess
extern FreeConsole
extern GetStdHandle
extern WriteConsoleW
extern wsprintfW
extern GetConsoleScreenBufferInfo
extern ReadConsoleInputW
extern FillConsoleOutputCharacterW
extern SetConsoleCursorPosition
extern QueryPerformanceCounter
extern Beep
extern SetConsoleTextAttribute

FOREGROUND_BLUE:            equ 0x0001
FOREGROUND_GREEN:           equ 0x0002
FOREGROUND_RED:             equ 0x0004
FOREGROUND_WHITE:           equ 00111b
FOREGROUND_INTENSITY:       equ 0x0008
BACKGROUND_BLUE:            equ 0x0010
BACKGROUND_GREEN:           equ 0x0020
BACKGROUND_RED:             equ 0x0040
BACKGROUND_INTENSITY:       equ 0x0080
COMMON_LVB_LEADING_BYTE:    equ 0x0100
COMMON_LVB_TRAILING_BYTE:   equ 0x0200
COMMON_LVB_GRID_HORIZONTAL: equ 0x0400
COMMON_LVB_GRID_LVERTICAL:  equ 0x0800
COMMON_LVB_GRID_RVERTICAL:  equ 0x1000
COMMON_LVB_REVERSE_VIDEO:   equ 0x4000
COMMON_LVB_UNDERSCORE:      equ 0x8000

SECTION .bss
stdout:         resq 1
stdin:          resq 1
csbi:           resw 15
cards:          resw 52*2
fmtbuffer:      resb 3*256
time:           resq 1
inputrecord:    resb 20
uselessptr:     resd 1
coord:          resw 2
rect:           resq 1
deck:           resd 24
colHidden:      resd 21
colShown:       resd 13*7




SECTION .data
playkeys:       db 'ATBCDEFGH', 20h
foundationslen: db 0, 0, 0, 0
decklen:        db 24
logs:           dw u('logged'), 0
talonlen:       db 0
colHiddenlen:   db 1, 2, 3, 4, 5, 6
colShownlen:    db 7 dup (1)
newline:        dw 10, 0
suits:          dw 9824, 9829, 9827, 9830
values:         dw u('A23456789XJQK') ; X will be changed to 10 during printing, to preserve memory space
unhandlederror: dw u("An unhandled exception occured"),10, 0
eventsnum:      dd 0
menutext:          dd u("S O L I T A I R E !Main MenuSelect an option:1. Turn 1, single pass2. Turn 3, multi pass3. Turn 2, multi pass4. Turn 1, multi pass5. Set game optionsF1: Help                    Esc: Exit"), 0
errormsg2:      dw u("Console too small <%hu,%hu>/<80,24>. Resize your console to the required height and width then press any key"), 10,0


SECTION .text
global main
main:
    sub rsp,    32
    mov rcx,   -11
    call GetStdHandle
    testfail
    mov [stdout], rax

    mov rcx,   -10
    call GetStdHandle
    testfail
    mov [stdin],  rax
    add rsp, 32
    jmp sizeok

    
    getconsolesize:
        clr
        sub rsp, 32
        mov rcx, [stdout]
        mov rdx, csbi
        call GetConsoleScreenBufferInfo
        ;testfail
        cmp word [csbi], 80
        jb errorsize
        cmp word [csbi+2], 24
        jb errorsize
        jmp sizeok

    errorsize:
        clr
        sub rsp, 32
        mov rcx, fmtbuffer
        mov rdx, errormsg2
        movzx r8, word[csbi]
        movzx r9, word [csbi+2]
        call wsprintfW
        add rsp, 32

        print fmtbuffer

        expectkey 0
        jmp getconsolesize
    
    sizeok:
        xor rax, rax
        xor rbx, rbx
        xor rcx, rcx
        xor rdx, rdx
        mov r8, values
        mov r9, suits
        mov r10, cards
    makecard:
        mov dx, [r9+rbx*2]
        shl edx, 16
        mov dx, [r8+rax*2]
        mov dword [r10+rcx*4], edx
        inc rcx
        cmp rax, 12
        jz newcolor
        inc rax
        jmp makecard
        newcolor:
        xor rax, rax
        cmp rbx, 3
        jz shuffleinit
        inc rbx
        jmp makecard

    shuffleinit:
        sub rsp, 32
        mov rcx, time
        call QueryPerformanceCounter
        add rsp, 32
        mov r8, cards
        mov rcx, time
        mov rax, [rcx]
        xor rcx, rcx
    shuffle: 
        mov rbx, 0x111
        mul rbx
        xor rdx, rdx
        add rax, 0x111
        mov rbx, 52
        push rax
        div rbx
        pop rax
        mov r9d, [r8+rcx*4]
        mov r10d, [r8+rdx*4]
        mov dword [r8+rcx*4], r10d
        mov dword [r8+rdx*4], r9d
        cmp rcx, 51
        jz distribute
        inc rcx
        jmp shuffle

    mainmenu:
        clr
        mov rcx, [stdout]
        mov rdx, FOREGROUND_GREEN
        call SetConsoleTextAttribute
        mov r12, menutext
        movecursor 1Eh, 1
        printlen r12, 19
        add r12, 19*2

        mov rcx, [stdout]
        mov rdx, FOREGROUND_WHITE
        call SetConsoleTextAttribute

        movecursor 23h, 3
        printlen r12, 9
        add r12, 9*2

        movecursor 1Bh, 7
        printlen r12, 17
        add r12, 17*2

        movecursor 1Dh, 9
        printlen r12, 22
        add r12, 22*2

        movecursor 1Dh, 11
        printlen r12, 21
        add r12, 21*2

        movecursor 1Dh, 13
        printlen r12, 21
        add r12, 21*2

        movecursor 1Dh, 15
        printlen r12, 21
        add r12, 21*2

        movecursor 1Dh, 17
        printlen r12, 19
        add r12, 19*2

        movecursor 16h, 18h
        print r12

    distribute:
        mov rsi, cards
        mov rdi, deck
        mov rcx, 24
        rep movsd
        
        mov rdi, colHidden
        mov rcx, 21
        rep movsd

        printlen deck, 48
        print newline
        printlen colHidden, 42
        

    xor rcx, rcx
    call ExitProcess