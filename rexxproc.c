// $RCSfile: rexxproc.c,v $

// $Title: RexxIPC processes API. $

// Copyright (c) Serge Brisson 1994, 1995.

#define INCL_RXFUNC
#define INCL_DOSEXCEPTIONS
#define INCL_DOSPROCESS
#define INCL_DOSERRORS
#include <rexxsaa.h>
#include <stdlib.h>
#include <string.h>
#include <float.h>

#include "rxapiutl.h"
#include "rexxipc.h"


// Name of the DLL for Load.

#define PROC_DLL_NAME "REXXIPC"


// Return values to REXX.

#define PROC_OK REXXAPI_OK
#define PROC_BADPARAM REXXAPI_BADPARAM
#define PROC_NOMEM REXXAPI_NOMEM


// REXX functions entry points:
// synchronize with REXXIPC.DEF.

RexxFunctionHandler ProcLoadFuncs;
RexxFunctionHandler ProcDropFuncs;
RexxFunctionHandler ProcCreateThread;
RexxFunctionHandler ProcGetThreadInfo;
RexxFunctionHandler ProcSendSignal;
RexxFunctionHandler ProcSetPriority;
RexxFunctionHandler ProcSetThreadPriority;
RexxFunctionHandler ProcSetTreePriority;


// ThreadContext structure.

typedef struct ThreadParams
{
    RXSTRING fileSpec;
    ULONG argc;
    PRXSTRING args;
}
    ThreadParams;


// RCS identification.

static char const rcsid[] =
{
    "$Id: rexxproc.c,v 1.5 1995/09/27 07:51:28 SFB Rel $"
};


// Function table for Load/Drop.

static RxFncEntry RxFncTable[] =
{
    {"ProcDropFuncs", "ProcDropFuncs"},
    {"ProcCreateThread", "ProcCreateThread"},
    {"ProcGetThreadInfo", "ProcGetThreadInfo"},
    {"ProcSendSignal", "ProcSendSignal"},
    {"ProcSetPriority", "ProcSetPriority"},
    {"ProcSetThreadPriority", "ProcSetThreadPriority"},
    {"ProcSetTreePriority", "ProcSetTreePriority"}
};


// Local prototypes.

static void Proc_EndThread(
    PIPCContext context,
    APIRET rc);

static ULONG Proc_SetPriority(
    ULONG scope,
    ULONG argc,
    PRXSTRING args,
    PRXSTRING result);

void APIENTRY Proc_Thread(
    ULONG context);


// ProcLoadFuncs -- Register all the functions with REXX.
//
//      Result: none
//
#pragma handler(ProcLoadFuncs)
//
ULONG ProcLoadFuncs(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    if (argc > 0) return PROC_BADPARAM;

    result->strlength = 0;

    LoadRxFuncs(
        RxFncTable,
        sizeof(RxFncTable) / sizeof(RxFncEntry),
        PROC_DLL_NAME);

    return PROC_OK;
}


// ProcDropFuncs -- Deregister all the functions with REXX.
//
//      Result: none
//
#pragma handler(ProcDropFuncs)
//
ULONG ProcDropFuncs(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    if (argc > 0) return PROC_BADPARAM;

    result->strlength = 0;

    DropRxFuncs(
        RxFncTable,
        sizeof(RxFncTable) / sizeof(RxFncEntry));

    return PROC_OK;
}


// ProcCreateThread -- Create and start a Thread.
//
//      Context: handle
//      Program: file name
//      Parameters: ...
//
//      Result: return code
//
#pragma handler(ProcCreateThread)
//
ULONG ProcCreateThread(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    ULONG handle;
    PIPCContext context;
    ThreadParams *params;
    ULONG size;
    ULONG arg;
    APIRET rc;
    ULONG cc;

    if (argc < 2) return PROC_BADPARAM;

    if (RxStringIsPresent(args + 0)) {
        if (!RxStringToUnsigned(args + 0, &handle)) return PROC_BADPARAM;
    }
    else handle = 0;

    if (!RxStringIsPresent(args + 1)) return PROC_BADPARAM;

    if (handle != 0) context = (PIPCContext)handle;
    else {
        context = IPCContext_Create(NULLHANDLE, FALSE);
        if (context == NULL) return PROC_NOMEM;
    }

    size = sizeof(ThreadParams) + (argc - 2) * sizeof(RXSTRING);
    params = IPCContext_Alloc(context, size);
    if (params == NULL) {
        IPCContext_Signal(context, ERROR_NOT_ENOUGH_MEMORY);
        return PROC_NOMEM;
    }
    memset(params, 0, size);
    params->args = (PRXSTRING)(params + 1);
    params->argc = argc - 2;

    rc = StringToRxResult(args[1].strptr, args[1].strlength, &params->fileSpec);

    if (rc == NO_ERROR) {
        for (arg = 0; arg < params->argc; ++arg) {
            rc = StringToRxResult(
                args[2 + arg].strptr,
                args[2 + arg].strlength,
                &params->args[arg]);
            if (rc != NO_ERROR) break;
        }
    }

    if (rc != NO_ERROR) {
        Proc_EndThread(context, ERROR_NOT_ENOUGH_MEMORY);
        return PROC_NOMEM;
    }

    rc = IPCContext_Start(context, Proc_Thread);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// ProcGetThreadInfo -- Get thread informations.
//
//      ThreadIdVar: variable name
//      PriorityClassVar: variable name
//      PriorityVar: variable name
//      ProcessIdVar: variable name
//      ParentProcessIdVar: variable name
//
//      Result: none
//
#pragma handler(ProcGetThreadInfo)
//
ULONG ProcGetThreadInfo(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    PTIB ptib;
    PPIB ppib;
    ULONG priorityClass;
    ULONG priority;
    PSZ className;

    if (argc > 5) return PROC_BADPARAM;

    DosGetInfoBlocks(&ptib, &ppib);

    priority = ptib->tib_ptib2->tib2_ulpri & 0xFF;
    priorityClass = ptib->tib_ptib2->tib2_ulpri >> 8;

    if (argc > 0 && RxStringIsPresent(args + 0)) {
        UnsignedToRxVariable(ptib->tib_ptib2->tib2_ultid, args + 0);
    }

    if (argc > 1 && RxStringIsPresent(args + 1)) {
        if (priorityClass == PRTYC_IDLETIME) className = "Idle";
        else if (priorityClass == PRTYC_REGULAR) className = "Regular";
        else if (priorityClass == PRTYC_FOREGROUNDSERVER) className = "Server";
        else if (priorityClass == PRTYC_TIMECRITICAL) className = "Critical";
        else className = NULL;

        if (className == NULL) UnsignedToRxVariable(priorityClass, args + 1);
        else StringToRxVariable(className, -1, args + 1);
    }

    if (argc > 2 && RxStringIsPresent(args + 2)) {
        UnsignedToRxVariable(priority, args + 2);
    }

    if (argc > 3 && RxStringIsPresent(args + 3)) {
        UnsignedToRxVariable(ppib->pib_ulpid, args + 3);
    }

    if (argc > 4 && RxStringIsPresent(args + 4)) {
        UnsignedToRxVariable(ppib->pib_ulppid, args + 4);
    }

    return PROC_OK;
}


// ProcSendSignal -- Send a Signal to a Process.
//
//      Id: Process Id
//      Type: 'Break' | 'Interrupt' | 'Kill'
//
//      Result: return code
//
#pragma handler(ProcSendSignal)
//
ULONG ProcSendSignal(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    PID pid;
    APIRET rc;
    ULONG cc;

    if (argc != 2) return PROC_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &pid)) return PROC_BADPARAM;

    if (RxStringIsAbbrev(args + 1, "Break", 1))
    {
        rc = DosSendSignalException(pid, XCPT_SIGNAL_BREAK);
    }
    else if (RxStringIsAbbrev(args + 1, "Interrupt", 1))
    {
        rc = DosSendSignalException(pid, XCPT_SIGNAL_INTR);
    }
    else if (RxStringIsAbbrev(args + 1, "Kill", 1))
    {
        rc = DosKillProcess(DKP_PROCESS, pid);
    }
    else return PROC_BADPARAM;

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// ProcSetPriority -- Set a Process Priority.
//
//      Id: Process Id
//      Class: 'Idle' | 'Regular' | 'Server' | 'Critical' [No Change]
//      Delta: (-31..31) [0]
//
//      Result: return code
//
#pragma handler(ProcSetPriority)
//
ULONG ProcSetPriority(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    ULONG cc;

    cc = Proc_SetPriority(PRTYS_PROCESS, argc, args, result);

    return cc;
}


// ProcSetThreadPriority -- Set a Thread Priority.
//
//      Id: Thread Id
//      Class: 'Idle' | 'Regular' | 'Server' | 'Critical' [No Change]
//      Delta: (-31..31) [0]
//
//      Result: return code
//
#pragma handler(ProcSetThreadPriority)
//
ULONG ProcSetThreadPriority(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    ULONG cc;

    cc = Proc_SetPriority(PRTYS_THREAD, argc, args, result);

    return cc;
}


// ProcSetTreePriority -- Set a Process Tree Priority.
//
//      Id: Head Process Id
//      Class: 'Idle' | 'Regular' | 'Server' | 'Critical' [No Change]
//      Delta: (-31..31) [0]
//
//      Result: return code
//
#pragma handler(ProcSetTreePriority)
//
ULONG ProcSetTreePriority(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    ULONG cc;

    cc = Proc_SetPriority(PRTYS_PROCESSTREE, argc, args, result);

    return cc;
}


// Local routines.

// Proc_EndThread.
//
static void Proc_EndThread(
    PIPCContext context,
    APIRET rc)
{
    ThreadParams *params;
    ULONG arg;

    params = IPCContext_Info((PIPCContext)context);

    FreeRxString(&params->fileSpec);

    for (arg = 0; arg < params->argc; ++arg) {
        FreeRxString(&params->args[arg]);
    }

    IPCContext_Signal(context, rc);
}


// Proc_SetPriority.
//
static ULONG Proc_SetPriority(
    ULONG scope,
    ULONG argc,
    PRXSTRING args,
    PRXSTRING result)
{
    ULONG id;
    ULONG class;
    LONG delta;
    APIRET rc;
    ULONG cc;

    if (argc < 2 || argc > 3) return PROC_BADPARAM;

    if (RxStringIsPresent(args + 0))
    {
        if (!RxStringToUnsigned(args + 0, &id)) return PROC_BADPARAM;
    }
    else id = 0;

    if (RxStringIsPresent(args + 1))
    {
        if (RxStringIsAbbrev(args + 1, "Idle", 1)) class = PRTYC_IDLETIME;
        else if (RxStringIsAbbrev(args + 1, "Regular", 1)) class = PRTYC_REGULAR;
        else if (RxStringIsAbbrev(args + 1, "Server", 1)) class = PRTYC_FOREGROUNDSERVER;
        else if (RxStringIsAbbrev(args + 1, "Critical", 1)) class = PRTYC_TIMECRITICAL;
        else return PROC_BADPARAM;
    }
    else class = PRTYC_NOCHANGE;

    if (argc > 2 && RxStringIsPresent(args + 2))
    {
        if (!RxStringToSigned(args + 2, &delta)) return PROC_BADPARAM;
    }
    else delta = 0;

    rc = DosSetPriority(scope, class, delta, id);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// Proc_Thread.
//
#pragma handler(Proc_Thread)
//
static void APIENTRY Proc_Thread(
    ULONG context)
{
    ThreadParams *params;
    APIRET rc;
    SHORT returnCode;

    _fpreset();

    params = IPCContext_Info((PIPCContext)context);

    IPCContext_Started((PIPCContext)context);

    rc = RexxStart(
        params->argc,
        params->args,
        params->fileSpec.strptr,
        NULL,
        NULL,
        RXCOMMAND,
        NULL,
        &returnCode,
        IPCContext_Result((PIPCContext)context));

    if (rc == 0) rc = returnCode;

    Proc_EndThread((PIPCContext)context, rc);
}


// $Log: rexxproc.c,v $
// Revision 1.5  1995/09/27 07:51:28  SFB
// Setup condition handling.
//
// Revision 1.4  1995/09/17 13:20:33  SFB
// Adds ProcGetThreadInfo.
//
// Revision 1.3  1995/05/22 21:15:33  SFB
// Added ProcCreateThread.
//
//
// Revision 1.2  1994/07/30  10:46:26  SFB
// Adjustments for V1.1-0
//
// Revision 1.1  1994/05/12  21:13:57  SFB
// Initial revision
//
