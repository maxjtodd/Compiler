# Lab9 makefile
# Max Todd
# 4/26/21
# Compiles code

all: lab9


lab9:	lab9.l lab9.y ast.h ast.c symtable.h symtable.c emit.h emit.c
	lex lab9.l
	yacc -d lab9.y
	gcc lex.yy.c y.tab.c ast.c symtable.c emit.c -o lab9

run:	
	./lab9

runtest:
	./lab9 < test.al

runtestdebug:
	./lab9 -d <test.al

clean:
	rm -f lab9
	rm -f lex.yy.c
	rm -f y.tab.h
	rm -f y.tab.c
	rm -f a.asm
