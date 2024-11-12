# contrib/raohook/Makefile

MODULE_big = raohook
OBJS = $(WIN32RES) raohook.o
EXTENSION = raohook
DATA = raohook--1.0.sql
PGFILEDESC = "raohook - Postgres hook statistics"

LDFLAGS_SL += $(filter -lm, $(LIBS))

REGRESS_OPTS = --temp-config $(top_srcdir)/contrib/raohook/raohook.conf
REGRESS = select dml cursors utility level_tracking planning \
	user_activity wal entry_timestamp cleanup oldextversions
NO_INSTALLCHECK = 1
TAP_TESTS = 0

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
subdir = contrib/raohook
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif
