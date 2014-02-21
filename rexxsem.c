// $RCSfile: rexxsem.c,v $

// $Title: RexxIPC semaphores API. $

// Copyright (c) Serge Brisson 1994, 1995.

#define INCL_RXFUNC
#define INCL_DOSDATETIME
#define INCL_DOSSEMAPHORES
#define INCL_DOSERRORS
#include <rexxsaa.h>

#include "rxapiutl.h"
#include "rexxsem.h"


// Name of the DLL for Load.

#define SEM_DLL_NAME "REXXIPC"


// Return values to REXX.

#define SEM_OK REXXAPI_OK
#define SEM_BADPARAM REXXAPI_BADPARAM


// REXX functions entry points:
// synchronize with REXXIPC.DEF.

RexxFunctionHandler SemLoadFuncs;
RexxFunctionHandler SemDropFuncs;
RexxFunctionHandler SemEventClose;
RexxFunctionHandler SemEventCreate;
RexxFunctionHandler SemEventOpen;
RexxFunctionHandler SemEventPost;
RexxFunctionHandler SemEventQuery;
RexxFunctionHandler SemEventReset;
RexxFunctionHandler SemEventWait;
RexxFunctionHandler SemMutexClose;
RexxFunctionHandler SemMutexCreate;
RexxFunctionHandler SemMutexOpen;
RexxFunctionHandler SemMutexQuery;
RexxFunctionHandler SemMutexRelease;
RexxFunctionHandler SemMutexRequest;
RexxFunctionHandler SemMuxwaitAdd;
RexxFunctionHandler SemMuxwaitClose;
RexxFunctionHandler SemMuxwaitCreate;
RexxFunctionHandler SemMuxwaitRemove;
RexxFunctionHandler SemMuxwaitOpen;
RexxFunctionHandler SemMuxwaitWait;
RexxFunctionHandler SemStartTimer;
RexxFunctionHandler SemStopTimer;


// RCS identification.

static char const rcsid[] =
{
    "$Id: rexxsem.c,v 1.5 1995/09/27 07:51:28 SFB Rel $"
};


// Function table for Load/Drop.

static RxFncEntry RxFncTable[] =
{
    {"SemDropFuncs", "SemDropFuncs"},
    {"SemEventClose", "SemEventClose"},
    {"SemEventCreate", "SemEventCreate"},
    {"SemEventOpen", "SemEventOpen"},
    {"SemEventPost", "SemEventPost"},
    {"SemEventQuery", "SemEventQuery"},
    {"SemEventReset", "SemEventReset"},
    {"SemEventWait", "SemEventWait"},
    {"SemMutexClose", "SemMutexClose"},
    {"SemMutexCreate", "SemMutexCreate"},
    {"SemMutexOpen", "SemMutexOpen"},
    {"SemMutexQuery", "SemMutexQuery"},
    {"SemMutexRelease", "SemMutexRelease"},
    {"SemMutexRequest", "SemMutexRequest"},
    {"SemMuxwaitAdd", "SemMuxwaitAdd"},
    {"SemMuxwaitClose", "SemMuxwaitClose"},
    {"SemMuxwaitCreate", "SemMuxwaitCreate"},
    {"SemMuxwaitRemove", "SemMuxwaitRemove"},
    {"SemMuxwaitOpen", "SemMuxwaitOpen"},
    {"SemMuxwaitWait", "SemMuxwaitWait"},
    {"SemStartTimer", "SemStartTimer"},
    {"SemStopTimer", "SemStopTimer"}
};


// SemLoadFuncs -- Register all the functions with REXX.
//
//      Result: none
//
#pragma handler(SemLoadFuncs)
//
ULONG SemLoadFuncs(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    if (argc > 0) return SEM_BADPARAM;

    result->strlength = 0;

    LoadRxFuncs(
        RxFncTable,
        sizeof(RxFncTable) / sizeof(RxFncEntry),
        SEM_DLL_NAME);

    return SEM_OK;
}


// SemDropFuncs -- Deregister all the functions with REXX.
//
//      Result: none
//
#pragma handler(SemDropFuncs)
//
ULONG SemDropFuncs(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    if (argc > 0 ) return SEM_BADPARAM;

    result->strlength = 0;

    DropRxFuncs(
        RxFncTable,
        sizeof(RxFncTable) / sizeof(RxFncEntry));

    return SEM_OK;
}


// SemEventClose -- Close an Event Semaphore.
//
//      Handle: handle
//
//      Result: return code
//
#pragma handler(SemEventClose)
//
ULONG SemEventClose(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HEV handle;
    APIRET rc;
    ULONG cc;

    if (argc != 1) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return SEM_BADPARAM;

    rc = DosCloseEventSem(handle);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemEventCreate -- Create an Event Semaphore.
//
//      HandleVar: variable name
//      Name: '\SEM32\'name []
//      Initial: (0 | 1) [0]
//
//      Result: return code
//
#pragma handler(SemEventCreate)
//
ULONG SemEventCreate(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    PRXSTRING handleVar;
    PSZ semName;
    ULONG semInitial;
    HEV handle;
    ULONG flattr = 0;
    APIRET rc;
    ULONG cc;

    if (argc < 1 || argc > 3) return SEM_BADPARAM;

    if (!RxStringIsPresent(args + 0)) return SEM_BADPARAM;
    handleVar = args + 0;

    if (argc > 1 && RxStringIsPresent(args + 1)) {
        if (RxStringIsAbbrev(args + 1, "Shared", 1)) {
            flattr |= DC_SEM_SHARED;
            semName = NULL;
        }
        else semName = args[1].strptr;
    }
    else semName = NULL;

    if (argc > 2 && RxStringIsPresent(args + 2)) {
        if (!RxStringToUnsigned(args + 2, &semInitial)) return SEM_BADPARAM;
        if (semInitial > 1) return SEM_BADPARAM;
    }
    else semInitial = 0;

    rc = DosCreateEventSem(semName, &handle, flattr, semInitial);

    if (rc == NO_ERROR) UnsignedToRxVariable(handle, handleVar);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemEventOpen -- Open an Event Semaphore.
//
//      HandleVar: variable name
//      Name: '\SEM32\'name
// or
//      Handle: shared semaphore handle
//
//      Result: return code
//
#pragma handler(SemEventOpen)
//
ULONG SemEventOpen(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    PRXSTRING handleVar;
    PSZ semName;
    HEV handle;
    APIRET rc;
    ULONG cc;

    if (argc == 2) {
        if (!RxStringIsPresent(args + 0)) return SEM_BADPARAM;
        handleVar = args + 0;

        if (!RxStringIsPresent(args + 1)) return SEM_BADPARAM;
        semName = args[1].strptr;

        handle = 0;
    }
    else if (argc == 1) {
        if (!RxStringToUnsigned(args + 0, &handle)) return SEM_BADPARAM;

        handleVar = NULL;
        semName = NULL;
    }
    else return SEM_BADPARAM;

    rc = DosOpenEventSem(semName, &handle);

    if (rc == NO_ERROR && handleVar != NULL) {
        UnsignedToRxVariable(handle, handleVar);
    }

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemEventPost -- Post an Event.
//
//      Handle: handle
//
//      Result: return code
//
#pragma handler(SemEventPost)
//
ULONG SemEventPost(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HEV handle;
    APIRET rc;
    ULONG cc;

    if (argc != 1) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return SEM_BADPARAM;

    rc = DosPostEventSem(handle);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemEventQuery -- Query an Event Semaphore.
//
//      Handle: handle
//      PostCountVar: variable name
//
//      Result: return code
//
#pragma handler(SemEventQuery)
//
ULONG SemEventQuery(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    PRXSTRING countVar;
    HEV handle;
    ULONG ulPostCt;
    APIRET rc;
    ULONG cc;

    if (argc != 2) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return SEM_BADPARAM;

    if (!RxStringIsPresent(args + 1)) return SEM_BADPARAM;
    countVar = args + 1;

    rc = DosQueryEventSem(handle, &ulPostCt);

    if (rc == NO_ERROR) UnsignedToRxVariable(ulPostCt, countVar);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemEventReset -- Reset an Event Semaphore.
//
//      Handle: handle
//      PostCount: variable name []
//
//      Result: return code
//
#pragma handler(SemEventReset)
//
ULONG SemEventReset(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HEV handle;
    ULONG ulPostCt;
    APIRET rc;
    ULONG cc;

    if (argc < 1 || argc > 2) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return SEM_BADPARAM;

    rc = DosResetEventSem(handle, &ulPostCt);

    if (rc == NO_ERROR && argc > 1 && RxStringIsPresent(args + 1)) {
        UnsignedToRxVariable(ulPostCt, args + 1);
    }

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemEventWait -- Wait for an Event.
//
//      Handle: handle
//      TimeOut: (ms) [-1]
//
//      Result: return code
//
#pragma handler(SemEventWait)
//
ULONG SemEventWait(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HEV handle;
    LONG timeOut;
    APIRET rc;
    ULONG cc;

    if (argc < 1 || argc > 2) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return SEM_BADPARAM;

    if (argc > 1 && RxStringIsPresent(args + 1)) {
        if (!RxStringToSigned(args + 1, &timeOut)) return SEM_BADPARAM;
    }
    else timeOut = -1;

    rc = DosWaitEventSem(handle, timeOut);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemMutexClose -- Close a Mutex Semaphore.
//
//      Handle: handle
//
//      Result: return code
//
#pragma handler(SemMutexClose)
//
ULONG SemMutexClose(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HMTX handle;
    APIRET rc;
    ULONG cc;

    if (argc != 1) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return SEM_BADPARAM;

    rc = DosCloseMutexSem(handle);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemMutexCreate -- Create a Mutex Semaphore.
//
//      HandleVar: variable name
//      Name: '\SEM32\'name
//      Initial: (0 | 1) [0]
//
//      Result: return code
//
#pragma handler(SemMutexCreate)
//
ULONG SemMutexCreate(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    PRXSTRING handleVar;
    PSZ semName;
    ULONG semInitial;
    HMTX handle;
    ULONG flattr = 0;
    APIRET rc;
    ULONG cc;

    if (argc < 1 || argc > 3) return SEM_BADPARAM;

    if (!RxStringIsPresent(args + 0)) return SEM_BADPARAM;
    handleVar = args + 0;

    if (argc > 1 && RxStringIsPresent(args + 1)) {
        if (RxStringIsAbbrev(args + 1, "Shared", 1)) {
            flattr |= DC_SEM_SHARED;
            semName = NULL;
        }
        else semName = args[1].strptr;
    }
    else semName = NULL;

    if (argc > 2 && RxStringIsPresent(args + 2)) {
        if (!RxStringToUnsigned(args + 2, &semInitial)) return SEM_BADPARAM;
        if (semInitial > 1) return SEM_BADPARAM;
    }
    else semInitial = 0;

    rc = DosCreateMutexSem(semName, &handle, flattr, semInitial);

    if (rc == NO_ERROR) UnsignedToRxVariable(handle, handleVar);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemMutexOpen -- Open a Mutex Semaphore.
//
//      HandleVar: variable name
//      Name: '\SEM32\'name
// or
//      Handle: shared semaphore handle
//
//      Result: return code
//
#pragma handler(SemMutexOpen)
//
ULONG SemMutexOpen(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    PRXSTRING handleVar;
    PSZ semName;
    HMTX handle;
    APIRET rc;
    ULONG cc;

    if (argc == 2) {
        if (!RxStringIsPresent(args + 0)) return SEM_BADPARAM;
        handleVar = args + 0;

        if (!RxStringIsPresent(args + 1)) return SEM_BADPARAM;
        semName = args[1].strptr;

        handle = 0;
    }
    else if (argc == 1) {
        if (!RxStringToUnsigned(args + 0, &handle)) return SEM_BADPARAM;

        handleVar = NULL;
        semName = NULL;
    }
    else return SEM_BADPARAM;

    rc = DosOpenMutexSem(semName, &handle);

    if (rc == NO_ERROR && handleVar != NULL) {
        UnsignedToRxVariable(handle, handleVar);
    }

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemMutexQuery -- Query a Mutex Semaphore.
//
//      Handle: handle
//      ProcessId: variable name []
//      ThreadId: variable name []
//      PostCount: variable name []
//
//      Result: return code
//
#pragma handler(SemMutexQuery)
//
ULONG SemMutexQuery(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HMTX handle;
    PID pidOwner = 0;
    TID tidOwner = 0;
    ULONG ulCount;
    APIRET rc;
    ULONG cc;

    if (argc < 1 || argc > 4) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return SEM_BADPARAM;

    rc = DosQueryMutexSem(handle, &pidOwner, &tidOwner, &ulCount);

    if (rc == NO_ERROR) {
        if (argc > 1 && RxStringIsPresent(args + 1)) {
            UnsignedToRxVariable(pidOwner, args + 1);
        }

        if (argc > 2 && RxStringIsPresent(args + 2)) {
            UnsignedToRxVariable(tidOwner, args + 2);
        }

        if (argc > 3 && RxStringIsPresent(args + 3)) {
            UnsignedToRxVariable(ulCount, args + 3);
        }
    }

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemMutexRelease -- Release a Mutex Semaphore.
//
//      Handle: handle
//
//      Result: return code
//
#pragma handler(SemMutexRelease)
//
ULONG SemMutexRelease(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HMTX handle;
    APIRET rc;
    ULONG cc;

    if (argc != 1) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return SEM_BADPARAM;

    rc = DosReleaseMutexSem(handle);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemMutexRequest -- Request a Mutex Semaphore.
//
//      Handle: handle
//      TimeOut: (ms) [-1]
//
//      Result: return code
//
#pragma handler(SemMutexRequest)
//
ULONG SemMutexRequest(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HMTX handle;
    LONG timeOut;
    APIRET rc;
    ULONG cc;

    if (argc < 1 || argc > 2) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return SEM_BADPARAM;

    if (argc > 1 && RxStringIsPresent(args + 1)) {
        if (!RxStringToSigned(args + 1, &timeOut)) return SEM_BADPARAM;
    }
    else timeOut = -1;

    rc = DosRequestMutexSem(handle, timeOut);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemMuxwaitAdd -- Add a semaphore to a Muxwait Semaphore.
//
//      Handle: handle
//      Semaphore: semaphore handle
//      User: User value (unsigned number) [0]
//
//      Result: return code
//
#pragma handler(SemMuxwaitAdd)
//
ULONG SemMuxwaitAdd(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HMUX handle;
    ULONG sem;
    ULONG user;
    SEMRECORD semRecord;
    APIRET rc;
    ULONG cc;

    if (argc < 2 || argc > 3) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 1, &sem)) return SEM_BADPARAM;

    if (argc > 2 && RxStringIsPresent(args + 2)) {
        if (!RxStringToUnsigned(args + 2, &user)) return SEM_BADPARAM;
    }
    else user = 0;

    semRecord.hsemCur = (HSEM) sem;
    semRecord.ulUser = user;

    rc = DosAddMuxWaitSem(handle, &semRecord);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemMuxwaitClose -- Close a Muxwait Semaphore.
//
//      Handle: handle
//
//      Result: return code
//
#pragma handler(SemMuxwaitClose)
//
ULONG SemMuxwaitClose(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HMUX handle;
    APIRET rc;
    ULONG cc;

    if (argc != 1) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return SEM_BADPARAM;

    rc = DosCloseMuxWaitSem(handle);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemMuxwaitCreate -- Create a Muxwait Semaphore.
//
//      HandleVar: variable name
//      Name: '\SEM32\'name
//      Mode: ('And' | 'Or')
//
//      Result: return code
//
#pragma handler(SemMuxwaitCreate)
//
ULONG SemMuxwaitCreate(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    PRXSTRING handleVar;
    PSZ semName;
    HMUX handle;
    ULONG flattr = 0;
    APIRET rc;
    ULONG cc;

    if (argc != 3) return SEM_BADPARAM;

    if (!RxStringIsPresent(args + 0)) return SEM_BADPARAM;
    handleVar = args + 0;

    if (argc > 1 && RxStringIsPresent(args + 1)) {
        if (RxStringIsAbbrev(args + 1, "Shared", 1)) {
            flattr |= DC_SEM_SHARED;
            semName = NULL;
        }
        else semName = args[1].strptr;
    }
    else semName = NULL;

    if (RxStringIsAbbrev(args + 2, "And", 1)) flattr |= DCMW_WAIT_ALL;
    else if (RxStringIsAbbrev(args + 2, "Or", 1)) flattr |= DCMW_WAIT_ANY;
    else return SEM_BADPARAM;

    rc = DosCreateMuxWaitSem(semName, &handle, 0, NULL, flattr);

    if (rc == NO_ERROR) UnsignedToRxVariable(handle, handleVar);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemMuxwaitOpen -- Open a Muxwait Semaphore.
//
//      HandleVar: variable name
//      Name: '\SEM32\'name
// or
//      Handle: shared semaphore handle
//
//      Result: return code
//
#pragma handler(SemMuxwaitOpen)
//
ULONG SemMuxwaitOpen(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    PRXSTRING handleVar;
    PSZ semName;
    HMUX handle;
    APIRET rc;
    ULONG cc;

    if (argc == 2) {
        if (!RxStringIsPresent(args + 0)) return SEM_BADPARAM;
        handleVar = args + 0;

        if (!RxStringIsPresent(args + 1)) return SEM_BADPARAM;
        semName = args[1].strptr;

        handle = 0;
    }
    else if (argc == 1) {
        if (!RxStringToUnsigned(args + 0, &handle)) return SEM_BADPARAM;

        handleVar = NULL;
        semName = NULL;
    }
    else return SEM_BADPARAM;

    rc = DosOpenMuxWaitSem(semName, &handle);

    if (rc == NO_ERROR && handleVar != NULL) {
        UnsignedToRxVariable(handle, handleVar);
    }

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemMuxwaitRemove -- Remove a semaphore from a Muxwait Semaphore.
//
//      Handle: handle
//      Semaphore: semaphore handle
//
//      Result: return code
//
#pragma handler(SemMuxwaitRemove)
//
ULONG SemMuxwaitRemove(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HMUX handle;
    ULONG sem;
    APIRET rc;
    ULONG cc;

    if (argc != 2) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 1, &sem)) return SEM_BADPARAM;

    rc = DosDeleteMuxWaitSem(handle, (HSEM) sem);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemMuxwaitWait -- Wait on a Muxwait Semaphore.
//
//      Handle: handle
//      TimeOut: (ms) [-1]
//      User: variable name for user value []
//
//      Result: return code
//
#pragma handler(SemMuxwaitWait)
//
ULONG SemMuxwaitWait(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HEV handle;
    LONG timeOut;
    ULONG user;
    APIRET rc;
    ULONG cc;

    if (argc < 1 || argc > 3) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return SEM_BADPARAM;

    if (argc > 1 && RxStringIsPresent(args + 1)) {
        if (!RxStringToSigned(args + 1, &timeOut)) return SEM_BADPARAM;
    }
    else timeOut = -1;

    rc = DosWaitMuxWaitSem(handle, timeOut, &user);

    if (rc == NO_ERROR && argc > 2 && RxStringIsPresent(args + 2)) {
        UnsignedToRxVariable(user, args + 2);
    }

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemStartTimer -- Start a Timer.
//
//      HandleVar: [variable name]
//      Interval: (ms)
//      SemHandle: event semaphore handle
//      Type: (Single | Repeat) [Single]
//
//      Result: return code
//
#pragma handler(SemStartTimer)
//
ULONG SemStartTimer(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HTIMER timerHandle;
    ULONG interval;
    HEV semHandle;
    BOOL repeat;
    APIRET rc;
    ULONG cc;

    if (argc < 3 || argc > 4) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 1, &interval)) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 2, &semHandle)) return SEM_BADPARAM;

    if (argc > 3 && RxStringIsPresent(args + 3)) {
        if (RxStringIsAbbrev(args + 3, "Repeated", 1)) repeat = TRUE;
        else if (RxStringIsAbbrev(args + 3, "Single", 1)) repeat = FALSE;
        else return SEM_BADPARAM;
    }
    else repeat = FALSE;

    if (repeat) rc = DosStartTimer(interval, (HSEM) semHandle, &timerHandle);
    else rc = DosAsyncTimer(interval, (HSEM) semHandle, &timerHandle);

    if (rc == NO_ERROR) {
        if (RxStringIsPresent(args + 0))
            UnsignedToRxVariable(timerHandle, args + 0);
    }

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// SemStopTimer -- Stop a Timer.
//
//      Handle: timer handle
//
//      Result: return code
//
#pragma handler(SemStopTimer)
//
ULONG SemStopTimer(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HTIMER handle;
    APIRET rc;
    ULONG cc;

    if (argc != 1) return SEM_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return SEM_BADPARAM;

    rc = DosStopTimer(handle);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// RexxSem internal routines.

APIRET SemEvent_Close
(
    ULONG handle
)
{
    APIRET rc;

    rc = DosCloseEventSem((HEV) handle);
    return rc;
}


APIRET SemEvent_Create
(
    PULONG handle
)
{
    APIRET rc;

    rc = DosCreateEventSem(NULL, (PHEV) handle, 0, 0);
    return rc;
}


APIRET SemEvent_Post
(
    ULONG handle
)
{
    APIRET rc;

    rc = DosPostEventSem((HEV) handle);
    return rc;
}


APIRET SemEvent_Reset
(
    ULONG handle
)
{
    ULONG ulPostCt;
    APIRET rc;

    rc = DosResetEventSem((HEV) handle, &ulPostCt);
    return rc;
}


APIRET SemEvent_Wait
(
    ULONG handle
)
{
    APIRET rc;

    rc = DosWaitEventSem((HEV) handle, SEM_INDEFINITE_WAIT);
    return rc;
}


// $Log: rexxsem.c,v $
// Revision 1.5  1995/09/27 07:51:28  SFB
// Setup condition handling.
//
// Revision 1.4  1995/09/17 13:23:45  SFB
// Use new RXAPIUTL names.
//
// Revision 1.3  1995/05/22 21:19:04  SFB
// Minor adjustments.
//
//
// Revision 1.2  1994/07/30  10:46:26  SFB
// Adjustments for V1.1-0
//
// Revision 1.1  1994/05/12  21:12:58  SFB
// Initial revision
//
