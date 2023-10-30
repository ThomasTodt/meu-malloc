#include "meuAlocador.h" 

int main() {
  void *a, *b, *c, *d, *e;
  iniciaAlocador();

  a=alocaMem(10);
  // // imprimeMapa();
  b=alocaMem(13);
  // // imprimeMapa();
  c=alocaMem(12);
  // // imprimeMapa();
  d=alocaMem(11);
  // // imprimeMapa();

  liberaMem(b);
  // imprimeMapa();
  liberaMem(d);
  // imprimeMapa();
  
  b=alocaMem(5);
  // // imprimeMapa();
  d=alocaMem(9);
  // // imprimeMapa();
  e=alocaMem(4);
  // // imprimeMapa();

  liberaMem(c);
  // // imprimeMapa();
  liberaMem(a);
  // // imprimeMapa();
  liberaMem(b);
  // // imprimeMapa();
  liberaMem(d);
  // // imprimeMapa();
  liberaMem(e);

  imprimeMapa();

  finalizaAlocador();

}
