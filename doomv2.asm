; ===========================================================================
; DOOM.asm - "Full Source of DOOM" (in reality, a minimal skeleton)
; ===========================================================================
; This single-file assembly code demonstrates a pretend DOOM-like engine.
; It is NOT the real DOOM. The real DOOM source is much larger and mostly in C.
; 
; This code targets x86_64 on macOS. You can run it on Apple Silicon (M1/M2)
; via Rosetta 2 by compiling for x86_64 and using `arch -x86_64 ./doom`.
;
; Usage example:
;   nasm -f macho64 DOOM.asm -o DOOM.o
;   clang -arch x86_64 -o doom DOOM.o -lSDL2
;   arch -x86_64 ./doom
;
; Sections:
;  1) Data (strings, placeholders)
;  2) BSS  (uninitialized memory)
;  3) Text (code)
;     - _main (entry point)
;     - poll_input
;     - update_game
;     - render_frame
;     - print_string, strlen (macOS syscalls)
;
; DISCLAIMER: 
;  This is purely instructional. It won't compile into a real DOOM engine.
;  The real DOOM includes thousands of lines of C/ASM, WAD loading, BSP logic,
;  sprite rendering, advanced input, networking, etc. 
; ===========================================================================
global _main

; -------------------------------------------------------------
; For real SDL usage, you'd declare external references here:
; extern SDL_Init
; extern SDL_CreateWindow
; extern SDL_PollEvent
; extern SDL_RenderClear
; extern SDL_RenderPresent
; extern SDL_Delay
; extern SDL_Quit
; ... etc.
; -------------------------------------------------------------

section .data
; ----------------------------------------------------------------------------
; Data Section: We place constants, strings, or placeholders for initialization.
; ----------------------------------------------------------------------------

welcome_msg: db "Welcome to the 'Full DOOM' (demo skeleton)!", 0
quit_msg:    db "Quitting DOOM...", 0

; Some placeholders for a "player"
player_x:    dq 100.0
player_y:    dq 100.0
player_angle:dq 0.0

; A fake "quit" flag
quit_flag:   db 0

section .bss
; ----------------------------------------------------------------------------
; BSS Section: Reserve uninitialized storage (for buffers, arrays, etc.).
; ----------------------------------------------------------------------------

; Example buffer for any usage (textures, sprite data, etc.)
resb 1024

section .text
; ----------------------------------------------------------------------------
; Code Section: all executable code goes here.
; ----------------------------------------------------------------------------

; ----------------------------------------------------------------------------
; _main: Our program entry point for macOS (x86_64). The C runtime calls _main.
;        We do minimal initialization here, then enter the "DOOM" loop.
; ----------------------------------------------------------------------------
_main:
    push rbp
    mov rbp, rsp

    ; (1) Print welcome message
    lea rdi, [rel welcome_msg]
    call print_string

    ; (2) Initialize platform/libraries (pseudo-steps)
    ;     e.g. SDL_Init, create window, etc.
    ;     mov edi, 0x00000020  ; SDL_INIT_VIDEO
    ;     call SDL_Init
    ;     ... more init if needed

    ; (3) Main game loop
main_loop:
    call poll_input      ; poll for keyboard/mouse/quit
    call update_game     ; run game logic: move player, handle collisions, etc.
    call render_frame    ; draw the scene

    ; Optionally, limit FPS
    ; mov edi, 16        ; ~16 ms for 60 fps
    ; call SDL_Delay

    ; Check if we should quit
    cmp byte [quit_flag], 1
    jne main_loop

    ; (4) Cleanup
    lea rdi, [rel quit_msg]
    call print_string

    ; e.g. SDL_Quit
    ; call SDL_Quit

    ; Return from _main with exit code 0
    mov eax, 0
    leave
    ret

; ----------------------------------------------------------------------------
; poll_input: Minimal placeholder for input handling
; ----------------------------------------------------------------------------
poll_input:
    push rbp
    mov rbp, rsp

    ; Real DOOM-like input code might:
    ;   - call SDL_PollEvent(&event)
    ;   - if (event.type == SDL_QUIT) -> set quit_flag
    ;   - if (keystate[SDL_SCANCODE_W]) -> move forward
    ;   - etc.
    ;
    ; In this skeleton, we'll do a trivial check that eventually sets quit_flag
    ; after some imaginary "frame_count" is reached.
    ;
    ; This is purely illustrative.
    ; 
    ; Example (not real):
    ;   mov rax, [frame_count]
    ;   inc rax
    ;   mov [frame_count], rax
    ;   cmp rax, 500
    ;   jne .done
    ;   mov byte [quit_flag], 1

.done:
    leave
    ret

; ----------------------------------------------------------------------------
; update_game: Very simple game logic placeholder
; ----------------------------------------------------------------------------
update_game:
    push rbp
    mov rbp, rsp

    ; A trivial example: increase player_x by 1.0 each frame
    ; using x87 instructions for demonstration:

    ; load the current player_x into st(0)
    fld qword [player_x]
    ; load 1.0 into st(0)
    fld1
    ; add st(1) += st(0), pop st(0)
    faddp st1, st0
    ; store result back into [player_x]
    fstp qword [player_x]

    leave
    ret

; ----------------------------------------------------------------------------
; render_frame: Minimal placeholder for a DOOM-like 2D or 2.5D scene
; ----------------------------------------------------------------------------
render_frame:
    push rbp
    mov rbp, rsp

    ; In a real engine: 
    ;   1) Clear screen or set up a render target
    ;   2) Draw walls, floors, ceilings, sprites
    ;   3) Present the frame (SDL_RenderPresent, or a custom routine)
    ;
    ; Example (pseudo-SDL):
    ;   call SDL_RenderClear
    ;   call draw_scene
    ;   call SDL_RenderPresent

    leave
    ret

; ----------------------------------------------------------------------------
; print_string: Example helper to write out a zero-terminated string via macOS
; ----------------------------------------------------------------------------
; input: rdi = pointer to string
print_string:
    push rbp
    mov rbp, rsp

    ; macOS syscall to write to stdout:
    ;   syscall # is 0x2000004 for write
    ;   param0 (rax) = 0x2000004
    ;   param1 (rdi) = file descriptor (1 for stdout)
    ;   param2 (rsi) = pointer to buffer
    ;   param3 (rdx) = length
    ;
    ; We'll first compute the string length via our local `strlen` function.
    push rdi                   ; save pointer to the string
    call strlen                ; returns length in rax
    pop rdi                    ; restore string pointer into rdi

    ; Set up registers for the write syscall
    mov rax, 0x2000004         ; write
    mov rdi, 1                 ; file descriptor (stdout)
    mov rsi, rdi               ; pointer to string (still in rdi)
    mov rdx, rax               ; length from strlen (was in rax)
    syscall

    ; Optionally write a newline
    mov rax, 0x2000004         ; write
    mov rdi, 1                 ; stdout
    lea rsi, [rel newline]
    mov rdx, 1                 ; length = 1
    syscall

    leave
    ret

; ----------------------------------------------------------------------------
; strlen: Return the length of a zero-terminated string in RAX
; ----------------------------------------------------------------------------
strlen:
    push rbp
    mov rbp, rsp

    mov rax, 0
.len_loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .len_loop
.done:
    leave
    ret

; ----------------------------------------------------------------------------
; Data for print_string’s newline
; ----------------------------------------------------------------------------
section .data
newline: db 0x0A
