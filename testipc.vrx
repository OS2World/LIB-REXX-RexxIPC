/*:VRX         TestIPC
*/

/* $Id: testipc.vrx,v 1.3 1996/01/14 11:57:49 SFB Rel $ */

/* $Title: Test file for RexxIPC. $ */

/* $Copyright: Serge Brisson. */

/* This file is supplied with RexxIPC starting with version 1.21-000.
** It is meant as a basic test of the library.
**
** It accepts a parameter which must be an abbreviation of:
**
**      Minimal     -- for a test of minimal operations
**      Semaphore   -- for a test of semaphore operations
**      Pipe        -- for a test of pipe operations
**      Queue       -- for a test of queue operations
**      Benchmark   -- to perform a simple communication benchmark
**
** Without a parameter, it will perform all the tests but not
** the benchmark.
**
** This file needs an other file (TestIPC.CFG) on the same
** directory as itself. */

    /* Initialize global variables. */
    !. = ''

    /* Specify signal processing. */
    signal on halt
    signal on failure
    signal on error
    signal on syntax
    signal on novalue
    signal on notready

    /* Identify commands source. */
    parse source . . !._source
    parse value Reverse(!._source) with . '.' !._source._pathName
    !._source._pathName = Reverse(!._source._pathName)
    !._source._name = FileSpec('Name', !._source._pathName)

    /* Get configuration. */
    call LoadConfig !._source._pathName'.CFG', '_CFG'

    /* Start the whole procedure or complete a callback. */
    if Translate(Word(Arg(1), 1)) \= 'CALL' then do
        call Main Arg(1)
    end
    else do
        parse value IPCVersion() with . 'V' !._major '.' !._minor '-' !._revision
        interpret Arg(1)
    end

    call Cleanup

    return


/*
** $Log: testipc.vrx,v $
** Revision 1.3  1996/01/14 11:57:49  SFB
** Queue support is completed.
**
** Revision 1.2  1995/09/18 20:05:10  SFB
** Adjustement for release with V1.21.
**
** Revision 1.1  1995/09/17 17:57:49  SFB
** Initial revision
*/



/*:VRX         BenchmarkDestination
*/

/* BenchmarkDestination -- Destination side of the benchmark. */

BenchmarkDestination:
    procedure expose !. record.

    eventOrig = Arg(1)
    eventDest = Arg(2)
    parse upper value Arg(3) with . test .
    if test = '*' then test = ''

    /* Resources used. */
    !._pipe.0 = 1
    !._queue.0 = 1

    /* Check for internal functions handicap. */
    handicap = !._CFG._Benchmark._Handicap
    if handicap = '' then handicap = 0
    else if handicap \= 0 & handicap \= 1 then signal Config

    /* Get the data from file transfer. */
    file = !._CFG._Benchmark._FileName
    if file \= '' & Abbrev('FILE', test, 0) then do
        /* Wait for the file to be written. */
        call SemEventWait eventOrig
        if result \= 0 then signal CallFailed
        call SemEventReset eventOrig
        if result \= 0 then signal CallFailed

        /* Read and compare. */
        if Stream(file, 'C', 'Open Read') \= 'READY:' then signal CheckFailed
        do i = 1 to record.0
            if LineIn(file) \= record.i then signal CheckFailed
            if handicap then call IPCVersion
        end
        call Stream file, 'C', 'Close'

        /* Indicate reception completed. */
        call SemEventPost eventDest
        if result \= 0 then signal CallFailed
    end

    /* Get the data from Rexx queue transfer. */
    rexxQueue = !._CFG._Benchmark._RexxQueue
    if rexxQueue \= '' & Abbrev('REXX', test, 0) then do
        /* Wait for the queue to be created. */
        call SemEventWait eventOrig
        if result \= 0 then signal CallFailed
        call SemEventReset eventOrig
        if result \= 0 then signal CallFailed

        /* Dequeue and compare. */
        previousQueue = RxQueue('Set', rexxQueue)
        do i = 1 to record.0
            if LineIn('QUEUE:') \= record.i then signal CheckFailed
            if handicap then call IPCVersion
        end
        call RxQueue 'Set', previousQueue

        /* Indicate reception completed. */
        call SemEventPost eventDest
        if result \= 0 then signal CallFailed
    end

    /* Get the data from named pipe transfer. */
    pipeName = !._CFG._Benchmark._PipeName
    if pipeName \= '' & Abbrev('PIPE', test, 0) then do
        /* Wait for the pipe to be created. */
        call SemEventWait eventOrig
        if result \= 0 then signal CallFailed
        call SemEventReset eventOrig
        if result \= 0 then signal CallFailed

        /* Wait until the server is ready. */
        call PipeWait pipeName, -1
        if result \= 0 then signal CallFailed

        /* Establish the connection. */
        call PipeOpen '!._pipe.1', pipeName
        if result \= 0 then signal CallFailed

        /* Receive and compare. */
        do i = 1 to record.0
            call PipeRead !._pipe.1, 'record'
            if result \= 0 then signal CallFailed
            if record \= record.i then signal CheckFailed
        end

        /* Close the connection. */
        call PipeClose !._pipe.1
        if result \= 0 then signal CallFailed
        !._pipe.1 = ''

        /* Indicate reception completed. */
        call SemEventPost eventDest
        if result \= 0 then signal CallFailed
    end

    /* Get the data from OS/2 queue transfer. */
    queueName = !._CFG._Benchmark._QueueName
    if !._major = 1 then
        if !._minor <= 20 then queueName = ''
        else if !._minor = 21 then
            if !._revision < 100 then queueName = ''
    if queueName \= '' & Abbrev('QUEUE', test, 0) then do
        /* Wait for the origin to be ready. */
        call SemEventWait eventOrig
        if result \= 0 then signal CallFailed
        call SemEventReset eventOrig
        if result \= 0 then signal CallFailed

        /* Create the queue. */
        call QueueCreate '!._queue.1', queueName
        if result \= 0 then signal CallFailed

        /* Indicate queue created. */
        call SemEventPost eventDest
        if result \= 0 then signal CallFailed

        /* Wait for the origin to start. */
        call SemEventWait eventOrig
        if result \= 0 then signal CallFailed
        call SemEventReset eventOrig
        if result \= 0 then signal CallFailed

        /* Dequeue and compare. */
        do i = 1 to record.0
            call QueueRead !._queue.1, 'record'
            if result \= 0 then signal CallFailed
            if record \= record.i then signal CheckFailed
        end

        /* Close the queue. */
        call QueueClose !._queue.1
        if result \= 0 then signal CallFailed
        !._queue.1 = ''

        /* Indicate reception completed. */
        call SemEventPost eventDest
        if result \= 0 then signal CallFailed

    end

    /* Resources released. */
    !._pipe.0 = ''
    !._queue.0 = ''

    return



/*:VRX         BenchmarkOrigin
*/

/* BenchmarkOrigin -- Origin side of the benchmark. */

BenchmarkOrigin:
    procedure expose !. record.

    eventOrig = Arg(1)
    eventDest = Arg(2)
    parse upper value Arg(3) with . test .
    if test = '*' then test = ''

    /* Resources used. */
    !._rexxQueue.0 = 1
    !._pipe.0 = 1
    !._queue.0 = 1

    /* Check for internal functions handicap. */
    handicap = !._CFG._Benchmark._Handicap
    if handicap = '' then handicap = 0
    else if handicap \= 0 & handicap \= 1 then signal Config
    if handicap then handicapNotice = ' (handicapped)'
    else handicapNotice = ''

    /* File transfer. */
    file = !._CFG._Benchmark._FileName
    if file \= '' & Abbrev('FILE', test, 0) then do
        say 'Doing a file transfer...'
        call Time 'Reset'

        /* Write the file. */
        if Stream(file, 'C', 'Open Write') \= 'READY:' then
            signal CheckFailed
        !._file = file
        call LineOut !._file, , 1
        do i = 1 to record.0
            call LineOut !._file, record.i
            if result \= 0 then signal CallFailed
            if handicap then call IPCVersion
        end
        call Stream !._file, 'C', 'Close'

        /* The destination may now read the file. */
        call SemEventPost eventOrig
        if result \= 0 then signal CallFailed

        /* Wait for the destination. */
        call SemEventWait eventDest
        if result \= 0 then signal CallFailed

        /* Display summary. */
        call Time 'Reset'
        say 'File transfer'handicapNotice':' Trunc(result, 2) 'seconds.'
        say
        call LineOut !._logFile,,
            '  File'handicapNotice':' Trunc(result, 2) 'seconds.'

        /* Reset destination event. */
        call SemEventReset eventDest
        if result \= 0 then signal CallFailed
    end

    /* Rexx queue transfer. */
    rexxQueue = !._CFG._Benchmark._RexxQueue
    if rexxQueue \= '' & Abbrev('REXX', test, 0) then do
        say 'Doing a Rexx queue transfer...'
        call Time 'Reset'

        /* Create the queue and set current. */
        rexxQueue = Translate(rexxQueue)
        !._rexxQueue.1 = RxQueue('Create', rexxQueue)
        if !._rexxQueue.1 \= rexxQueue then signal CheckFailed
        previousQueue = RxQueue('Set', !._rexxQueue.1)

        /* The destination may now open the queue. */
        call SemEventPost eventOrig
        if result \= 0 then signal CallFailed

        /* Put all the records on the queue. */
        do i = 1 to record.0
            queue record.i
            if handicap then call IPCVersion
        end

        /* Wait for the destination. */
        call SemEventWait eventDest
        if result \= 0 then signal CallFailed

        /* Display summary. */
        call Time 'Reset'
        say 'Rexx queue transfer'handicapNotice':' Trunc(result, 2) 'seconds.'
        say
        call LineOut !._logFile,,
            '  Rexx queue'handicapNotice':' Trunc(result, 2) 'seconds.'

        /* Reset destination event. */
        call SemEventReset eventDest
        if result \= 0 then signal CallFailed

        /* Cleanup the queue environment. */
        call RxQueue 'Set', previousQueue
        call RxQueue 'Delete', !._rexxQueue.1
        !._rexxQueue.1 = ''
        if result \= 0 then signal CallFailed
    end

    /* Named pipe transfer. */
    pipeName = !._CFG._Benchmark._PipeName
    if pipeName \= '' & Abbrev('PIPE', test, 0) then do
        say 'Doing a named pipe transfer...'

        /* Create the server's named pipe. */
        call PipeCreate '!._pipe.1', pipeName
        if result \= 0 then signal CallFailed

        /* The client may now try to open the pipe. */
        call SemEventPost eventOrig
        if result \= 0 then signal CallFailed

        call Time 'Reset'

        /* Wait for the connection. */
        call PipeConnect !._pipe.1
        if result \= 0 then signal CallFailed

        /* Send the records on the pipe. */
        do i = 1 to record.0
            call PipeWrite !._pipe.1, record.i
            if result \= 0 then signal CallFailed
        end

        /* Wait for the destination. */
        call SemEventWait eventDest
        if result \= 0 then signal CallFailed

        /* Disconnect. */
        call PipeDisconnect !._pipe.1
        if result \= 0 then signal CallFailed

        /* Display summary. */
        call Time 'Reset'
        say 'Named pipe transfer:' Trunc(result, 2) 'seconds.'
        say
        call LineOut !._logFile,,
            '  Named pipe:' Trunc(result, 2) 'seconds.'

        /* Reset destination event. */
        call SemEventReset eventDest
        if result \= 0 then signal CallFailed

        /* Close the server's pipe. */
        call PipeClose !._pipe.1
        if result \= 0 then signal CallFailed
        !._pipe.1 = ''
    end

    /* OS/2 queue transfer. */
    queueName = !._CFG._Benchmark._QueueName
    if !._major = 1 then
        if !._minor <= 20 then queueName = ''
        else if !._minor = 21 then
            if !._revision < 100 then queueName = ''
    if queueName \= '' & Abbrev('QUEUE', test, 0) then do
        say 'Doing a OS/2 queue transfer...'

        /* The client should now create the queue. */
        call SemEventPost eventOrig
        if result \= 0 then signal CallFailed

        /* Wait for the confirmation. */
        call SemEventWait eventDest
        if result \= 0 then signal CallFailed
        call SemEventReset eventDest
        if result \= 0 then signal CallFailed

        call Time 'Reset'

        /* Let the client serve. */
        call SemEventPost eventOrig
        if result \= 0 then signal CallFailed

        /* Queue the records. */
        call QueueOpen '!._queue.1', queueName, 'server'
        if result \= 0 then signal CallFailed
        do i = 1 to record.0
            call QueueWrite !._queue.1, record.i
            if result \= 0 then signal CallFailed
        end

        /* Close the queue if inter-process. */
        call ProcGetThreadInfo , , , 'process'
        if process \= server then do
            call QueueClose !._queue.1
            if result \= 0 then signal CallFailed
        end
        !._queue.1 = ''

        /* Wait for the destination. */
        call SemEventWait eventDest
        if result \= 0 then signal CallFailed

        /* Display summary. */
        call Time 'Reset'
        say 'OS/2 queue transfer:' Trunc(result, 2) 'seconds.'
        say
        call LineOut !._logFile,,
            '  OS/2 queue:' Trunc(result, 2) 'seconds.'

        /* Reset destination event. */
        call SemEventReset eventDest
        if result \= 0 then signal CallFailed
    end

    /* Resources released. */
    !._rexxQueue.0 = ''
    !._pipe.0 = ''
    !._queue.0 = ''

    return



/*:VRX         BenchmarkProcess
*/

/* BenchmarkProcess -- Created for PerformSimpleBenchmark. */

BenchmarkProcess:
    procedure expose !.

    eventOrig = Arg(1)
    eventDest = Arg(2)
    parse value Arg(3) with . . encore .

    /* Resources used. */
    !._event.0 = 2

    /* Open supplied shared events. */
    call SemEventOpen eventOrig
    if result \= 0 then signal CallFailed
    !._event.1 = eventOrig
    call SemEventOpen eventDest
    if result \= 0 then signal CallFailed
    !._event.2 = eventDest

    /* Get benchmark data generated by the main process. */
    file = !._CFG._Benchmark._FileName
    if file = '' then file = !._source._pathName'.TMP'
    if Stream(file, 'C', 'Open Read') \= 'READY:' then signal CheckFailed
    record.0 = !._CFG._Benchmark._RecordCount
    do i = 1 to record.0
        record.i = LineIn(file)
    end
    call Stream file, 'C', 'Close'

    /* Indicate that the destination process is ready. */
    call SemEventPost eventDest
    if result \= 0 then signal CallFailed

    /* Do the destination part of the benchmark. */
    call BenchmarkDestination eventOrig, eventDest, Arg(3)

    /* Encore if specified. */
    if encore = '' then encore = !._CFG._Benchmark._Encore
    if encore = '' then encore = 0
    do encore
        call BenchmarkDestination eventOrig, eventDest, Arg(3)
    end

    /* Close the shared events. */
    call SemEventClose !._event.1
    if result \= 0 then signal CallFailed
    !._event.1 = ''
    call SemEventClose !._event.2
    if result \= 0 then signal CallFailed
    !._event.2 = ''

    /* Resources released. */
    !._event.0 = ''

    call Cleanup

    '@EXIT'

    return



/*:VRX         BenchmarkThread
*/

/* BenchmarkThread -- Created for PerformSimpleBenchmark. */

BenchmarkThread:
    procedure expose !.

    eventOrig = Arg(1)
    eventDest = Arg(2)
    parse value Arg(3) with . . encore .

    /* Get benchmark data generated by the main thread. */
    record.0 = !._CFG._Benchmark._RecordCount
    do i = 1 to record.0
        record.i = LineIn('QUEUE:')
    end

    /* Indicate that the destination thread is ready. */
    call SemEventPost eventDest
    if result \= 0 then signal CallFailed

    /* Do the destination part of the benchmark. */
    call BenchmarkDestination eventOrig, eventDest, Arg(3)

    /* Encore if specified. */
    if encore = '' then encore = !._CFG._Benchmark._Encore
    if encore = '' then encore = 0
    do encore
        call BenchmarkDestination eventOrig, eventDest, Arg(3)
    end

    return



/*:VRX         Cleanup
*/

/* Cleanup -- Cleanup before exit. */

Cleanup:
    procedure expose !.

    signal off notready

    /* Close any open context. */
    if !._context.0 \= '' then
        do context = 1 to !._context.0
            if !._context.context \= '' then do
                call IPCContextClose !._context.context
                !._context.context = ''
            end
        end

    /* Close any open event semaphore. */
    if !._event.0 \= '' then
        do event = 1 to !._event.0
            if !._event.event \= '' then do
                call SemEventClose !._event.event
                !._event.event = ''
            end
        end

    /* Close any open mutex semaphore. */
    if !._mutex.0 \= '' then
        do mutex = 1 to !._mutex.0
            if !._mutex.mutex \= '' then do
                call SemMutexRelease !._mutex.mutex
                call SemMutexClose !._mutex.mutex
                !._mutex.mutex = ''
            end
        end

    /* Close any open muxwait semaphore. */
    if !._muxwait.0 \= '' then
        do muxwait = 1 to !._muxwait.0
            if !._muxwait.muxwait \= '' then do
                call SemMuxwaitClose !._muxwait.muxwait
                !._muxwait.muxwait = ''
            end
        end

    /* Stop any active timer. */
    if !._timer.0 \= '' then
        do timer = 1 to !._timer.0
            if !._timer.timer \= '' then do
                call SemStopTimer !._timer.timer
                !._timer.timer = ''
            end
        end

    /* Close any open named pipe. */
    if !._pipe.0 \= '' then
        do pipe = 1 to !._pipe.0
            if !._pipe.pipe \= '' then do
                call PipeClose !._pipe.pipe
                !._pipe.pipe = ''
            end
        end

    /* Close any open OS/2 queue. */
    if !._queue.0 \= '' then
        do queue = 1 to !._queue.0
            if !._queue.queue \= '' then do
                call QueueClose !._queue.queue
                !._queue.queue = ''
            end
        end

    /* Delete any created Rexx queue. */
    if !._rexxQueue.0 \= '' then
        do rexxQueue = 1 to !._rexxQueue.0
            if !._rexxQueue.rexxQueue \= '' then do
                call RxQueue 'Delete', !._rexxQueue.rexxQueue
                !._rexxQueue.rexxQueue = ''
            end
        end

    /* Close and delete a temporary file. */
    if !._file \= '' then do
        call Stream !._file, 'C', 'Close'
        call SysFileDelete !._file
        !._file = ''
    end

    /* Close a log file. */
    if !._logFile \= '' then do
        call Stream !._logFile, 'C', 'Close'
        !._logFile = ''
    end

    return



/*:VRX         LoadConfig
*/

/* LoadConfig -- Load configuration parameters from file. */

LoadConfig:
    procedure expose !.

    parse arg file, subStem

    /* Open the configuration file. */
    if Stream(file, 'C', 'Open Read') \= 'READY:' then
        signal ConfigFileMissing

    lineNumber = 0
    section = ''

    /* Read the configuration file. */
    do while Lines(file)
        /* Get a line. */
        line = Strip(LineIn(file))
        lineNumber = lineNumber + 1

        /* If line is empty or comment, ignore. */
        if line = '' | Left(line, 1) = ';' then iterate

        /* Line is either section header or entry definition. */
        if Left(line, 1) = '[' then do
            /* Get upper case section name prefixed with '_'. */
            parse var line '[' section ']' .
            section = '_'Translate(Strip(section))

            /* On first occurrence of section, zero count of entries. */
            if !.subStem.section.0 = '' then !.subStem.section.0 = 0
        end
        else do
            /* Get upper case entry name prefixed with '_', value. */
            parse var line entry '=' value
            entry = '_'Translate(Strip(entry))

            /* Save value stripped of prefix / suffix spaces. */
            !.subStem.section.entry = Strip(value)

            /* Save the entry stem in the section list. */
            entryIndex = !.subStem.section.0 + 1
            !.subStem.section.entryIndex = entry
            !.subStem.section.0 = entryIndex
        end

    end /* do while */

    /* Close the configuration file. */
    call Stream file, 'C', 'Close'

    return


ConfigFileMissing:

    say 'Failed to open configuration file "'file'"!'
    signal Abort



/*:VRX         Main
*/

Main:
    procedure expose !.

    arg test .

    /* Load OS/2 supplied utilities. */
    call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
    signal on syntax name SysLoadFailed
    call SysLoadFuncs
    signal on syntax

    /* Drop previous definition of library. */
    if \RxFuncQuery('IPCDropFuncs') then call IPCDropFuncs
    call RxFuncDrop 'IPCLoadFuncs'

    /* Load new definition or fail. */
    call RxFuncAdd 'IPCLoadFuncs', 'REXXIPC', 'IPCLoadFuncs'
    signal on syntax name IPCLoadFailed
    call IPCLoadFuncs
    signal on syntax

    /* External identification. */
    say
    say 'TestIPC V1.10-000.'
    say
    say !._CFG._Configuration._Identification !._CFG._Configuration._Version'.'
    say
    parse value IPCVersion() with producer ipcVersion
    say 'Using' producer ipcVersion'.'
    say

    /* Test for minimum RexxIPC version. */
    if producer \= 'SFB' then signal Producer
    parse value Word(ipcVersion, 2) with 'V' !._major '.' !._minor '-' !._revision
    if !._major = 1 then
        if !._minor < 20 then signal Version
        else if !._minor = 20 then
            if !._revision < 103 then signal Version

    !._profiler = !._CFG._Configuration._Profiler
    if !._profiler = '' then !._profiler = 0
    else if !._profiler \= 0 & !._profiler \= 1 then signal Config

    if Abbrev('MINIMAL', test, 0) then call TestMinimalOperations Arg(1)
    if Abbrev('SEMAPHORE', test, 0) then call TestSemaphoreOperations Arg(1)
    if Abbrev('PIPE', test, 0) then call TestPipeOperations Arg(1)
    if Abbrev('QUEUE', test, 0) then call TestQueueOperations Arg(1)
    if Abbrev('BENCHMARK', test, 1) then call PerformSimpleBenchmark Arg(1)

    say 'TestIPC completed.'

    return


SysLoadFailed:

    say 'TestIPC needs REXXUTIL functions!'
    signal Abort


IPCLoadFailed:

    say 'Failed to load RexxIPC functions!'
    signal Abort


Producer:

    say 'TestIPC expects SFB as producer!'
    signal Abort


Version:

    say 'TestIPC needs RexxIPC V1.20-103 or later!'
    signal Abort



/*:VRX         MinimalProcess
*/

/* MinimalProcess -- Created for TestMinimalOperations. */

MinimalProcess:
    procedure expose !.

    event1 = Arg(1)
    event2 = Arg(2)

    /* Resources used. */
    !._event.0 = 1
    !._pipe.0 = 1

    /* Try to open what should be a local event. */
    call SemEventOpen event2
    if result \= 006 then signal CallFailed

    /* Open and post the supplied event. */
    call SemEventOpen event1
    if result \= 0 then signal CallFailed
    !._event.1 = event1
    call SemEventPost !._event.1
    if result \= 0 then signal CallFailed

    /* The server must be waiting on connect. */
    name = !._CFG._Minimal._PipeName
    if name = '' then signal Config
    call PipeOpen '!._pipe.1', name
    if result \= 0 then signal CallFailed

    /* Send our PID. */
    call ProcGetThreadInfo , , , 'PID'
    call PipeWrite !._pipe.1, PID
    if result \= 0 then signal CallFailed

    /* Get the negated PID as response. */
    call PipeRead !._pipe.1, 'response'
    if result \= 0 then signal CallFailed
    if response \= -PID then signal CheckFailed

    /* Disconnect. */
    call PipeClose !._pipe.1
    if result \= 0 then signal CallFailed
    !._pipe.1 = ''

    /* Close event. */
    call SemEventClose !._event.1
    if result \= 0 then signal CallFailed
    !._event.1 = ''

    /* Resources released. */
    !._event.0 = ''
    !._pipe.0 = ''

    call Cleanup

    '@EXIT'

    return



/*:VRX         MinimalThread
*/

/* MinimalThread -- Created for TestMinimalOperations. */

MinimalThread:
    procedure expose !.

    event = Arg(1)

    /* Boost priority and test for the C Set++ optimizer
    ** bug triggered when 1st parameter absent. */
    call ProcSetThreadPriority , , +31
    if result \= 0 then signal CallFailed

    /* Wait for the calling thread. */
    timeout = !._CFG._Minimal._ThreadTimeout
    if timeout = '' then signal Config
    call SemEventWait event, timeout * 1000
    if result \= 0 then signal CallFailed

    return



/*:VRX         PerformSimpleBenchmark
*/

/* PerformSimpleBenchmark -- Perform a simple benchmark. */

PerformSimpleBenchmark:
    procedure expose !.

    arg . . encore .

    say 'Performing a simple benchmark...'

    /* Resources used. */
    !._event.0 = 4
    !._context.0 = 1

    /* Open benchmark log file. */
    !._logFile = !._CFG._Benchmark._LogFile
    if !._logFile = '' then signal Config
    if Stream(!._logFile, 'C', 'Open Write') \= 'READY:' then
        signal CheckFailed
    say 'Logging results in "'!._logFile'"...'
    call LineOut !._logFile,,
        'Started' Translate(Date('Ordered'), '-', '/') Time()'.'

    /* Get specifications. */
    record.0 = !._CFG._Benchmark._RecordCount
    if record.0 = '' | \DataType(record.0, 'W') then signal Config
    length = !._CFG._Benchmark._RecordLength
    if length = '' | \DataType(length, 'W') then signal Config
    say 'Using' record.0 'records of' length 'bytes...'
    call LineOut !._logFile,,
        'With' record.0 'records of' length 'bytes.'

    /* Event 1 will be used as origin thread ready indicator. */
    call SemEventCreate '!._event.1'
    if result \= 0 then signal CallFailed

    /* Event 2 will be used as destination thread ready indicator. */
    call SemEventCreate '!._event.2'
    if result \= 0 then signal CallFailed

    /* Context 1 will be used for thread monitoring. */
    call IPCContextCreate '!._context.1'
    if result \= 0 then signal CallFailed

    /* Clear the session queue. */
    do while Queued() > 0
        pull anything
    end

    /* Start the destination thread. */
    call ProcCreateThread !._context.1, !._source,,
        'call BenchmarkThread' !._event.1',' !._event.2', "'Arg(1)'"'
    if result \= 0 then signal CallFailed

    /* Create the data records. */
    say 'Generating test data...'
    call Time 'Reset'
    do i = 1 to record.0
        record = ''
        do while Length(record) < length
            record = record || X2B(D2X(Random(0, 65535), 4))
        end
        record.i = Left(record, length)
        queue record.i
    end
    call Time 'Reset'
    call LineOut !._logFile,,
            'Test data generation:' Trunc(result, 2) 'seconds.'
    say 'Test data generated.'
    say

    /* Thread benchmark. */
    say 'Thread to thread transfers.'
    say
    call LineOut !._logFile, 'Thread to thread.'

    /* Wait for the destination thread to be ready. */
    call SemEventWait !._event.2
    if result \= 0 then signal CallFailed
    call SemEventReset !._event.2
    if result \= 0 then signal CallFailed

    /* Do the origin part of the benchmark. */
    call BenchMarkOrigin !._event.1, !._event.2, Arg(1)

    /* The process benchmark is skipped when profiling. */
    if \!._profiler then do
        /* Event 3 will be used as origin process ready indicator. */
        call SemEventCreate '!._event.3', 'Shared'
        if result \= 0 then signal CallFailed

        /* Event 4 will be used as destination process ready indicator. */
        call SemEventCreate '!._event.4', 'Shared'
        if result \= 0 then signal CallFailed

        /* Save benchmark data for process. */
        if !._file = '' then do
            !._file = !._source._pathName'.TMP'
            if Stream(!._file, 'C', 'Open Write') \= 'READY:' then
                signal CheckFailed
            call LineOut !._file, , 1
            do i = 1 to record.0
                call LineOut !._file, record.i
                if result \= 0 then signal CallFailed
            end
            call Stream !._file, 'C', 'Close'
        end

        /* Process benchmark. */
        say 'Process to process transfers.'
        say
        call LineOut !._logFile, 'Process to process.'

        /* Start the destination process. */
        '@START "TestIPC Benchmark" /B /WIN /MIN' !._source,
            'call BenchmarkProcess' !._event.3',' !._event.4',"'Arg(1)'"'

        /* Wait for destination process to be ready. */
        call SemEventWait !._event.4
        if result \= 0 then signal CallFailed
        call SemEventReset !._event.4
        if result \= 0 then signal CallFailed

        /* Delete the temporary data file. */
        call SysFileDelete !._file
        if result \= 0 then signal CallFailed
        !._file = ''

        /* Do the origin part of the benchmark. */
        call BenchMarkOrigin !._event.3, !._event.4, Arg(1)
    end

    /* Encore if specified. */
    if encore = '' then encore = !._CFG._Benchmark._Encore
    if encore = '' then encore = 0
    else if \DataType(encore, 'W') then signal Config
    do encore
        /* Thread benchmark. */
        say 'Thread to thread transfers.'
        say
        call LineOut !._logFile, 'Thread to thread.'

        /* Delete the temporary data file. */
        if !._file \= '' then do
            call SysFileDelete !._file
            if result \= 0 then signal CallFailed
            !._file = ''
        end

        /* Do the origin part of the benchmark. */
        call BenchMarkOrigin !._event.1, !._event.2, Arg(1)

        /* The process benchmark is skipped when profiling. */
        if \!._profiler then do
            /* Process benchmark. */
            say 'Process to process transfers.'
            say
            call LineOut !._logFile, 'Process to process.'

            /* Delete the temporary data file. */
            if !._file \= '' then do
                call SysFileDelete !._file
                if result \= 0 then signal CallFailed
                !._file = ''
            end

            /* Do the origin part of the benchmark. */
            call BenchMarkOrigin !._event.3, !._event.4, Arg(1)
        end
    end

    /* Wait for completion of destination thread. */
    call IPCContextWait !._context.1
    if result \= 0 then signal CallFailed

    /* Close context. */
    call IPCContextClose !._context.1
    if result \= 0 then signal CallFailed
    !._context.1 = ''

    /* Close events. */
    call SemEventClose !._event.1
    if result \= 0 then signal CallFailed
    !._event.1 = ''
    call SemEventClose !._event.2
    if result \= 0 then signal CallFailed
    !._event.2 = ''
    if \!._profiler then do
        call SemEventClose !._event.3
        if result \= 0 then signal CallFailed
        !._event.3 = ''
        call SemEventClose !._event.4
        if result \= 0 then signal CallFailed
        !._event.4 = ''
    end

    /* Close the log file. */
    call LineOut !._logFile, ''
    call Stream !._logFile, 'C', 'Close'
    !._logFile = ''

    /* Delete the temporary data file. */
    if !._file \= '' then do
        call SysFileDelete !._file
        if result \= 0 then signal CallFailed
        !._file = ''
    end

    /* Resources released. */
    !._event.0 = ''
    !._context.0 = ''

    say 'Simple benchmark completed.'
    say

    return



/*:VRX         PipeThread
*/

/* PipeThread -- Created for TestPipeOperations. */

PipeThread:
    procedure expose !.

    event = Arg(1)

    /* Resources used. */
    !._pipe.0 = 1

    /* Get the pipe name. */
    pipeName = !._CFG._Pipe._PipeName
    if pipeName = '' then signal Config

    /* Get a timeout value. */
    timeout = !._CFG._Pipe._Timeout
    if timeout = '' | \DataType(timeout, 'W') then signal Config

    /* Wait for the main to be ready. */
    call SemEventWait event, timeout * 1000
    if result \= 0 then signal CallFailed
    call SemEventReset event
    if result \= 0 then signal CallFailed

    /* Wait for the connect. */
    call PipeWait pipeName, timeout * 1000
    if result \= 0 then signal CallFailed

    /* Open the pipe. */
    call PipeOpen '!._pipe.1', pipeName
    if result \= 0 then signal CallFailed

    /* Get some data and return it reversed. */
    call PipeRead !._pipe.1, 'data'
    if result \= 0 then signal CallFailed
    call PipeWrite !._pipe.1, Reverse(data)
    if result \= 0 then signal CallFailed

    /* Close the pipe. */
    call PipeClose !._pipe.1
    if result \= 0 then signal CallFailed
    !._pipe.1 = ''

    /* Wait for the main to be ready. */
    call SemEventWait event, timeout * 1000
    if result \= 0 then signal CallFailed
    call SemEventReset event
    if result \= 0 then signal CallFailed

    /* Wait for the connect. */
    call PipeWait pipeName, timeout * 1000
    if result \= 0 then signal CallFailed

    /* Open the pipe (this should fail). */
    call PipeOpen '!._pipe.1', pipeName
    if result \= 087 then signal CallFailed

    /* Wait for the connect. */
    call PipeWait pipeName, timeout * 1000
    if result \= 0 then signal CallFailed

    /* Open the pipe (this should fail again). */
    call PipeOpen '!._pipe.1', pipeName, 'Duplex', 'Message'
    if result \= 087 then signal CallFailed

    /* Wait for the connect. */
    call PipeWait pipeName, timeout * 1000
    if result \= 0 then signal CallFailed

    /* Open the pipe (this should succeed). */
    call PipeOpen '!._pipe.1', pipeName, 'Duplex', 'Byte'
    if result \= 0 then signal CallFailed

    /* Get some data and return it reversed. */
    call PipeRead !._pipe.1, 'data'
    if result \= 0 then signal CallFailed
    call PipeWrite !._pipe.1, Reverse(data)
    if result \= 0 then signal CallFailed

    /* Close the pipe. */
    call PipeClose !._pipe.1
    if result \= 0 then signal CallFailed
    !._pipe.1 = ''

    /* Wait for the main to be ready. */
    call SemEventWait event, timeout * 1000
    if result \= 0 then signal CallFailed
    call SemEventReset event
    if result \= 0 then signal CallFailed

    /* Wait for the connect. */
    call PipeWait pipeName, timeout * 1000
    if result \= 0 then signal CallFailed

    /* Open the pipe (this should fail). */
    call PipeOpen '!._pipe.1', pipeName
    if result \= 005 then signal CallFailed

    /* Open the pipe (this should fail also). */
    call PipeOpen '!._pipe.1', pipeName, 'Outbound'
    if result \= 005 then signal CallFailed

    /* Open the pipe (this should succees). */
    call PipeOpen '!._pipe.1', pipeName, 'Inbound'
    if result \= 0 then signal CallFailed

    /* Get some data. */
    call PipeRead !._pipe.1, 'data'
    if result \= 0 then signal CallFailed

    /* Close the pipe. */
    call PipeClose !._pipe.1
    if result \= 0 then signal CallFailed
    !._pipe.1 = ''

    /* Wait for the main to be ready. */
    call SemEventWait event, timeout * 1000
    if result \= 0 then signal CallFailed
    call SemEventReset event
    if result \= 0 then signal CallFailed

    /* Wait for the connect. */
    call PipeWait pipeName, timeout * 1000
    if result \= 0 then signal CallFailed

    /* Open the pipe (this should fail). */
    call PipeOpen '!._pipe.1', pipeName
    if result \= 005 then signal CallFailed

    /* Open the pipe (this should fail also). */
    call PipeOpen '!._pipe.1', pipeName, 'Inbound'
    if result \= 005 then signal CallFailed

    /* Open the pipe (this should succees). */
    call PipeOpen '!._pipe.1', pipeName, 'Outbound'
    if result \= 0 then signal CallFailed

    /* Get some data (this should fail. */
    call PipeRead !._pipe.1, 'data'
    if result \= 005 then signal CallFailed

    /* Send some data. */
    call PipeWrite !._pipe.1, 'A'
    if result \= 0 then signal CallFailed

    /* Close the pipe. */
    call PipeClose !._pipe.1
    if result \= 0 then signal CallFailed
    !._pipe.1 = ''

    /* Resources released. */
    !._pipe.0 = ''

    return



/*:VRX         QueueProcess
*/

/* QueueProcess -- Created for TestQueueOperations. */

QueueProcess:
    procedure expose !.

    event = Arg(1)

    /* Resources used. */
    !._queue.0 = 1
    !._event.0 = 1

    /* Get the queue name. */
    queueName = !._CFG._Queue._QueueName
    if queueName = '' then signal Config

    /* Open the queue. */
    call QueueOpen '!._queue.1', queueName
    if result \= 0 then signal CallFailed

    /* Open the event. */
    call SemEventOpen event
    if result \= 0 then signal CallFailed
    !._event.1 = event

    /* Get data value. */
    data = !._CFG._Queue._ProcessData
    if data = '' then signal Config

    /* Queue to the server. */
    call QueueWrite !._queue.1, data
    if result \= 0 then signal CallFailed
    call QueueWrite !._queue.1, Reverse(data)
    if result \= 0 then signal CallFailed

    /* Close the queue. */
    call QueueClose !._queue.1
    if result \= 0 then signal CallFailed
    !._queue.1 = ''

    /* Post the event for the server. */
    call SemEventPost !._event.1
    if result \= 0 then signal CallFailed

    /* Close the event. */
    call SemEventClose !._event.1
    if result \= 0 then signal CallFailed
    !._event.1 = ''

    /* Resources released. */
    !._queue.0 = ''
    !._event.0 = ''

    call Cleanup

    '@EXIT'

    return



/*:VRX         QueueThread
*/

/* QueueThread -- Created for TestQueueOperations. */

QueueThread:
    procedure expose !.

    queue = Arg(1)

    /* Get data value. */
    data = !._CFG._Queue._ThreadData
    if data = '' then signal Config

    /* Queue to the server. */
    call QueueWrite queue, data, 1, 2
    if result \= 0 then signal CallFailed
    call QueueWrite queue, data, 2, 3
    if result \= 0 then signal CallFailed
    call QueueWrite queue, data, 3, 1
    if result \= 0 then signal CallFailed

    return



/*:VRX         SemaphoreThread
*/

/* SemaphoreThread -- Created for TestSemaphoreOperations. */

SemaphoreThread:
    procedure expose !.

    event = Arg(1)
    mutex = Arg(2)
    muxwait = Arg(3)

    /* Resources used. */
    !._event.0 = 1
    !._mutex.0 = 1
    !._muxwait.0 = 1

    /* Open the named event semaphore. */
    name = !._CFG._Semaphore._EventName
    if name = '' then signal Config
    call SemEventOpen '!._event.1', name
    if result \= 0 then signal CallFailed

    /* Open the named mutex semaphore. */
    name = !._CFG._Semaphore._MutexName
    if name = '' then signal Config
    call SemMutexOpen '!._mutex.1', name
    if result \= 0 then signal CallFailed

    /* Open the named muxwait semaphore. */
    name = !._CFG._Semaphore._MuxwaitName
    if name = '' then signal Config
    call SemMuxwaitOpen '!._muxwait.1', name
    if result \= 0 then signal CallFailed

    /* Get a timeout value. */
    timeout = !._CFG._Semaphore._Timeout
    if timeout = '' | \DataType(timeout, 'W') then signal Config

    /* Wait for the mutex to be available. */
    call SemMutexRequest mutex, timeout * 1000
    if result \= 0 then signal CallFailed

    /* Request the named mutex. */
    call SemMutexRequest !._mutex.1, 0
    if result \= 0 then signal CallFailed

    /* Post the event. */
    call SemEventPost event
    if result \= 0 then signal CallFailed

    /* Release the mutex. */
    call SemMutexRelease mutex
    if result \= 0 then signal CallFailed

    /* Wait for signal from main. */
    call SemEventWait !._event.1, timeout * 1000
    if result \= 0 then signal CallFailed
    call SemEventReset !._event.1
    if result \= 0 then signal CallFailed

    /* Release the named mutex. */
    call SemMutexRelease !._mutex.1
    if result \= 0 then signal CallFailed

    /* Post the named event. */
    call SemEventPost !._event.1
    if result \= 0 then signal CallFailed

    /* Close the semaphores. */
    call SemEventClose !._event.1
    if result \= 0 then signal CallFailed
    !._event.1 = ''
    call SemMutexClose !._mutex.1
    if result \= 0 then signal CallFailed
    !._mutex.1 = ''
    call SemmuxwaitClose !._muxwait.1
    if result \= 0 then signal CallFailed
    !._muxwait.1 = ''

    /* Resources released. */
    !._event.0 = ''
    !._muxwait.0 = ''
    !._mutex.0 = ''

    return



/*:VRX         Signals
*/

/* Signals. */

Halt:

    say 'Halted (line' sigl')!'
    signal Abort


Failure:

    say 'Failure (line' sigl', code' rc')!'
    say 'On command "'Condition('D')'"'
    signal abort


Error:

    say 'Error (line' sigl', code' rc')!'
    say 'On command "'Condition('D')'"'
    signal abort


Syntax:

    say 'Rexx syntax error detected (line' sigl')!'
    say 'On string "'Condition('D')'"!'
    say ErrorText(rc)'!'
    signal Abort


NoValue:

    say 'Undefined variable "'Condition('D')'" (line' sigl')!'
    signal Abort


NotReady:

    stream = Condition('D')
    say 'I/O error on stream "'stream'" (line' sigl')!'
    say '"'Stream(stream, 'D')'"!'
    signal Abort


CallFailed:

    say 'Test failed (line 'sigl - 1', code 'result')!'
    signal Abort


Config:

    say 'Configuration file error (line 'SIGL')!'
    signal Abort


CheckFailed:

    say 'Validity check failed (line 'SIGL')!'
    signal Abort


Abort:

    call Cleanup
    exit 1



/*:VRX         TestMinimalOperations
*/

/* TestMinimalOperations -- Test minimal operations.
**
** This procedure test the minimal operations
** needed to perform the other tests.
**
** Note: the asynchronous form of pipe calls
** is used here to be able to detect malfunctions
** with a timeout on event. */

TestMinimalOperations:
    procedure expose !.

    say 'Testing minimal operations...'

    /* Resources used. */
    !._event.0 = 2
    !._context.0 = 1
    !._pipe.0 = 1

    /* Event 1 will be used by context 1. */
    call SemEventCreate '!._event.1'
    if result \= 0 then signal CallFailed

    /* Context 1 will be used for thread monitoring and pipe operations. */
    call IPCContextCreate '!._context.1', !._event.1
    if result \= 0 then signal CallFailed
    call IPCContextQuery !._context.1, 'thread'
    if result \= 0 then signal CallFailed
    if thread \= 0 then signal CheckFailed

    /* Event 2 will be used for thread and process synchronisation. */
    call SemEventCreate '!._event.2', 'Shared'
    if result \= 0 then signal CallFailed

    /* Create the collaborating thread. */
    call ProcCreateThread !._context.1, !._source,,
        'call MinimalThread' !._event.2
    if result \= 0 then signal CallFailed

    /* Thread will be waiting for this. */
    call SemEventPost !._event.2
    if result \= 0 then signal CallFailed

    /* Get a thread timeout value. */
    timeout = !._CFG._Minimal._ThreadTimeout
    if timeout = '' | \DataType(timeout, 'W') then signal Config

    /* Wait for thread completion. */
    call SemEventWait !._event.1, timeout * 1000
    if result \= 0 then signal CallFailed
    call IPCContextQuery !._context.1
    if result \= 0 then signal CallFailed

    /* First event 2 reset should return success. */
    call SemEventReset !._event.2
    if result \= 0 then signal CallFailed

    /* Second event 2 reset should return failure. */
    call SemEventReset !._event.2
    if result \= 300 then signal CallFailed

    /* The process tests are skipped when profiling. */
    if \!._profiler then do
        /* Pipe 1 will be used for process handshaking. */
        name = !._CFG._Minimal._PipeName
        if name = '' then signal Config
        call PipeCreate '!._pipe.1', name
        if result \= 0 then signal CallFailed

        /* Start listening for a client. */
        call PipeConnectAsync !._pipe.1, !._context.1
        if result \= 0 then signal CallFailed
        call IPCContextQuery !._context.1, 'thread'
        if result \= 170 then signal CallFailed
        if thread = 0 then signal CheckFailed

        /* This wait should fail on timeout. */
        call SemEventWait !._event.1, 1
        if result \= 640 then signal CallFailed

        /* Start the client process. */
        '@START "TestIPC Minimal" /B /WIN /MIN' !._source,
            'call MinimalProcess' !._event.2',' !._event.1

        /* Get a process timeout value. */
        timeout = !._CFG._Minimal._ProcessTimeout
        if timeout = '' | \DataType(timeout, 'W') then signal Config

        /* Wait for the client to post the shared event. */
        call SemEventWait !._event.2, timeout * 1000
        if result \= 0 then signal CallFailed

        /* Wait for the client to request a connection. */
        call SemEventWait !._event.1, timeout * 1000
        if result \= 0 then signal CallFailed
        call IPCContextQuery !._context.1
        if result \= 0 then signal CallFailed

        /* Wait for the client to write on the pipe. */
        call PipeReadAsync !._pipe.1, !._context.1
        if result \= 0 then signal CallFailed
        call SemEventWait !._event.1, timeout * 1000
        if result \= 0 then signal CallFailed
        call IPCContextQuery !._context.1
        if result \= 0 then signal CallFailed

        /* The received data should be the client PID. */
        PID = IPCContextResult(!._context.1)

        /* Test for the ReadAsync bug. */
        call PipeReadAsync !._pipe.1, !._context.1
        if result \= 0 then signal CallFailed
        call IPCContextClose !._context.1
        if result \= 0 then signal CallFailed
        !._context.1 = ''
        call IPCContextCreate '!._context.1', !._event.1
        if result \= 0 then signal CallFailed

        /* Negate PID as response and wait for the client to read it. */
        call PipeWriteAsync !._pipe.1, !._context.1, -PID
        if result \= 0 then signal CallFailed
        call SemEventWait !._event.1, timeout * 1000
        if result \= 0 then signal CallFailed
        call IPCContextQuery !._context.1
        if result \= 0 then signal CallFailed

        /* Wait for the client to disconnect the pipe. */
        call PipeReadAsync !._pipe.1, !._context.1
        if result \= 0 then signal CallFailed
        call SemEventWait !._event.1, timeout * 1000
        if result \= 0 then signal CallFailed
        call IPCContextQuery !._context.1
        if result \= 0 then signal CallFailed
        if IPCContextResult(!._context.1) \= '' then signal CheckFailed

        /* Disconnect the server. */
        call PipeDisconnect !._pipe.1
        if result \= 0 then signal CallFailed

        /* Close the server's pipe. */
        call PipeClose !._pipe.1
        if result \= 0 then signal CallFailed
        !._pipe.1 = ''
    end

    /* Close the context. */
    call IPCContextClose !._context.1
    if result \= 0 then signal CallFailed
    !._context.1 = ''

    /* Close events. */
    call SemEventClose !._event.1
    if result \= 0 then signal CallFailed
    !._event.1 = ''
    call SemEventClose !._event.2
    if result \= 0 then signal CallFailed
    !._event.2 = ''

    /* Resources released. */
    !._event.0 = ''
    !._context.0 = ''
    !._pipe.0 = ''

    say 'Minimal operations test completed.'
    say

    return



/*:VRX         TestPipeOperations
*/

/* TestPipeOperations -- Test pipe operations. */

TestPipeOperations:
    procedure expose !.

    say 'Testing pipe operations...'

    /* Resources used. */
    !._event.0 = 1
    !._pipe.0 = 3
    !._context.0 = 1

    /* Get the pipe name. */
    pipeName = !._CFG._Pipe._PipeName
    if pipeName = '' then signal Config

    /* Get a timeout value. */
    timeout = !._CFG._Pipe._Timeout
    if timeout = '' | \DataType(timeout, 'W') then signal Config

    /* Create synchronization event. */
    call SemEventCreate '!._event.1'
    if result \= 0 then signal CallFailed

    /* Create a context for the thread. */
    call IPCContextCreate '!._context.1'
    if result \= 0 then signal CallFailed

    /* Create the collaborating thread. */
    call ProcCreateThread !._context.1, !._source,,
        'call PipeThread' !._event.1
    if result \= 0 then signal CallFailed

    /* Create a message pipe. */
    call PipeCreate '!._pipe.1', pipeName, 'Duplex', 'Message'
    if result \= 0 then signal CallFailed

    /* It should not be possible to create a clone. */
    call PipeCreate '!._pipe.2', pipeName
    if result \= 231 then signal CallFailed

    /* Signal that the main is ready. */
    call SemEventPost !._event.1
    if result \= 0 then signal CallFailed

    /* Wait for the thread to connect. */
    call PipeConnect !._pipe.1
    if result \= 0 then signal CallFailed

    /* Send and receive some data. */
    data = 'AB'
    call PipeWrite !._pipe.1, data
    if result \= 0 then signal CallFailed
    call PipeRead !._pipe.1, 'received'
    if result \= 0 then signal CallFailed
    if received \= Reverse(data) then signal CheckFailed

    /* Close the pipe. */
    call PipeClose !._pipe.1
    if result \= 0 then signal CallFailed
    !._pipe.1 = ''

    /* Create a byte pipe. */
    call PipeCreate '!._pipe.1', pipeName, 'Duplex', 'Byte', 2
    if result \= 0 then signal CallFailed

    /* It should be possible to create a clone. */
    call PipeCreate '!._pipe.2', pipeName
    if result \= 0 then signal CallFailed

    /* But not 2 clones. */
    call PipeCreate '!._pipe.3', pipeName
    if result \= 231 then signal CallFailed

    /* Close the clone. */
    call PipeClose !._pipe.2
    if result \= 0 then signal CallFailed
    !._pipe.2 = ''

    /* Signal that the main is ready. */
    call SemEventPost !._event.1
    if result \= 0 then signal CallFailed

    /* Wait for the thread to connect. */
    call PipeConnect !._pipe.1
    if result \= 0 then signal CallFailed

    /* A send should fail. */
    call PipeWrite !._pipe.1, 'A'
    if result \= 109 then signal CallFailed
    call PipeDisconnect !._pipe.1
    if result \= 0 then signal CallFailed

    /* Wait for the thread to connect again. */
    call PipeConnect !._pipe.1
    if result \= 0 then signal CallFailed

    /* A send should fail again. */
    call PipeWrite !._pipe.1, 'A'
    if result \= 109 then signal CallFailed
    call PipeDisconnect !._pipe.1
    if result \= 0 then signal CallFailed

    /* Wait for the thread to connect again. */
    call PipeConnect !._pipe.1
    if result \= 0 then signal CallFailed

    /* Send and receive some data. */
    data = 'AB'
    call PipeWrite !._pipe.1, data
    if result \= 0 then signal CallFailed
    call PipeRead !._pipe.1, 'received'
    if result \= 0 then signal CallFailed
    if received \= Reverse(data) then signal CheckFailed

    /* Close the pipe. */
    call PipeClose !._pipe.1
    if result \= 0 then signal CallFailed
    !._pipe.1 = ''

    /* Create an outbound pipe. */
    call PipeCreate '!._pipe.1', pipeName, 'Outbound'
    if result \= 0 then signal CallFailed

    /* Signal that the main is ready. */
    call SemEventPost !._event.1
    if result \= 0 then signal CallFailed

    /* Wait for the thread to connect. */
    call PipeConnect !._pipe.1
    if result \= 0 then signal CallFailed

    /* Send some data. */
    call PipeWrite !._pipe.1, 'A'
    if result \= 0 then signal CallFailed

    /* Receive some data (this should fail). */
    call PipeRead !._pipe.1, 'received'
    if result \= 005 then signal CallFailed

    /* Close the pipe. */
    call PipeClose !._pipe.1
    if result \= 0 then signal CallFailed
    !._pipe.1 = ''

    /* Create an inbound pipe. */
    call PipeCreate '!._pipe.1', pipeName, 'Inbound'
    if result \= 0 then signal CallFailed

    /* Signal that the main is ready. */
    call SemEventPost !._event.1
    if result \= 0 then signal CallFailed

    /* Wait for the thread to connect. */
    call PipeConnect !._pipe.1
    if result \= 0 then signal CallFailed

    /* Send some data (this should fail). */
    call PipeWrite !._pipe.1, 'A'
    if result \= 005 then signal CallFailed

    /* Receive some data. */
    call PipeRead !._pipe.1, 'received'
    if result \= 0 then signal CallFailed

    /* Close the pipe. */
    call PipeClose !._pipe.1
    if result \= 0 then signal CallFailed
    !._pipe.1 = ''

    /* Wait for completion of collaborating thread. */
    call IPCContextWait !._context.1
    if result \= 0 then signal CallFailed

    /* Close the context. */
    call IPCContextClose !._context.1
    if result \= 0 then signal CallFailed
    !._context.1 = ''

    /* Close the event. */
    call SemEventClose !._event.1
    if result \= 0 then signal CallFailed
    !._event.1 = ''

    /* Resources released. */
    !._event.0 = ''
    !._pipe.0 = ''
    !._context.0 = ''

    say 'Pipe operations test completed.'
    say

    return



/*:VRX         TestQueueOperations
*/

/* TestQueueOperations -- Test queue operations. */

TestQueueOperations:
    procedure expose !.

    /* Queue operations implementation starts with V1.21-100. */
    if !._major = 1 then
        if !._minor <= 20 then return
        else if !._minor = 21 then
            if !._revision < 100 then return

    say 'Testing queue operations...'

    /* Resources used. */
    !._queue.0 = 1
    !._event.0 = 2
    !._context.0 = 1

    /* Get the queue name. */
    queueName = !._CFG._Queue._QueueName
    if queueName = '' then signal Config

    /* Create the queue. */
    call QueueCreate '!._queue.1', queueName
    if result \= 0 then signal CallFailed

    /* Peek should fail on empty. */
    call QueuePeek !._queue.1
    if result \= 342 then signal CallFailed

    /* Close the queue. */
    call QueueClose !._queue.1
    if result \= 0 then signal CallFailed
    !._queue.1 = ''

    /* Get a timeout value. */
    timeout = !._CFG._Queue._Timeout
    if timeout = '' | \DataType(timeout, 'W') then signal Config

    /* Create the queue event. */
    call SemEventCreate '!._event.1', 'Shared'
    if result \= 0 then signal CallFailed

    /* Create the queue. */
    call QueueCreate '!._queue.1', queueName, 'FIFO', !._event.1
    if result \= 0 then signal CallFailed

    /* Peek should fail on empty. */
    call QueuePeek !._queue.1
    if result \= 342 then signal CallFailed

    /* Create a context for the thread. */
    call IPCContextCreate '!._context.1'
    if result \= 0 then signal CallFailed

    /* Create the collaborating thread. */
    call ProcCreateThread !._context.1, !._source,,
        'call QueueThread' !._queue.1
    if result \= 0 then signal CallFailed

    /* Wait for completion of collaborating thread. */
    call IPCContextWait !._context.1
    if result \= 0 then signal CallFailed

    /* The queue event should have been posted. */
    call SemEventQuery !._event.1, 'postCount'
    if result \= 0 then signal CallFailed
    if postCount \= 1 then signal CheckFailed

    /* Peek should now succeed. */
    call QueuePeek !._queue.1
    if result \= 0 then signal CallFailed

    /* There should be 3 entries in the queue. */
    call QueueQuery !._queue.1, 'elements'
    if result \= 0 then signal CallFailed
    if elements \= 3 then signal CheckFailed

    /* Get data value. */
    threadData = !._CFG._Queue._ThreadData
    if threadData = '' then signal Config

    /* Get the data queued by the thread. */
    call QueueRead !._queue.1, 'data', 'request', 'priority'
    if result \= 0 then signal CallFailed
    if data \= threadData then signal CheckFailed
    if request \= 1 | priority \= 0 then signal CheckFailed
    call QueueRead !._queue.1, 'data', 'request', 'priority'
    if result \= 0 then signal CallFailed
    if data \= threadData then signal CheckFailed
    if request \= 2 | priority \= 0 then signal CheckFailed
    call QueueRead !._queue.1, 'data', 'request', 'priority'
    if result \= 0 then signal CallFailed
    if data \= threadData then signal CheckFailed
    if request \= 3 | priority \= 0 then signal CheckFailed

    /* There should be no entries in the queue. */
    call QueueQuery !._queue.1, 'elements'
    if result \= 0 then signal CallFailed
    if elements \= 0 then signal CheckFailed

    /* Peek should fail on empty. */
    call QueuePeek !._queue.1
    if result \= 342 then signal CallFailed

    /* The queue event should have been reset. */
    call SemEventQuery !._event.1, 'postCount'
    if result \= 0 then signal CallFailed
    if postCount \= 0 then signal CheckFailed

    /* Close the queue. */
    call QueueClose !._queue.1
    if result \= 0 then signal CallFailed
    !._queue.1 = ''

    /* Create the queue. */
    call QueueCreate '!._queue.1', queueName, 'LIFO'
    if result \= 0 then signal CallFailed

    /* Create the collaborating thread. */
    call ProcCreateThread !._context.1, !._source,,
        'call QueueThread' !._queue.1
    if result \= 0 then signal CallFailed

    /* Wait for completion of collaborating thread. */
    call IPCContextWait !._context.1
    if result \= 0 then signal CallFailed

    /* Get the data queued by the thread. */
    call QueueRead !._queue.1, 'data', 'request', 'priority'
    if result \= 0 then signal CallFailed
    if data \= threadData then signal CheckFailed
    if request \= 3 | priority \= 0 then signal CheckFailed
    call QueueRead !._queue.1, 'data', 'request', 'priority'
    if result \= 0 then signal CallFailed
    if data \= threadData then signal CheckFailed
    if request \= 2 | priority \= 0 then signal CheckFailed
    call QueueRead !._queue.1, 'data', 'request', 'priority'
    if result \= 0 then signal CallFailed
    if data \= threadData then signal CheckFailed
    if request \= 1 | priority \= 0 then signal CheckFailed

    /* Close the queue. */
    call QueueClose !._queue.1
    if result \= 0 then signal CallFailed
    !._queue.1 = ''

    /* Create the queue. */
    call QueueCreate '!._queue.1', queueName, 'Priority'
    if result \= 0 then signal CallFailed

    /* Create the collaborating thread. */
    call ProcCreateThread !._context.1, !._source,,
        'call QueueThread' !._queue.1
    if result \= 0 then signal CallFailed

    /* Wait for completion of collaborating thread. */
    call IPCContextWait !._context.1
    if result \= 0 then signal CallFailed

    /* Get the data queued by the thread. */
    call QueueRead !._queue.1, 'data', 'request', 'priority'
    if result \= 0 then signal CallFailed
    if data \= threadData then signal CheckFailed
    if request \= 2 | priority \= 3 then signal CheckFailed
    call QueueRead !._queue.1, 'data', 'request', 'priority'
    if result \= 0 then signal CallFailed
    if data \= threadData then signal CheckFailed
    if request \= 1 | priority \= 2 then signal CheckFailed
    call QueueRead !._queue.1, 'data', 'request', 'priority'
    if result \= 0 then signal CallFailed
    if data \= threadData then signal CheckFailed
    if request \= 3 | priority \= 1 then signal CheckFailed

    /* Close the queue. */
    call QueueClose !._queue.1
    if result \= 0 then signal CallFailed
    !._queue.1 = ''

    /* Close the context. */
    call IPCContextClose !._context.1
    if result \= 0 then signal CallFailed
    !._context.1 = ''

    /* The process tests are skipped when profiling. */
    if \!._profiler then do
        /* Create the queue. */
        call QueueCreate '!._queue.1', queueName, , !._event.1
        if result \= 0 then signal CallFailed

        /* Peek to enable event posting. */
        call QueuePeek !._queue.1
        if result \= 342 then signal CallFailed

        /* Create the process synchronization event. */
        call SemEventCreate '!._event.2', 'Shared'
        if result \= 0 then signal CallFailed

        /* Start the client process. */
        '@START "TestIPC Queue" /B /WIN /MIN' !._source,
            'call QueueProcess' !._event.2

        /* Wait for the process to complete. */
        call SemEventWait !._event.2
        if result \= 0 then signal CallFailed

        /* The queue event should have been posted. */
        call SemEventQuery !._event.1, 'postCount'
        if result \= 0 then signal CallFailed
        if postCount \= 1 then signal CheckFailed

        /* Get data value. */
        processData = !._CFG._Queue._ProcessData
        if processData = '' then signal Config

        /* There should be 2 entries in the queue. */
        call QueueQuery !._queue.1, 'elements'
        if result \= 0 then signal CallFailed
        if elements \= 2 then signal CheckFailed

        /* Get the data queued by the process. */
        call QueueRead !._queue.1, 'data'
        if result \= 0 then signal CallFailed
        if data \= processData then signal CheckFailed
        call QueueRead !._queue.1, 'data'
        if result \= 0 then signal CallFailed
        if data \= Reverse(processData) then signal CheckFailed

        /* Close the process event. */
        call SemEventClose !._event.2
        if result \= 0 then signal CallFailed
        !._event.2 = ''

        /* Close the queue. */
        call QueueClose !._queue.1
        if result \= 0 then signal CallFailed
        !._queue.1 = ''
    end

    /* Close the queue event. */
    call SemEventClose !._event.1
    if result \= 0 then signal CallFailed
    !._event.1 = ''

    /* Resources released. */
    !._queue.0 = ''
    !._event.0 = ''
    !._context.0 = ''

    say 'Queue operations test completed.'
    say

    return



/*:VRX         TestSemaphoreOperations
*/

/* TestSemaphoreOperations -- Test semaphore operations. */

TestSemaphoreOperations:
    procedure expose !.

    say 'Testing semaphore operations...'

    /* Resources used. */
    !._event.0 = 2
    !._mutex.0 = 2
    !._muxwait.0 = 2
    !._context.0 = 1
    !._timer.0 = 1

    /* Create a named event semaphore. */
    name = !._CFG._Semaphore._EventName
    if name = '' then signal Config
    call SemEventCreate '!._event.1', name
    if result \= 0 then signal CallFailed

    /* The event should be reset. */
    call SemEventQuery !._event.1, 'postCount'
    if result \= 0 then signal CallFailed
    if postCount \= 0 then CheckFailed

    /* Create a unnamed event semaphore. */
    call SemEventCreate '!._event.2', , 0
    if result \= 0 then signal CallFailed

    /* The event should be reset. */
    call SemEventQuery !._event.2, 'postCount'
    if result \= 0 then signal CallFailed
    if postCount \= 0 then CheckFailed

    /* Recreate the unnamed event semaphore. */
    call SemEventClose !._event.2
    if result \= 0 then signal CallFailed
    !._event.2 = ''
    call SemEventCreate '!._event.2', 'Shared', 1
    if result \= 0 then signal CallFailed

    /* The event should be posted. */
    call SemEventReset !._event.2, 'postCount'
    if result \= 0 then signal CallFailed
    if postCount \= 1 then CheckFailed

    /* Create a named mutex semaphore. */
    name = !._CFG._Semaphore._MutexName
    if name = '' then signal Config
    call SemMutexCreate '!._mutex.1', name
    if result \= 0 then signal CallFailed

    /* The mutex should not be owned. */
    call SemMutexQuery !._mutex.1, 'process', 'thread', 'owned'
    if result \= 0 then signal CallFailed
    if owned \= 0 then CheckFailed
    if process \= 0 then signal CheckFailed
    if thread \= 0 then signal CheckFailed

    /* Create a unnamed mutex semaphore. */
    call SemMutexCreate '!._mutex.2', , 0
    if result \= 0 then signal CallFailed

    /* The mutex should not be owned. */
    call SemMutexQuery !._mutex.2, , , 'owned'
    if result \= 0 then signal CallFailed
    if owned \= 0 then CheckFailed

    /* A release should fail. */
    call SemMutexRelease !._mutex.2
    if result \= 288 then signal CallFailed

    /* Recreate the unnamed mutex semaphore. */
    call SemMutexClose !._mutex.2
    if result \= 0 then signal CallFailed
    !._mutex.2 = ''
    call SemMutexCreate '!._mutex.2', 'Shared', 1
    if result \= 0 then signal CallFailed

    /* We should own the mutex. */
    call ProcGetThreadInfo 'tid', , , 'pid'
    call SemMutexQuery !._mutex.2, 'process', 'thread', 'owned'
    if result \= 0 then signal CallFailed
    if owned \= 1 then CheckFailed
    if process \= pid then signal CheckFailed
    if thread \= tid then signal CheckFailed

    /* Create a named muxwait semaphore. */
    name = !._CFG._Semaphore._MuxwaitName
    if name = '' then signal Config
    call SemMuxwaitCreate '!._muxwait.1', name, 'And'
    if result \= 0 then signal CallFailed

    /* Add the mutex semaphores to the muxwait. */
    call SemMuxwaitAdd !._muxwait.1, !._mutex.1
    if result \= 0 then signal CallFailed
    call SemMuxwaitAdd !._muxwait.1, !._mutex.2
    if result \= 0 then signal CallFailed

    /* Adding an event semaphore should fail. */
    call SemMuxwaitAdd !._muxwait.1, !._event.1
    if result \= 292 then signal CallFailed

    /* Create an unnamed muxwait semaphore. */
    call SemMuxwaitCreate '!._muxwait.2', , 'Or'
    if result \= 0 then signal CallFailed

    /* Add the event semaphores to the muxwait. */
    call SemMuxwaitAdd !._muxwait.2, !._event.1
    if result \= 0 then signal CallFailed
    call SemMuxwaitAdd !._muxwait.2, !._event.2
    if result \= 0 then signal CallFailed

    /* Adding a mutex semaphore should fail. */
    call SemMuxwaitAdd !._muxwait.2, !._mutex.1
    if result \= 292 then signal CallFailed

    /* Create a context for the thread. */
    call IPCContextCreate '!._context.1'
    if result \= 0 then signal CallFailed

    /* Create the collaborating thread. */
    call ProcCreateThread !._context.1, !._source,,
        'call SemaphoreThread' !._event.2',' !._mutex.2',' !._muxwait.2
    if result \= 0 then signal CallFailed

    /* Create a single timer and wait for a ms. */
    call SemStartTimer '!._timer.1', 100, !._event.1
    if result \= 0 then signal CallFailed
    call SemEventWait !._event.1, 500
    if result \= 0 then signal CallFailed
    call SemEventReset !._event.1
    if result \= 0 then signal CallFailed
    call SemStopTimer !._timer.1
    if result \= 326 then signal CallFailed

    /* Again with explicit type. */
    call SemStartTimer '!._timer.1', 100, !._event.1, 'Single'
    if result \= 0 then signal CallFailed
    call SemEventWait !._event.1, 500
    if result \= 0 then signal CallFailed
    call SemEventReset !._event.1
    if result \= 0 then signal CallFailed
    call SemStopTimer !._timer.1
    if result \= 326 then signal CallFailed

    /* Create a repeat timer and wait for a ms. */
    call SemStartTimer '!._timer.1', 100, !._event.1, 'Repeat'
    if result \= 0 then signal CallFailed

    /* Get at least 3 posts. */
    do posts = 0 until posts >= 3
        call SemEventWait !._event.1, 500
        if result \= 0 then signal CallFailed
        call SemEventReset !._event.1, 'postCount'
        if result \= 0 then signal CallFailed
        posts = posts + postCount
    end

    /* Stop the timer. */
    call SemStopTimer !._timer.1
    if result \= 0 then signal CallFailed
    !._timer = ''

    /* Make sure the event is reset. */
    call SemEventReset !._event.1
    if result \= 0 & result \= 300 then signal CallFailed

    /* The event should still be reset. */
    call SemEventQuery !._event.2, 'postCount'
    if result \= 0 then signal CallFailed
    if postCount \= 0 then CheckFailed

    /* Release the mutex. */
    call SemMutexRelease !._mutex.2
    if result \= 0 then signal CallFailed

    /* Get a timeout value. */
    timeout = !._CFG._Semaphore._Timeout
    if timeout = '' | \DataType(timeout, 'W') then signal Config

    /* Wait for the thread to post the event. */
    call SemEventWait !._event.2, timeout * 1000
    if result \= 0 then signal CallFailed

    /* Wait for the thread to release the mutex. */
    call SemMutexRequest !._mutex.2, timeout * 1000
    if result \= 0 then signal CallFailed

    /* Release the mutex. */
    call SemMutexRelease !._mutex.2
    if result \= 0 then signal CallFailed

    /* Reset the event. */
    call SemEventReset !._event.2
    if result \= 0 then signal CallFailed

    /* Check the mutex muxwait. */
    call SemMuxwaitWait !._muxwait.1, 0
    if result \= 640 then signal CallFailed

    /* Check the event muxwait. */
    call SemMuxwaitWait !._muxwait.2, 0
    if result \= 640 then signal CallFailed

    /* Post the named event. */
    call SemEventPost !._event.1
    if result \= 0 then signal CallFailed

    /* The mutex muxwait wait should now succeed. */
    call SemMuxwaitWait !._muxwait.1, timeout * 1000
    if result \= 0 then signal CallFailed

    /* The event muxwait wait should now succeed. */
    call SemMuxwaitWait !._muxwait.2, timeout * 1000
    if result \= 0 then signal CallFailed

    /* Release both mutexes. */
    call SemMutexRelease !._mutex.1
    if result \= 0 then signal CallFailed
    call SemMutexRelease !._mutex.2
    if result \= 0 then signal CallFailed

    /* Wait for completion of collaborating thread. */
    call IPCContextWait !._context.1
    if result \= 0 then signal CallFailed

    /* Close the context. */
    call IPCContextClose !._context.1
    if result \= 0 then signal CallFailed
    !._context.1 = ''

    /* Close the semaphores. */
    call SemEventClose !._event.1
    if result \= 0 then signal CallFailed
    !._event.1 = ''
    call SemEventClose !._event.2
    if result \= 0 then signal CallFailed
    !._event.2 = ''
    call SemMutexClose !._mutex.1
    if result \= 0 then signal CallFailed
    !._mutex.1 = ''
    call SemMutexClose !._mutex.2
    if result \= 0 then signal CallFailed
    !._mutex.2 = ''
    call SemmuxwaitClose !._muxwait.1
    if result \= 0 then signal CallFailed
    !._muxwait.1 = ''
    call SemmuxwaitClose !._muxwait.2
    if result \= 0 then signal CallFailed
    !._muxwait.2 = ''

    /* Resources released. */
    !._event.0 = ''
    !._muxwait.0 = ''
    !._mutex.0 = ''
    !._context.0 = ''
    !._timer.0 = ''

    say 'Semaphore operations test completed.'
    say

    return



