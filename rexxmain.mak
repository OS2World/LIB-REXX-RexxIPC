# IBM Developer's Workframe/2 Make File Creation run at 10:49:45 on 10/21/95

# Make File Creation run in directory:
#   E:\PROJECT\PERS\REXXIPC;

.SUFFIXES:

.SUFFIXES: .c .cpp .cxx

REXXMAIN.EXE:  \
  REXXMAIN.OBJ \
  REXXMAIN.MAK
   ICC.EXE @<<
 /B" /de /st:8192 /nologo"
 /Fe"REXXMAIN.EXE" REXX.LIB REXXIPC.LIB DDE4XTRA.OBJ 
REXXMAIN.OBJ
<<

{.}.c.obj:
   ICC.EXE /Ss /Q /Gh /Ti /Gm /C   .\$*.c

{.}.cpp.obj:
   ICC.EXE /Ss /Q /Gh /Ti /Gm /C   .\$*.cpp

{.}.cxx.obj:
   ICC.EXE /Ss /Q /Gh /Ti /Gm /C   .\$*.cxx

!include REXXMAIN.DEP
