
BKPNAME=$(date '+%Y-%m-%d')

PROG=calculadora

run: compilar
	./${PROG}.exe

compilar: clean parser scanner
	gcc ${PROG}.yy.c ${PROG}.tab.c ${PROG}.c -o ${PROG}.exe -std=c89 -ll -ly -lc -lm -std=c89
	
parser:
	bison -d ${PROG}.y

scanner:
	flex --outfile=${PROG}.yy.c ${PROG}.l

clean:
	rm -f *.exe *.output *.tab.* *.yy.c

zip:
	tar -czvf `(date +%y-%m-%d-%H-%M-%S)`.tar.gz Makefile ${PROG}.l ${PROG}.y ${PROG}.c ${PROG}.h

