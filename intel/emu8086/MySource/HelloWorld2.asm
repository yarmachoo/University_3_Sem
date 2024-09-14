; ������������� �������� ������
data segment
    message db 'Hello, world!', '$'
    beep_frequency dw 1000 ; ������� ��������� �������
    beep_duration dw 1000 ; ������������ ��������� �������
data ends

; ������������� �������� ����
code segment
    assume cs:code, ds:data

start:
    mov ax, data ; �������� ������ �������� ������ � ������� AX
    mov ds, ax ; �������� ������ �������� ������ � ������� DS

    mov ah, 09h ; ����� ������� ������ ������ �� �����
    mov dx, offset message ; �������� ������ ������ � ������� DX
    int 21h ; ����� ���������� ��� ������ ������ �� �����

    mov ax, 0 ; ��������� �������� AX � ���� ��� ��������� ��������� �������
    mov al, 0x0E ; ��������� �������� AL � �������� 0x0E ��� ��������� ��������� �������
    out 0x61, al ; ������ �������� AL � ���� 0x61 ��� ��������� ��������� �������

    mov cx, beep_duration ; �������� ������������ ��������� ������� � ������� CX
beep_loop:
    dec cx ; ���������� �������� �������� CX �� �������
    jnz beep_loop ; ������� � ����� beep_loop �� ��� ���, ���� �������� CX �� ������ ������ ����

    mov al, 0x00 ; ��������� �������� AL � �������� 0x00 ��� ��������� ��������� �������
    out 0x61, al ; ������ �������� AL � ���� 0x61 ��� ��������� ��������� �������

    mov ah, 4Ch ; ����� ������� ���������� ���������
    int 21h ; ����� ���������� ��� ���������� ���������

code ends
end start