# IBM Developer's Workframe/2 Make File Creation run at 11:12:43 on 04/26/97

# Make File Creation run in directory:
#   E:\PROJECT\PERS\REXXIPC;

.SUFFIXES:

.SUFFIXES: .c .cpp .cxx

REXXIPC.DLL:  \
  REXXIPC.OBJ \
  REXXPIPE.OBJ \
  REXXPROC.OBJ \
  REXXQ.OBJ \
  REXXSEM.OBJ \
  RXAPIUTL.OBJ \
  REXXIPCR.MAK
   ICC.EXE @<<
 /B" /st:8192 /nologo"
 /Fe"REXXIPC.DLL" REXX.LIB REXXIPC.DEF 
REXXIPC.OBJ 
REXXPIPE.OBJ 
REXXPROC.OBJ 
REXXQ.OBJ 
REXXSEM.OBJ 
RXAPIUTL.OBJ
<<
  IMPLIB REXXIPC.LIB REXXIPC.DLL

{.}.c.obj:
   ICC.EXE /DNDEBUG=1 /Ss /Q /Wgotobsprorearettru /O /Op- /Gm /Ge- /C   .\$*.c

{.}.cpp.obj:
   ICC.EXE /DNDEBUG=1 /Ss /Q /Wgotobsprorearettru /O /Op- /Gm /Ge- /C   .\$*.cpp

{.}.cxx.obj:
   ICC.EXE /DNDEBUG=1 /Ss /Q /Wgotobsprorearettru /O /Op- /Gm /Ge- /C   .\$*.cxx

!include REXXIPCR.DEP
