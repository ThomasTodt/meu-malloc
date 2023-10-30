#include "meuAlocador.h" 

int main() {
  void *a, *b, *c, *d, *e;
  iniciaAlocador();

  a=alocaMem(100);
  // imprimeMapa();
  b=alocaMem(130);
  // imprimeMapa();
  c=alocaMem(120);
  // imprimeMapa();
  d=alocaMem(110);
  // imprimeMapa();

  liberaMem(b);
  // imprimeMapa();
  liberaMem(d);
  // imprimeMapa();
  
  b=alocaMem(50);
  // imprimeMapa();
  d=alocaMem(90);
  // imprimeMapa();
  e=alocaMem(40);
  // imprimeMapa();

  liberaMem(c);
  // imprimeMapa();
  liberaMem(a);
  // imprimeMapa();
  liberaMem(b);
  // imprimeMapa();
  liberaMem(d);
  // imprimeMapa();
  liberaMem(e);
  imprimeMapa();

  finalizaAlocador();

}
