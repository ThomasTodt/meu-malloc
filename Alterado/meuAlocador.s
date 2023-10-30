.section .data
comeco_heap: .quad 0
tam_brk: .quad 0
parada: .quad 0
tam_rest: .quad 0
maior_tam: .quad 0
maior_add: .quad 0
.equ TAM, 100

velha: .ascii  "\n################"
velha_length: .quad   . - velha

mais: .ascii  "+"
mais_length: .quad   . - mais

risco: .ascii  "-"
risco_length: .quad   . - risco

.section .text
.globl iniciaAlocador
iniciaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    # imprimir o risco de inicio
    movq     $1,%rax
    movq     $1,%rdi               
    movq     $risco,%rsi           
    movq     risco_length,%rdx     
    syscall   

    # Pega o valor atual de BRK e retorna em rax
    movq $12, %rax
    movq $0,  %rdi
    syscall

    movq %rax, comeco_heap  # comeco_heap = BRK

    movq %rax, %r10         # r10 = BRK
    addq $TAM, %r10         # r10 = BRK + TAM (tamanho novo bloco)
    addq $16,  %r10         # r10 = BRK + TAM + 16 (header)

    # sobe BRK
    movq $12,  %rax
    movq %r10, %rdi
    syscall                 # BRK += TAM + 16

    movq comeco_heap, %rax  # rax = comeco_heap
    movq $0, (%rax)         # bloco livre
    movq $TAM, 8(%rax)      # tamanho do bloco livre 
    
    # Guarda o valor de BRK em uma variavel global
    # movq %rax, parada         # parada = comeco_heap

    # movq $12, %rax
    # movq $0,  %rdi 
    # syscall                 # retorna BRK em rax

    popq %rbp
    ret

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ------------------------------------------------------------------------------------------
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

.globl alocaMem
alocaMem:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %r9               # r9 = tamanho do bloco a ser alocado

    movq $12, %rax
    movq $0,  %rdi 
    syscall                      # retorna BRK em rax

verificaAlocacao:
	movq comeco_heap, %rbx       # rbx = comeco_heap // comeca olhando do comeco
    movq $0, maior_tam           # inicia maior_tam em 0 toda vez
    # movq 8(%rbx), %r10
    
    while_aloca:

        cmpq $0, (%rbx)         # if (*bloco != livre)
        jne proximo_bloco       # bloco++ (proximo bloco)
        
        cmpq %r9, 8(%rbx)       # if (bloco.tamanho < tamanho do bloco a ser alocado)
        jl  proximo_bloco       # bloco++

        movq 8(%rbx), %rax      # rax = bloco.tamanho
        cmpq maior_tam, %rax    # if (bloco.tamanho > maior_tam)
        jle  fim_if_maior
        movq %rax, maior_tam    # maior_tam = bloco.tamanho 
        movq %rbx, %r8        # r8 aponta para o maior bloco
        fim_if_maior:

        # jmp proximo_bloco       # sepa seja soh tirar esse e o jmp alocaMemoria

        # jmp alocaMemoria        # se passou nas condicoes, pode alocar ali

        proximo_bloco:
        movq 8(%rbx), %r10      # r10 = bloco.tamanho
        addq $16,     %r10      # r10 = bloco.tamanho + header
        addq %r10,    %rbx      # rbx = bloco + bloco.tamanho + 16   // aponta para o proximo bloco

        movq $12, %rax
        movq $0,  %rdi 
        syscall                 # retorna BRK em rax

        cmpq %rax, %rbx         # if (rbx < BRK)
        jl while_aloca          # continua procurando um bloco maior na heap

        # se chegou no final
        cmpq $0, maior_tam      # se nenhum bloco de tamanho adequado 
        je  aumenta_heap        # aumenta_heap
        jmp alocaMemoria


        # jl if_parada
        # movq comeco_heap, %rbx  # else // se chegou no final da heap, volta a olhar pro comeco


        # if_parada:
        # cmpq parada, %rbx       # if (rbx = parada)
        # je aumenta_heap         # se rodou toda a heap e nao achou lugar, vai ter que alocar mais


        # jmp while_aloca


alocaMemoria:
    # popq %rcx              # rcx = endereco do bloco em que vai alocar 
    movq %r8, %rcx
    movq %rcx, %r8
    addq $16, %r8
    addq 8(%rcx), %r8      # r8 aponta pro proximo de rcx (rcx que sera ocupado)

    # adiciona a flag de ocupado e o tamanho de memória
    movq $1,  (%rcx)    # bloco indicado por rcx esta ocupado agora
    movq %r9, 8(%rcx)   # bloco de tamanho pedido pelo programador

    # atualiza o endereço de parada da ultima alocação
    movq %rcx,    %r10     # r10 = rcx
    addq $16,     %r10     # r10 aponta pro primeiro byte de conteudo
    movq %rcx,    %r11
    addq $8,      %r11
    movq (%r11),  %r11
    addq %r11,    %r10     # r10 = header do proximo NOVO bloco que sera criado 

    pushq %rcx

    movq $12, %rax
    movq $0,  %rdi
    syscall                 # retorna BRK em rax

    popq %rcx

    movq %rax, %r11         # r11 = BRK
    subq $16,  %r11         # r11 = BRK - 16

    cmpq %r11, %r10         # if (r10 < BRK - 16)
    jl cria_header_novo_bloco

    pushq %rcx

    movq $12, %rax          # se nao tem espaco pra um novo header sobrando
    movq %r10, %rdi         # encolhe heap ate o final do ultimo bloco
    syscall   

    popq %rcx            

    # movq comeco_heap, %r10  # e entao a parada vai ser o primeiro bloco dnv
    # movq %r10, parada
    
    jmp fim_alocacao

    cria_header_novo_bloco: # cria header do proximo se tiver espaco de 16 bytes
    # movq $0,   (%r10)
    # subq %r10, %r11         # tamanho = (BRK - r10) - 16 // ou (BRK - 16) - r10
    subq $16, %r8
    subq %r10, %r8            # r8 tem o tamanho do bloco criado apos o alocado  

    cmpq $16, %r8
    jge fim_if_menos_que_16
    addq %r8, 8(%rcx)         # se menor que 16 adiciona os que sobraram no alocado
    # movq %rbx, %rcx
    
    # addq 8(%rcx), %rcx
    # addq $16, %rcx            # rcx aponta pro proximo bloco depois do alocado

    # addq $16, %r11
    # cmpq %r11, %rcx           # se proximo == brk  
    # je   reinicia_parada      # reinicia parada  
    # movq %rcx, parada 
    # jmp fim_if_seila

    # reinicia_parada:
    # movq comeco_heap, %rcx
    # movq %rcx, parada

    # fim_if_seila:
        

    jmp fim_alocacao


    # movq %r11, 8(%r10)      # guarda o tamanho
    # movq %r10, parada       # parada = r10 (proximo header)
    fim_if_menos_que_16:
    movq $0,   (%r10)       # novo bloco eh livre
    movq %r8, 8(%r10)       # guarda o tamanho
    # movq %r10, parada       # parada = r10 (proximo header)


    fim_alocacao:
        movq %rcx, %rax           # retorna endereco do bloco que agora esta ocupado  
        addq $16,  %rax           # endereco do conteudo  

    popq %rbp
    ret


aumenta_heap:
    # BRK ainda esta em rax
    movq %rax, %r10         # vamos precisar desse BRK ANTIGO no r10 pra nao ter que fazer syscall dnv

    movq %rax, %rbx         # rbx = BRK
    addq $TAM, %rbx         # aumentar o tamanho da heap de acordo com o tamanho definido

    movq $12,  %rax
    movq %rbx, %rdi
    syscall                 # aumentou a heap


    # header do novo bloco OU fundir com o ultimo que ja tinha
    movq comeco_heap, %rax    # rax = comeco_heap
    movq %rax, %rbx           # rbx = rax

    procura_ultimo:
    addq $16,     %rbx        # rbx + header  
    addq 8(%rax), %rbx        # rbx + tamanho do bloco apontado por rax + header // rbx aponta pro proximo bloco

    cmpq %r10, %rbx           # if (rbx >= BRK ANTIGO)  
    jge fim_procura_ultimo    # entao achou o ultimo  (rax)

    movq %rbx, %rax           # rax = rbx
    jmp procura_ultimo

    fim_procura_ultimo:       # rax contem o endereco pro header do ultimo bloco  
    cmpq $0, (%rax)           # if (ultimo == livre)
    je aumenta_ultimo

    movq $0,   (%r10)           # BRK ANTIGO, o novo bloco da heap aumentada, eh livre
    movq $TAM, %r8
    subq $16,  %r8
    movq %r8,  8(%r10)
    jmp fim_aumenta_heap 

    aumenta_ultimo:
    addq $TAM, 8(%rax)        # adiociona o tamanho aumentado da heap no ultimo 

    fim_aumenta_heap:
    
    movq comeco_heap, %rbx
    jmp while_aloca      # depois de aumentar a heap, repete o processo todo
                              # possivel que tenha que aumentar mais vezes, o que vai ser coberto pelo loop

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ------------------------------------------------------------------------------------------
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

.globl liberaMem
liberaMem:
    pushq %rbp
	movq %rsp,%rbp

    movq %rdi, %rax     # rax = x (endereço do byte de inicio do bloco)
    subq $16,  %rax     # rax -= 16 (bytes que indicam livre ou ocupado)
    movq $0,  (%rax)    # *rax = 0 ("livre")

    # juntar blocos livres contiguos

    movq $12, %rax
    movq $0,  %rdi
    syscall                    # retorna valor atual do brk (topo da heap) em rax    

    movq %rax, %r11            # r11 = brk 
    movq comeco_heap, %rax     # rax = comeco_heap (endereço) (conteudo: L/O)

    # rax e rbx apontarao para dois blocos em sequencia

    while:
    # rbx apontar para o proximo bloco
    movq %rax,   %rbx
    addq $8,     %rbx           # rbx = rax+8          // rbx aponta para tamanho do bloco apontado por rax
    movq (%rbx), %r10           # r10 =  *rbx          // r10 recebe o tamanho do bloco
    addq $8,     %rbx           # rbx aponta pro conteudo
    addq %r10,   %rbx           # rbx += ( tamanho_bloco + 1 )   // rbx aponta pro proximo bloco


    # while (rbx < brk) // (existe um proximo bloco)
    cmpq %r11, %rbx
    jge fim_while

    # If(bloco == livre)
    cmpq $0, (%rax)
    jne fim_if_0
    # jmp dowhile

    # && if(bloco+1 == livre)
    cmpq $0, (%rbx)
    jne fim_if_0
    jmp dowhile

    fim_if_0:
    movq %rbx, %rax
    jmp while

    dowhile: # junta os blocos de fato

    # If (parada == proximo) then parada = bloco
    # cmpq parada, %rbx
    # jne fim_if
    # movq %rax, parada
    
    # fim_if:

    movq 8(%rax), %r10          # r10 = tamanho(rax)
    movq 8(%rbx), %rbx          # rbx = tamanho(rbx)

    addq $16, %rbx              # rbx = tamanho(rbx) + 2 (pra contar tambem o "livre" e o "tamanho")             
    addq %rbx, %r10             # r10 recebe o novo tamanho do bloco juntado
    movq %r10, 8(%rax)          # esse tamanho eh entao guardado no local correto (logo depois do "livre" do bloco apontado por rax)


    # rbx apontar para o proximo bloco
    # transformar em funcao? nao
    movq %rax,   %rbx
    addq $8,     %rbx           # rbx = rax+8          // rbx aponta para tamanho do bloco apontado por rax
    movq (%rbx), %r10           # r10 =  *rbx          // r10 recebe o tamanho do bloco
    addq $8,     %rbx           # bytes do "tamanho" (long)e
    addq %r10,   %rbx           # rbx += ( tamanho_bloco + 1 )   // rbx aponta pro proximo bloco

    # while (rbx < brk) // (existe um proximo bloco)
    cmpq %r11, %rbx
    jge fim_dowhile    # break

    # && if(bloco+1 == livre)
    cmpq $0, (%rbx)
    jne fim_dowhile     # break

    jmp dowhile

    fim_dowhile:
    fim_while:
    popq %rbp
    ret

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ------------------------------------------------------------------------------------------
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

.globl finalizaAlocador
finalizaAlocador:
    pushq %rbp
	movq %rsp,%rbp

    movq comeco_heap, %rdi
    movq $12, %rax
    syscall

    popq %rbp
    ret

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ------------------------------------------------------------------------------------------
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

.globl imprimeMapa
imprimeMapa:
  	movq comeco_heap, %r11

decide_sinal:
    # pega o tamanho da sessão alocada e coloca em rbx
    movq 8(%r11), %rbx
    movq $0, %r8

    # verifica se existem elementos a serem impressos
    cmpq $0, %rbx
    je fim

    # imprime - se estiver oculpado e + se estiver livre
	cmpq $1, 0(%r11)
	je imprime_mais
    cmpq $0, 0(%r11)
	je imprime_menos
    
    fim:
        ret

imprime_cabecalho:
    pushq %rbp
	movq %rsp,%rbp

    cmpq $0, %r8 
    jg fim_cabecalho
    
    pushq %r11
    movq $1,%rax 
    movq $1,%rdi               
    movq $velha,%rsi           
    movq velha_length,%rdx   
    syscall
    popq %r11

    addq $16, %r11
    # addq $8, %r11

    fim_cabecalho:
        popq %rbp
        ret

imprime_menos:
    call imprime_cabecalho
    pushq %r11
    movq $1,%rax               
    movq $1,%rdi               
    movq $risco,%rsi           
    movq risco_length,%rdx     
    syscall

    popq %r11

    addq $1, %r11       # r11 vai apontar pro proximo bloco no fim do loop
    addq $1, %r8        # r8 eh o iterador
    cmpq %r8, %rbx
    je decide_sinal
    jg imprime_menos

  	ret

imprime_mais:
    call imprime_cabecalho
    pushq %r11
    movq %rax, %r10
    movq $1,%rax                   
    movq $1,%rdi                    
    movq $mais,%rsi                 
    movq mais_length,%rdx          
    syscall                        

    popq %r11 

    addq $1, %r11
    addq $1, %r8
    cmpq %r8, %rbx
    je decide_sinal
    jg imprime_mais
    
  	ret
ret



