.* $Id: rexxsem.ipf,v 1.5 1995/09/17 13:25:27 SFB Rel $
.*
.* $Title: RexxIPC documentation: semaphores. $
.*
.* Copyright (c) Serge Brisson 1994.
.*
:h1 id=se.Semaphore Procedures and Functions
:i1 id=sem.semaphore
:p.
The Sem prefix identifies semaphore related function.  Except for
a few procedures
(:link reftype=hd refid=seload.SemLoadFuncs:elink.
and :link reftype=hd refid=sedrop.SemDropFuncs:elink.),
the prefix is expressed as SemEvent, SemMutex or SemMuxwait,
to specify to which type of semaphore the function applies.
:p.
The "Control Program Guide and Reference" (Developer's Toolkit for OS/2)
or "Client/Server Programming with OS/2"
(Van Nostrand Reinhold) are valuable sources of information.
:nt.
The semaphore handle mentionned in the individual semaphore functions
description is the actual value used by the operating system,
converted to an unsigned decimal
number character string.  It is not associated with internal structures of
the RexxIPC library and may be created/used by other modules
of the same process.
:ent.
.*
.***********************************
:h2 id=sedrop.SemDropFuncs procedure
.***********************************
:i2 refid=sem.drop functions
:i2 refid=drop.semaphore
:p.
:h3.:hp2.Syntax:ehp2.
:p.
call SemDropFuncs
.br
:h3.:hp2.Description:ehp2.
:p.
SemDropFuncs deregisters all the semaphore procedures and functions.
.br
:h3.:hp2.Arguments:ehp2.
:p.
No arguments are required by SemDropFuncs.
.br
:h3.:hp2.Returns:ehp2.
:p.
Nothing is returned by SemDropFuncs.
.br
:h3.:hp2.Notes:ehp2.
:p.
Semaphore procedures and functions may be deregistered
individually.  SemDropFuncs is only a shortcut to have
them all deregistered with one call.
:p.
:link reftype=hd refid=pcdrop.IPCDropFuncs:elink.
will by itself call SemDropFuncs and deregister it.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=pcload.IPCLoadFuncs:elink.,
:link reftype=hd refid=pcdrop.IPCDropFuncs:elink.,
:link reftype=hd refid=seload.SemLoadFuncs:elink..
.*
.***********************************
:h2 id=evclos.SemEventClose function
.***********************************
:i2 refid=event.close
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemEventClose(:hp1.semHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
SemEventClose closes an event semaphore.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.semHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=evcrea.SemEventCreate:elink.
or :link reftype=hd refid=evopen.SemEventOpen:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemEventClose returns the code supplied by the DosCloseEventSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.006 -- ERROR_INVALID_HANDLE
:li.301 -- ERROR_SEM_BUSY
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=evcrea.SemEventCreate:elink.,
:link reftype=hd refid=evopen.SemEventOpen:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To close an event semaphore:
:xmp.
    call SemEventClose sem
    if result \= 0 then signal SemCloseError
:exmp.
.*
.************************************
:h2 id=evcrea.SemEventCreate function
.************************************
:i2 refid=sem.event
:i1 id=event.event semaphore
:i2 refid=event.create
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemEventCreate(:hp1.handleVar:ehp1.,
[&rbl.:hp1.name:ehp1.&rbl.],
[&rbl.:hp1.initial:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
SemEventCreate is used to create an event semaphore.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.handleVar:ehp1.
:pd.is the name of a variable which will receive the handle to the
event semaphore.
.*
:pt.:hp1.name:ehp1.
:pd.specifies the name for the semaphore. If present, it must have the form:
:p.
        \SEM32\:hp1.semName:ehp1.
:p.
where:
:parml tsize=30 break=none.
:pt.            :hp1.semName:ehp1.
:pd.is the name of the semaphore.
:eparml.
:p.
If a name is not specified,
the keyword :hp2.Shared:ehp2. (case insensitive and
may be abbreviated) can be used to create a shared
unnamed semaphore; otherwise
a local semaphore is created.
.*
:pt.:hp1.initial:ehp1.
:pd.is the initial state of the event semaphore: posted (1) or
reset (0).  The default is 0.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemEventCreate returns the code supplied by the DosCreateEventSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.008 -- ERROR_NOT_ENOUGH_MEMORY
:li.123 -- ERROR_INVALID_NAME
:li.285 -- ERROR_DUPLICATE_NAME
:li.290 -- ERROR_TOO_MANY_HANDLES
:esl.
:esl.
:h3.:hp2.Notes:ehp2.
:p.
If the return code is non-zero, :hp1.handleVar:ehp1. is not
created or modified.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=evopen.SemEventOpen:elink.,
:link reftype=hd refid=evclos.SemEventClose:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To create an event semaphore or just open if it already exists&colon.
:xmp.
    semName = '\SEM32\MY_SEMAPHORE'
    call SemEventCreate 'sem', semName
    if result = 285 then call SemEventOpen 'sem', semName
    if result \= 0 then signal SemCreateError
:exmp.
.*
.**********************************
:h2 id=evopen.SemEventOpen function
.**********************************
:i2 refid=event.open
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemEventOpen(:hp1.handleVar:ehp1.,
:hp1.name:ehp1.)
.br
:hp1.rc:ehp1. = SemEventOpen(:hp1.semHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
SemEventOpen is used to open either a named event semaphore
(first form), or a shared unnamed event semaphore
(second form).
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.handleVar:ehp1.
:pd.is the name of a variable which will receive the handle to the
event semaphore.
.*
:pt.:hp1.name:ehp1.
:pd.specifies the name for the semaphore. It must have the form:
:p.
        \SEM32\:hp1.semName:ehp1.
:p.
where:
:parml tsize=30 break=none.
:pt.            :hp1.semName:ehp1.
:pd.is the name of the semaphore.
:eparml.
.*
:pt.:hp1.semHandle:ehp1.
:pd.is a handle to a shared unnamed event semaphore.  This handle
has to be obtained from the process which created the semaphore.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemEventOpen returns the code supplied by the DosOpenEventSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.006 -- ERROR_INVALID_HANDLE
:li.008 -- ERROR_NOT_ENOUGH_MEMORY
:li.123 -- ERROR_INVALID_NAME
:li.187 -- ERROR_SEM_NOT_FOUND
:li.291 -- ERROR_TOO_MANY_OPENS
:esl.
:esl.
:h3.:hp2.Notes:ehp2.
:p.
If the return code is non-zero, :hp1.handleVar:ehp1. is not
created or modified.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=evcrea.SemEventCreate:elink.,
:link reftype=hd refid=evclos.SemEventClose:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To open a named event semaphore:
:xmp.
    call SemEventOpen 'sem', '\SEM32\A_NAMED_SEMAPHORE'
    if result \= 0 then signal SemOpenError
:exmp.
.*
.**********************************
:h2 id=evpost.SemEventPost function
.**********************************
:i2 refid=event.post
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemEventPost(:hp1.semHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
SemEventPost posts an event semaphore.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.semHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=evcrea.SemEventCreate:elink.
or :link reftype=hd refid=evopen.SemEventOpen:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemEventPost returns the code supplied by the DosPostEventSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.006 -- ERROR_INVALID_HANDLE
:li.298 -- ERROR_TOO_MANY_POSTS
:li.299 -- ERROR_ALREADY_POSTED
:esl.
:esl.
:h3.:hp2.Notes:ehp2.
:p.
OS/2 limits the number of posts without a reset to 65535.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=evrese.SemEventReset:elink.,
:link reftype=hd refid=evquer.SemEventQuery:elink.,
:link reftype=hd refid=evwait.SemEventWait:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To post an event:
:xmp.
    call SemEventPost sem
    if result \= 0 then signal SemPostError
:exmp.
.*
.***********************************
:h2 id=evquer.SemEventQuery function
.***********************************
:i2 refid=event.query
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemEventQuery(:hp1.semHandle:ehp1.,
:hp1.postCountVar:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
SemEventQuery queries informations from an event semaphore.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.semHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=evcrea.SemEventCreate:elink.
or :link reftype=hd refid=evopen.SemEventOpen:elink.
.*
:pt.:hp1.postCountVar:ehp1.
:pd.is the name of the variable which will receive
the number of post actions since the last time the
semaphore was in a reset state.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemEventQuery returns the code supplied by the DosQueryEventSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.006 -- ERROR_INVALID_HANDLE
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=evrese.SemEventReset:elink.,
:link reftype=hd refid=evpost.SemEventPost:elink.,
:link reftype=hd refid=evwait.SemEventWait:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To query an event semaphore:
:xmp.
    call SemEventQuery sem, 'count'
    if result \= 0 then signal SemQueryError
    say 'Semaphore post count&colon.' count
:exmp.
.*
.***********************************
:h2 id=evrese.SemEventReset function
.***********************************
:i2 refid=event.reset
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemEventReset(:hp1.semHandle:ehp1.,
[&rbl.:hp1.postCountVar:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
SemEventReset resets an event semaphore.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.semHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=evcrea.SemEventCreate:elink.
or :link reftype=hd refid=evopen.SemEventOpen:elink..
.*
:pt.:hp1.postCountVar:ehp1.
:pd.if present, is the name of the variable which will receive
the number of post actions since the last time the
semaphore was in a reset state.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemEventReset returns the code supplied by the DosResetEventSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.006 -- ERROR_INVALID_HANDLE
:li.300 -- ERROR_ALREADY_RESET
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=evpost.SemEventPost:elink.,
:link reftype=hd refid=evquer.SemEventQuery:elink.,
:link reftype=hd refid=evwait.SemEventWait:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To reset an event semaphore:
:xmp.
    call SemEventReset sem
    if result \= 0 then signal SemResetError
:exmp.
.*
.**********************************
:h2 id=evwait.SemEventWait function
.**********************************
:i2 refid=event.wait
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemEventWait(:hp1.semHandle:ehp1.,
[&rbl.:hp1.timeout:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
SemEventWait waits for an event semaphore to be in a non reset state.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.semHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=evcrea.SemEventCreate:elink.
or :link reftype=hd refid=evopen.SemEventOpen:elink..
.*
:pt.:hp1.timeout:ehp1.
:pd.is the wait timeout in milliseconds.  A value of -1 means an
infinite wait;  this is the default.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemEventWait returns the code supplied by the DosWaitEventSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.006 -- ERROR_INVALID_HANDLE
:li.008 -- ERROR_NOT_ENOUGH_MEMORY
:li.095 -- ERROR_INTERRUPT
:li.640 -- ERROR_TIMEOUT
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=evpost.SemEventPost:elink.,
:link reftype=hd refid=evrese.SemEventReset:elink.,
:link reftype=hd refid=evquer.SemEventQuery:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To wait for an event semaphore:
:xmp.
    call SemEventWait sem
    if result \= 0 then signal SemWaitError
:exmp.
.*
.***********************************
:h2 id=seload.SemLoadFuncs procedure
.***********************************
:i2 refid=sem.load functions
:i2 refid=load.semaphore
:p.
:h3.:hp2.Syntax:ehp2.
:p.
call SemLoadFuncs
.br
:h3.:hp2.Description:ehp2.
:p.
SemLoadFuncs registers all the semaphore procedures and functions.
.br
:h3.:hp2.Arguments:ehp2.
:p.
No arguments are required by SemLoadFuncs.
.br
:h3.:hp2.Returns:ehp2.
:p.
Nothing is returned by SemLoadFuncs.
.br
:h3.:hp2.Notes:ehp2.
:p.
Semaphore procedures and functions must be registered before they can
be used.  They may be registered individually.  SemLoadFuncs is
only a shortcut to have them all registered with one call.
:p.
:link reftype=hd refid=pcload.IPCLoadFuncs:elink.
will by itself register and call SemLoadFuncs.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=pcload.IPCLoadFuncs:elink.,
:link reftype=hd refid=sedrop.SemDropFuncs:elink..
.*
.***********************************
:h2 id=mxclos.SemMutexClose function
.***********************************
:i2 refid=mutex.close
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemMutexClose(:hp1.semHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
SemMutexClose closes a mutex semaphore.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.semHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=mxcrea.SemMutexCreate:elink.
or :link reftype=hd refid=mxopen.SemMutexOpen:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemMutexClose returns the code supplied by the DosCloseMutexSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.006 -- ERROR_INVALID_HANDLE
:li.301 -- ERROR_SEM_BUSY
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=mxcrea.SemMutexCreate:elink.,
:link reftype=hd refid=mxopen.SemMutexOpen:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To close a mutex semaphore:
:xmp.
    call SemMutexClose sem
    if result \= 0 then signal SemCloseError
:exmp.
.*
.************************************
:h2 id=mxcrea.SemMutexCreate function
.************************************
:i2 refid=sem.mutex
:i1 id=mutex.mutex semaphore
:i2 refid=mutex.create
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemMutexCreate(:hp1.handleVar:ehp1.,
[&rbl.:hp1.name:ehp1.&rbl.],
[&rbl.:hp1.initial:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
SemMutexCreate is used to create a mutex semaphore.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.handleVar:ehp1.
:pd.is the name of a variable which will receive the handle to the
mutex semaphore.
.*
:pt.:hp1.name:ehp1.
:pd.specifies the name for the semaphore. If present, it must have the form:
:p.
        \SEM32\:hp1.semName:ehp1.
:p.
where:
:parml tsize=30 break=none.
:pt.            :hp1.semName:ehp1.
:pd.is the name of the semaphore.
:eparml.
:p.
If a name is not specified,
the keyword :hp2.Shared:ehp2. (case insensitive and
may be abbreviated) can be used to create a shared
unnamed semaphore; otherwise
a local semaphore is created.
.*
:pt.:hp1.initial:ehp1.
:pd.is the initial state of the mutex semaphore: held (1) or
released (0).  The default is 0.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemMutexCreate returns the code supplied by the DosCreateMutexSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.008 -- ERROR_NOT_ENOUGH_MEMORY
:li.123 -- ERROR_INVALID_NAME
:li.285 -- ERROR_DUPLICATE_NAME
:li.290 -- ERROR_TOO_MANY_HANDLES
:esl.
:esl.
:h3.:hp2.Notes:ehp2.
:p.
If the return code is non-zero, :hp1.handleVar:ehp1. is not
created or modified.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=mxopen.SemMutexOpen:elink.,
:link reftype=hd refid=mxclos.SemMutexClose:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To create a mutex semaphore:
:xmp.
    call SemMutexCreate 'sem', '\SEM32\MY_SEMAPHORE'
    if result \= 0 then signal SemCreateError
:exmp.
.*
.**********************************
:h2 id=mxopen.SemMutexOpen function
.**********************************
:i2 refid=mutex.open
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemMutexOpen(:hp1.handleVar:ehp1.,
:hp1.name:ehp1.)
.br
:hp1.rc:ehp1. = SemMutexOpen(:hp1.semHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
SemMutexOpen is used to open either a named mutex semaphore
(first form), or a shared unnamed mutex semaphore
(second form).
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.handleVar:ehp1.
:pd.is the name of a variable which will receive the handle to the
mutex semaphore.
.*
:pt.:hp1.name:ehp1.
:pd.specifies the name for the semaphore. It must have the form:
:p.
        \SEM32\:hp1.semName:ehp1.
:p.
where:
:parml tsize=30 break=none.
:pt.            :hp1.semName:ehp1.
:pd.is the name of the semaphore.
:eparml.
.*
:pt.:hp1.semHandle:ehp1.
:pd.is a handle to a shared unnamed mutex semaphore.  This handle
has to be obtained from the process which created the semaphore.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemMutexOpen returns the code supplied by the DosOpenMutexSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.006 -- ERROR_INVALID_HANDLE
:li.008 -- ERROR_NOT_ENOUGH_MEMORY
:li.105 -- ERROR_SEM_OWNER_DIED
:li.123 -- ERROR_INVALID_NAME
:li.187 -- ERROR_SEM_NOT_FOUND
:li.291 -- ERROR_TOO_MANY_OPENS
:esl.
:esl.
:h3.:hp2.Notes:ehp2.
:p.
If the return code is non-zero, :hp1.handleVar:ehp1. is not
created or modified.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=mxcrea.SemMutexCreate:elink.,
:link reftype=hd refid=mxclos.SemMutexClose:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To open a named mutex semaphore:
:xmp.
    call SemMutexOpen 'sem', '\SEM32\A_NAMED_SEMAPHORE'
    if result \= 0 then signal SemOpenError
:exmp.
.*
.***********************************
:h2 id=mxquer.SemMutexQuery function
.***********************************
:i2 refid=mutex.query
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemMutexQuery(:hp1.semHandle:ehp1.,
[&rbl.:hp1.processIdVar:ehp1.&rbl.],
[&rbl.:hp1.threadIdVar:ehp1.&rbl.],
[&rbl.:hp1.countVar:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
SemMutexQuery queries informations from a mutex semaphore.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.semHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=mxcrea.SemMutexCreate:elink.
or :link reftype=hd refid=mxopen.SemMutexOpen:elink..
.*
:pt.:hp1.processIdVar:ehp1.
:pd.if present, is the name of the variable which will receive
the id of the owner process.
.*
:pt.:hp1.threadIdVar:ehp1.
:pd.if present, is the name of the variable which will receive
the id of the owner thread.
.*
:pt.:hp1.countVar:ehp1.
:pd.if present, is the name of the variable which will receive
the request count from the owner process.  If the semaphore is
unowned, the count is zero.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemMutexQuery returns the code supplied by the DosQueryMutexSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.006 -- ERROR_INVALID_HANDLE
:li.105 -- ERROR_SEM_OWNER_DIED
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=mxrequ.SemMutexRequest:elink.,
:link reftype=hd refid=mxrele.SemMutexRelease:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To query a mutex semaphore:
:xmp.
    call SemMutexQuery sem, 'processId', 'threadId', 'count'
    if result \= 0 then signal SemQueryError
    say 'Semaphore post count&colon.' count
    if count \= 0 then
    do
        say 'Semaphore owner process&colon.' processId
        say 'Semaphore owner thread&colon.' threadId
    end
:exmp.
.*
.*************************************
:h2 id=mxrele.SemMutexRelease function
.*************************************
:i2 refid=mutex.release
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemMutexRelease(:hp1.semHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
SemMutexRelease releases a mutex semaphore.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.semHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=mxcrea.SemMutexCreate:elink.
or :link reftype=hd refid=mxopen.SemMutexOpen:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemMutexRelease returns the code supplied by the DosReleaseMutexSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.006 -- ERROR_INVALID_HANDLE
:li.288 -- ERROR_NOT_OWNER
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=mxrequ.SemMutexRequest:elink.,
:link reftype=hd refid=mxquer.SemMutexQuery:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To release a mutex semaphore:
:xmp.
    call SemMutexRelease sem
    if result \= 0 then signal SemReleaseError
:exmp.
.*
.*************************************
:h2 id=mxrequ.SemMutexRequest function
.*************************************
:i2 refid=mutex.request
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemMutexRequest(:hp1.semHandle:ehp1.,
[&rbl.:hp1.timeout:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
SemMutexRequest requests to be the owner of a mutex semaphore.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.semHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=mxcrea.SemMutexCreate:elink.
or :link reftype=hd refid=mxopen.SemMutexOpen:elink..
.*
:pt.:hp1.timeout:ehp1.
:pd.is the wait timeout in milliseconds.  A value of -1 means an
infinite wait;  this is the default.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemMutexRequest returns the code supplied by the DosRequestMutexSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.006 -- ERROR_INVALID_HANDLE
:li.095 -- ERROR_INTERRUPT
:li.103 -- ERROR_TOO_MANY_SEM_REQUESTS
:li.105 -- ERROR_SEM_OWNER_DIED
:li.640 -- ERROR_TIMEOUT
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=mxcrea.SemMutexCreate:elink.,
:link reftype=hd refid=mxrele.SemMutexRelease:elink.,
:link reftype=hd refid=mxquer.SemMutexQuery:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To request a mutex semaphore:
:xmp.
    call SemMutexRequest sem
    if result \= 0 then signal SemRequestError
:exmp.
.*
.**********************************
:h2 id=mwadd.SemMuxwaitAdd function
.**********************************
:i2 refid=mux.add semaphore
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemMuxwaitAdd(:hp1.semHandle:ehp1.,
:hp1.otherSemHandle:ehp1.,
[&rbl.:hp1.userValue:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
SemMuxwaitAdd adds a semaphore to the associated semaphores list.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.semHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=mwcrea.SemMuxwaitCreate:elink.
or :link reftype=hd refid=mwopen.SemMuxwaitOpen:elink..
.*
:pt.:hp1.otherSemHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=evcrea.SemEventCreate:elink.,
:link reftype=hd refid=evopen.SemEventOpen:elink.,
:link reftype=hd refid=mxcrea.SemMutexCreate:elink.,
or :link reftype=hd refid=mxopen.SemMutexOpen:elink..
.*
:pt.:hp1.userValue:ehp1.
:pd.a numeric value to be returned by
:link reftype=hd refid=mwwait.SemMuxwaitWait:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemMuxwaitAdd returns the code supplied by the DosAddMuxWaitSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.006 -- ERROR_INVALID_HANDLE
:li.008 -- ERROR_NOT_ENOUGH_MEMORY
:li.100 -- ERROR_TOO_MANY_SEMAPHORES
:li.105 -- ERROR_SEM_OWNER_DIED
:li.284 -- ERROR_DUPLICATE_HANDLE
:li.292 -- ERROR_WRONG_TYPE
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=mwcrea.SemMuxwaitCreate:elink.,
:link reftype=hd refid=mwopen.SemMuxwaitOpen:elink.,
:link reftype=hd refid=mwdele.SemMuxwaitRemove:elink.,
:link reftype=hd refid=evcrea.SemEventCreate:elink.,
:link reftype=hd refid=evopen.SemEventOpen:elink.,
:link reftype=hd refid=mxcrea.SemMutexCreate:elink.,
:link reftype=hd refid=mxopen.SemMutexOpen:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To add an event semaphore to a muxwait semaphore:
:xmp.
    call SemEventCreate 'eventSem'
    if result \= 0 then signal SemCreateError
    call SemMuxwaitAdd muxSem, eventSem, 1
    if result \= 0 then signal SemAddError
:exmp.
.*
.*************************************
:h2 id=mwclos.SemMuxwaitClose function
.*************************************
:i2 refid=mux.close
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemMuxwaitClose(:hp1.semHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
SemMuxwaitClose closes a muxwait semaphore.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.semHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=mwcrea.SemMuxwaitCreate:elink.
or :link reftype=hd refid=mwopen.SemMuxwaitOpen:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemMuxwaitClose returns the code supplied by the DosCloseMuxWaitSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.006 -- ERROR_INVALID_HANDLE
:li.301 -- ERROR_SEM_BUSY
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=mwcrea.SemMuxwaitCreate:elink.,
:link reftype=hd refid=mwopen.SemMuxwaitOpen:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To close a muxwait semaphore:
:xmp.
    call SemMuxwaitClose sem
    if result \= 0 then signal SemCloseError
:exmp.
.*
.**************************************
:h2 id=mwcrea.SemMuxwaitCreate function
.**************************************
:i2 refid=sem.muxwait
:i1 id=mux.muxwait semaphore
:i2 refid=mux.create
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemMuxwaitCreate(:hp1.handleVar:ehp1.,
[&rbl.:hp1.name:ehp1.&rbl.],
:hp1.mode:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
SemMuxwaitCreate is used to create a muxwait semaphore.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.handleVar:ehp1.
:pd.is the name of a variable which will receive the handle to the
muxwait semaphore.
.*
:pt.:hp1.name:ehp1.
:pd.specifies the name for the semaphore. If present, it must have the form:
:p.
        \SEM32\:hp1.semName:ehp1.
:p.
where:
:parml tsize=30 break=none.
:pt.            :hp1.semName:ehp1.
:pd.is the name of the semaphore.
:eparml.
:p.
If a name is not specified,
the keyword :hp2.Shared:ehp2. (case insensitive and
may be abbreviated) can be used to create a shared
unnamed semaphore; otherwise
a local semaphore is created.
.*
:pt.:hp1.mode:ehp1.
:pd.is the muxwait semaphore wait mode.  It must be one
of the following keywords:
:parml tsize=30 break=none.
:pt.            :hp2.And:ehp2.
:pd.wait for all associated semaphores;
:pt.            :hp2.Or:ehp2.
:pd.wait for any associated semaphore.
:eparml.
:p.
The keywords are case insensitive and may be abbreviated.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemMuxwaitCreate returns the code supplied by the DosCreateMuxWaitSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.008 -- ERROR_NOT_ENOUGH_MEMORY
:li.123 -- ERROR_INVALID_NAME
:li.285 -- ERROR_DUPLICATE_NAME
:li.290 -- ERROR_TOO_MANY_HANDLES
:esl.
:esl.
:h3.:hp2.Notes:ehp2.
:p.
If the return code is non-zero, :hp1.handleVar:ehp1. is not
created or modified.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=mwadd.SemMuxwaitAdd:elink.,
:link reftype=hd refid=mwclos.SemMuxwaitClose:elink.,
:link reftype=hd refid=mwopen.SemMuxwaitOpen:elink.,
:link reftype=hd refid=mwwait.SemMuxwaitWait:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To create a muxwait semaphore:
:xmp.
    call SemMuxwaitCreate 'sem', '\SEM32\MY_MUXWAIT_SEM', 'Or'
    if result \= 0 then signal SemCreateError
:exmp.
.*
.************************************
:h2 id=mwopen.SemMuxwaitOpen function
.************************************
:i2 refid=mux.open
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemMuxwaitOpen(:hp1.handleVar:ehp1.,
:hp1.name:ehp1.)
.br
:hp1.rc:ehp1. = SemMuxwaitOpen(:hp1.semHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
SemMuxwaitOpen is used to open either a named muxwait semaphore
(first form), or a shared unnamed muxwait semaphore
(second form).
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.handleVar:ehp1.
:pd.is the name of a variable which will receive the handle to the
muxwait semaphore.
.*
:pt.:hp1.name:ehp1.
:pd.specifies the name for the semaphore. It must have the form:
:p.
        \SEM32\:hp1.semName:ehp1.
:p.
where:
:parml tsize=30 break=none.
:pt.            :hp1.semName:ehp1.
:pd.is the name of the semaphore.
:eparml.
.*
:pt.:hp1.semHandle:ehp1.
:pd.is a handle to a shared unnamed muxwait semaphore.  This handle
has to be obtained from the process which created the semaphore.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemMuxwaitOpen returns the code supplied by the DosOpenMuxWaitSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.006 -- ERROR_INVALID_HANDLE
:li.008 -- ERROR_NOT_ENOUGH_MEMORY
:li.105 -- ERROR_SEM_OWNER_DIED
:li.123 -- ERROR_INVALID_NAME
:li.187 -- ERROR_SEM_NOT_FOUND
:li.291 -- ERROR_TOO_MANY_OPENS
:esl.
:esl.
:h3.:hp2.Notes:ehp2.
:p.
If the return code is non-zero, :hp1.handleVar:ehp1. is not
created or modified.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=mwcrea.SemMuxwaitCreate:elink.,
:link reftype=hd refid=mwclos.SemMuxwaitClose:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To open a named muxwait semaphore:
:xmp.
    call SemMuxwaitOpen 'sem', '\SEM32\A_NAMED_MUXWAIT_SEM'
    if result \= 0 then signal SemOpenError
:exmp.
.*
.**************************************
:h2 id=mwdele.SemMuxwaitRemove function
.**************************************
:i2 refid=mux.delete semaphore
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemMuxwaitRemove(:hp1.semHandle:ehp1.,
:hp1.otherSemHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
SemMuxwaitRemove removes a semaphore from the
associated semaphores list.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.semHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=mwcrea.SemMuxwaitCreate:elink.
or :link reftype=hd refid=mwopen.SemMuxwaitOpen:elink..
.*
:pt.:hp1.otherSemHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=evcrea.SemEventCreate:elink.,
:link reftype=hd refid=evopen.SemEventOpen:elink.,
:link reftype=hd refid=mxcrea.SemMutexCreate:elink.,
or :link reftype=hd refid=mxopen.SemMutexOpen:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemMuxwaitRemove returns the code supplied by
the DosDeleteMuxWaitSem system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.006 -- ERROR_INVALID_HANDLE
:li.286 -- ERROR_EMPTY_MUXWAIT
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=mwcrea.SemMuxwaitAdd:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To remove an event semaphore from a muxwait semaphore:
:xmp.
    call SemMuxwaitRemove muxSem, eventSem
    if result \= 0 then signal SemRemoveError
:exmp.
.*
.************************************
:h2 id=mwwait.SemMuxwaitWait function
.************************************
:i2 refid=mux.wait
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemMuxwaitWait(:hp1.semHandle:ehp1.,
[&rbl.:hp1.timeout:ehp1.&rbl.],
[&rbl.:hp1.userVar:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
SemMuxwaitWait waits for a muxwait semaphore.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.semHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=mwcrea.SemMuxwaitCreate:elink.
or :link reftype=hd refid=mwopen.SemMuxwaitOpen:elink..
.*
:pt.:hp1.timeout:ehp1.
:pd.is the wait timeout in milliseconds.  A value of -1 means an
infinite wait;  this is the default.
.*
:pt.:hp1.userVar:ehp1.
:pd.is the name of a variable which will receive
the optional value specified with the
:link reftype=hd refid=mwadd.SemMuxwaitAdd:elink. function.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemMuxwaitWait returns the code supplied by
the DosWaitMuxWaitSem system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.006 -- ERROR_INVALID_HANDLE
:li.008 -- ERROR_NOT_ENOUGH_MEMORY
:li.095 -- ERROR_INTERRUPT
:li.105 -- ERROR_SEM_OWNER_DIED
:li.286 -- ERROR_EMPTY_MUXWAIT
:li.287 -- ERROR_MUTEX_OWNED
:li.640 -- ERROR_TIMEOUT
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=mwadd.SemMuxwaitAdd:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To wait for a muxwait semaphore:
:xmp.
    call SemMuxwaitWait sem
    if result \= 0 then signal SemWaitError
:exmp.
.*
.***********************************
:h2 id=tistar.SemStartTimer function
.***********************************
:i1 id=timer.timer
:i2 refid=timer.start
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemStartTimer([&rbl.:hp1.handleVar:ehp1.&rbl.],
:hp1.interval:ehp1.,
:hp1.semHandle:ehp1.,
[&rbl.:hp1.type:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
SemStartTimer is used to create and start a timer
which will post a shared event semaphore.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.handleVar:ehp1.
:pd.is the name of a variable which will receive
the handle to the timer.
.*
:pt.:hp1.interval:ehp1.
:pd.is the time interval in milliseconds.
.*
:pt.:hp1.semHandle:ehp1.
:pd.is a shared event semaphore handle as obtained from
:link reftype=hd refid=evcrea.SemEventCreate:elink.
or :link reftype=hd refid=evopen.SemEventOpen:elink..
.*
:pt.:hp1.type:ehp1.
:pd.is the timer type.  It must be one
of the following keywords:
:parml tsize=30 break=none.
:pt.            :hp2.Repeat:ehp2.
:pd.the timer will repeat;
:pt.            :hp2.Single:ehp2.
:pd.the timer will execute only once; this is the default.
:eparml.
:p.
The keywords are case insensitive and may be abbreviated.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemStartTimer returns the code supplied by the DosAsyncTimer
or DosStartTimer system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.323 -- ERROR_TS_SEMHANDLE
:li.324 -- ERROR_TS_NOTIMER
:esl.
:esl.
:h3.:hp2.Notes:ehp2.
:p.
If the return code is non-zero, :hp1.handleVar:ehp1. is not
created or modified.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=tistop.SemStopTimer:elink.,
:link reftype=hd refid=evcrea.SemEventCreate:elink.,
:link reftype=hd refid=evwait.SemEventWait:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To start a timer and wait until it fires (60 seconds):
:xmp.
    call SemEventCreate 'timerSem', 'Shared'
    if result \= 0 then signal SemCreateError

    call SemStartTimer , 60 * 1000, timerSem
    if result \= 0 then signal TimerStartError

    call SemEventWait timerSem
    if result \= 0 then signal SemWaitError
:exmp.
.*
.**********************************
:h2 id=tistop.SemStopTimer function
.**********************************
:i2 refid=timer.stop
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = SemStopTimer(:hp1.timerHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
SemStopTimer is used to stop a timer started with
:link reftype=hd refid=tistar.SemStartTimer:elink..
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.timerHandle:ehp1.
:pd.is the handle created by
:link reftype=hd refid=tistar.SemStartTimer:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
SemStopTimer returns the code supplied by the
DosStopTimer system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.326 -- ERROR_TS_HANDLE
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=tistar.SemStartTimer:elink..
.*
.* $Log: rexxsem.ipf,v $
.* Revision 1.5  1995/09/17 13:25:27  SFB
.* Adds expected result codes.
.*
.* Revision 1.4  1995/06/24 13:03:47  SFB
.* Minor corrections.
.*
.* Revision 1.3  1995/05/22 21:19:04  SFB
.* Minor adjustments.
.* 
.* Revision 1.2  1994/07/30  10:46:26  SFB
.* Adjustments for V1.1-0
.*
.* Revision 1.1  1994/05/12  20:59:50  SFB
.* Initial revision

