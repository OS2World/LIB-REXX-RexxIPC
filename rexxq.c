// $RCSfile: rexxq.c,v $

// $Title: RexxIPC queues API. $

// Copyright (c) Serge Brisson 1995.

#define INCL_RXFUNC
#define INCL_DOSQUEUES
#define INCL_DOSMEMMGR
#define INCL_DOSPROCESS
#define INCL_DOSERRORS
#include <rexxsaa.h>
#include <stdlib.h>
#include <string.h>

#include "rxapiutl.h"
#include "rexxipc.h"
#include "rexxsem.h"


// Name of the DLL for Load.

#define QUEUE_DLL_NAME "REXXIPC"


// Return values to REXX.

#define QUEUE_OK REXXAPI_OK
#define QUEUE_NOMEM REXXAPI_NOMEM
#define QUEUE_BADPARAM REXXAPI_BADPARAM


// REXX functions entry points:
// synchronize with REXXIPC.DEF.

RexxFunctionHandler QueueLoadFuncs;
RexxFunctionHandler QueueDropFuncs;
RexxFunctionHandler QueueClose;
RexxFunctionHandler QueueCreate;
RexxFunctionHandler QueueOpen;
RexxFunctionHandler QueuePeek;
RexxFunctionHandler QueuePurge;
RexxFunctionHandler QueueQuery;
RexxFunctionHandler QueueRead;
RexxFunctionHandler QueueWrite;


// Queue structure.

typedef struct Queue
{
    HQUEUE handle;
    PID server;
    PID client;
    HEV sem;
    HEV event;
}
    Queue, *PQueue;


// RCS identification.

static char const rcsid[] =
{
    "$Id: rexxq.c,v 1.2 1996/01/14 12:10:47 SFB Rel $"
};


// Function table for Load/Drop.

static RxFncEntry RxFncTable[] =
{
    {"QueueDropFuncs", "QueueDropFuncs"},
    {"QueueClose", "QueueClose"},
    {"QueueCreate", "QueueCreate"},
    {"QueueOpen", "QueueOpen"},
    {"QueuePeek", "QueuePeek"},
    {"QueuePurge", "QueuePurge"},
    {"QueueQuery", "QueueQuery"},
    {"QueueRead", "QueueRead"},
    {"QueueWrite", "QueueWrite"}
};


// Local prototypes.

static PID Queue_GetPID(
    void);


// QueueLoadFuncs -- Register all the functions with REXX.
//
//      Result: none
//
#pragma handler(QueueLoadFuncs)
//
ULONG QueueLoadFuncs(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    if (argc > 0) return QUEUE_BADPARAM;

    result->strlength = 0;

    LoadRxFuncs(
        RxFncTable,
        sizeof(RxFncTable) / sizeof(RxFncEntry),
        QUEUE_DLL_NAME);

    return QUEUE_OK;
}


// QueueDropFuncs -- Deregister all the functions with REXX.
//
//      Result: none
//
#pragma handler(QueueDropFuncs)
//
ULONG QueueDropFuncs(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    if (argc > 0 ) return QUEUE_BADPARAM;

    result->strlength = 0;

    DropRxFuncs(
        RxFncTable,
        sizeof(RxFncTable) / sizeof(RxFncEntry));

    return QUEUE_OK;
}


// QueueClose -- Close a Queue.
//
//      Handle: handle
//
//      Result: return code
//
#pragma handler(QueueClose)
//
ULONG QueueClose(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HQUEUE handle;
    PQueue q;
    APIRET rc;
    ULONG cc;

    if (argc != 1) return QUEUE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return QUEUE_BADPARAM;
    q = (PQueue)handle;

    rc = DosCloseQueue(q->handle);

    if (q->event != 0 && q->sem == 0) {
        SemEvent_Close(q->event);
    }

    free(q);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// QueueCreate -- Create a Queue.
//
//      HandleVar: variable name
//      Name: '\QUEUES\'name
//      Algorithm: ('FIFO' | 'LIFO' | 'Priority') ['FIFO']
//      SemHandle: handle []
//
//      Result: return code
//
#pragma handler(QueueCreate)
//
ULONG QueueCreate(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    PRXSTRING handleVar;
    PSZ qName;
    ULONG algorithm;
    HEV sem;
    PQueue q;
    APIRET rc;
    ULONG cc;

    if (argc < 2 || argc > 4) return QUEUE_BADPARAM;

    if (!RxStringIsPresent(args + 0)) return QUEUE_BADPARAM;
    handleVar = args + 0 ;

    if (!RxStringIsPresent(args + 1)) return QUEUE_BADPARAM;
    qName = args[1].strptr;

    if (argc > 2 && RxStringIsPresent(args + 2)) {
        if (RxStringIsAbbrev(args + 2, "FIFO", 1)) algorithm = QUE_FIFO;
        else if (RxStringIsAbbrev(args + 2, "LIFO", 1)) algorithm = QUE_LIFO;
        else if (RxStringIsAbbrev(args + 2, "Priority", 1)) algorithm = QUE_PRIORITY;
        else return QUEUE_BADPARAM;
    }
    else algorithm = QUE_FIFO;

    if (argc > 3 && RxStringIsPresent(args + 3)) {
        if (!RxStringToUnsigned(args + 3, &sem)) return QUEUE_BADPARAM;
    }
    else sem = 0;

    q = malloc(sizeof(Queue));
    if (q == NULL) return QUEUE_NOMEM;

    rc = DosCreateQueue(&q->handle, algorithm, qName);

    if (rc == NO_ERROR) {
        q->server = Queue_GetPID();
        q->client = q->server;
        q->sem = sem;
        q->event = sem;

        UnsignedToRxVariable((ULONG)q, handleVar);
    }
    else free(q);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// QueueOpen -- Open a Queue.
//
//      HandleVar: variable name
//      Name: \QUEUES\'name
//      ServerVar: variable name []
//      SemHandle: handle []
//
//      Result: return code
//
#pragma handler(QueueOpen)
//
ULONG QueueOpen(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    PRXSTRING handleVar;
    PSZ qName;
    PRXSTRING serverVar;
    HEV sem;
    PQueue q;
    APIRET rc;
    ULONG cc;

    if (argc < 2 || argc > 4) return QUEUE_BADPARAM;

    if (!RxStringIsPresent(args + 0)) return QUEUE_BADPARAM;
    handleVar = args + 0;

    if (!RxStringIsPresent(args + 1)) return QUEUE_BADPARAM;
    qName = args[1].strptr;

    if (argc > 2 && RxStringIsPresent(args + 2)) serverVar = args + 2;
    else serverVar = NULL;

    if (argc > 3 && RxStringIsPresent(args + 3)) {
        if (!RxStringToUnsigned(args + 3, &sem)) return QUEUE_BADPARAM;
    }
    else sem = 0;

    q = malloc(sizeof(Queue));
    if (q == NULL) return QUEUE_NOMEM;

    rc = DosOpenQueue(&q->server, &q->handle, qName);

    if (rc == NO_ERROR) {
        q->client = Queue_GetPID();
        q->sem = sem;

        UnsignedToRxVariable((ULONG)q, handleVar);
        if (serverVar != NULL) UnsignedToRxVariable(q->server, serverVar);
    }
    else free(q);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// QueuePeek -- Peek from a Queue.
//
//      Handle: handle
//      DataVar: variable name []
//      RequestVar: variable name []
//      PriorityVar: variable name []
//      ClientVar: variable name []
//      ElementVar: variable name []
//      Wait: ('NoWait' | 'Wait') ['NoWait']
//
//      Result: return code
//
#pragma handler(QueuePeek)
//
ULONG QueuePeek(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HQUEUE handle;
    PQueue q;
    REQUESTDATA requestData;
    ULONG length;
    PVOID data;
    RXSTRING elementString;
    ULONG element;
    BYTE priority;
    BOOL noWait;
    APIRET rc;
    ULONG cc;

    if (argc < 1 || argc > 7) return QUEUE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return QUEUE_BADPARAM;
    q = (PQueue)handle;

    if (argc > 5 && RxStringIsPresent(args + 5)) {
        elementString.strptr = NULL;
        elementString.strlength = 0;
        rc = RxVariableToRxString(args + 5, &elementString);
        if (rc == NO_ERROR && RxStringIsPresent(&elementString)) {
            BOOL success = RxStringToUnsigned(&elementString, &element);
            FreeRxString(&elementString);
            if (!success) return QUEUE_BADPARAM;
        }
        else element = 0;
    }
    else element = 0;

    if (argc > 6 && RxStringIsPresent(args + 6)) {
        if (RxStringIsAbbrev(args + 6, "Wait", 1)) noWait = FALSE;
        else if (RxStringIsAbbrev(args + 6, "NoWait", 1)) noWait = TRUE;
        else return QUEUE_BADPARAM;
    }
    else noWait = TRUE;

    if (noWait && q->event == 0) {
        rc = SemEvent_Create(&q->event);
    }
    else rc = NO_ERROR;

    if (rc == NO_ERROR) {
        rc = DosPeekQueue(
            q->handle,
            &requestData,
            &length, &data,
            &element, noWait,
            &priority,
            q->event);
    }

    if (rc == NO_ERROR) {
        if (argc > 1 && RxStringIsPresent(args + 1)) { // Data.
            StringToRxVariable(data, length, args + 1);
        }

        if (argc > 2 && RxStringIsPresent(args + 2)) { // Request.
            UnsignedToRxVariable(requestData.ulData, args + 2);
        }

        if (argc > 3 && RxStringIsPresent(args + 3)) { // Priority.
            UnsignedToRxVariable(priority, args + 3);
        }

        if (argc > 4 && RxStringIsPresent(args + 4)) { // Client.
            UnsignedToRxVariable(requestData.pid, args + 4);
        }

        if (argc > 5 && RxStringIsPresent(args + 5)) { // Element.
            UnsignedToRxVariable(element, args + 5);
        }
    }

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// QueuePurge -- Purge a Queue.
//
//      Handle: handle
//
//      Result: return code
//
#pragma handler(QueuePurge)
//
ULONG QueuePurge(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HQUEUE handle;
    PQueue q;
    APIRET rc;
    ULONG cc;

    if (argc != 1) return QUEUE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return QUEUE_BADPARAM;
    q = (PQueue)handle;

    rc = DosPurgeQueue(q->handle);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// QueueQuery -- Query a Queue.
//
//      Handle: handle
//      ElementsVar: variable name
//
//      Result: return code
//
#pragma handler(QueueQuery)
//
ULONG QueueQuery(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HQUEUE handle;
    PQueue q;
    PRXSTRING elementsVar;
    ULONG elements;
    APIRET rc;
    ULONG cc;

    if (argc != 2) return QUEUE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return QUEUE_BADPARAM;
    q = (PQueue)handle;

    if (!RxStringIsPresent(args + 1)) return QUEUE_BADPARAM;
    elementsVar = args + 1;

    rc = DosQueryQueue(q->handle, &elements);

    if (rc == NO_ERROR) {
        UnsignedToRxVariable(elements, elementsVar);
    }

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// QueueRead -- Read from a Queue.
//
//      Handle: handle
//      DataVar: variable name
//      RequestVar: variable name
//      PriorityVar: variable name
//      ClientVar: variable name
//      Element: unsigned number
//      Wait: ('NoWait' | 'Wait') ['Wait']
//
//      Result: return code
//
#pragma handler(QueueRead)
//
ULONG QueueRead(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HQUEUE handle;
    PQueue q;
    PRXSTRING dataVar;
    REQUESTDATA requestData;
    ULONG length;
    PVOID data;
    ULONG element;
    BYTE priority;
    BOOL noWait;
    APIRET rc;
    ULONG cc;

    if (argc < 2 || argc > 7) return QUEUE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return QUEUE_BADPARAM;
    q = (PQueue)handle;

    if (!RxStringIsPresent(args + 1)) return QUEUE_BADPARAM;
    dataVar = args + 1;

    if (argc > 5 && RxStringIsPresent(args + 5)) {
        if (!RxStringToUnsigned(args + 5, &element)) return QUEUE_BADPARAM;
    }
    else element = 0;

    if (argc > 6 && RxStringIsPresent(args + 6)) {
        if (RxStringIsAbbrev(args + 6, "Wait", 1)) noWait = FALSE;
        else if (RxStringIsAbbrev(args + 6, "NoWait", 1)) noWait = TRUE;
        else return QUEUE_BADPARAM;
    }
    else noWait = FALSE;

    if (noWait && q->event == 0) {
        rc = SemEvent_Create(&q->event);
    }
    else rc = NO_ERROR;

    if (rc == NO_ERROR) {
        rc = DosReadQueue(
            q->handle,
            &requestData,
            &length, &data,
            element, noWait,
            &priority,
            q->event);
    }

    if (rc == NO_ERROR) {
        StringToRxVariable(data, length, dataVar);

        if (argc > 2 && RxStringIsPresent(args + 2)) { // Request.
            UnsignedToRxVariable(requestData.ulData, args + 2);
        }

        if (argc > 3 && RxStringIsPresent(args + 3)) { // Priority.
            UnsignedToRxVariable(priority, args + 3);
        }

        if (argc > 4 && RxStringIsPresent(args + 4)) { // Client.
            UnsignedToRxVariable(requestData.pid, args + 4);
        }

        if (q->server != requestData.pid) DosFreeMem(data);
        else free(data);
    }

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// QueueWrite -- Write on a Queue.
//
//      Handle: handle
//      Data: string
//      Request: user value (unsigned number) [0]
//      Priority: 0..15 [0]
//
//      Result: return code
//
#pragma handler(QueueWrite)
//
ULONG QueueWrite(
    PUCHAR name,
    ULONG argc,
    PRXSTRING args,
    PSZ queue,
    PRXSTRING result)
{
    HQUEUE handle;
    PQueue q;
    PCH dataString;
    ULONG length;
    PVOID data;
    ULONG request;
    ULONG priority;
    APIRET rc;
    ULONG cc;

    if (argc < 2 || argc > 4) return QUEUE_BADPARAM;

    if (!RxStringToUnsigned(args + 0, &handle)) return QUEUE_BADPARAM;
    q = (PQueue)handle;

    if (!RxStringIsValid(args + 1)) return QUEUE_BADPARAM;
    dataString = args[1].strptr;
    length = args[1].strlength;

    if (argc > 2 && RxStringIsPresent(args + 2)) {
        if (!RxStringToUnsigned(args + 2, &request)) return QUEUE_BADPARAM;
    }
    else request = 0;

    if (argc > 3 && RxStringIsPresent(args + 3)) {
        if (!RxStringToUnsigned(args + 3, &priority)) return QUEUE_BADPARAM;
    }
    else priority = 0;

    if (q->server == q->client) {
        data = malloc(length);
        if (data == NULL) return QUEUE_NOMEM;
        memcpy(data, dataString, length);
        rc = NO_ERROR;
    }
    else {
        rc = DosAllocSharedMem(
            &data, NULL, length,
            PAG_COMMIT | PAG_WRITE | PAG_READ | OBJ_GIVEABLE);
        if (rc != NO_ERROR) return QUEUE_NOMEM;
        memcpy(data, dataString, length);
        rc = DosGiveSharedMem(data, q->server, PAG_READ | PAG_WRITE);
    }

    if (rc == NO_ERROR) {
        rc = DosWriteQueue(q->handle, request, length, data, priority);
        if (rc == ERROR_SYS_INTERNAL) rc = NO_ERROR;
    }

    if (q->server != q->client) DosFreeMem(data);
    else if (rc != NO_ERROR) free(data);

    cc = UnsignedToRxResult(rc, result);
    return cc;
}


// Local routines.

// Queue_GetPID.
//
static PID Queue_GetPID(
    void)
{
    PTIB pTIB;
    PPIB pPIB;

    DosGetInfoBlocks(&pTIB, &pPIB);

    return pPIB->pib_ulpid;
}


// $Log: rexxq.c,v $
// Revision 1.2  1996/01/14 12:10:47  SFB
// First release.
//
// Revision 1.1  1995/09/27 07:54:55  SFB
// Initial revision
//

