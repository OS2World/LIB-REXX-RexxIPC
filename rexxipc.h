// $Id: rexxipc.h,v 1.4 1995/09/17 13:02:40 SFB Rel $

// $Title: RexxIPC local routines. $

// Copyright (c) Serge Brisson 1994, 1995.

#ifndef REXXIPC_H
#define REXXIPC_H

typedef struct IPCContext IPCContext, *PIPCContext;

PVOID IPCContext_Alloc(
    PIPCContext context,
    ULONG size);

void IPCContext_Close(
    PIPCContext context);

PIPCContext IPCContext_Create(
    ULONG semHandle,
    BOOL keep);

PVOID IPCContext_Info(
    PIPCContext context);

BOOL IPCContext_IsBusy(
    PIPCContext context);

PRXSTRING IPCContext_Result(
    PIPCContext context);

void IPCContext_Signal(
    PIPCContext context,
    APIRET rc);

APIRET IPCContext_Start(
    PIPCContext context,
    VOID APIENTRY function(ULONG));

void IPCContext_Started(
    PIPCContext context);

#endif

// $Log: rexxipc.h,v $
// Revision 1.4  1995/09/17 13:02:40  SFB
// Adjust copyright.
//
// Revision 1.3  1995/05/22 21:13:10  SFB
// Added prototype for IPCContext_Result.
//
// 
// Revision 1.2  1994/07/30  10:46:26  SFB
// Adjustments for V1.1-0
//
// Revision 1.1  1994/05/12  21:10:03  SFB
// Initial revision
//
