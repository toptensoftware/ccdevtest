# Target output file
ifeq ($(strip $(PROJKIND)),exe)
TARGETNAME ?= $(PROJNAME).exe
else ifeq ($(strip $(PROJKIND)),lib)
TARGETNAME ?= $(PROJNAME).lib
else ifeq ($(strip $(PROJKIND)),so)
TARGETNAME ?= $(PROJNAME).dll
else
$(error PROJKIND should be 'exe' or 'lib' or 'so')
endif 
TARGET = $(OUTDIR)/$(TARGETNAME)

# Compile/link flags
COMMONFLAGS = $(MSVC_COMMONFLAGS) /Zi $(addprefix /D,$(DEFINE)) $(addprefix /I,$(INCLUDEPATH))
CFLAGS = $(MSVC_CFLAGS)
CPPFLAGS = $(MSVC_CPPFLAGS)
LDFLAGS = /DEBUG $(MSVC_LDFLAGS)
ARFLAGS = $(MSVC_ARFLAGS)

# debug vs release
ifeq ($(strip $(CONFIG)),debug)
COMMONFLAGS += /D_DEBUG /Od
else ifeq ($(strip $(CONFIG)),release)
COMMONFLAGS += /DNDEBUG /O2 /Oi
LDFLAGS += /OPT:REF /OPT:ICF
else
$(error CONFIG should be 'debug' or 'release')
endif

# Object files
OBJS ?= $(addprefix $(OUTDIR)/,$(CSOURCES:%.c=%.obj) $(CPPSOURCES:%.cpp=%.obj))

# .h file dependencies
-include $(OBJS:.obj=.d)

# Tool-chain
PREFIX	 ?= 
CC	= node $(RULESDIR)/cl-filter cl
CPP	= node $(RULESDIR)/cl-filter cl
LD = link
AR = lib

# Compile C Rule
$(OUTDIR)/%.obj: %.c
	@echo "  CC    $(notdir $@)"
	@mkdir -p $(@D)
	@$(CC) /nologo $(COMMONFLAGS) $(CFLAGS) /c $< /Fo$@ /Fd$(OUTDIR) /showIncludes

# Compile C++ Rule
$(OUTDIR)/%.obj: %.cpp
	@echo "  CC    $(notdir $@)"
	@mkdir -p $(@D)
	@$(CPP) /nologo $(COMMONFLAGS) $(CPPFLAGS) /c $< /Fo$@ /Fd$(OUTDIR)/ /showIncludes

# Rule to copy target file to a super-project specified output directory
COPYTARGET=$(COPYTARGETTO)/$(notdir $(TARGET))
$(COPYTARGET): $(TARGET)
	@echo "  CP    "$(notdir $@)
	@mkdir -p $(@D)
	@cp $< $@


ifeq ($(strip $(PROJKIND)),exe)

# Link Rule (exe)
$(TARGET): $(OBJS) $(LIBS) $(OTHERLIBS)
	@echo "  LINK  $(notdir $@)"
	@$(LD) /nologo $(LDFLAGS) /out:$@ /pdb:$(@:%.exe=%.pdb) $^

# Run target for exe
run: target
	@$(TARGET)

list-libs:
	@echo -n

copy-target: $(COPYTARGET)

else ifeq ($(strip $(PROJKIND)),so)

# Link Rule (dll)
$(TARGET): $(OBJS) $(LIBS) $(OTHERLIBS)
	@echo "  LINK    $(notdir $@)"
	@$(LD) /nologo /dll $(LDFLAGS) /out:$@ $^

list-libs:
	@echo $(abspath $(TARGET:%.dll=%.lib))" "

copy-target: $(COPYTARGET)

else ifeq ($(strip $(PROJKIND)),lib)

# Library Rule
$(TARGET): $(OBJS)
	@echo "  LIB   $(notdir $@)"
	@$(AR) /nologo /out:$@ $(OBJS)

list-libs:
	@echo -n $(abspath $(TARGET))" "

copy-target:

endif
