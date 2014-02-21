.* $Id: rexxproc.ipf,v 1.6 1996/01/14 12:08:31 SFB Rel $
.*
.* $Title: RexxIPC documentation: processes. $
.*
.* Copyright (c) Serge Brisson 1994.
.*
:h1.Process Procedures and Functions
:i1 id=proc.process
:p.
The Proc prefix identifies process related functions.
:p.
The "Control
Program Guide and Reference" (Developer's Toolkit for OS/2)
or "Client/Server Programming with OS/2"
(Van Nostrand Reinhold) are valuable sources of information.
:nt.
The facilities provided by these functions are simple mapping
to the corresponding system services.  They should by used with
caution, since they are much more likely to affect other
processes in the system than the other function groups in
this library.
:ent.
.*
.**************************************
:h2 id=prcrth.ProcCreateThread function
.**************************************
:i2 refid=proc.create thread
:i1.thread
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = ProcCreateThread([&rbl.:hp1.ctxHandle:ehp1.&rbl.],
:hp1.commandFile:ehp1., [&rbl.:hp1....:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
ProcCreateThread is used to create and start a Rexx thread.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.ctxHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=iccrea.IPCContextCreate:elink..  This context is
used to anchor the execution of the thread.  If this parameter
is not supplied, a temporary context
will be automatically generated before the thread is started and
discarded after the thread has terminated.
.*
:pt.:hp1.commandFile:ehp1.
:pd.is the name of a Rexx command file to be executed by the
Rexx interpreter in the thread.
.*
:pt.:hp1....:ehp1.
:pd.these parameters will be passed to the Rexx program.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
ProcSendSignal returns the code supplied by
the DosCreateThread
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.008 -- ERROR_NOT_ENOUGH_MEMORY
:li.095 -- ERROR_INTERRUPT
:li.164 -- ERROR_MAX_THRDS_REACHED
:esl.
:esl.
:h3.:hp2.Notes:ehp2.
:p.
The use of an explicit context allows for a more controlled
execution of the started thread.  It is then possible to specify
an event semaphore to
:link reftype=hd refid=iccrea.IPCContextCreate:elink.
which will be posted when the thread
terminates, to periodically check the thread with
:link reftype=hd refid=icquer.IPCContextQuery:elink.,
to wait for the thread to terminate and get the return code with
:link reftype=hd refid=icwait.IPCContextWait:elink.,
to get the result string returned by the thread with
:link reftype=hd refid=icresu.IPCContextResult:elink.,
and to terminate the thread with
:link reftype=hd refid=icclos.IPCContextClose:elink..
:p.
Thread synchronization and resource access control may be done
with :link reftype=hd refid=se.Semaphore functions:elink..  The
Rexx Queue facility (RxQueue and LineIn functions; Push, Pull
and Queue keywords) may be used to support communication
between threads.
.br
:h3.:hp2.Examples:ehp2.
:p.
To start and forget a thread&colon.
:xmp.
    call ProcCreateThread , 'thread.cmd'
    if result \= 0 then signal CreateThreadError
:exmp.
:p.
To start a thread, do some processing,
then wait and get the thread result&colon.
:xmp.
    call IPCContextCreate 'context'
    if result \= 0 then signal CreateContextError

    call ProcCreateThread context, 'thread.cmd', '1st', '2nd'
    if result \= 0 then signal CreateThreadError

    .
    .
    .

    call IPCContextWait context
    if result \= 0 then signal ThreadTerminatedOnError

    call IPCContextResult context
    say 'The thread returned: "'result'".'
:exmp.
.*
.************************************
:h2 id=prdrop.ProcDropFuncs procedure
.************************************
:i2 refid=proc.drop functions
:i2 refid=drop.process
:p.
:h3.:hp2.Syntax:ehp2.
:p.
call ProcDropFuncs
.br
:h3.:hp2.Description:ehp2.
:p.
ProcDropFuncs deregisters all the process
procedures and functions.
.br
:h3.:hp2.Arguments:ehp2.
:p.
No arguments are required by ProcDropFuncs.
.br
:h3.:hp2.Returns:ehp2.
:p.
Nothing is returned by ProcDropFuncs.
.br
:h3.:hp2.Notes:ehp2.
:p.
Process procedures and functions may be deregistered
individually.  ProcDropFuncs is only a shortcut to have
them all deregistered with one call.
:p.
:link reftype=hd refid=pcdrop.IPCDropFuncs:elink.
will by itself call ProcDropFuncs and deregister it.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=pcdrop.IPCDropFuncs:elink.,
:link reftype=hd refid=prload.ProcLoadFuncs:elink..
.*
.***************************************
:h2 id=prgthi.ProcGetThreadInfo function
.***************************************
:i2 refid=proc.get thread informations
:p.
:h3.:hp2.Syntax:ehp2.
:p.
call ProcGetThreadInfo [&rbl.:hp1.threadIdVar:ehp1.&rbl.],
[&rbl.:hp1.priorityClassVar:ehp1.&rbl.],
[&rbl.:hp1.priorityVar:ehp1.&rbl.],
[&rbl.:hp1.processIdVar:ehp1.&rbl.],
[&rbl.:hp1.parentProcessIdVar:ehp1.&rbl.]
.br
:h3.:hp2.Description:ehp2.
:p.
ProcGetThreadInfo is used to get informations on the current thread.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.threadIdVar:ehp1.
:pd.is the name of the variable which, if present,
will receive the system identification for the thread.
.*
:pt.:hp1.priorityClassVar:ehp1.
:pd.is the name of the variable which will receive the
priority class.  If present, it will get one
of the following keywords:
:parml tsize=30 break=none.
:pt.            :hp2.Idle:ehp2.
:pd.identifies the Idle (lowest) priority class;
:pt.            :hp2.Regular:ehp2.
:pd.identifies the Regular (default) priority class;
:pt.            :hp2.Server:ehp2.
:pd.identifies the Server (high) priority class;
:pt.            :hp2.Critical:ehp2.
:pd.identifies the Critical (highest) priority class.
:eparml.
.*
:pt.:hp1.priorityVar:ehp1.
:pd.is the name of the variable which, if present,
will receive the priority within the current class.
.*
:pt.:hp1.processIdVar:ehp1.
:pd.is the name of the variable which, if present,
will receive the system identification for the process.
.*
:pt.:hp1.parentProcessIdVar:ehp1.
:pd.is the name of the variable which, if present,
will receive the system identification for the parent process.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
Nothing is returned by ProcGetThreadInfo.
.*
.************************************
:h2 id=prload.ProcLoadFuncs procedure
.************************************
:i2 refid=proc.load functions
:i2 refid=load.process
:p.
:h3.:hp2.Syntax:ehp2.
:p.
call ProcLoadFuncs
.br
:h3.:hp2.Description:ehp2.
:p.
ProcLoadFuncs registers all the process
procedures and functions.
.br
:h3.:hp2.Arguments:ehp2.
:p.
No arguments are required by ProcLoadFuncs.
.br
:h3.:hp2.Returns:ehp2.
:p.
Nothing is returned by ProcLoadFuncs.
.br
:h3.:hp2.Notes:ehp2.
:p.
Process procedures and functions must
be registered before they can
be used.  They may be registered individually.  ProcLoadFuncs is
only a shortcut to have them all registered with one call.
:p.
:link reftype=hd refid=pcload.IPCLoadFuncs:elink.
will by itself register and call ProcLoadFuncs.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=pcload.IPCLoadFuncs:elink.,
:link reftype=hd refid=prdrop.ProcDropFuncs:elink..
.*
.************************************
:h2 id=prsign.ProcSendSignal function
.************************************
:i2 refid=proc.send signal
:i1.break
:i1.interrupt
:i1.kill
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = ProcSendSignal(:hp1.processId:ehp1.,
:hp1.signal:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
ProcSendSignal is used to send a signal
(Break, Interrupt or Kill) to a process.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.processId:ehp1.
:pd.is the process identification for the target process.
.*
:pt.:hp1.signal:ehp1.
:pd.identifies the signal to send.  It must be one
of the following keywords:
:parml tsize=30 break=none.
:pt.            :hp2.Break:ehp2.
:pd.send a Break (Ctrl+Break) signal;
:pt.            :hp2.Interrupt:ehp2.
:pd.send an Interrupt (Ctrl+C) signal;
:pt.            :hp2.Kill:ehp2.
:pd.send a Kill signal.
:eparml.
:p.
The keywords are case insensitive and may be abbreviated.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
ProcSendSignal returns the code supplied by
the DosSendSignalException or DosKillProcess
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.156 -- ERROR_SIGNAL_REFUSED
:li.205 -- ERROR_NO_SIGNAL_SENT
:li.217 -- ERROR_ZOMBIE_PROCESS
:li.303 -- ERROR_INVALID_PROCID
:li.305 -- ERROR_NOT_DESCENDANT
:esl.
:esl.
:h3.:hp2.Examples:ehp2.
:p.
To kill a process:
:xmp.
    call ProcSendSignal processId, 'Kill'
    if result \= 0 then signal ProcessKillError
:exmp.
.*
.*************************************
:h2 id=prsprp.ProcSetPriority function
.*************************************
:i2 refid=proc.set process priority
:i1 id=prio.priority
:i2 refid=prio.process
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = ProcSetPriority([&rbl.:hp1.processId:ehp1.&rbl.],
[&rbl.:hp1.class:ehp1.&rbl.],
[&rbl.:hp1.delta:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
ProcSetPriority is used to modify the execution priority
of a process.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.processId:ehp1.
:pd.is the system identification for the target
process.  Absence or 0 (zero) identifies the calling process.
.*
:pt.:hp1.class:ehp1.
:pd.is the new priority class.  If present, it must be one
of the following keywords:
:parml tsize=30 break=none.
:pt.            :hp2.Idle:ehp2.
:pd.identifies the Idle (lowest) priority class;
:pt.            :hp2.Regular:ehp2.
:pd.identifies the Regular (default) priority class;
:pt.            :hp2.Server:ehp2.
:pd.identifies the Server (high) priority class;
:pt.            :hp2.Critical:ehp2.
:pd.identifies the Critical (highest) priority class.
:eparml.
:p.
The keywords are case insensitive and may be abbreviated.
.*
:pt.:hp1.delta:ehp1.
:pd.if the class is not specified, this is the
priority variation within the current class
and may range from -31 to +31;  if the class
is specified, this is the absolute priority within
that class and may range from 0 to +31.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
ProcSetPriority returns the code supplied by
the DosSetPriority system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.303 -- ERROR_INVALID_PROCID
:li.304 -- ERROR_INVALID_PDELTA
:li.305 -- ERROR_NOT_DESCENDANT
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=prsthp.ProcSetThreadPriority:elink.,
:link reftype=hd refid=prstrp.ProcSetTreePriority:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To set the priority of the current process to 20
in the Idle class:
:xmp.
    call ProcSetPriority 0, 'Idle', 20
    if result \= 0 then signal SetPriorityError
:exmp.
.*
.*******************************************
:h2 id=prsthp.ProcSetThreadPriority function
.*******************************************
:i2 refid=proc.set thread priority
:i2 refid=prio.thread
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = ProcSetThreadPriority([&rbl.:hp1.threadId:ehp1.&rbl.],
[&rbl.:hp1.class:ehp1.&rbl.],
[&rbl.:hp1.delta:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
ProcSetThreadPriority is used to modify the execution priority
of a thread.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.threadId:ehp1.
:pd.is the system identification for the target
thread.  Absence or 0 (zero) identifies the calling thread.
.*
:pt.:hp1.class:ehp1.
:pd.is the new priority class.  If present, it must be one
of the following keywords:
:parml tsize=30 break=none.
:pt.            :hp2.Idle:ehp2.
:pd.identifies the Idle (lowest) priority class;
:pt.            :hp2.Regular:ehp2.
:pd.identifies the Regular (default) priority class;
:pt.            :hp2.Server:ehp2.
:pd.identifies the Server (high) priority class;
:pt.            :hp2.Critical:ehp2.
:pd.identifies the Critical (highest) priority class.
:eparml.
:p.
The keywords are case insensitive and may be abbreviated.
.*
:pt.:hp1.delta:ehp1.
:pd.if the class is not specified, this is the
priority variation within the current class
and may range from -31 to +31;  if the class
is specified, this is the absolute priority within
that class and may range from 0 to +31.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
ProcSetThreadPriority returns the code supplied by
the DosSetPriority system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.304 -- ERROR_INVALID_PDELTA
:li.309 -- ERROR_INVALID_THREADID
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=prsprp.ProcSetPriority:elink.,
:link reftype=hd refid=prstrp.ProcSetTreePriority:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To set the priority of the current thread to 20
in the Idle class:
:xmp.
    call ProcSetThreadPriority 0, 'Idle', 20
    if result \= 0 then signal SetPriorityError
:exmp.
.*
.*****************************************
:h2 id=prstrp.ProcSetTreePriority function
.*****************************************
:i2 refid=proc.set process tree priority
:i2 refid=prio.process tree
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = ProcSetTreePriority([&rbl.:hp1.processId:ehp1.&rbl.],
[&rbl.:hp1.class:ehp1.&rbl.],
[&rbl.:hp1.delta:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
ProcSetPriority is used to modify the execution priority
of a process tree.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.processId:ehp1.
:pd.is the system identification for the parent process of
the target process tree.  Absence or 0 (zero) identifies
the calling process as the parent.
.*
:pt.:hp1.class:ehp1.
:pd.is the new priority class.  If present, it must be one
of the following keywords:
:parml tsize=30 break=none.
:pt.            :hp2.Idle:ehp2.
:pd.identifies the Idle (lowest) priority class;
:pt.            :hp2.Regular:ehp2.
:pd.identifies the Regular (default) priority class;
:pt.            :hp2.Server:ehp2.
:pd.identifies the Server (high) priority class;
:pt.            :hp2.Critical:ehp2.
:pd.identifies the Critical (highest) priority class.
:eparml.
:p.
The keywords are case insensitive and may be abbreviated.
.*
:pt.:hp1.delta:ehp1.
:pd.if the class is not specified, this is the
priority variation within the current class
and may range from -31 to +31;  if the class
is specified, this is the absolute priority within
that class and may range from 0 to +31.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
ProcSetPriority returns the code supplied by
the DosSetPriority system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.303 -- ERROR_INVALID_PROCID
:li.304 -- ERROR_INVALID_PDELTA
:li.305 -- ERROR_NOT_DESCENDANT
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=prsprp.ProcSetPriority:elink.,
:link reftype=hd refid=prsthp.ProcSetThreadPriority:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To set the priority of the current process tree to 20
in the Idle class:
:xmp.
    call ProcSetTreePriority 0, 'Idle', 20
    if result \= 0 then signal SetPriorityError
:exmp.
.*
.* $Log: rexxproc.ipf,v $
.* Revision 1.6  1996/01/14 12:08:31  SFB
.* Correction to ProcGetThreadInfo syntax.
.*
.* Revision 1.5  1995/09/17 13:21:57  SFB
.* Adds ProcGetThreadInfo.
.* Adds expected result codes.
.*
.* Revision 1.4  1995/06/24 12:52:41  SFB
.* Minor changes.
.*
.* Revision 1.3  1995/05/22 21:15:33  SFB
.* Added ProcCreateThread.
.* 
.* Revision 1.2  1994/07/30  10:46:26  SFB
.* Adjustments for V1.1-0
.*
.* Revision 1.1  1994/05/12  20:59:50  SFB
.* Initial revision

