all: test

test : 
	yacc ot1.y
	g++ y.tab.c -o cfg
	./cfg

clean : 
	rm -f y.tab.c cfg