.model small 
.stack 100h
.data 
    errMessage1 db "Error", '$'
    errMessage2 db "Command line is empty :(", '$' 
    errMessage3 db "Please, enter a NUMBER in RANGE [0, 255]", '$'
    errMessage4 db "Error in memory allocation", '$'
       
    runError0 db "File is not found :( $" 
    runError1 db "Access denied :( $"  
    runError2 db "Not enough memory :( $"   
    runError3 db "Wrong format :( $"
    
    endl db 0Dh, 0Ah, '$'
    
    N db 4 dup ('$')  
    
    name_exe db 64 dup ('$') 
    
    EPB dw 0000
    cmd_off    dw ? 
    cmd_seg    dw ?
    fcb_1    dw 005Ch,0
    fcb_2 dw 006Ch,0
        
    com_line db 127 dup (0Dh)

dataLength = $ - errMessage1          
.code
begin: 
ASSUME cs:code, ds:data  

display macro string
    pusha
    displaySingle string
    displaySingle endl
    popa
endm 
 
displaySingle macro string
    lea dx, string
    mov ah, 09h
    int 21h
endm  

exit proc 
   mov ah,4ch               
   int 21h
   ret   
exit endp

atoi proc
    pusha
    push si
    
xor cx, cx
mov cl, 4
   
CHECK_DIGIT: 
    cmp [si], '$'
    je EXIT_FROM_CYCLE   
    cmp [si], '0'
    jb ERROR_GET 
    cmp [si], '9'
    ja ERROR_GET
    inc si
    loop CHECK_DIGIT 
    display errMessage3
    call exit
    
EXIT_FROM_CYCLE:
    cmp cl, 4
    je ERROR_GET
    pop si 
    xor ax, ax 
    xor bx, bx
    mov bl, 10
CONVERT:
    mov cl, [si]
    sub cl, '0'
    mul bx
    jc ERROR_GET
    add al, cl
    jz ERROR_GET
    inc si
    cmp [si], '$'
    jne CONVERT
    mov [N], al
    
    popa
    ret
 
    ERROR_GET: 
    display errMessage3 
    call exit
    
atoi endp

scan_cmd proc  
    ; command_line parametrs: N filename file_attributes
   mov si,80h
   cmp byte ptr es:[si],0
   je EMPTY_LINE
    
   mov di, 82h
   call skip_spaces
   lea si, N
   call get_parametr
   lea si, N  
   call atoi
   
   call skip_spaces
   lea si, name_exe
   call get_parametr
   
   call skip_spaces
   lea si, com_line+1
   mov [com_line], 0
   dec di
   GET_PARAMETRS:
        cmp es:[di], 0dh
        je END_SCANNING
        
        mov al, es:[di]
        mov [si], al      
        
        inc si
        inc di
        inc [com_line]
        jmp GET_PARAMETRS
        
   END_SCANNING:
        ret
         
    EMPTY_LINE:
    display errMessage2
    call exit     
scan_cmd endp

get_parametr proc         
     WRITE_CYCLE:
        mov al, es:[di]    
        cmp al, 0
        je END_OF_WRITE
        cmp al, ' '
        je END_OF_WRITE  
        cmp al, 9
        je END_OF_WRITE     
        cmp al, 0dh
        je END_OF_WRITE 
        mov [si], al               
        inc di
        inc si
        jmp WRITE_CYCLE    
                       
    END_OF_WRITE:          
    ret 
get_parametr endp

skip_spaces proc     
    dec di
    CYCLE:  
        inc di
        cmp es:[di], 0dh
        je END_OF_SKIPPING
        cmp es:[di], 0
        je CYCLE
        cmp es:[di], ' '
        je CYCLE
        cmp es:[di], 9     
        je CYCLE
    END_OF_SKIPPING:
    ret
skip_spaces endp

change_size proc
    mov ah,4Ah                  
    mov bx, ((codeLength / 16) + 1) + ((dataLength / 16) + 1) + 16 + 16;psp+stack+code+data
    int 21h 
    jc MEMORY_ISSUES
    ret  
    MEMORY_ISSUES:
    display errMessage4
    call exit
change_size endp

run_exe proc 
    mov ax, @data
    mov es, ax 
     mov ax, 4b00h
        lea dx, name_exe  
        mov bx, offset epb
        int 21h
        jc ERROR
    ret 
    ERROR:
    cmp ax, 02h
    jne error_1
    display runError0
    call exit
    
    error_1:
    cmp ax, 05h
    jne error_2
    display runError1
    call exit
    
    error_2:
    cmp ax, 08h
    jne error_3
    display runError2
    call exit
    
    error_3:
    cmp ax, 0Bh
    jne error_n
    display runError3
    call exit
    
    error_n:
    display errMessage1
    call exit 
run_exe endp 

start:
mov ax, data
mov ds, ax
call scan_cmd 
call change_size 

mov bx, offset com_line
mov cmd_off, bx
mov ax, ds
mov cmd_seg, ax  

mov cl, byte ptr[N] 

RUN_EXE_CYCLE:   
call run_exe
loop RUN_EXE_CYCLE

call exit 
codeLength = $ - begin
    
end start