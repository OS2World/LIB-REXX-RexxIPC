.* $Id: rexxq.ipf,v 1.2 1996/01/14 12:10:47 SFB Rel $
.*
.* $Title: RexxIPC documentation: queues. $
.*
.* Copyright (c) Serge Brisson 1995.
.*
:h1.Queue Procedures and Functions
:i1 id=queue.queue
:p.
The Queue prefix identifies queue related functions.
:p.
Some functions are most often used by the server side of an application (like
:link reftype=hd refid=qcrea.QueueCreate:elink.,
:link reftype=hd refid=qpeek.QueuePeek:elink.
and :link reftype=hd refid=qread.QueueRead:elink.),
while others are used by the client side
(like :link reftype=hd refid=qopen.QueueOpen:elink.
and :link reftype=hd refid=qwrit.QueueWrite:elink.).
:p.
The "Control Program Guide and Reference" (Developer's Toolkit for OS/2)
or "Client/Server Programming with OS/2"
(Van Nostrand Reinhold) are valuable sources of information.
:nt.
The queue handle mentionned in the individual Queue functions description is
the value of a pointer to an internal structure of the RexxIPC library,
converted to an unsigned decimal number character string.  To simplify the
use of OS/2 queues by Rexx programs, this implementation handles the
memory issues related with the management of queue data;  for this, it
needs to associate some informations to the system provided queue handle.
:ent.
.*
.*******************************
:h2 id=qclos.QueueClose function
.*******************************
:i2 refid=queue.close
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = QueueClose(:hp1.queueHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
QueueClose closes a queue.  It is called both for a created queue
(server side), and for an opened queue (client side).
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.queueHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=qcrea.QueueCreate:elink.
or :link reftype=hd refid=qopen.QueueOpen:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
QueueClose returns the code supplied by the DosCloseQueue
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.337 -- ERROR_QUE_INVALID_HANDLE
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=qcrea.QueueCreate:elink.,
:link reftype=hd refid=qopen.QueueOpen:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To close a queue:
:xmp.
    call QueueClose queue
    if result \= 0 then signal QueueCloseError
:exmp.
.*
.********************************
:h2 id=qcrea.QueueCreate function
.********************************
:i2 refid=queue.create
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = QueueCreate(:hp1.handleVar:ehp1.,
:hp1.name:ehp1.,
[&rbl.:hp1.algorithm:ehp1.&rbl.],
[&rbl.:hp1.semHandle:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
QueueCreate is used to create a queue.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.handleVar:ehp1.
:pd.is the name of a variable which will receive the handle to the
queue.
.*
:pt.:hp1.name:ehp1.
:pd.specifies the name for the queue. It must have the form:
:p.
        \QUEUES\:hp1.queueName:ehp1.
:p.
where:
:parml tsize=30 break=none.
:pt.            :hp1.queueName:ehp1.
:pd.is the actual name of the queue.
:eparml.
.*
:pt.:hp1.algorithm:ehp1.
:pd.is the queue access algorithm.  If present, it must be one
of the following keywords:
:parml tsize=30 break=none.
:pt.            :hp2.FIFO:ehp2.
:pd.for a FIFO queue (First In, First Out), this is the default;
:pt.            :hp2.LIFO:ehp2.
:pd.for a LIFO queue (Last In, First Out);
:pt.            :hp2.Priority:ehp2.
:pd.for a Priority queue.
:eparml.
:p.
The keywords are case insensitive and may be abbreviated.
.*
:pt.:hp1.semHandle:ehp1.
:pd.is the handle to a shared event semaphore which will be used
in :link reftype=hd refid=qpeek.QueuePeek:elink.
and :link reftype=hd refid=qread.QueueRead:elink.
calls when the wait parameter is set to NoWait.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
QueueCreate returns the code supplied by the DosCreateQueue
system directive.
.br
:h3.:hp2.Notes:ehp2.
:p.
If the return code is non-zero, :hp1.handleVar:ehp1. is not
created or modified.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.332 -- ERROR_QUE_DUPLICATE
:li.334 -- ERROR_QUE_NO_MEMORY
:li.335 -- ERROR_QUE_INVALID_NAME
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=qopen.QueueOpen:elink.,
:link reftype=hd refid=qclos.QueueClose:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To create a queue:
:xmp.
    call QueueCreate 'queue', '\QUEUES\MY_QUEUE'
    if result \= 0 then signal QueueCreateError
:exmp.
.*
.************************************
:h2 id=qdrop.QueueDropFuncs procedure
.************************************
:i2 refid=queue.drop functions
:i2 refid=drop.queue
:p.
:h3.:hp2.Syntax:ehp2.
:p.
call QueueDropFuncs
.br
:h3.:hp2.Description:ehp2.
:p.
QueueDropFuncs deregisters all the Queue procedures and functions.
.br
:h3.:hp2.Arguments:ehp2.
:p.
No arguments are required by QueueDropFuncs.
.br
:h3.:hp2.Returns:ehp2.
:p.
Nothing is returned by QueueDropFuncs.
.br
:h3.:hp2.Notes:ehp2.
:p.
Queue procedures and functions may be deregistered
individually.  QueueDropFuncs is only a shortcut to have
them all deregistered with one call.
:p.
:link reftype=hd refid=pcdrop.IPCDropFuncs:elink.
will by itself call QueueDropFuncs and deregister it.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=pcdrop.IPCDropFuncs:elink.,
:link reftype=hd refid=qload.QueueLoadFuncs:elink..
.*
.************************************
:h2 id=qload.QueueLoadFuncs procedure
.************************************
:i2 refid=queue.load functions
:i2 refid=load.queue
:p.
:h3.:hp2.Syntax:ehp2.
:p.
call QueueLoadFuncs
.br
:h3.:hp2.Description:ehp2.
:p.
QueueLoadFuncs registers all the Queue procedures and functions.
.br
:h3.:hp2.Arguments:ehp2.
:p.
No arguments are required by QueueLoadFuncs.
.br
:h3.:hp2.Returns:ehp2.
:p.
Nothing is returned by QueueLoadFuncs.
.br
:h3.:hp2.Notes:ehp2.
:p.
Queue procedures and functions must be registered before they can
be used.  They may be registered individually.  QueueLoadFuncs is
only a shortcut to have them all registered with one call.
:p.
:link reftype=hd refid=pcload.IPCLoadFuncs:elink.
will by itself register and call QueueLoadFuncs.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=pcload.IPCLoadFuncs:elink.,
:link reftype=hd refid=qdrop.QueueDropFuncs:elink..
.*
.******************************
:h2 id=qopen.QueueOpen function
.******************************
:i2 refid=queue.open
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = QueueOpen(:hp1.handleVar:ehp1.,
:hp1.name:ehp1.,
[&rbl.:hp1.serverVar:ehp1.&rbl.],
[&rbl.:hp1.semHandle:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
QueueOpen is used to open a queue.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.handleVar:ehp1.
:pd.is the name of a variable which will receive the handle to the
queue.
.*
:pt.:hp1.name:ehp1.
:pd.specifies the name for the queue. It must have the form:
:p.
        \QUEUES\:hp1.queueName:ehp1.
:p.
where:
:parml tsize=30 break=none.
:pt.            :hp1.queueName:ehp1.
:pd.is the actual name of the queue.
:eparml.
.*
:pt.:hp1.serverVar:ehp1.
:pd.is the name of a variable which will receive the
process identification of the queue server.
.*
:pt.:hp1.semHandle:ehp1.
:pd.is the handle to a shared event semaphore which will be used
in :link reftype=hd refid=qpeek.QueuePeek:elink.
and :link reftype=hd refid=qread.QueueRead:elink.
calls when the wait parameter is set to NoWait.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
QueueOpen returns the code supplied by the DosOpenQueue
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.334 -- ERROR_QUE_NO_MEMORY
:li.341 -- ERROR_QUE_PROC_NO_ACCESS
:li.343 -- ERROR_QUE_NAME_NOT_EXIST
:esl.
:esl.
:h3.:hp2.Notes:ehp2.
:p.
If the return code is non-zero, :hp1.handleVar:ehp1. is not
created or modified.
.br
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=qcrea.QueueCreate:elink.,
:link reftype=hd refid=qclos.QueueClose:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To open a queue:
:xmp.
    call QueueOpen 'queue', '\QUEUES\MY_QUEUE'
    if result \= 0 then signal QueueOpenError
:exmp.
.*
.******************************
:h2 id=qpeek.QueuePeek function
.******************************
:i2 refid=queue.peek
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = QueuePeek(:hp1.queueHandle:ehp1.,
[&rbl.:hp1.dataVar:ehp1.&rbl.],
[&rbl.:hp1.requestVar:ehp1.&rbl.],
[&rbl.:hp1.priorityVar:ehp1.&rbl.],
[&rbl.:hp1.clientVar:ehp1.&rbl.],
[&rbl.:hp1.elementVar:ehp1.&rbl.],
[&rbl.:hp1.wait:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
QueuePeek performs a read operation on a queue.  The operation
returns immediatly with the currently available data as well as with
other requested informations.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.queueHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=qcrea.QueueCreate:elink.
or :link reftype=hd refid=qopen.QueueOpen:elink..
.*
:pt.:hp1.dataVar:ehp1.
:pd.is the name of the variable which will receive the data.
.*
:pt.:hp1.requestVar:ehp1.
:pd.is the name of the variable which will receive the request
information associated with the data.
.*
:pt.:hp1.priorityVar:ehp1.
:pd.is the name of the variable which will receive the priority
associated with the data.
.*
:pt.:hp1.clientVar:ehp1.
:pd.is the name of the variable which will receive the process
identification of the client from which the data originated.
.*
:pt.:hp1.elementVar:ehp1.
:pd.is the name of the variable which will receive the element
position in the queue.  If present, initialized and non-zero, it must
contain a value returned from a previous QueuePeek call on the
same queue; otherwise, the first element according to the queue
algorithm will be returned.
.*
:pt.:hp1.wait:ehp1.
:pd.is the wait option.  If present, it must be one
of the following keywords:
:parml tsize=30 break=none.
:pt.            :hp2.Wait:ehp2.
:pd.to wait until a queue element is available;
:pt.            :hp2.NoWait:ehp2.
:pd.to return an error code (342) if the queue is empty,
this is the default; this will also
trigger the use of the shared event semaphore if supplied
in :link reftype=hd refid=qcrea.QueueCreate:elink.
or :link reftype=hd refid=qopen.QueueOpen:elink..
:eparml.
:p.
The keywords are case insensitive and may be abbreviated.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
QueuePeek returns the code supplied by the DosPeekQueue
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.330 -- ERROR_QUE_PROC_NOT_OWNED
:li.333 -- ERROR_QUE_ELEMENT_NOT_EXIST
:li.337 -- ERROR_QUE_INVALID_HANDLE
:li.340 -- ERROR_QUE_PREV_AT_END
:li.342 -- ERROR_QUE_EMPTY
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=qread.QueueRead:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To peek for the first element from a queue:
:xmp.
    element = 0
    call QueuePeek queue, 'data', 'request', 'priority', 'client', 'element'
    if result \= 0 then signal QueuePeekError
    say 'Queue data&colon.' data
    say 'Queue request&colon.' request
    say 'Queue priority&colon.' priority
    say 'Queue client&colon.' client
    say 'Queue element&colon.' element
:exmp.
.*
.*******************************
:h2 id=qpurg.QueuePurge function
.*******************************
:i2 refid=queue.purge
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = QueuePurge(:hp1.queueHandle:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
QueuePurge purges a queue.  It may be called only from
the server side.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.queueHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=qcrea.QueueCreate:elink.
or :link reftype=hd refid=qopen.QueueOpen:elink..
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
QueuePurge returns the code supplied by the DosPurgeQueue
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.330 -- ERROR_QUE_PROC_NOT_OWNED
:li.337 -- ERROR_QUE_INVALID_HANDLE
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=qcrea.QueueCreate:elink.,
:link reftype=hd refid=qclos.QueueClose:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To purge a queue:
:xmp.
    call QueuePurge queue
    if result \= 0 then signal QueuePurgeError
:exmp.
.*
.*******************************
:h2 id=qquer.QueueQuery function
.*******************************
:i2 refid=queue.query
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = QueueQuery(:hp1.queueHandle:ehp1.,
:hp1.elementsVar:ehp1.)
.br
:h3.:hp2.Description:ehp2.
:p.
QueueQuery gets the number of entries in the queue.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.queueHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=qcrea.QueueCreate:elink.
or :link reftype=hd refid=qopen.QueueOpen:elink..
.*
:pt.:hp1.elementsVar:ehp1.
:pd.is the number of elements currently in the queue.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
QueueQuery returns the code supplied by the DosQueryQueue
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.337 -- ERROR_QUE_INVALID_HANDLE
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=qpeek.QueuePeek:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To get the number of elements in a queue:
:xmp.
    call QueueQuery queue, 'elements'
    if result \= 0 then signal QueueQueryError
    say 'Queue elements&colon.' elements
:exmp.
.*
.******************************
:h2 id=qread.QueueRead function
.******************************
:i2 refid=queue.read
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = QueueRead(:hp1.queueHandle:ehp1.,
:hp1.dataVar:ehp1.,
[&rbl.:hp1.requestVar:ehp1.&rbl.],
[&rbl.:hp1.priorityVar:ehp1.&rbl.],
[&rbl.:hp1.clientVar:ehp1.&rbl.],
[&rbl.:hp1.element:ehp1.&rbl.],
[&rbl.:hp1.wait:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
QueueRead performs a blocking read operation on a queue.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.queueHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=qcrea.QueueCreate:elink.
or :link reftype=hd refid=qopen.QueueOpen:elink..
.*
:pt.:hp1.dataVar:ehp1.
:pd.is the name of the variable which will receive the data.
.*
:pt.:hp1.requestVar:ehp1.
:pd.is the name of the variable which will receive the request
information associated with the data.
.*
:pt.:hp1.priorityVar:ehp1.
:pd.is the name of the variable which will receive the priority
associated with the data.
.*
:pt.:hp1.clientVar:ehp1.
:pd.is the name of the variable which will receive the process
identification of the client from which the data originated.
.*
:pt.:hp1.element:ehp1.
:pd.is the position of the requested element in the queue,
as obtained from
:link reftype=hd refid=qpeek.QueuePeek:elink..
.*
:pt.:hp1.wait:ehp1.
:pd.is the wait option.  If present, it must be one
of the following keywords:
:parml tsize=30 break=none.
:pt.            :hp2.Wait:ehp2.
:pd.to wait until a queue element is available, this is the default;
:pt.            :hp2.NoWait:ehp2.
:pd.to return an error code (342) if the queue is empty; this will also
trigger the use of the shared event semaphore if supplied
in :link reftype=hd refid=qcrea.QueueCreate:elink.
or :link reftype=hd refid=qopen.QueueOpen:elink..
:eparml.
:p.
The keywords are case insensitive and may be abbreviated.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
QueueRead returns the code supplied by the DosReadQueue
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.330 -- ERROR_QUE_PROC_NOT_OWNED
:li.333 -- ERROR_QUE_ELEMENT_NOT_EXIST
:li.337 -- ERROR_QUE_INVALID_HANDLE
:li.342 -- ERROR_QUE_EMPTY
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=qwrit.QueueWrite:elink.,
:link reftype=hd refid=qpeek.QueuePeek:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To read from a queue:
:xmp.
    call QueueRead queue, 'data'
    if result \= 0 then signal QueueReadError
    say 'Queue data&colon.' data
:exmp.
.*
.*******************************
:h2 id=qwrit.QueueWrite function
.*******************************
:i2 refid=queue.write
:p.
:h3.:hp2.Syntax:ehp2.
:p.
:hp1.rc:ehp1. = QueueWrite(:hp1.queueHandle:ehp1.,
:hp1.data:ehp1.,
[&rbl.:hp1.request:ehp1.&rbl.],
[&rbl.:hp1.priority:ehp1.&rbl.])
.br
:h3.:hp2.Description:ehp2.
:p.
QueueWrite performs a write operation on a queue.
.br
:h3.:hp2.Arguments:ehp2.
:parml tsize=15 break=none.
.*
:pt.:hp1.queueHandle:ehp1.
:pd.as obtained from
:link reftype=hd refid=qcrea.QueueCreate:elink.
or :link reftype=hd refid=qopen.QueueOpen:elink..
.*
:pt.:hp1.data:ehp1.
:pd.is the data to be put on the queue.
.*
:pt.:hp1.request:ehp1.
:pd.is the request information (numeric value representing
an unsigned long) to associate with the data.
.*
:pt.:hp1.priority:ehp1.
:pd.is the priority to associate with the data.
:eparml.
:lm margin=1.
:h3.:hp2.Returns:ehp2.
:p.
QueueWrite returns the code supplied by the DosWriteQueue
system directive.
:p.
Expected&colon.
:sl.
:sl compact.
:li.000 -- NO_ERROR
:li.334 -- ERROR_QUE_NO_MEMORY
:li.337 -- ERROR_QUE_INVALID_HANDLE
:esl.
:esl.
:h3.:hp2.See also:ehp2.
:p.
:link reftype=hd refid=qread.QueueRead:elink..
.br
:h3.:hp2.Examples:ehp2.
:p.
To write on a queue:
:xmp.
    call QueueWrite queue, 'Hello, Queue!'
    if result \= 0 then signal QueueWriteError
:exmp.
.*
.* $Log: rexxq.ipf,v $
.* Revision 1.2  1996/01/14 12:10:47  SFB
.* First release.
.*
.* Revision 1.1  1995/09/27 07:55:17  SFB
.* Initial revision
.*

