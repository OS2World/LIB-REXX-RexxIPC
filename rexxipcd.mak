# IBM Developer's Workframe/2 Make File Creation run at 10:36:04 on 10/22/95

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
  REXXIPCD.MAK
   ICC.EXE @<<
 /B" /de /st:8192 /nologo"
 /Fe"REXXIPC.DLL" /Fm"REXXIPC.MAP" REXX.LIB DDE4XTRA.OBJ _DOSCALL.LIB REXXIPC.DEF 
REXXIPC.OBJ 
REXXPIPE.OBJ 
REXXPROC.OBJ 
REXXQ.OBJ 
REXXSEM.OBJ 
RXAPIUTL.OBJ
<<
  IMPLIB REXXIPC.LIB REXXIPC.DLL

{.}.c.obj:
   ICC.EXE /Ss /Q /Wgotobsprorearettru /Gh /Ti /Gm /Ge- /C   .\$*.c

{.}.cpp.obj:
   ICC.EXE /Ss /Q /Wgotobsprorearettru /Gh /Ti /Gm /Ge- /C   .\$*.cpp

{.}.cxx.obj:
   ICC.EXE /Ss /Q /Wgotobsprorearettru /Gh /Ti /Gm /Ge- /C   .\$*.cxx

!include REXXIPCD.DEP
