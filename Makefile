fileTree.xml: temp.txt generateXMLTree.out
	./generateXMLTree.out temp.txt > fileTree.xml
	rm generateXMLTree.out

generateXMLTree.out: generateXMLTree.cpp
	g++ -o generateXMLTree.out generateXMLTree.cpp

temp.txt: a.out testfile.c
	./a.out testfile.c > temp.txt

a.out: lex.yy.o y.tab.o
	g++ lex.yy.o y.tab.o -ll

lex.yy.o: lex.yy.c y.tab
	g++ -c lex.yy.c

y.tab.o: y.tab
	g++ -c y.tab.c

y.tab: tinyC.y
	yacc -dtv tinyC.y

lex.yy.c: tinyC.l
	flex tinyC.l

clean:
	rm y.tab.o y.tab.c y.tab.h a.out lex.yy.c lex.yy.o y.output
