.* $Id: rexxipc.ipf,v 1.6 1996/01/14 11:58:47 SFB Rel $
.*
.* $Title: RexxIPC documentation main file. $
.*
.* Copyright (c) Serge Brisson 1994, 1995.
.*
:userdoc.
:title.RexxIPC V1.30-000
:docprof toc=12.
.*
:h1.Copyright (c) Serge Brisson 1994, 1995
:p.
:hp2.Copyright (c) Serge Brisson 1994, 1995.  All rights reserved.:ehp2.
:p.
:h3 id=distrib.:hp2.Distribution:ehp2.
:p.
The copyright owner allows the free distribution
of the following files, as long as they are kept
together, unmodified&colon.
:sl.
:ul compact.
:li.REXXIPC.DLL -- The library.
:li.REXXIPC.INF -- The documentation.
:li.REXXIPC.TXT -- Distribution text.
:li.TESTIPC.CMD -- A test program.
:li.TESTIPC.CFG -- A test configuration.
:li.FILE_ID.DIZ -- Identification.
:eul.
:esl.
.*
:h1 id=intro.Introduction
:i1.introduction
:p.
The RexxIPC library provides access to OS/2 Inter
Process Communication capabilities for Rexx programs.
Threads, named pipes, semaphores (event, mutex and
muxwait) and queues are supported.
:p.
The design requirements for this library specified
support of multi-threaded Rexx applications,
support of access to the same IPC services by other C or C++
functions, simplicity of use and non-interference in the
application's design.
:p.
Since the underlying system services already meet these
requirements, the library's design is mostly a straightforward
Rexx interface to these services.
This document is supplied as a reference to this
interface.  It assumes that the reader has access
to the Control Program Guide and Reference from the Developer's
Toolkit for OS/2.
:nt.
The explicit use of system handles in the Pipe interface allows
the access to multiple instances of the same pipe (useful in
a multi-threaded environment).
:p.
The explicit use of system handles in the Semaphore interface
allows the use of unnamed semaphores.
:ent.
.*
.***
.*
:h1 id=ipc.IPC Procedures and Functions
:i1 id=ipc.IPC
:i1.Inter Process Communication
:p.
The IPC prefix identifies a few generic routines related to
the operation of the library.
:p.
The :link reftype=hd refid=pcload.IPCLoadFuncs:elink.
and :link reftype=hd refid=pcdrop.IPCDropFuncs:elink.
register and deregister all the external routines.  It is possible
to be more specific by using the
:link reftype=hd refid=pcload.PipeLoadFuncs:elink.,
:link reftype=hd refid=seload.SemLoadFuncs:elink.
and :link reftype=hd refid=npdrop.PipeDropFuncs:elink.,
:link reftype=hd refid=seload.SemLoadFuncs:elink. procedures.
:p.
The :link reftype=hd refid=pcvers.IPCVersion:elink.
function returns a version identification string.
:p.
The IPCContext functions are used to support threads and
asynchronous services.
.*
.*************************************
:h2 id=icclos.IPCContextClose function
.*************************************
:i2 refid=ipc.close context
:i2 refid=ctx.close
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = IPCContextClose(:hp1.ctxHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
IPCContextClose is used to free the memory resources consumed by
the IPC Context structure.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.ctxHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=iccrea.IPCCreateContext:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
IPCContextClose returns 0.
.br
:h3.:hp2.Notes:ehp2.
:p.
If a thread is still associated with the context when
IPCContextClose is called, that thread is killed.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=iccrea.IPCContextCreate:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To close an IPC Context:
:xmp.
    call IPCContextClose myContext
    if result \= 0 then signal ContextCloseError
:exmp.
.*
.**************************************
:h2 id=iccrea.IPCContextCreate function
.**************************************
:i2 refid=ipc.create context
:i1 id=ctx.context
:i2 refid=ctx.create
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = IPCContextCreate(:hp1.handleVar:ehp1.,
[&rbl.:hp1.semHandle:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
IPCContextCreate is used to create a context for the execution of an
asynchronous (multi-threaded) function.  This context holds the
completion status and may hold an event semaphore handle to signal
the completion of the requested function.  It will also hold the
result string returned by a thread started with
:link reftype=hd refid=prcrth.ProcCreateThread:elink..
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.handleVar:ehp1.
:pd.is the name of the variable which is to receive the handle
to the allocated context.
.*
:pt.:hp1.semHandle:ehp1.
:pd.is the handle of the event semaphore which will be used to signal
the completion of the asynchronous function.  If this semaphore
is not supplied, the function
:link reftype=hd refid=icwait.IPCContextWait:elink.
may be used to wait for completion.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
IPCContextCreate returns 0.
.br
:h3.:hp2.Notes:ehp2.
:p.
An IPCContext is a structure local to the RexxIPC
library.  It consumes a few bytes and an internal event
semaphore in the current process.  The memory and the
semaphore is released by a call to IPCContextClose.
:p.
The internal event semaphore is used for thread
synchronization and is not related to the optional
semaphore supplied as an argument to this function.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=icclos.IPCContextClose:elink.,
:link reftype=hd refid=evcrea.SemEventCreate:elink.,
:link reftype=hd refid=npcoas.PipeConnectAsync:elink.,
:link reftype=hd refid=prcrth.ProcCreateThread:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To create an IPC Context:
:xmp.
    call SemEventCreate 'myContextEvent'
    if result \= 0 then signal SemCreateError
    call IPCContextCreate 'myContext', myContextEvent
    if result \= 0 then signal ContextCreateError
    .
    .
    .
    call IPCContextClose myContext
    if result \= 0 then signal ContextCloseError
    call SemEventClose myContextEvent
    if result \= 0 then signal SemCloseError
:exmp.
.*
.*************************************
:h2 id=icquer.IPCContextQuery function
.*************************************
:i2 refid=ipc.query context
:i2 refid=ctx.query
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = IPCContextQuery(:hp1.ctxHandle:ehp1.,
[&rbl.:hp1.threadVar:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
IPCContextQuery is used to get the completion code of the last thread
associated with the context.  If the thread is still active, the system
Id may be returned in an optional parameter.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.ctxHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=iccrea.IPCCreateContext:elink..
.*
:pt.:hp1.threadVar:ehp1.
:pd.is the name of the variable which is to receive the system
Id of the thread active on the context.  If there is
no such thread, the value will be 0 (zero).
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
IPCContextQuery returns the completion code.
.br
:h3.:hp2.Notes:ehp2.
:p.
If a thread is still active on the context,
IPCContextQuery will return the code ERROR_BUSY (170).  It will also put
a non-zero value in the optional variable parameter.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=iccrea.IPCContextCreate:elink.,
:link reftype=hd refid=icwait.IPCContextWait:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To query an IPC Context used in a
:link reftype=hd refid=npcoas.PipeConnectAsync:elink.&colon.
:xmp.
    call IPCContextQuery myContext
    if result \= 0 then signal PipeConnectError
:exmp.
:p.
To query an IPC Context used in a
:link reftype=hd refid=prcrth.ProcCreateThread:elink.&colon.
:xmp.
    call IPCContextQuery myContext, 'threadId'
    if result = 170 then say 'Thread' threadId 'is still active.'
    else say 'Thread completed with return code' result'.'
:exmp.
.*
.**************************************
:h2 id=icresu.IPCContextResult function
.**************************************
:i2 refid=ipc.get thread result from context
:i2 refid=ctx.get thread result
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.threadResult:ehp1. = IPCContextResult(:hp1.ctxHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
IPCContextResult is used to get the string returned by
the thread associated with the context.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.ctxHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=iccrea.IPCCreateContext:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
IPCContextResult returns the string produced by the last Rexx thread
associated with the context.  It will return a null string if
the thread is still active or did not return a string.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=iccrea.IPCContextCreate:elink.,
:link reftype=hd refid=icquer.IPCContextQuery:elink.,
:link reftype=hd refid=icwait.IPCContextWait:elink.,
:link reftype=hd refid=prcrth.ProcCreateThread:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To get the result from the last thread started by
:link reftype=hd refid=prcrth.ProcCreateThread:elink.&colon.
:xmp.
    call IPCContextResult myContext
    say 'The thread returned: "'result'".'
:exmp.
.*
.************************************
:h2 id=icwait.IPCContextWait function
.************************************
:i2 refid=ipc.wait for context
:i2 refid=ctx.wait
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = IPCContextWait(:hp1.ctxHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
IPCContextWait is used to wait for the thread associated
with the context and get the completion code.  If the
thread has already completed execution at the time of
the call, there will be no wait but the completion code
will be returned.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.ctxHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=iccrea.IPCCreateContext:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
IPCContextWait returns the completion code.
.br
:h3.:hp2.Notes:ehp2.
:p.
After IPCContextWait returns,
:link reftype=hd refid=icresu.IPCContextResult:elink. may
be called to get the string (if any) returned by the thread.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=iccrea.IPCContextCreate:elink.,
:link reftype=hd refid=icquer.IPCContextQuery:elink.,
:link reftype=hd refid=icresu.IPCContextResult:elink.,
:link reftype=hd refid=prcrth.ProcCreateThread:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To wait for an IPC Context used in a
:link reftype=hd refid=npcoas.PipeConnectAsync:elink.&colon.
:xmp.
    call IPCContextWait myContext
    if result \= 0 then signal PipeConnectError
:exmp.
.*
.***********************************
:h2 id=pcdrop.IPCDropFuncs procedure
.***********************************
:i2 refid=ipc.drop functions
:i1 id=drop.drop functions
:i2 refid=drop.IPC
:p.
:h3.:hp2.Syntax:ehp2.
:p.
call IPCDropFuncs
.br
:h3.:hp2.Description:ehp2.
:p.
IPCDropFuncs deregisters all the library procedures and functions.
.br
:h3.:hp2.Arguments:ehp2.
:p.
No arguments are required by IPCDropFuncs.
.br
:h3.:hp2.Returns:ehp2.
:p.
Nothing is returned by IPCDropFuncs.
.br
:h3.:hp2.Notes:ehp2.
:p.
IPC procedures and functions may be deregistered
individually.  IPCDropFuncs is only a shortcut to have
them all deregistered with one call.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=pcload.IPCLoadFuncs:elink.,
:link reftype=hd refid=npload.PipeLoadFuncs:elink.,
:link reftype=hd refid=npdrop.PipeDropFuncs:elink.,
:link reftype=hd refid=prload.ProcLoadFuncs:elink.,
:link reftype=hd refid=prdrop.ProcDropFuncs:elink.,
:link reftype=hd refid=seload.SemLoadFuncs:elink.,
:link reftype=hd refid=sedrop.SemDropFuncs:elink..
.*
.***********************************
:h2 id=pcload.IPCLoadFuncs procedure
.***********************************
:i2 refid=ipc.load functions
:i1 id=load.load functions
:i2 refid=load.IPC
:p.
:h3.:hp2.Syntax:ehp2.
:p.
call IPCLoadFuncs
.br
:h3.:hp2.Description:ehp2.
:p.
IPCLoadFuncs registers all the library procedures and functions.
.br
:h3.:hp2.Arguments:ehp2.
:p.
No arguments are required by IPCLoadFuncs.
.br
:h3.:hp2.Returns:ehp2.
:p.
Nothing is returned by IPCLoadFuncs.
.br
:h3.:hp2.Notes:ehp2.
:p.
IPC procedures and functions must be registered before they can
be used.  They may be registered individually.  IPCLoadFuncs is
only a shortcut to have them all registered with one call.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=pcdrop.IPCDropFuncs:elink.,
:link reftype=hd refid=npload.PipeLoadFuncs:elink.,
:link reftype=hd refid=npdrop.PipeDropFuncs:elink.,
:link reftype=hd refid=prload.ProcLoadFuncs:elink.,
:link reftype=hd refid=prdrop.ProcDropFuncs:elink.,
:link reftype=hd refid=seload.SemLoadFuncs:elink.,
:link reftype=hd refid=sedrop.SemDropFuncs:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To register all the RexxIPC functions&colon.
:xmp.
    call RxFuncAdd 'IPCLoadFuncs', 'REXXIPC', 'IPCLoadFuncs'
    call IPCLoadFuncs
:exmp.
.*
.********************************
:h2 id=pcvers.IPCVersion function
.********************************
:i2 refid=ipc.version
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.versionString:ehp1. = IPCVersion()
.br
:h3.:hp2.Description:ehp2.
:p.
IPCVersion may be used to identify the version of the IPC library.
.br
:h3.:hp2.Arguments:ehp2.
:p.
No arguments are required by IPCVersion.
.br
:h3.:hp2.Returns:ehp2.
:p.
IPCVersion currently returns a string with the format
:hp1.producer:ehp1. :hp1.product:ehp1.
:hp1.major:ehp1..:hp1.minor:ehp1.-:hp1.revision:ehp1.
but this may change in the future.
.*
.im REXXPIPE.IPF
.*
.im REXXPROC.IPF
.*
.im REXXQ.IPF
.*
.im REXXSEM.IPF
.*
:euserdoc.
.*
.* $Log: rexxipc.ipf,v $
.* Revision 1.6  1996/01/14 11:58:47  SFB
.* V1.30-000.
.*
.* Revision 1.5  1995/09/17 13:10:37  SFB
.* Minor adjustements for V1.21.
.*
.* Revision 1.4  1995/06/24 12:42:21  SFB
.* Minor corrections and version set to 1.20-000.
.*
.* Revision 1.3  1995/05/22 21:17:26  SFB
.* Added thread parameter to IPCContextQuery.
.* Added IPCContextResult.
.* Other minor adjustements to documentation.
.*
.*
.* Revision 1.2  1994/07/30  10:46:26  SFB
.* Adjustments for V1.1-0
.*
.* Revision 1.1  1994/05/12  20:59:50  SFB
.* Initial revision

