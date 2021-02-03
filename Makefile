PROJKIND=exe
LINKPROJECTS=mysharedlib mystaticlib
COPYPROJECTS=mysharedlib
INCLUDEPATH=./mysharedlib
PRECOMPSOURCE=precomp.cpp
PCH_CPP=precomp.cpp
include Rules/Rules.mk
