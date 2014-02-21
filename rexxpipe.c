// $RCSfile: rexxpipe.c,v $

// $Title: RexxIPC named pipes API. $

// Copyright (c) Serge Brisson 1994, 1995.

#define INCL_RXFUNC
#define INCL_DOSFILEMGR
#define INCL_DOSNMPIPES
#define INCL_DOSERRORS
#include <rexxsaa.h>
#define __TILED__
#include <stdlib.h>
#include <string.h>

#include "rxapiutl.h"
#include "rexxipc.h"


// Name of the DLL for Load.

#define PIPE_DLL_NAME "REXXIPC"


// Default values for missing parameters.

#define PIPE_DEFAULT_SIZE 1024
#define PIPE_DEFAULT_LIMIT 4096


// Return values to REXX.

#define PIPE_OK REXXAPI_OK
#define PIPE_NOMEM REXXAPI_NOMEM
#define PIPE_BADPARAM REXXAPI_BADPARAM


// REXX functions entry points:
// synchronize with REXXIPC.DEF.

RexxFunctionHandler PipeLoadFuncs;
RexxFunctionHandler PipeDropFuncs;
RexxFunctionHandler PipeCall;
RexxFunctionHandler PipeClose;
RexxFunctionHandler PipeConnect;
RexxFunctionHandler PipeConnectAsync;
RexxFunctionHandler PipeCreate;
RexxFunctionHandler PipeDisconnect;
RexxFunctionHandler PipeFlush;
RexxFunctionHandler PipeOpen;
RexxFunctionHandler PipePeek;
RexxFunctionHandler PipeRead;
RexxFunctionHandler PipeReadAsync;
RexxFunctionHandler PipeSetSem;
RexxFunctionHandler PipeTransact;
RexxFunctionHandler PipeWait;
RexxFunctionHandler PipeWrite;
RexxFunctionHandler PipeWriteAsync;


// RCS identification.

static char const rcsid[] =
{
    "$Id: rexxpipe.c,v 1.6 1995/09/27 07:51:28 SFB Rel $"
};


// Function table for Load/Drop.

static RxFncEntry RxFncTable[] =
{
    {"PipeDropFuncs", "PipeDropFuncs"},
    {"PipeCall", "PipeCall"},
    {"PipeClose", "PipeClose"},
    {"PipeConnect", "PipeConnect"},
    {"PipeConnectAsync", "PipeConnectAsync"},
    {"PipeCreate", "PipeCreate"},
    {"PipeDisconnect", "PipeDisconnect"},
    {"PipeFlush", "PipeFlush"},
    {"PipeOpen", "PipeOpen"},
    {"PipePeek", "PipePeek"},
    {"PipeRead", "PipeRead"},
    {"PipeReadAsync", "PipeReadAsync"},
    {"PipeSetSem", "PipeSetSem"},
    {"PipeTransact", "PipeTransact"},
    {"PipeWait", "PipeWait"},
    {"PipeWrite", "PipeWrite"},
    {"PipeWriteAsync", "PipeWriteAsync"}
};


// Local prototypes.

void APIENTRY Pipe_ConnectAsync(
    ULONG context);

void APIENTRY Pipe_ReadAsync(
    ULONG context);

void APIENTRY Pipe_WriteAsync(
    ULONG context);


// PipeLoadFuncs -- Register all the functions with REXX.
//
//      Result: none
//
#pragma handler(PipeLoadFuncs)
//
ULONG PipeLoadFuncs(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    if (argc > 0) return PIPE_BADPARAM;

    result->strlength = 0;

    LoadRxFuncs(
        RxFncTable,
        sizeof(RxFncTable) / sizeof(RxFncEntry),
        PIPE_DLL_NAME);

    return PIPE_OK;
}


// PipeDropFuncs -- Deregister all the functions with REXX.
//
//      Result: none
//
#pragma handler(PipeDropFuncs)
//
ULONG PipeDropFuncs(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    if (argc > 0 ) return PIPE_BADPARAM;

    result->strlength = 0;

    DropRxFuncs(
        RxFncTable,
        sizeof(RxFncTable) / sizeof(RxFncEntry));

    return PIPE_OK;
}


// PipeCall -- Execute a Call on a Named Pipe.
//
//      Name: ['\\'server]'\PIPE\'name
//      Output: output string []
//      InputVar: variable name []
//      InputLimit: 0..InpBufSize [0]
//      TimeOut: (ms) [50]
//
//      Result: return code
//
#pragma handler(PipeCall)
//
ULONG PipeCall(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    PSZ pipeName;
    PCH outputString;
    ULONG outputLength;
    PVOID outputBuffer;
    PRXSTRING inputVar;
    LONG inputLimit;
    LONG timeOut;
    PCH inputBuffer;
    ULONG inputLength;
    APIRET rc;
    ULONG cc;

    if (argc < 3 || argc > 5) return PIPE_BADPARAM;

    if (!RxStringIsPresent(args + 0)) return PIPE_BADPARAM;
    pipeName = args[0].strptr;

    if (!RxStringIsValid(args + 1)) return PIPE_BADPARAM;
    outputString = args[1].strptr;
    outputLength = args[1].strlength;

    if (!RxStringIsPresent(args + 2)) return PIPE_BADPARAM;
    inputVar = args + 2;

    if (argc > 3 && RxStringIsPresent(args + 3)) {
        if (!RxStringToSigned(args + 3, &inputLimit)) return PIPE_BADPARAM;
    }
    else inputLimit = PIPE_DEFAULT_LIMIT;

    if (argc > 4 && RxStringIsPresent(args + 4)) {
        if (!RxStringToSigned(args + 4, &timeOut)) return PIPE_BADPARAM;
    }
    else timeOut = 0;

    outputBuffer = _tmalloc(outputLength);
    if (outputBuffer == NULL) return PIPE_NOMEM;
    memcpy(outputBuffer, outputString, outputLength);

    inputBuffer = _tmalloc(inputLimit);
    if (inputBuffer == NULL) return PIPE_NOMEM;

    rc = DosCallNPipe(
        pipeName,
        outputBuffer, outputLength,
        inputBuffer, inputLimit, &inputLength,
        timeOut);

    if (rc == NO_ERROR) {
        StringToRxVariable(inputBuffer, inputLength, inputVar);
    }

    _tfree(inputBuffer);
    _tfree(outputBuffer);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// PipeClose -- Close a Named Pipe.
//
//      Handle: handle
//
//      Result: return code
//
#pragma handler(PipeClose)
//
ULONG PipeClose(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HPIPE handle;
    APIRET rc;
    ULONG cc;

    if (argc != 1) return PIPE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return PIPE_BADPARAM;

    rc = DosClose(handle);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// PipeConnect -- Listen for a connection on a Named Pipe.
//
//      Handle: handle
//
//      Result: return code
//
#pragma handler(PipeConnect)
//
ULONG PipeConnect(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HPIPE handle;
    APIRET rc;
    ULONG cc;

    if (argc != 1) return PIPE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return PIPE_BADPARAM;

    rc = DosConnectNPipe(handle);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// PipeConnectAsync -- Start listening for a connection on a Named Pipe.
//
//      Handle: handle
//      Context: context handle
//
//      Result: return code
//
#pragma handler(PipeConnectAsync)
//
ULONG PipeConnectAsync(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HPIPE handle;
    ULONG context;
    PULONG info;
    APIRET rc;
    ULONG cc;

    if (argc != 2) return PIPE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return PIPE_BADPARAM;

    if (!RxStringToUnsigned(args + 1, &context)) return PIPE_BADPARAM;

    if (IPCContext_IsBusy((PIPCContext)context)) rc = ERROR_BUSY;
    else {
        info = IPCContext_Alloc((PIPCContext)context, sizeof(ULONG) * 1);
        if (info == NULL) return PIPE_NOMEM;
        info[0] = handle;

        rc = IPCContext_Start((PIPCContext)context, Pipe_ConnectAsync);
    }

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// PipeCreate -- Create a Named Pipe.
//
//      HandleVar: variable name
//      Name: '\PIPE\'name
//      Mode: ('Inbound' | 'Outbound' | 'Duplex') ['Duplex']
//      Type: ('Byte' | 'Message') ['Message']
//      Instances: (1..255, -1) [1]
//      OutBufSize: [1024]
//      InpBufSize: [1024]
//      TimeOut: (ms) [50]
//
//      Result: return code
//
#pragma handler(PipeCreate)
//
ULONG PipeCreate(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    PRXSTRING handleVar;
    PSZ pipeName;
    ULONG pipeMode;
    ULONG pipeType;
    LONG pipeInstances;
    ULONG outBufSize;
    ULONG inpBufSize;
    LONG timeOut;
    HPIPE handle;
    APIRET rc;
    ULONG cc;

    if (argc < 2 || argc > 8) return PIPE_BADPARAM;

    if (!RxStringIsPresent(args + 0)) return PIPE_BADPARAM;
    handleVar = args + 0;

    if (!RxStringIsPresent(args + 1)) return PIPE_BADPARAM;
    pipeName = args[1].strptr;

    if (argc > 2 && RxStringIsPresent(args + 2)) {
        if (RxStringIsAbbrev(args + 2, "Inbound", 1)) pipeMode = NP_ACCESS_INBOUND;
        else if (RxStringIsAbbrev(args + 2, "Outbound", 1)) pipeMode = NP_ACCESS_OUTBOUND;
        else if (RxStringIsAbbrev(args + 2, "Duplex", 1)) pipeMode = NP_ACCESS_DUPLEX;
        else return PIPE_BADPARAM;
    }
    else pipeMode = NP_ACCESS_DUPLEX;

    if (argc > 3 && RxStringIsPresent(args + 3)) {
        if (RxStringIsAbbrev(args + 3, "Message", 1)) pipeType = NP_TYPE_MESSAGE | NP_READMODE_MESSAGE;
        else if (RxStringIsAbbrev(args + 3, "Byte", 1)) pipeType = NP_TYPE_BYTE | NP_READMODE_BYTE;
        else return PIPE_BADPARAM;
    }
    else pipeType = NP_TYPE_MESSAGE | NP_READMODE_MESSAGE;

    if (argc > 4 && RxStringIsPresent(args + 4)) {
        if (!RxStringToSigned(args + 4, &pipeInstances)) return PIPE_BADPARAM;
        if (pipeInstances < -1 || pipeInstances == 0 || pipeInstances > 255)
            return PIPE_BADPARAM;
    }
    else pipeInstances = 1;
    pipeInstances &= 0xFF;

    if (argc > 5 && RxStringIsPresent(args + 5)) {
        if (!RxStringToUnsigned(args + 5, &outBufSize)) return PIPE_BADPARAM;
    }
    else outBufSize = PIPE_DEFAULT_SIZE;

    if (argc > 6 && RxStringIsPresent(args + 6)) {
        if (!RxStringToUnsigned(args + 6, &inpBufSize)) return PIPE_BADPARAM;
    }
    else inpBufSize = PIPE_DEFAULT_SIZE;

    if (argc > 7 && RxStringIsPresent(args + 7)) {
        if (!RxStringToSigned(args + 7, &timeOut)) return PIPE_BADPARAM;
    }
    else timeOut = 50;

    rc = DosCreateNPipe(
        pipeName, &handle,
        pipeMode | NP_NOINHERIT, pipeType | pipeInstances,
        outBufSize, inpBufSize,
        timeOut);

    if (rc == NO_ERROR) UnsignedToRxVariable(handle, handleVar);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// PipeDisconnect -- Disconnect a Named Pipe.
//
//      Handle: handle
//
//      Result: return code
//
#pragma handler(PipeDisconnect)
//
ULONG PipeDisconnect(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HPIPE handle;
    APIRET rc;
    ULONG cc;

    if (argc != 1) return PIPE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return PIPE_BADPARAM;

    rc = DosDisConnectNPipe(handle);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// PipeFlush -- Flush the write buffer of a Named Pipe.
//
//      Handle: handle
//
//      Result: return code
//
#pragma handler(PipeFlush)
//
ULONG PipeFlush(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HPIPE handle;
    APIRET rc;
    ULONG cc;

    if (argc != 1) return PIPE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return PIPE_BADPARAM;

    rc = DosResetBuffer(handle);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// PipeOpen -- Open a Named Pipe.
//
//      HandleVar: variable name
//      Name: ['\\'server]'\PIPE\'name
//      Mode: ('Inbound' | 'Outbound' | 'Duplex') ['Duplex']
//      Type: ('Byte' | 'Message') ['Message']
//
//      Result: return code
//
#pragma handler(PipeOpen)
//
ULONG PipeOpen(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    PRXSTRING handleVar;
    PSZ pipeName;
    ULONG pipeMode;
    ULONG pipeType;
    HPIPE handle;
    ULONG ulAction;
    APIRET rc;
    ULONG cc;

    if (argc < 2 || argc > 4) return PIPE_BADPARAM;

    if (!RxStringIsPresent(args + 0)) return PIPE_BADPARAM;
    handleVar = args + 0;

    if (!RxStringIsPresent(args + 1)) return PIPE_BADPARAM;
    pipeName = args[1].strptr;

    if (argc > 2 && RxStringIsPresent(args + 2)) {
        if (RxStringIsAbbrev(args + 2, "Inbound", 1)) pipeMode = OPEN_ACCESS_READONLY;
        else if (RxStringIsAbbrev(args + 2, "Outbound", 1)) pipeMode = OPEN_ACCESS_WRITEONLY;
        else if (RxStringIsAbbrev(args + 2, "Duplex", 1)) pipeMode = OPEN_ACCESS_READWRITE;
        else return PIPE_BADPARAM;
    }
    else pipeMode = OPEN_ACCESS_READWRITE;
    pipeMode |= OPEN_SHARE_DENYNONE | OPEN_FLAGS_NOINHERIT;

    if (argc > 3 && RxStringIsPresent(args + 3)) {
        if (RxStringIsAbbrev(args + 3, "Message", 1)) pipeType = NP_READMODE_MESSAGE;
        else if (RxStringIsAbbrev(args + 3, "Byte", 1)) pipeType = NP_READMODE_BYTE;
        else return PIPE_BADPARAM;
    }
    else pipeType = NP_READMODE_MESSAGE;

    rc = DosOpen(
        pipeName, &handle, &ulAction, 0,
        FILE_NORMAL, OPEN_ACTION_OPEN_IF_EXISTS,
        pipeMode, NULL);

    if (rc == NO_ERROR) {
        if (pipeType != NP_READMODE_BYTE) {
            rc = DosSetNPHState(handle, pipeType);
        }
        if (rc == NO_ERROR) {
            UnsignedToRxVariable(handle, handleVar);
        }
        else DosClose(handle);
    }

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// PipePeek -- Peek from a Named Pipe.
//
//      Handle: handle
//      Input: variable name
//      Limit: 0..InpBufSize [0]
//      PipeBytes: variable name []
//      MessageBytes: variable name []
//      State: variable name []
//
//      Result: return code
//
#pragma handler(PipePeek)
//
ULONG PipePeek(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HPIPE handle;
    ULONG inputLimit;
    PCH inputBuffer;
    ULONG inputLength;
    AVAILDATA avail;
    ULONG state;
    APIRET rc;
    ULONG cc;

    if (argc < 2 || argc > 6) return PIPE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return PIPE_BADPARAM;

    if (argc > 2 && RxStringIsPresent(args + 2)) {
        if (!RxStringToUnsigned(args + 2, &inputLimit)) return PIPE_BADPARAM;
    }
    else inputLimit = PIPE_DEFAULT_LIMIT;

    inputBuffer = _tmalloc(inputLimit < 16? 16: inputLimit);
    if (inputBuffer == NULL) return PIPE_NOMEM;

    rc = DosPeekNPipe(
        handle,
        inputBuffer,
        inputLimit,
        &inputLength,
        &avail,
        &state);

    if (rc == NO_ERROR && RxStringIsPresent(args + 1)) {
        StringToRxVariable(inputBuffer, inputLength, args + 1);
    }

    _tfree(inputBuffer);

    if (rc == NO_ERROR) {
        if (argc > 3 && RxStringIsPresent(args + 3)) {
            UnsignedToRxVariable((ULONG) avail.cbpipe, args + 3);
        }

        if (argc > 4 && RxStringIsPresent(args + 4)) {
            UnsignedToRxVariable((ULONG) avail.cbmessage, args + 4);
        }

        if (argc > 5 && RxStringIsPresent(args + 5)) {
            UnsignedToRxVariable(state, args + 5);
        }
    }

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// PipeRead -- Read from a Named Pipe.
//
//      Handle: handle
//      Input: variable name
//      Limit: 0..InpBufSize [0]
//
//      Result: return code
//
#pragma handler(PipeRead)
//
ULONG PipeRead(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HPIPE handle;
    PRXSTRING inputVar;
    ULONG inputLimit;
    PCH inputBuffer;
    ULONG inputLength;
    APIRET rc;
    ULONG cc;

    if (argc < 2 || argc > 3) return PIPE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return PIPE_BADPARAM;

    if (!RxStringIsPresent(args + 1)) return PIPE_BADPARAM;
    inputVar = args + 1;

    if (argc > 2 && RxStringIsPresent(args + 2)) {
        if (!RxStringToUnsigned(args + 2, &inputLimit)) return PIPE_BADPARAM;
    }
    else inputLimit = PIPE_DEFAULT_LIMIT;

    inputBuffer = _tmalloc(inputLimit);
    if (inputBuffer == NULL) return PIPE_NOMEM;

    rc = DosRead(handle, inputBuffer, inputLimit, &inputLength);

    if (rc == NO_ERROR) {
        StringToRxVariable(inputBuffer, inputLength, inputVar);
    }

    _tfree(inputBuffer);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// PipeReadAsync -- Start to read from a Named Pipe.
//
//      Handle: handle
//      CtxHandle: context handle
//      Limit: 0..InpBufSize [0]
//
//      Result: return code
//
#pragma handler(PipeReadAsync)
//
ULONG PipeReadAsync(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HPIPE handle;
    ULONG context;
    ULONG inputLimit;
    PULONG info;
    APIRET rc;
    ULONG cc;

    if (argc < 2 || argc > 3) return PIPE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return PIPE_BADPARAM;

    if (!RxStringToUnsigned(args + 1, &context)) return PIPE_BADPARAM;

    if (argc > 2 && RxStringIsPresent(args + 2)) {
        if (!RxStringToUnsigned(args + 2, &inputLimit)) return PIPE_BADPARAM;
    }
    else inputLimit = PIPE_DEFAULT_LIMIT;

    if (IPCContext_IsBusy((PIPCContext)context)) rc = ERROR_BUSY;
    else {
        info = IPCContext_Alloc((PIPCContext)context, sizeof(ULONG) * 2);
        if (info == NULL) return PIPE_NOMEM;
        info[0] = handle;
        info[1] = inputLimit;

        FreeRxString(IPCContext_Result((PIPCContext)context));

        rc = IPCContext_Start((PIPCContext)context, Pipe_ReadAsync);
    }

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// PipeSetSem -- Associate an Event Semaphore to a Named Pipe.
//
//      Handle: handle
//      SemHandle: handle
//      KeyHandle: handle [0]
//
#pragma handler(PipeSetSem)
//
ULONG PipeSetSem(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HPIPE handle;
    ULONG semHandle;
    ULONG keyHandle;
    APIRET rc;
    ULONG cc;

    if (argc < 2 || argc > 3) return PIPE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return PIPE_BADPARAM;

    if (!RxStringToUnsigned(args + 1, &semHandle)) return PIPE_BADPARAM;

    if (argc > 2 && RxStringIsPresent(args + 2)) {
        if (!RxStringToUnsigned(args + 2, &keyHandle)) return PIPE_BADPARAM;
    }
    else keyHandle = 0;

    rc = DosSetNPipeSem(handle, (HSEM)semHandle, keyHandle);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// PipeTransact -- Execute a Transaction on a Named Pipe.
//
//      Handle: handle
//      Output: output
//      Input: variable name
//      Limit: 0..InpBufSize [0]
//
//      Result: return code
//
#pragma handler(PipeTransact)
//
ULONG PipeTransact(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HPIPE handle;
    PCH outputString;
    ULONG outputLength;
    PVOID outputBuffer;
    PRXSTRING inputVar;
    ULONG inputLimit;
    PCH inputBuffer;
    ULONG inputLength;
    APIRET rc;
    ULONG cc;

    if (argc < 3 || argc > 4) return PIPE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return PIPE_BADPARAM;

    if (!RxStringIsValid(args + 1)) return PIPE_BADPARAM;
    outputString = args[1].strptr;
    outputLength = args[1].strlength;

    if (!RxStringIsPresent(args + 2)) return PIPE_BADPARAM;
    inputVar = args + 2;

    if (argc > 3 && RxStringIsPresent(args + 3)) {
        if (!RxStringToUnsigned(args + 3, &inputLimit)) return PIPE_BADPARAM;
    }
    else inputLimit = PIPE_DEFAULT_LIMIT;

    outputBuffer = _tmalloc(outputLength);
    if (outputBuffer == NULL) return PIPE_NOMEM;
    memcpy(outputBuffer, outputString, outputLength);

    inputBuffer = _tmalloc(inputLimit);
    if (inputBuffer == NULL) return PIPE_NOMEM;

    rc = DosTransactNPipe(
        handle,
        outputBuffer, outputLength,
        inputBuffer, inputLimit, &inputLength);

    if (rc == NO_ERROR) {
        StringToRxVariable(inputBuffer, inputLength, inputVar);
    }

    _tfree(inputBuffer);
    _tfree(outputBuffer);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// PipeWait -- Wait on a busy Named Pipe.
//
//      Name: ['\\'server]'\PIPE\'name
//      TimeOut: (-1, 0, 1..n ms) [0]
//
//      Result: return code
//
#pragma handler(PipeWait)
//
ULONG PipeWait(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    PSZ pipeName;
    LONG timeOut;
    APIRET rc;
    ULONG cc;

    if (argc < 1 || argc > 2) return PIPE_BADPARAM;

    if (!RxStringIsPresent(args + 0)) return PIPE_BADPARAM;
    pipeName = args[0].strptr;

    if (argc > 1 && RxStringIsPresent(args + 1)) {
        if (!RxStringToSigned(args + 1, &timeOut)) return PIPE_BADPARAM;
    }
    else timeOut = 0;

    rc = DosWaitNPipe(pipeName, timeOut);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// PipeWrite -- Write on a Named Pipe.
//
//      Handle: handle
//      Output: output
//
//      Result: return code
//
#pragma handler(PipeWrite)
//
ULONG PipeWrite(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HPIPE handle;
    PCH outputString;
    ULONG outputLength;
    PVOID outputBuffer;
    ULONG bytesWritten;
    APIRET rc;
    ULONG cc;

    if (argc != 2) return PIPE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return PIPE_BADPARAM;

    if (!RxStringIsValid(args + 1)) return PIPE_BADPARAM;
    outputString = args[1].strptr;
    outputLength = args[1].strlength;

    outputBuffer = _tmalloc(outputLength);
    if (outputBuffer == NULL) return PIPE_NOMEM;

    memcpy(outputBuffer, outputString, outputLength);

    rc = DosWrite(handle, outputBuffer, outputLength, &bytesWritten);

    _tfree(outputBuffer);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// PipeWriteAsync -- Start write on a Named Pipe.
//
//      Handle: handle
//      CtxHandle: context handle
//      Output: output
//
//      Result: return code
//
#pragma handler(PipeWriteAsync)
//
ULONG PipeWriteAsync(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HPIPE handle;
    ULONG context;
    PCH outputString;
    ULONG outputLength;
    PRXSTRING output;
    PULONG info;
    APIRET rc;
    ULONG cc;

    if (argc != 3) return PIPE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return PIPE_BADPARAM;

    if (!RxStringToUnsigned(args + 1, &context)) return PIPE_BADPARAM;

    if (!RxStringIsValid(args + 2)) return PIPE_BADPARAM;
    outputString = args[2].strptr;
    outputLength = args[2].strlength;

    if (IPCContext_IsBusy((PIPCContext)context)) rc = ERROR_BUSY;
    else    {
        info = IPCContext_Alloc((PIPCContext)context, sizeof(ULONG) * 1);
        if (info == NULL) return PIPE_NOMEM;
        info[0] = handle;

        output = IPCContext_Result((PIPCContext)context);
        FreeRxString(output);

        rc = StringToRxResult(outputString, outputLength, output);

        if (rc == NO_ERROR) {
            rc = IPCContext_Start((PIPCContext)context, Pipe_WriteAsync);
        }
    }

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// Local routines.

// Pipe_ConnectAsync.
//
#pragma handler(Pipe_ConnectAsync)
//
static void APIENTRY Pipe_ConnectAsync(
    ULONG context)
{
    PULONG info;
    HPIPE handle;
    APIRET rc;

    info = IPCContext_Info((PIPCContext)context);
    handle = info[0];

    IPCContext_Started((PIPCContext)context);

    rc = DosConnectNPipe(handle);

    IPCContext_Signal((PIPCContext)context, rc);
}


// Pipe_ReadAsync.
//
#pragma handler(Pipe_ReadAsync)
//
static void APIENTRY Pipe_ReadAsync(
    ULONG context)
{
    PULONG info;
    HPIPE handle;
    ULONG limit;
    PRXSTRING result;
    PCH buffer;
    ULONG length;
    APIRET rc;

    info = IPCContext_Info((PIPCContext)context);
    handle = info[0];
    limit = info[1];

    result = IPCContext_Result((PIPCContext)context);

    IPCContext_Started((PIPCContext)context);

    buffer = _tmalloc(limit);
    if (buffer != NULL) {
        rc = DosRead(handle, buffer, limit, &length);

        if (rc == NO_ERROR) {
            rc = StringToRxResult(buffer, length, result);
        }

        _tfree(buffer);
    }
    else rc = PIPE_NOMEM;

    IPCContext_Signal((PIPCContext)context, rc);
}


// Pipe_WriteAsync.
//
#pragma handler(Pipe_WriteAsync)
//
static void APIENTRY Pipe_WriteAsync(
    ULONG context)
{
    PULONG info;
    HPIPE handle;
    PRXSTRING output;
    PCH buffer;
    ULONG length;
    ULONG bytesWritten;
    APIRET rc;

    info = IPCContext_Info((PIPCContext)context);
    handle = info[0];

    output = IPCContext_Result((PIPCContext)context);

    IPCContext_Started((PIPCContext)context);

    length = output->strlength;

    buffer = _tmalloc(length);
    if (buffer == NULL) rc = PIPE_NOMEM;
    else {
        memcpy(buffer, output->strptr, length);

        rc = DosWrite(handle, buffer, length, &bytesWritten);

        _tfree(buffer);
    }

    FreeRxString(output);

    IPCContext_Signal((PIPCContext)context, rc);
}


// $Log: rexxpipe.c,v $
// Revision 1.6  1995/09/27 07:51:28  SFB
// Setup condition handling.
//
// Revision 1.5  1995/09/17 13:18:31  SFB
// Adds PipeReadAsync and PipeWriteAsync.
//
// Revision 1.4  1995/06/24 12:49:36  SFB
// Preliminary implementation of Read/Write Async.
//
// Revision 1.3  1995/05/22 21:13:59  SFB
// Added PipeSetSem.
//
// Revision 1.2  1994/07/30  10:46:26  SFB
// Adjustments for V1.1-0
//
// Revision 1.1  1994/05/12  21:13:57  SFB
// Initial revision

