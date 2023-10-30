#include <stdio.h>
#include "meuAlocador.h"
#define TAM 102

int tam_restate = TAM;
int heap[TAM];
int parada;



// minimize o número de chamadas ao serviço brk alocando 
// espaços múltiplos de 4096 bytes por vez. Se for
// solicitado um espaço maior, digamos 5000 bytes, 
// então será alocado um espaço de 4096 ∗ 2 = 8192 bytes
// para acomodá-lo.



// Faz uma chamada ao sistema com o serviço brk para 
// localizar o endereço do topo da heap e o armazena na
// variável que indica o topo da heap
//
// Inicia a variável que indica o início da heap 
// apontando para o topo da heap. 
// Isto indica que a heap está vazia;
void iniciaAlocador(){
    heap[0] = 'L';
    heap[1] = TAM;
};

// variacao: best fit: percorre toda a lista e seleciona o nó
// com menor bloco, que é maior do que o solicitado;
//
// Como a lista está vazia, cria um novo nó usando 
// o serviço brk para aumentar o topo da heap em 100 + 16
// bytes. Os 16 bytes correspondem às informações gerenciais.
// Este espaço corresponde ao novo nó
//
// ou
// 
// Percorre a lista procurando por um nó livre. Não encontra 
// e por isso cria um novo nó usando o serviço brk
// para aumentar o topo da heap em 200 + 16 bytes. 
// Os 16 bytes correspondem às informações gerenciais. Este
// espaço corresponde ao novo nó.
//
// No campo livre/ocupado indica ocupado;
//
// No campo tamanho armazena o tamanho do bloco (100);
int *alocaMem(int num_bytes){
    void *ret_addr;

    heap[parada] = 'O';
    heap[parada + 1] = num_bytes;
    heap[parada + num_bytes + 2] = 'L';
    heap[parada + num_bytes + 3] = (tam_restate - num_bytes - 2);

    ret_addr = &(heap[parada]);

    parada = parada + num_bytes + 2;
    tam_restate = (tam_restate - num_bytes - 2);

    return ret_addr;


}

// O parâmetro passado (x) aponta para o primeiro byte do bloco. 
// Subtrai 16 e encontra o campo livre/ocupado. 
// Armazena 0 (zero=livre) neste campo
void liberaMem(int *bloco){
    *bloco = 'L';
}

// contrario do inicia
void finalizaAlocador(){
    heap[0] = 'L';
    heap[1] = TAM;
};

void imprimeVetor(){
    for (int i = 0; i<TAM;i++){
        printf("%d ", heap[i]);
    }

    printf("\n");
}

int main(void){
    void* bloco;
    void* bloco_ret;

    iniciaAlocador();
    imprimeVetor();
    printf("-------------------------------------------------------------------------- \n");
    bloco = alocaMem(10);
    imprimeVetor();
    printf("-------------------------------------------------------------------------- \n");
    bloco = alocaMem(10);
    imprimeVetor();
    printf("-------------------------------------------------------------------------- \n");
    bloco_ret = alocaMem(5);
    imprimeVetor();


    liberaMem(bloco_ret);
    imprimeVetor();


    finalizaAlocador();

    return 13;
}