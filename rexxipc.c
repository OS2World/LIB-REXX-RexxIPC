// $RCSfile: rexxipc.c,v $

// $Title: Rexx Inter-Process Communication API. $

// Copyright (c) Serge Brisson 1994, 1995.

#define INCL_RXFUNC
#define INCL_DOSPROCESS
#define INCL_DOSERRORS
#include <rexxsaa.h>
#include <stdlib.h>

#include "rxapiutl.h"
#include "rexxipc.h"
#include "rexxsem.h"


// Identification of the API.

#define IPC_PRODUCER "SFB"
#define IPC_PRODUCT "RexxIPC"
#define IPC_MAJOR "1"
#define IPC_MINOR "30"
#define IPC_REVISION "001"
#define IPC_LOCAL ""

#ifdef NDEBUG
#define IPC_DEBUG ""
#else
#define IPC_DEBUG "D"
#endif

#define IPC_VERSION IPC_PRODUCER " " IPC_PRODUCT \
                    " V" IPC_MAJOR "." IPC_MINOR \
                    "-" IPC_REVISION IPC_LOCAL IPC_DEBUG


// Name of the DLL for Load.

#define IPC_DLL_NAME "REXXIPC"


// Return values to REXX.

#define IPC_OK REXXAPI_OK
#define IPC_BADPARAM REXXAPI_BADPARAM
#define IPC_NOMEM REXXAPI_NOMEM


// REXX functions entry points:
// synchronize with REXXIPC.DEF.

RexxFunctionHandler IPCContextClose;
RexxFunctionHandler IPCContextCreate;
RexxFunctionHandler IPCContextQuery;
RexxFunctionHandler IPCContextResult;
RexxFunctionHandler IPCContextWait;
RexxFunctionHandler IPCLoadFuncs;
RexxFunctionHandler IPCDropFuncs;
RexxFunctionHandler IPCVersion;
RexxFunctionHandler PipeLoadFuncs;
RexxFunctionHandler PipeDropFuncs;
RexxFunctionHandler ProcLoadFuncs;
RexxFunctionHandler ProcDropFuncs;
RexxFunctionHandler QueueLoadFuncs;
RexxFunctionHandler QueueDropFuncs;
RexxFunctionHandler SemLoadFuncs;
RexxFunctionHandler SemDropFuncs;


// IPCContext structure.

struct IPCContext
{
    volatile TID thread;
    ULONG suppliedSem;
    ULONG ownSem;
    volatile APIRET rc;
    RXSTRING result;
    ULONG size;
    PVOID info;
    BOOL keep;
};


// RCS identification.

static char const copyright[] =
{
    "$Copyright: (c) Serge Brisson 1994, 1995. $"
};
static char const rcsid[] =
{
    "$Id: rexxipc.c,v 1.8 1997/04/26 13:09:44 SFB Exp $"
};


// Function table for Load/Drop.

static RxFncEntry RxFncTable[] =
{
    {"IPCContextClose", "IPCContextClose"},
    {"IPCContextCreate", "IPCContextCreate"},
    {"IPCContextQuery", "IPCContextQuery"},
    {"IPCContextResult", "IPCContextResult"},
    {"IPCContextWait", "IPCContextWait"},
    {"IPCDropFuncs", "IPCDropFuncs"},
    {"IPCVersion", "IPCVersion"},
    {"PipeLoadFuncs", "PipeLoadFuncs"},
    {"ProcLoadFuncs", "ProcLoadFuncs"},
    {"QueueLoadFuncs", "QueueLoadFuncs"},
    {"SemLoadFuncs", "SemLoadFuncs"}
};


// IPCLoadFuncs -- Register all the functions with REXX.
//
//      Result: none
//
#pragma handler(IPCLoadFuncs)
//
ULONG IPCLoadFuncs(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    if (argc > 0) return IPC_BADPARAM;

    result->strlength = 0;

    LoadRxFuncs(
        RxFncTable,
        sizeof(RxFncTable) / sizeof(RxFncEntry),
        IPC_DLL_NAME);

    PipeLoadFuncs(name, argc, args, queue, result);
    ProcLoadFuncs(name, argc, args, queue, result);
    QueueLoadFuncs(name, argc, args, queue, result);
    SemLoadFuncs(name, argc, args, queue, result);

    return IPC_OK;
}


// IPCDropFuncs -- Deregister all the functions with REXX.
//
//      Result: none
//
#pragma handler(IPCDropFuncs)
//
ULONG IPCDropFuncs(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    if (argc > 0 ) return IPC_BADPARAM;

    result->strlength = 0;

    DropRxFuncs(
        RxFncTable,
        sizeof(RxFncTable) / sizeof(RxFncEntry));

    PipeDropFuncs(name, argc, args, queue, result);
    ProcDropFuncs(name, argc, args, queue, result);
    QueueDropFuncs(name, argc, args, queue, result);
    SemDropFuncs(name, argc, args, queue, result);

    return IPC_OK;
}


// IPCContextClose -- Close an IPC Context.
//
//      Handle: handle
//
//      Result: return code
//
#pragma handler(IPCContextClose)
//
ULONG IPCContextClose(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    ULONG handle;
    ULONG cc;

    if (argc != 1 ) return IPC_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return IPC_BADPARAM;

    IPCContext_Close((PIPCContext)handle);

    cc = UnsignedToRxResult(NO_ERROR, result);
    return cc;
}


// IPCContextCreate -- Create an IPC Context.
//
//      HandleVar: variable name
//      SemHandle: event semaphore handle []
//
//      Result: return code
//
#pragma handler(IPCContextCreate)
//
ULONG IPCContextCreate(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    PRXSTRING handleVar;
    ULONG semHandle;
    PIPCContext context;
    ULONG cc;

    if (argc < 1 || argc > 2 ) return IPC_BADPARAM;

    if (!RxStringIsPresent(args + 0)) return IPC_BADPARAM;
    handleVar = args + 0;

    if (argc > 1 && RxStringIsPresent(args + 1)) {
        if (!RxStringToUnsigned(args + 1, &semHandle)) return IPC_BADPARAM;
    }
    else semHandle = NULLHANDLE;

    context = IPCContext_Create(semHandle, TRUE);
    if (context == NULL) return IPC_NOMEM;

    UnsignedToRxVariable((ULONG)context, handleVar);

    cc = UnsignedToRxResult(NO_ERROR, result);
    return cc;
}


// IPCContextQuery -- Query an IPC Context.
//
//      Handle: handle
//      ThreadVar: variable name []
//
//      Result: return code
//
#pragma handler(IPCContextQuery)
//
ULONG IPCContextQuery(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    ULONG handle;
    PRXSTRING threadVar;
    APIRET rc;
    TID thread;
    PIPCContext context;
    ULONG cc;

    if (argc < 1 || argc > 2) return IPC_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return IPC_BADPARAM;

    if (argc > 1 && RxStringIsPresent(args + 1)) threadVar = args + 1;
    else threadVar = NULL;

    context = (PIPCContext)handle;

    DosEnterCritSec();
    {
        thread = context->thread;
        rc = thread == 0? context->rc: ERROR_BUSY;
    }
    DosExitCritSec();

    if (threadVar != NULL) {
        UnsignedToRxVariable(context->thread, threadVar);
    }

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// IPCContextResult -- Get a IPC Context result.
//
//      Handle: handle
//
//      Result: result
//
#pragma handler(IPCContextResult)
//
ULONG IPCContextResult(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    ULONG handle;
    PIPCContext context;
    RXSTRING threadResult;
    ULONG cc;

    if (argc != 1) return IPC_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return IPC_BADPARAM;

    context = (PIPCContext)handle;

    if (context->thread == 0) {
        threadResult.strptr = context->result.strptr;
        threadResult.strlength = context->result.strlength;
    }
    else {
        threadResult.strptr = NULL;
        threadResult.strlength = 0;
    }

    cc = StringToRxResult(threadResult.strptr, threadResult.strlength, result);
    return cc;
}


// IPCContextWait -- Wait for an IPC Context.
//
//      Handle: handle
//
//      Result: return code
//
#pragma handler(IPCContextWait)
//
ULONG IPCContextWait(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    ULONG handle;
    APIRET rc;
    PIPCContext context;
    TID thread;
    ULONG cc;

    if (argc != 1 ) return IPC_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return IPC_BADPARAM;

    context = (PIPCContext)handle;
    thread = context->thread;

    if (thread != 0) {
        rc = DosWaitThread(&thread, DCWW_WAIT);
    }
    else rc = 0;

    if (rc == 0) rc = context->rc;

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// IPCVersion -- Supply the REXX IPC API Version.
//
//      Result: SFB RexxIPC n.nn-nnn
//
#pragma handler(IPCVersion)
//
ULONG IPCVersion(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    if (argc > 0 ) return IPC_BADPARAM;

    StringToRxResult(IPC_VERSION, sizeof(IPC_VERSION) - 1, result);

    return IPC_OK;
}


// IPCContext internal routines.

// IPCContext_Alloc -- Allocate context space.
//
//      context: pointer to context
//      size: requested size
//
//      return: pointer to allocated space
//      errors: return NULL if context busy or no memory available
//
//      callers: thread starters
//
PVOID IPCContext_Alloc(
    PIPCContext context,
    ULONG size)
{
    if (context->thread != 0) return NULL;

    if (size > context->size) {
        if (context->size > 0) free(context->info);
        context->size = 0;

        context->info = malloc(size);
        if (context->info != NULL) context->size = size;
    }

    return context->info;
}


// IPCContext_Close -- Close and free context.
//
//      context: pointer to context
//
//      return: nothing
//
//      callers: thread starters or started threads (signal)
//
void IPCContext_Close(
    PIPCContext context)
{
    DosEnterCritSec();
    {
        if (context->thread != 0) {
            DosKillThread(context->thread);
        }
    }
    DosExitCritSec();

    SemEvent_Close(context->ownSem);

    if (context->size > 0) free(context->info);
    FreeRxString(&context->result);

    free(context);
}


// IPCContext_Create -- Create a context.
//
//      semHandle: event semaphore handle (may be 0)
//      keep: true to keep the context after signal
//
//      return: pointer to context
//
//      callers: thread starters
//
PIPCContext IPCContext_Create(
    ULONG semHandle,
    BOOL keep)
{
    PIPCContext context;

    context = malloc(sizeof(IPCContext));

    if (context != NULL) {
        context->thread = 0;
        context->suppliedSem = semHandle;
        context->rc = 0;
        context->result.strptr = NULL;
        context->result.strlength = 0;
        context->size = 0;
        context->info = NULL;
        context->keep = keep;

        SemEvent_Create(&context->ownSem);
    }

    return context;
}


// IPCContext_Info -- Return pointer to context space.
//
//      context: pointer to context
//
//      return: pointer to space
//
//      callers: started threads
//
PVOID IPCContext_Info(
    PIPCContext context)
{
    return context->info;
}


// IPCContext_IsBusy -- Return TRUE if context is busy.
//
//      context: pointer to context
//
//      return: TRUE if context is busy
//
//      callers: thread starters
//
BOOL IPCContext_IsBusy(
    PIPCContext context)
{
    return context->thread != 0;
}


// IPCContext_Result -- Return a pointer to result.
//
//      context: pointer to context
//
//      return: pointer to the result field
//
//      callers: REXX threads
//
PRXSTRING IPCContext_Result(
    PIPCContext context)
{
    return &context->result;
}


// IPCContext_Signal -- Signal completion.
//
//      context: pointer to context
//      rc: return code of the requested operation
//
//      callers: started threads
//
void IPCContext_Signal(
    PIPCContext context,
    APIRET rc)
{
    ULONG suppliedSem = context->suppliedSem;

    context->rc = rc;
    context->thread = 0;

    if (suppliedSem != NULLHANDLE) SemEvent_Post(suppliedSem);

    if (!context->keep) IPCContext_Close(context);
}


// IPCContext_Start -- Start a thread.
//
//      context: pointer to context
//      function: function to call
//
//      return: ERROR_BUSY or return code from DosStartThread
//
//      callers: thread starters
//
APIRET IPCContext_Start(
    PIPCContext context,
    VOID APIENTRY function(ULONG))
{
    ULONG suppliedSem = context->suppliedSem;
    APIRET rc;

    if (context->thread != 0) return ERROR_BUSY;

    if (suppliedSem != NULLHANDLE) SemEvent_Reset(suppliedSem);

    SemEvent_Reset(context->ownSem);

    rc = DosCreateThread(
        (PTID)&context->thread,
        function,
        (ULONG)context,
        0,
        8192);

    SemEvent_Wait(context->ownSem);

    return rc;
}


// IPCContext_Started -- The thread has started.
//
//      context: pointer to context
//
//      return: none
//
//      callers: started threads
//
void IPCContext_Started(
    PIPCContext context)
{
    DosSetPriority(PRTYS_THREAD, PRTYC_NOCHANGE, +1, context->thread);

    SemEvent_Post(context->ownSem);
}


// $Log: rexxipc.c,v $
// Revision 1.8  1997/04/26 13:09:44  SFB
// Bug in QueuePeek found and corrected.
//
// Revision 1.7  1996/01/14 11:54:53  SFB
// Adds Queues.
// V1.30-000.
//
// Revision 1.6  1995/09/27 07:51:28  SFB
// Setup condition handling.
//
// Revision 1.5  1995/09/17 13:00:47  SFB
// Minor adjustements for V1.21.
//
// Revision 1.4  1995/06/24 12:40:46  SFB
// Set version to 1.20-000.
//
// Revision 1.3  1995/05/22 21:07:22  SFB
// Added thread parameter to IPCContextQuery.
// Added IPCContextResult.
// Rearranged IPC Context processing for ProcCreateThread.
//
// Revision 1.2  1994/07/30  10:46:26  SFB
// Adjustments for V1.1-0
//
// Revision 1.1  1994/05/12  21:10:03  SFB
// Initial revision

