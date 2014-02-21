// $RCSfile: rxapiutl.c,v $

// $Title: Rexx API utility routines. $

// Copyright (c) Serge Brisson 1994, 1995.

#define INCL_RXFUNC
#define INCL_RXSHV
#define INCL_DOSERRORS
#include <rexxsaa.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#include "rxapiutl.h"


// RCS identification.

static char const rcsid[] =
{
    "$Id: rxapiutl.c,v 1.7 1997/04/26 13:09:44 SFB Exp $"
};


// DropRxFuncs -- Drop Rexx functions.
//
//      Return: none
//
void DropRxFuncs(
    const RxFncEntry rxFncTable[],
    USHORT tableDim)
{
    USHORT i;

    for (i = 0; i < tableDim; ++i) {
        RexxDeregisterFunction(rxFncTable[i].rxName);
    }
}


// FreeRxString -- Free a REXX string.
//
//      Return: none
//
void FreeRxString(
    PRXSTRING rxString)
{
    if (
        rxString != NULL &&
        rxString->strptr != NULL)
    {
        DosFreeMem(rxString->strptr);
        rxString->strptr = NULL;
        rxString->strlength = 0;
    }
}


// LoadRxFuncs -- Load Rexx functions.
//
//      Return: none
//
void LoadRxFuncs(
    const RxFncEntry rxFncTable[],
    USHORT tableDim,
    PCSZ dllName)
{
    USHORT i;

    for (i = 0; i < tableDim; ++i) {
        RexxRegisterFunctionDll(
            rxFncTable[i].rxName,
            dllName,
            rxFncTable[i].cName);
    }
}


// RxStringIsAbbrev -- Check for abbreviation of a keyword.
//
//      Return: TRUE if 'rxString' is 'minimum' abbreviation of 'keyword'.
//
BOOL RxStringIsAbbrev(
    const RXSTRING *rxString,           // Input string.
    PCSZ keyword,                       // Reference string.
    USHORT minimum)                     // Minimum match.
{
    USHORT length;
    PSZ string;

    if (
        rxString == NULL ||
        rxString->strptr == NULL ||
        rxString->strlength == 0) return FALSE;

    string = rxString->strptr;
    for (length = 0; length < rxString->strlength; ++length) {
        if (toupper(string[length]) != toupper(keyword[length])) return FALSE;
    }

    return length >= minimum;
}


// RxStringIsPresent -- Check if REXX string is present.
//
//      Return: TRUE if 'rxString' is present.
//
BOOL RxStringIsPresent(
    const RXSTRING *rxString)           // REXX function argument.
{
    if (rxString == NULL) return FALSE;
    if (rxString->strptr == NULL) return FALSE;
    if (rxString->strlength == 0) return FALSE;
    if (rxString->strptr[0] == '\0') return FALSE;

    return TRUE;
}


// RxStringIsValid -- Check if REXX string is valid.
//
//      Return: TRUE if 'rxString' is valid.
//
BOOL RxStringIsValid(
    const RXSTRING *rxString)           // REXX function argument.
{
    if (rxString == NULL) return FALSE;
    if (rxString->strptr == NULL) return FALSE;

    return TRUE;
}


// RxStringToSigned -- Convert a REXX string to a signed number.
//
//      Return: TRUE if 'rxString' is a signed number.
//
BOOL RxStringToSigned(
    const RXSTRING *rxString,           // REXX function argument.
    PLONG number)                       // Output value.
{
    BOOL success;

    if (
        rxString == NULL ||
        rxString->strptr == NULL ||
        rxString->strlength == 0) return FALSE;

    success = StringToSigned(rxString->strptr, rxString->strlength, number);

    return success;
}


// RxStringToUnsigned -- Convert a REXX string to an unsigned number.
//
//      Return: TRUE if 'rxString' is an unsigned number.
//
BOOL RxStringToUnsigned(
    const RXSTRING *rxString,           // REXX function argument.
    PULONG number)                      // Output value.
{
    BOOL success;

    if (
        rxString == NULL ||
        rxString->strptr == NULL ||
        rxString->strlength == 0) return FALSE;

    success = StringToUnsigned(rxString->strptr, rxString->strlength, number);

    return success;
}


// RxVariableToRxString -- Get a REXX string from a REXX variable.
//
//      Return: REXX Variable Pool return code
//
ULONG RxVariableToRxString(
    const RXSTRING *rxVariable,
    PRXSTRING rxString)
{
    SHVBLOCK block;
    ULONG cc;

    block.shvcode = RXSHV_SYFET;
    block.shvret = RXSHV_OK;
    block.shvnext = NULL;
    block.shvname = *rxVariable;
    block.shvnamelen = block.shvname.strlength;
    block.shvvalue = *rxString;
    block.shvvaluelen = 0;

    cc = RexxVariablePool(&block);

    if (cc == REXXAPI_OK) *rxString = block.shvvalue;

    return cc;
}


// SignedToRxResult -- Convert a numeric code to Result.
//
//      Return: return of 'StringToRxResult'
//
ULONG SignedToRxResult(
    LONG number,                        // Code to convert.
    PRXSTRING rxResult)                 // REXX function result.
{
    UCHAR string[34];
    ULONG cc;

    _ltoa(number, string, 10);

    cc = StringToRxResult(string, strlen(string), rxResult);
    return cc;
}


// SignedToRxVariable -- Convert a signed number into a REXX String.
//
//      Return: REXX Variable Pool return code
//
ULONG SignedToRxVariable(
    LONG number,
    PRXSTRING rxName)
{
    UCHAR string[34];
    ULONG cc;

    _ltoa(number, string, 10);

    cc = StringToRxVariable(string, strlen(string), rxName);
    return cc;
}


// StringToRxResult -- Copy a string to Result.
//
//      Return: REXX return code
//
ULONG StringToRxResult(
    const char *string,                 // String to return as REXX result.
    LONG length,                        // Length of REXX result.
    PRXSTRING rxResult)                 // REXX result.
{
    if (string != NULL && length < 0) length = strlen(string);

    if (rxResult == NULL) {
        ;
    }
    else if ((string == NULL || (USHORT)length == 0) && rxResult->strptr != NULL) {
        rxResult->strptr[0] = '\0';
        rxResult->strlength = 0;
    }
    else if (rxResult->strptr != NULL && (USHORT)length < rxResult->strlength) {
        memcpy(rxResult->strptr, string, (USHORT)length);
        rxResult->strptr[(USHORT)length] = '\0';
        rxResult->strlength = (USHORT)length;
    }
    else {
        PVOID mem;
        APIRET rc;

        rc = DosAllocMem(
            &mem,
            (USHORT)length + 1,
            PAG_COMMIT | PAG_WRITE | PAG_READ);
        if (rc != NO_ERROR) {
            if (rxResult->strptr != NULL) rxResult->strptr[0] = '\0';
            rxResult->strlength = 0;

            return REXXAPI_NOMEM;
        }

        rxResult->strptr = mem;
        memcpy(rxResult->strptr, string, (USHORT)length);
        rxResult->strptr[(USHORT)length + 1] = '\0';
        rxResult->strlength = (USHORT)length;
    }

    return REXXAPI_OK;
}


// StringToRxVariable -- Store a string into a REXX variable.
//
//      Return: REXX Variable Pool return code
//
ULONG StringToRxVariable(
    const char *string,
    LONG length,
    PRXSTRING rxName)
{
    SHVBLOCK block;
    ULONG cc;

    if (string != NULL && length < 0) length = strlen(string);

    block.shvcode = RXSHV_SYSET;
    block.shvret = RXSHV_OK;
    block.shvnext = NULL;
    block.shvname = *rxName;
    block.shvnamelen = block.shvname.strlength;
    block.shvvalue.strptr = (PCH)string;
    block.shvvalue.strlength = (USHORT)length;
    block.shvvaluelen = (USHORT)length;

    cc = RexxVariablePool(&block) & ~RXSHV_NEWV;
    return cc;
}


// StringToSigned -- Convert a string to a signed number.
//
//      Return: TRUE if 'string' is a signed number.
//
BOOL StringToSigned(
    const char *string,
    LONG length,
    PLONG number)
{
    BOOL negative = FALSE;
    BOOL success;

    if (string != NULL && length < 0) length = strlen(string);

    while (length > 0 && (*string == ' ' || *string == '\t'))
        ++string, --length;
    if (length > 0)
        if (*string == '+') ++string, --length;
        else if (*string == '-') {
            negative = TRUE;
            ++string, --length;
        }

    success = StringToUnsigned(string, length, (PULONG)number);
    if (success && *number < 0) success = FALSE;
    if (success && negative) *number = -*number;

    return success;
}


// StringToUnsigned -- Convert a string to an unsigned number.
//
//      Return: TRUE if 'string' is an unsigned number.
//
BOOL StringToUnsigned(
    const char *string,
    LONG length,
    PULONG number)
{
    BOOL success = TRUE;

    if (string != NULL && length < 0) length = strlen(string);

    while (length > 0 && (*string == ' ' || *string == '\t'))
        ++string, --length;

    *number = 0;
    while (length > 0) {
        char digit = *string;
        ULONG newValue;

        if (digit < '0' || '9' < digit) {
            success = FALSE;
            break;
        }

        digit -= '0';
        newValue = *number * 10 + digit;

        if (newValue < *number) {
            success = FALSE;
            break;
        }
        *number = newValue;

        ++string, --length;
    }

    return success;
}


// UnsignedToRxResult -- Convert a numeric code to Result.
//
//      Return: return of 'StringToRxResult'
//
ULONG UnsignedToRxResult(
    ULONG number,                       // Code to convert.
    PRXSTRING rxResult)                 // REXX function result.
{
    UCHAR string[34];
    ULONG cc;

    _ultoa(number, string, 10);

    cc = StringToRxResult(string, strlen(string), rxResult);
    return cc;
}


// UnsignedToRxVariable -- Convert an unsigned number into a REXX String.
//
//      Return: REXX Variable Pool return code
//
ULONG UnsignedToRxVariable(
    ULONG number,
    PRXSTRING rxName)
{
    UCHAR string[34];
    ULONG cc;

    _ultoa(number, string, 10);

    cc = StringToRxVariable(string, strlen(string), rxName);
    return cc;
}


// $Log: rxapiutl.c,v $
// Revision 1.7  1997/04/26 13:09:44  SFB
// Bug in QueuePeek found and corrected.
//
// Revision 1.6  1996/01/14 12:22:11  SFB
// Corrects keyword recognition bug.
//
// Revision 1.5  1995/09/27 07:52:16  SFB
// Split return instructions.
//
// Revision 1.4  1995/09/17 13:26:18  SFB
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

