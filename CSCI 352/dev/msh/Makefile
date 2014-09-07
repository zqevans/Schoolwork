 #    $Id: Makefile,v 1.4 2014/05/30 07:53:50 evansz2 Exp $

CC = gcc
CFLAGS = -g -Wall
SOURCES = arg_parse.c builtin.c msh.c expand.c redirect.c
OBJECTS = $(SOURCES:.c=.o)

all: msh


msh: $(OBJECTS)
	$(CC) $(CFLAGS) -o msh $(OBJECTS)

$(OBJECTS):$(SOURCES)
	@echo Making Object 
	$(CC) -c -g -Wall $(SOURCES)

clean:
	rm *.o msh
	@echo Clean done

$(SOURCES): proto.h
