// $Id: rxapiutl.h,v 1.5 1996/01/14 12:22:11 SFB Rel $

// $Title: Rexx API utility routines. $

// Copyright (c) Serge Brisson 1994, 1995.

#ifndef RXAPIUTL_H
#define RXAPIUTL_H

#define REXXAPI_OK 0
#define REXXAPI_NOMEM 5
#define REXXAPI_BADPARAM 40

typedef struct
{
    PSZ rxName;
    PSZ cName;
}
    RxFncEntry;

void DropRxFuncs(
    const RxFncEntry rxFncTable[],
    USHORT tableDim);

void FreeRxString(
    PRXSTRING rxString);

void LoadRxFuncs(
    const RxFncEntry rxFncTable[],
    USHORT tableDim,
    PCSZ dllName);

BOOL RxStringIsAbbrev(
    const RXSTRING *rxString,
    PCSZ keyword,
    USHORT minimum);

BOOL RxStringIsPresent(
    const RXSTRING *rxString);

BOOL RxStringIsValid(
    const RXSTRING *rxString);

BOOL RxStringToSigned(
    const RXSTRING *rxString,
    PLONG number);

BOOL RxStringToUnsigned(
    const RXSTRING *rxString,
    PULONG number);

ULONG RxVariableToRxString(
    const RXSTRING *rxVariable,
    PRXSTRING rxString);

ULONG SignedToRxResult(
    LONG number,
    PRXSTRING rxResult);

ULONG SignedToRxVariable(
    LONG number,
    PRXSTRING rxName);

ULONG StringToRxResult(
    const char *string,
    LONG length,
    PRXSTRING rxResult);

ULONG StringToRxVariable(
    const char *string,
    LONG length,
    PRXSTRING rxName);

BOOL StringToSigned(
    const char *string,
    LONG length,
    PLONG number);

BOOL StringToUnsigned(
    const char *string,
    LONG length,
    PULONG number);

ULONG UnsignedToRxResult(
    ULONG number,
    PRXSTRING rxResult);

ULONG UnsignedToRxVariable(
    ULONG number,
    PRXSTRING rxName);

#endif

// $Log: rxapiutl.h,v $
// Revision 1.5  1996/01/14 12:22:11  SFB
// Corrects keyword recognition bug.
//
// Revision 1.4  1995/09/17 13:30:51  SFB
// Adds RxVariableToRxString.
// Renames many routines.
//
// Revision 1.3  1995/05/22 21:16:41  SFB
// Integrated improvements from other projects.
//
// 
// Revision 1.2  1994/07/30  10:46:26  SFB
// Adjustments for V1.1-0
//
// Revision 1.1  1994/05/12  21:11:26  SFB
// Initial revision

