CFLAGS = -Wall
PIE = -no-pie 
DYLINK = -dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 \
/usr/lib/x86_64-linux-gnu/crt1.o /usr/lib/x86_64-linux-gnu/crti.o \
/usr/lib/x86_64-linux-gnu/crtn.o

NAME = avalia

OBJ = meuAlocador.o


all: main

# gcc $(PIE) main.c $(OBJ) -o $(NAME)
# usa o ligador ao inves do gcc pra juntar tudo
main: meuAlocador.o
	gcc $(PIE) avalia.c -c -g -o avalia.o
	ld meuAlocador.o avalia.o -o $(NAME) $(DYLINK) -lc

%.o: %.s
	as $(PIE) -g meuAlocador.s -o meuAlocador.o


clean:
	rm *.o

purge: clean
	rm $(NAME)