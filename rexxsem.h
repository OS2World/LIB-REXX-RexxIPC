// $Id: rexxsem.h,v 1.4 1995/09/17 13:24:30 SFB Rel $

// $Title: RexxSem local routines. $

// Copyright (c) Serge Brisson 1994, 1995.

#ifndef REXXSEM_H
#define REXXSEM_H

APIRET SemEvent_Close(
    ULONG handle);

APIRET SemEvent_Create(
    PULONG handle);

APIRET SemEvent_Post(
    ULONG handle);

APIRET SemEvent_Reset(
    ULONG handle);

APIRET SemEvent_Wait(
    ULONG handle);

#endif

// $Log: rexxsem.h,v $
// Revision 1.4  1995/09/17 13:24:30  SFB
// Adjust copyright.
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
