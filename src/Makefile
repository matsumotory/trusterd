TARGET1=mini_trusterd.c
TARGET2=mini_trusterd_client.c
BIN_NAME1=mini-trusterd
BIN_NAME2=mini-trusterd-client

MRUBY_ROOT=../mruby/
LIBMRUBY=$(MRUBY_ROOT)/build/host/lib/libmruby.a
MRUBY_CFLAGS=$(shell $(MRUBY_ROOT)/bin/mruby-config --cflags)
MRUBY_LDFLAGS=$(shell $(MRUBY_ROOT)/bin/mruby-config --ldflags)
MRUBY_LDFLAGS_BEFORE_LIBS=$(shell $(MRUBY_ROOT)/bin/mruby-config --ldflags-before-libs)
MRUBY_LIBS=$(shell $(MRUBY_ROOT)/bin/mruby-config --libs)

all:
	  gcc $(MRUBY_CFLAGS) $(MRUBY_LDFLAGS) $(TARGET1) $(LIBMRUBY) $(MRUBY_LDFLAGS_BEFORE_LIBS) $(MRUBY_LIBS) -o $(BIN_NAME1)
	  gcc $(MRUBY_CFLAGS) $(MRUBY_LDFLAGS) $(TARGET2) $(LIBMRUBY) $(MRUBY_LDFLAGS_BEFORE_LIBS) $(MRUBY_LIBS) -o $(BIN_NAME2)

clean:
		-rm $(BIN_NAME1) $(BIN_NAME2)
