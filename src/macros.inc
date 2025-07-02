; macros.inc

%macro testfail 0
    cmp rax, 0
    jnz %%good
    mov rcx, -1
    sub rsp, 32
    print unhandlederror
    call ExitProcess
    %%good:
%endmacro

%macro print 1
    sub rsp, 32
    xor r8, r8
    mov rcx, [stdout]
    mov rdx, %1
    %%lenloop:
        mov ax, [rdx + r8*2]
        cmp ax, 0
        je %%done
        inc r8
        jmp %%lenloop
    %%done:
        mov r9, 0
        call WriteConsoleW
    add rsp, 32
%endmacro

%macro printlen 2 ; print macro but length specified directly
    sub rsp, 40
    mov rcx, [stdout]
    mov rdx, %1
    mov r8, %2
    mov r9, 0
    mov qword [rsp+32], 0
    call WriteConsoleW
    add rsp, 40
%endmacro

%macro expectkey 1 ; pass 0 for any and get num in rax, pass >1 for
    sub rsp, 32
    %if %1 = 0
        %%inputloop0:
            mov rcx, [stdin]
            mov rdx, inputrecord
            mov r8, 1
            mov r9, eventsnum
            call ReadConsoleInputW
            cmp word [inputrecord], 1
            jnz %%inputloop0
            cmp dword [inputrecord+2], 0
            jnz %%inputloop0

        add rsp, 32
        mov eax, [inputrecord+4]
        sub rsp, 32
    %else
        %%inputloop1:
            mov rcx, [stdin]
            mov rdx, inputrecord
            mov r8, 1
            mov r9, eventsnum
            call ReadConsoleInputW

            cmp word [inputrecord], 1
            jnz %%inputloop1
            cmp dword [inputrecord+2], 0
            jnz %%inputloop1
            cmp word [inputrecord+10], %1
            jnz %%inputloop1
    %endif
    xor rax, rax
    mov rcx, 20
    mov rdi, inputrecord
    rep stosb
    add rsp, 32
%endmacro

%macro clr 0
    sub rsp, 40
    mov rcx, [stdout]
    movzx rax, word [csbi]
    movzx rbx, word [csbi+2]
    mul rbx
    mov rdx, 0
    mov r8, rax
    xor r9, r9
    mov rax, uselessptr
    mov qword [rsp + 32], rax
    call FillConsoleOutputCharacterW
    add rsp, 32
%endmacro

%macro movecursor 2
    sub rsp, 32
    mov word [coord], %1
    mov word [coord+2], %2
    mov rcx, [stdout]
    mov edx, [coord]
    call SetConsoleCursorPosition
    add rsp, 32
%endmacro

%macro expectmove 0
    %%expect:
        expectkey
        %ifn rax == 'A' || rax == 'B' || rax == 'C' || rax == 'D' || rax == 'E' || rax == 'F' || rax == 'G' || rax == 'H' || rax == 'T'
            jmp %%expect
        %endif
%endmacro

%macro getvalidmoves 1

%endmacro

%macro displaycard 1
    
%endmacro