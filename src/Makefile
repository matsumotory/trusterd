TARGET=mini_trusterd.c
BIN_NAME=mini-trusterd

MRUBY_ROOT=../mruby/
LIBMRUBY=$(MRUBY_ROOT)/build/host/lib/libmruby.a
MRUBY_CFLAGS=$(shell $(MRUBY_ROOT)/bin/mruby-config --cflags)
MRUBY_LDFLAGS=$(shell $(MRUBY_ROOT)/bin/mruby-config --ldflags)
MRUBY_LDFLAGS_BEFORE_LIBS=$(shell $(MRUBY_ROOT)/bin/mruby-config --ldflags-before-libs)
MRUBY_LIBS=$(shell $(MRUBY_ROOT)/bin/mruby-config --libs)

all:
	  gcc $(MRUBY_CFLAGS) $(MRUBY_LDFLAGS) $(TARGET) $(LIBMRUBY) $(MRUBY_LDFLAGS_BEFORE_LIBS) $(MRUBY_LIBS) -o $(BIN_NAME)
