.* $Id: rexxpipe.ipf,v 1.5 1995/09/17 13:19:20 SFB Rel $
.*
.* $Title: RexxIPC documentation: named pipes. $
.*
.* Copyright (c) Serge Brisson 1994.
.*
:h1.Pipe Procedures and Functions
:i1 id=pipe.pipe
:i1.named pipe
:p.
The Pipe prefix identifies named pipe related functions.  Some of these
are not pipe specific in the operating system implementation (like DosRead
used by PipeRead, or DosClose used by PipeClose), but are needed for
pipe operations.
:p.
Some functions are most often used by the server side of an application (like
:link reftype=hd refid=npcrea.PipeCreate:elink.,
:link reftype=hd refid=npconn.PipeConnect:elink.
and :link reftype=hd refid=npdisc.PipeDisconnect:elink.),
while others are used by the client side
(like :link reftype=hd refid=npopen.PipeOpen:elink.,
:link reftype=hd refid=npwait.PipeWait:elink.,
:link reftype=hd refid=npcall.PipeCall:elink.
and :link reftype=hd refid=nptran.PipeTransact:elink.).
:p.
The "Control Program Guide and Reference" (Developer's Toolkit for OS/2)
or "Client/Server Programming with OS/2"
(Van Nostrand Reinhold) are valuable sources of information.
:nt.
The pipe handle mentionned in the individual Pipe functions description is the
actual value used by the operating system, converted to an unsigned decimal
number character string.  It is not associated with internal structures of
the RexxIPC library and may be created/used by other modules of the same process.
:ent.
.*
.******************************
:h2 id=npcall.PipeCall function
.******************************
:i2 refid=pipe.call
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = PipeCall(:hp1.name:ehp1.,
:hp1.output:ehp1.,
:hp1.inputVar:ehp1.,
[&rbl.:hp1.inputLimit:ehp1.&rbl.],
[&rbl.:hp1.timeout:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
PipeCall executes a call operation.  It combines the effect of
:link reftype=hd refid=npopen.PipeOpen:elink.,
:link reftype=hd refid=nptran.PipeTransact:elink.
and :link reftype=hd refid=npclos.PipeClose:elink..
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.name:ehp1.
:pd.specifies the name for the pipe. It must have the form:
:p.
        [\\:hp1.serverName:ehp1.&rbl.]\PIPE\:hp1.pipeName:ehp1.
:p.
where:
:parml tsize=30 break=none.
:pt.            :hp1.serverName:ehp1.
:pd.is the name of the server on which the pipe has
been created;
:pt.            :hp1.pipeName:ehp1.
:pd.is the actual name of the pipe.
:eparml.
.*
:pt.:hp1.output:ehp1.
:pd.is the string expression to be sent on the pipe.
.*
:pt.:hp1.inputVar:ehp1.
:pd.is the name of the variable which will receive the response.
.*
:pt.:hp1.inputLimit:ehp1.
:pd.is the size limit (in bytes) for the response.  If zero or omitted,
a default of 4096 is used.
.*
:pt.:hp1.timeout:ehp1.
:pd.is the wait timeout in milliseconds.  The default is 50.  This
timeout refers to the time the directive will wait for a pipe instance
to become available.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
PipeCall returns the code supplied by the DosCallNPipe
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.002 -- ERROR_FILE_NOT_FOUND
:li.011 -- ERROR_BAD_FORMAT
:li.095 -- ERROR_INTERRUPT
:li.231 -- ERROR_PIPE_BUSY
:esl.
:esl.
:h3.:hp2.Notes:ehp2.
:p.
The named pipe must have been created in duplex mode with message format.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=npopen.PipeOpen:elink.,
:link reftype=hd refid=npwait.PipeWait:elink.,
:link reftype=hd refid=nptran.PipeTransact:elink.,
:link reftype=hd refid=npclos.PipeClose:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To make a call on a named pipe&colon.
:xmp.
    call PipeCall '\PIPE\MY_PIPE', 'Hello?', 'answer'
    if result \= 0 then signal PipeCallError
    say 'Pipe answer&colon. "'answer'".'
:exmp.
.*
.*******************************
:h2 id=npclos.PipeClose function
.*******************************
:i2 refid=pipe.close
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = PipeClose(:hp1.pipeHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
PipeClose closes a pipe.  It is called both for a created pipe
(server side), and for an opened pipe (client side).
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.pipeHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=npcrea.PipeCreate:elink.
or :link reftype=hd refid=npopen.PipeOpen:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
PipeClose returns the code supplied by the DosClose
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
:link reftype=hd refid=npcrea.PipeCreate:elink.,
:link reftype=hd refid=npopen.PipeOpen:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To close a named pipe:
:xmp.
    call PipeClose pipe
    if result \= 0 then signal PipeCloseError
:exmp.
.*
.*********************************
:h2 id=npconn.PipeConnect function
.*********************************
:i2 refid=pipe.connect
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = PipeConnect(:hp1.pipeHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
PipeConnect listens for a connection on a named pipe.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.pipeHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=npcrea.PipeCreate:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
PipeConnect returns the code supplied by the DosConnectNPipe
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.095 -- ERROR_INTERRUPT
:li.109 -- ERROR_BROKEN_PIPE
:li.230 -- ERROR_BAD_PIPE
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=npcrea.PipeCreate:elink.,
:link reftype=hd refid=npcoas.PipeConnectAsync:elink.,
:link reftype=hd refid=npopen.PipeOpen:elink.,
:link reftype=hd refid=npdisc.PipeDisconnect:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To create a named pipe and listen for a connection&colon.
:xmp.
    call PipeCreate 'pipe', '\PIPE\MY_PIPE'
    if result \= 0 then signal PipeCreateError

    call PipeConnect pipe
    if result \= 0 then signal PipeConnectError
:exmp.
:p.
To answer requests from PipeCall or PipeTransact calls&colon.
:xmp.
    call PipeCreate 'pipe', '\PIPE\MY_PIPE'
    if result \= 0 then signal PipeCreateError

    do forever
        call PipeConnect pipe
        if result \= 0 then signal PipeConnectError

        do forever
            call PipeRead pipe, 'request'
            if result \= 0 then signal PipeReadError
            if request = '' then leave
            .
            .
            .
            call PipeWrite pipe, 'answer'
            if result \= 0 then signal PipeWriteError
        end

        call PipeDisconnect pipe
        if result \= 0 then signal PipeDisconnectError
    end
:exmp.
.*
.**************************************
:h2 id=npcoas.PipeConnectAsync function
.**************************************
:i2 refid=pipe.connect asynchronously
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = PipeConnectAsync(:hp1.pipeHandle:ehp1.,
:hp1.ctxHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
PipeConnectAsync listens for a connection on a named pipe.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.pipeHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=npcrea.PipeCreate:elink..
.*
:pt.:hp1.ctxHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=iccrea.IPCContextCreate:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
PipeConnectAsync returns the code supplied by the DosCreateThread
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
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=iccrea.IPCContextCreate:elink.,
:link reftype=hd refid=npconn.PipeConnect:elink.,
:link reftype=hd refid=evwait.SemEventWait:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To create a pipe and start a process which will
immediately open the pipe&colon.
:xmp.
    call PipeCreate 'pipe', '\PIPE\REDIRECTED_INPUT'
    if result \= 0 then signal PipeCreateError

    call IPCContextCreate 'context'
    if result \= 0 then signal ContextCreateError

    call PipeConnectAsync pipe, context
    if result \= 0 then signal PipeConnectAsyncError

    'DETACH RED_PROC <\PIPE\REDIRECTED_INPUT >NUL'

    call IPCContextWait context
    if result \= 0 then signal PipeConnectError
:exmp.
.*
.********************************
:h2 id=npcrea.PipeCreate function
.********************************
:i2 refid=pipe.create
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = PipeCreate(:hp1.handleVar:ehp1.,
:hp1.name:ehp1.,
[&rbl.:hp1.mode:ehp1.&rbl.],
[&rbl.:hp1.format:ehp1.&rbl.],
[&rbl.:hp1.instances:ehp1.&rbl.],
[&rbl.:hp1.outBufSize:ehp1.&rbl.],
[&rbl.:hp1.inpBufSize:ehp1.&rbl.],
[&rbl.:hp1.timeout:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
PipeCreate is used to create a named pipe.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.handleVar:ehp1.
:pd.is the name of a variable which will receive the handle to the
named pipe.
.*
:pt.:hp1.name:ehp1.
:pd.specifies the name for the pipe. It must have the form:
:p.
        \PIPE\:hp1.pipeName:ehp1.
:p.
where:
:parml tsize=30 break=none.
:pt.            :hp1.pipeName:ehp1.
:pd.is the actual name of the pipe.
:eparml.
.*
:pt.:hp1.mode:ehp1.
:pd.is the pipe access mode.  If present, it must be one
of the following keywords:
:parml tsize=30 break=none.
:pt.            :hp2.Inbound:ehp2.
:pd.for an inbound pipe (receive only);
:pt.            :hp2.Outbound:ehp2.
:pd.for an outbound pipe (transmit only);
:pt.            :hp2.Duplex:ehp2.
:pd.for a duplex pipe (transmit and receive), this is the default.
:eparml.
:p.
The keywords are case insensitive and may be abbreviated.
.*
:pt.:hp1.format:ehp1.
:pd.is the pipe format.  If present, it must be one of the
following keywords:
:parml tsize=30 break=none.
:pt.            :hp2.Byte:ehp2.
:pd.for a byte pipe (no implicit length);
:pt.            :hp2.Message:ehp2.
:pd.for a message pipe (implicit length), this is the default.
:eparml.
:p.
The keywords are case insensitive and may be abbreviated.
.*
:pt.:hp1.instances:ehp1.
:pd.is the maximum number of instances for this pipe.  It must be a
value between 1 and 255, or -1 (meaning no limit).  The default is 1.
.*
:pt.:hp1.outBufSize:ehp1.
:pd.is the output buffer size.  The default is 1024.
.*
:pt.:hp1.inpBufSize:ehp1.
:pd.is the input buffer size.  The default is 1024.
.*
:pt.:hp1.timeout:ehp1.
:pd.is the default wait timeout in milliseconds.  The default is 50.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
PipeCreate returns the code supplied by the DosCreateNPipe
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.003 -- ERROR_PATH_NOT_FOUND
:li.008 -- ERROR_NOT_ENOUGH_MEMORY
:li.084 -- ERROR_OUT_OF_STRUCTURES
:li.231 -- ERROR_PIPE_BUSY
:esl.
:esl.
:h3.:hp2.Notes:ehp2.
:p.
If the return code is non-zero, :hp1.handleVar:ehp1. is not
created or modified.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=npopen.PipeOpen:elink.,
:link reftype=hd refid=npclos.PipeClose:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To create a named pipe:
:xmp.
    call PipeCreate 'pipe', '\PIPE\MY_PIPE'
    if result \= 0 then signal PipeCreateError
:exmp.
.*
.************************************
:h2 id=npdisc.PipeDisconnect function
.************************************
:i2 refid=pipe.disconnect
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = PipeDisconnect(:hp1.pipeHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
PipeDisconnect drops a connection on a named pipe.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.pipeHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=npcrea.PipeCreate:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
PipeDisconnect returns the code supplied by the DosDisConnectNPipe
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.230 -- ERROR_BAD_PIPE
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=npcrea.PipeCreate:elink.,
:link reftype=hd refid=npconn.PipeConnect:elink..
.br
.*
.************************************
:h2 id=npdrop.PipeDropFuncs procedure
.************************************
:i2 refid=pipe.drop functions
:i2 refid=drop.pipe
:p.
:h3.:hp2.Syntax:ehp2.
:p.
call PipeDropFuncs
.br
:h3.:hp2.Description:ehp2.
:p.
PipeDropFuncs deregisters all the Pipe procedures and functions.
.br
:h3.:hp2.Arguments:ehp2.
:p.
No arguments are required by PipeDropFuncs.
.br
:h3.:hp2.Returns:ehp2.
:p.
Nothing is returned by PipeDropFuncs.
.br
:h3.:hp2.Notes:ehp2.
:p.
Pipe procedures and functions may be deregistered
individually.  PipeDropFuncs is only a shortcut to have
them all deregistered with one call.
:p.
:link reftype=hd refid=pcdrop.IPCDropFuncs:elink.
will by itself call PipeDropFuncs and deregister it.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=pcdrop.IPCDropFuncs:elink.,
:link reftype=hd refid=npload.PipeLoadFuncs:elink..
.*
.*******************************
:h2 id=npflus.PipeFlush function
.*******************************
:i2 refid=pipe.flush
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = PipeFlush(:hp1.pipeHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
PipeFlush flushes the write buffer of a named pipe.  It may be called
both for a created pipe (server side), and for an opened pipe (client side).
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.pipeHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=npcrea.PipeCreate:elink.
or :link reftype=hd refid=npopen.PipeOpen:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
PipeFlush returns the code supplied by the DosResetBuffer
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.005 -- ERROR_ACCESS_DENIED
:li.006 -- ERROR_INVALID_HANDLE
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=npclos.PipeClose:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To flush a named pipe:
:xmp.
    call PipeFlush pipe
    if result \= 0 then signal PipeFlushError
:exmp.
.*
.************************************
:h2 id=npload.PipeLoadFuncs procedure
.************************************
:i2 refid=pipe.load functions
:i2 refid=load.pipe
:p.
:h3.:hp2.Syntax:ehp2.
:p.
call PipeLoadFuncs
.br
:h3.:hp2.Description:ehp2.
:p.
PipeLoadFuncs registers all the Pipe procedures and functions.
.br
:h3.:hp2.Arguments:ehp2.
:p.
No arguments are required by PipeLoadFuncs.
.br
:h3.:hp2.Returns:ehp2.
:p.
Nothing is returned by PipeLoadFuncs.
.br
:h3.:hp2.Notes:ehp2.
:p.
Pipe procedures and functions must be registered before they can
be used.  They may be registered individually.  PipeLoadFuncs is
only a shortcut to have them all registered with one call.
:p.
:link reftype=hd refid=pcload.IPCLoadFuncs:elink.
will by itself register and call PipeLoadFuncs.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=pcload.IPCLoadFuncs:elink.,
:link reftype=hd refid=npdrop.PipeDropFuncs:elink..
.*
.******************************
:h2 id=npopen.PipeOpen function
.******************************
:i2 refid=pipe.open
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = PipeOpen(:hp1.handleVar:ehp1.,
:hp1.name:ehp1.,
[&rbl.:hp1.mode:ehp1.&rbl.],
[&rbl.:hp1.format:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
PipeOpen is used to open a named pipe.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.handleVar:ehp1.
:pd.is the name of a variable which will receive the handle to the
named pipe.
.*
:pt.:hp1.name:ehp1.
:pd.specifies the name for the pipe. It must have the form:
:p.
        [\\:hp1.serverName:ehp1.&rbl.]\PIPE\:hp1.pipeName:ehp1.
:p.
where:
:parml tsize=30 break=none.
:pt.            :hp1.serverName:ehp1.
:pd.is the name of the server on which the pipe has
been created;
:pt.            :hp1.pipeName:ehp1.
:pd.is the actual name of the pipe.
:eparml.
.*
:pt.:hp1.mode:ehp1.
:pd.is the pipe access mode.  If present, it must be one
of the following keywords:
:parml tsize=30 break=none.
:pt.            :hp2.Inbound:ehp2.
:pd.for an inbound pipe (receive only);
:pt.            :hp2.Outbound:ehp2.
:pd.for an outbound pipe (transmit only);
:pt.            :hp2.Duplex:ehp2.
:pd.for a duplex pipe (transmit and receive), this is the default.
:eparml.
:p.
The keywords are case insensitive and may be abbreviated.
.*
:pt.:hp1.format:ehp1.
:pd.is the pipe format.  If present, it must be one of the
following keywords:
:parml tsize=30 break=none.
:pt.            :hp2.Byte:ehp2.
:pd.for a byte pipe (no implicit length);
:pt.            :hp2.Message:ehp2.
:pd.for a message pipe (implicit length), this is the default.
:eparml.
:p.
The keywords are case insensitive and may be abbreviated.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
PipeOpen returns the code supplied by the DosOpen
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.002 -- ERROR_FILE_NOT_FOUND
:li.003 -- ERROR_PATH_NOT_FOUND
:li.005 -- ERROR_ACCESS_DENIED
:li.087 -- ERROR_INVALID_PARAMETER
:li.231 -- ERROR_PIPE_BUSY
:esl.
:esl.
:h3.:hp2.Notes:ehp2.
:p.
If the return code is non-zero, :hp1.handleVar:ehp1. is not
created or modified.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=npcrea.PipeCreate:elink.,
:link reftype=hd refid=npclos.PipeClose:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To open a named pipe:
:xmp.
    call PipeOpen 'pipe', '\PIPE\MY_PIPE'
    if result \= 0 then signal PipeOpenError
:exmp.
.*
.******************************
:h2 id=nppeek.PipePeek function
.******************************
:i2 refid=pipe.peek
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = PipePeek(:hp1.pipeHandle:ehp1.,
[&rbl.:hp1.inputVar:ehp1.&rbl.],
[&rbl.:hp1.inputLimit:ehp1.&rbl.],
[&rbl.:hp1.pipeBytesVar:ehp1.&rbl.],
[&rbl.:hp1.msgBytesVar:ehp1.&rbl.],
[&rbl.:hp1.stateVar:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
PipePeek performs a read operation on a named pipe.  The operation
returns immediatly with the currently available data as well as with
other requested informations.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.pipeHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=npcrea.PipeCreate:elink.
or :link reftype=hd refid=npopen.PipeOpen:elink..
.*
:pt.:hp1.inputVar:ehp1.
:pd.is the name of the variable which will receive the data.
.*
:pt.:hp1.inputLimit:ehp1.
:pd.is the allowed size limit for the response.  If zero or omitted,
a default limit of 4096 is used.
.*
:pt.:hp1.pipeBytesVar:ehp1.
:pd.is the name of the variable which will receive the number
of bytes held in the pipe buffer.
.*
:pt.:hp1.msgBytesVar:ehp1.
:pd.is the name of the variable which will receive the number
of bytes held in the pipe buffer for the current message.
.*
:pt.:hp1.stateVar:ehp1.
:pd.is the name of the variable which will receive a code
identifying the state of the pipe:
:parml tsize=15 break=none compact.
:pt.            1&colon.
:pd.the pipe is disconnected;
:pt.            2&colon.
:pd.the pipe is listening for a connection;
:pt.            3&colon.
:pd.the pipe is connected;
:pt.            4&colon.
:pd.the pipe is closing.
:eparml.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
PipePeek returns the code supplied by the DosPeekNPipe
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.230 -- ERROR_BAD_PIPE
:li.231 -- ERROR_PIPE_BUSY
:li.233 -- ERROR_PIPE_NOT_CONNECTED
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=npread.PipeRead:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To peek for a maximum of 80 bytes from a named pipe:
:xmp.
    call PipePeek pipe, 'data', 80, 'pipeBytes', 'msgBytes', 'state'
    if result \= 0 then signal PipePeekError
    say 'Pipe data&colon.' data
    say 'Pipe bytes held&colon.' pipeBytes
    say 'Pipe bytes in message&colon.' msgBytes
    say 'Pipe state&colon.' state
:exmp.
.*
.******************************
:h2 id=npread.PipeRead function
.******************************
:i2 refid=pipe.read
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = PipeRead(:hp1.pipeHandle:ehp1.,
:hp1.inputVar:ehp1.,
[&rbl.:hp1.inputLimit:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
PipeRead performs a blocking read operation on a named pipe.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.pipeHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=npcrea.PipeCreate:elink.
or :link reftype=hd refid=npopen.PipeOpen:elink..
.*
:pt.:hp1.inputVar:ehp1.
:pd.is the name of the variable which will receive the data.
.*
:pt.:hp1.inputLimit:ehp1.
:pd.is the allowed size limit for the response.  If zero or omitted,
a default limit of 4096 is used.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
PipeRead returns the code supplied by the DosRead
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.005 -- ERROR_ACCESS_DENIED
:li.006 -- ERROR_INVALID_HANDLE
:li.109 -- ERROR_BROKEN_PIPE
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=npreas.PipeReadAsync:elink.,
:link reftype=hd refid=npwrit.PipeWrite:elink.,
:link reftype=hd refid=nppeek.PipePeek:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To read from a named pipe:
:xmp.
    call PipeRead pipe, 'data'
    if result \= 0 then signal PipeReadError
    say 'Pipe data&colon.' data
:exmp.
.*
.***********************************
:h2 id=npreas.PipeReadAsync function
.***********************************
:i2 refid=pipe.read asynchronously
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = PipeReadAsync(:hp1.pipeHandle:ehp1.,
:hp1.ctxHandle:ehp1.,
[&rbl.:hp1.inputLimit:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
PipeReadAsync starts a read operation on a named pipe.  It does
not wait for completion.  When the read has completed (see
:link reftype=hd refid=iccrea.IPCContextCreate:elink.), the data
can be obtained with
:link reftype=hd refid=icresu.IPCContextResult:elink..
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.pipeHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=npcrea.PipeCreate:elink.
or :link reftype=hd refid=npopen.PipeOpen:elink..
.*
:pt.:hp1.ctxHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=iccrea.IPCContextCreate:elink..
.*
:pt.:hp1.inputLimit:ehp1.
:pd.is the allowed size limit for the response.  If zero or omitted,
a default limit of 4096 is used.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
PipeReadAsync returns the code supplied by the DosCreateThread
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
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=iccrea.IPCContextCreate:elink.,
:link reftype=hd refid=icresu.IPCContextResult:elink.,
:link reftype=hd refid=npread.PipeRead:elink.,
:link reftype=hd refid=npwras.PipeWriteAsync:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To start a read operation from a named pipe and, later, get the data:
:xmp.
    call IPCContextCreate 'context'
    if result \= 0 then signal ContextCreateError

    call PipeReadAsync pipe, context
    if result \= 0 then signal PipeReadAsyncError
    .
    .
    .
    call IPCContextWait context
    if result \= 0 then signal ContextWaitError

    data = IPCContextResult(context)
:exmp.
.*
.********************************
:h2 id=npsets.PipeSetSem function
.********************************
:i2 refid=pipe.set semaphore
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = PipeSetSem(:hp1.pipeHandle:ehp1.,
:hp1.semHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
PipeSetSem associates a shared event semaphore with
the pipe.  Read and write operations on the other end
of the pipe will post events on that semaphore.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.pipeHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=npcrea.PipeCreate:elink.
or :link reftype=hd refid=npopen.PipeOpen:elink..
.*
:pt.:hp1.semHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=evcrea.SemEventCreate:elink.
or :link reftype=hd refid=evopen.SemEventOpen:elink.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
PipeSetSem returns the code supplied by the DosSetNPipeSem
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.001 -- ERROR_INVALID_FUNCTION
:li.006 -- ERROR_INVALID_HANDLE
:li.187 -- ERROR_SEM_NOT_FOUND
:li.230 -- ERROR_BAD_PIPE
:li.233 -- ERROR_PIPE_NOT_CONNECTED
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=evcrea.SemEventCreate:elink.,
:link reftype=hd refid=evwait.SemEventWait:elink.,
:link reftype=hd refid=npread.PipeRead:elink.,
:link reftype=hd refid=npwrit.PipeWrite:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To associate a shared event semaphore to a pipe&colon.
:xmp.
    call SemEventCreate 'event', 'Shared'
    if result \= 0 then signal SemCreateError

    call PipeSetSem pipe, event
    if result \= 0 then signal PipeSetSemError
    .
    .
    .
    call SemEventWait event
    if result \= 0 then signal SemWaitError
:exmp.
.*
.**********************************
:h2 id=nptran.PipeTransact function
.**********************************
:i2 refid=pipe.transaction
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = PipeTransact(:hp1.pipeHandle:ehp1.,
:hp1.output:ehp1.,
:hp1.inputVar:ehp1.,
[&rbl.:hp1.inputLimit:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
PipeTransact combines the effect of
:link reftype=hd refid=npwrit.PipeWrite:elink.
and :link reftype=hd refid=npread.PipeRead:elink..
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.pipeHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=npcrea.PipeCreate:elink.
or :link reftype=hd refid=npopen.PipeOpen:elink..
.*
:pt.:hp1.output:ehp1.
:pd.is the string expression to be sent on the pipe.
.*
:pt.:hp1.inputVar:ehp1.
:pd.is the name of the variable which will receive the response.
.*
:pt.:hp1.inputLimit:ehp1.
:pd.is the allowed size limit for the response.  If zero or omitted,
a default limit of 4096 is used.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
PipeTransact returns the code supplied by the DosTransactNPipe
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.011 -- ERROR_BAD_FORMAT
:li.230 -- ERROR_BAD_PIPE
:li.233 -- ERROR_PIPE_NOT_CONNECTED
:esl.
:esl.
:h3.:hp2.Notes:ehp2.
:p.
The pipe must have been created in duplex mode with message format.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=npcall.PipeCall:elink.,
:link reftype=hd refid=npread.PipeRead:elink.,
:link reftype=hd refid=npwrit.PipeWrite:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To make a named pipe transaction:
:xmp.
    call PipeTransact pipe, 'Hello?', 'answer'
    if result \= 0 then signal PipeTransactError
    say 'Pipe answer&colon.' answer
:exmp.
.*
.******************************
:h2 id=npwait.PipeWait function
.******************************
:i2 refid=pipe.wait
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = PipeWait(:hp1.name:ehp1.,
[&rbl.:hp1.timeout:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
PipeWait performs a wait on a busy named pipe.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.name:ehp1.
:pd.specifies the name for the pipe. It must have the form:
:p.
        [\\:hp1.serverName:ehp1.&rbl.]\PIPE\:hp1.pipeName:ehp1.
:p.
where:
:parml tsize=30 break=none.
:pt.            :hp1.serverName:ehp1.
:pd.is the name of the server on which the pipe has
been created;
:pt.            :hp1.pipeName:ehp1.
:pd.is the actual name of the pipe.
:eparml.
.*
:pt.:hp1.timeout:ehp1.
:pd.is the wait timeout in milliseconds.  A value of -1 means an
infinite wait; 0 or no value uses the value specified in the
PipeCreate call.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
PipeWait returns the code supplied by the DosWaitNPipe
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.002 -- ERROR_FILE_NOT_FOUND
:li.095 -- ERROR_INTERRUPT
:li.231 -- ERROR_PIPE_BUSY
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=npopen.PipeOpen:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To open a very busy named pipe:
:xmp.
    do forever
        call PipeOpen 'pipe', '\PIPE\MY_PIPE'
        if result = 0 then leave
        if result \= 231 then signal PipeOpenError
        call PipeWait '\PIPE\MY_PIPE', -1
        if result \= 0 then signal PipeWaitError
    end
:exmp.
.*
.*******************************
:h2 id=npwrit.PipeWrite function
.*******************************
:i2 refid=pipe.write
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = PipeWrite(:hp1.pipeHandle:ehp1.,
:hp1.output:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
PipeWrite performs a blocking write operation on a named pipe.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.pipeHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=npcrea.PipeCreate:elink.
or :link reftype=hd refid=npopen.PipeOpen:elink..
.*
:pt.:hp1.output:ehp1.
:pd.is the string expression to be sent on the pipe.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
PipeWrite returns the code supplied by the DosWrite
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.005 -- ERROR_ACCESS_DENIED
:li.006 -- ERROR_INVALID_HANDLE
:li.109 -- ERROR_BROKEN_PIPE
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=npread.PipeRead:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To write on a named pipe:
:xmp.
    call PipeWrite pipe, 'Hello, Pipe!'
    if result \= 0 then signal PipeWriteError
:exmp.
.*
.************************************
:h2 id=npwras.PipeWriteAsync function
.************************************
:i2 refid=pipe.write asynchronously
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = PipeWriteAsync(:hp1.pipeHandle:ehp1.,
:hp1.ctxHandle:ehp1.,
:hp1.output:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
PipeWriteAsync starts a write operation on a named pipe.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.pipeHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=npcrea.PipeCreate:elink.
or :link reftype=hd refid=npopen.PipeOpen:elink..
.*
:pt.:hp1.ctxHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=iccrea.IPCContextCreate:elink..
.*
:pt.:hp1.output:ehp1.
:pd.is the string expression to be sent on the pipe.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
PipeWriteAsync returns the code supplied by the DosCreateThread
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
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=iccrea.IPCContextCreate:elink.,
:link reftype=hd refid=npreas.PipeReadAsync:elink.,
:link reftype=hd refid=npwrit.PipeWrite:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To start a write operation on a named pipe:
:xmp.
    call IPCContextCreate 'context'
    if result \= 0 then signal ContextCreateError

    call PipeWriteAsync pipe, context, 'Hello, Pipe!'
    if result \= 0 then signal PipeWriteAsyncError
:exmp.
.*
.* $Log: rexxpipe.ipf,v $
.* Revision 1.5  1995/09/17 13:19:20  SFB
.* Adds PipeReadAsync and PipeWriteAsync.
.* Adds expected result codes.
.*
.* Revision 1.4  1995/06/24 13:02:57  SFB
.* Corrections + addition of PipeSetSem.
.*
.* Revision 1.3  1995/05/22 21:14:37  SFB
.* Added PipeSetSem.
.* 
.* Revision 1.2  1994/07/30  10:46:26  SFB
.* Adjustments for V1.1-0
.*
.* Revision 1.1  1994/05/12  20:59:50  SFB
.* Initial revision

