; Rezidentinė programa
; 
; 
; Nustatome 88 pertraukimą
; 
%include 'yasmmac.inc'          ; Pagalbiniai makrosai
;------------------------------------------------------------------------
org 100h                        ; visos COM programos prasideda nuo 100h
                                ; Be to, DS=CS=ES=SS !

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text                   ; kodas prasideda cia 
    Pradzia:
      jmp     Nustatymas                           ;Pirmas paleidimas
    Senas_I88:
      dw      0, 0

    procRasyk:                      ;Nadosime doroklyje 
      jmp .toliau                                  ;Praleidziame teksta
    
    .tekstas:
      db  'Laikas ...',0Dh, 0Ah
     .CR:
      db   0Dh, 0Ah,'$' 
    
    .ciklai:                                     ;Kiek laikmacio ciklu jau praejo
      dw 0
    
    .toliau:                                     ;Pradedame apdorojima
      push ds
      push cs
      pop ds
      inc word  [.ciklai]                          ; ciklai++
      cmp word  [.ciklai],  0001                   ; ciklai >= 1?
      jl .toliau2                                   ; jeigu ne - iseiname
      mov word [.ciklai], 0000                    ; ciklai = 0  
      call  procRaudonasEkranas
      mov ah, 09
      mov dx, .tekstas
      int 21h                                      ; isvedame  teksta
    .toliau2:    
      pop ds
      ret                                          ; griztame is proceduros
;end procRasyk

procRaudonasEkranas:                               ;Nadosime doroklyje 
      jmp .daryk
      .rezimas:
      dw  0013h
    
      .daryk:
      macPushAll
    
      cmp word  [cs:.rezimas], 0003h               ; 03 -> tekstinis rezimas
      jne .t1
      mov word  [cs:.rezimas], 0013h               ; 13 -> 320x200x256 rezimas
      jmp .t2
      .t1:
      mov word [cs:.rezimas], 0003h
      .t2:
      mov ax, word [cs:.rezimas]                  ; nustatome reikiama rezima
      int 0x10
      mov di,0000h
      mov ax,0A000h                                  ; Nuo A0000 - grafine atmintis
      mov es, ax
      mov cx, 7FFFh
      mov ax, 0C0Ch
      rep stosw                                      ; pildome grafine atminti  
      
      mov ax, 0003h
      int 10h
      macPopAll    
      ret 
;end procRaudonasEkranas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
Naujas_I88:                                            ; Doroklis prasideda cia
    
      macPushAll                                       ; Saugome registrus
      call  procRasyk                                  ; 
      mov ax, 0xb800
      mov es, ax
      mov ax, 0x6F41
      mov di, 0000 
      mov cx, 0xa0
      rep stosw
      macPopAll                                       ; 
    

      iret                                         ; Griztame is pertraukimo 

    ;

;
;
;  Rezidentinio bloko pabaiga
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Nustatymo (po pirmo paleidimo) blokas: jis NELIEKA atmintyje
;
;

 
Nustatymas:
        ; Gauname sena 88h  vektoriu
        push    cs
        pop     ds
        mov     ax, 3588h                 ; gauname sena pertraukimo vektoriu
        int     21h
        ;; Zr. http://helppc.netcore2k.net/interrupt/int-21-35
        
        ; Saugome sena vektoriu 
        mov     [cs:Senas_I88], bx             ; issaugome seno doroklio poslinki    
        mov     [cs:Senas_I88 + 2], es         ; issaugome seno doroklio segmenta
        
        ; Nustatome nauja 1Ch (taimerio) vektoriu
        ;lea     dx, [Naujas_I88]
        mov     dx,  Naujas_I88
        mov     ax, 2588h                 ; nustatome pertraukimo vektoriu
        int     21h
        ;; Zr. http://helppc.netcore2k.net/interrupt/int-21-25
        
        macPutString "OK ...", crlf, '$'
        
        ;lea     dx, [Nustatymas  + 1]       ; dx - kiek baitu  
        mov dx, Nustatymas + 1
        int     27h                       ; Padarome rezidentu
        ;; Zr. http://helppc.netcore2k.net/interrupt/int-27
%include 'yasmlib.asm'        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss                    ; neinicializuoti duomenys  


