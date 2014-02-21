// $RCSfile: rexxmain.c,v $

// $Title: Rexx DLL debugging main. $

// Copyright (c) 1994 Serge Brisson.

#include <rexxsaa.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

static char const rcsid[] =
{
    "$Id: rexxmain.c,v 1.2 1996/01/14 12:02:50 SFB Rel $"
};


// Local prototypes.

APIRET Execute(
    const char *fileName,
    PRXSTRING argList,
    PRXSTRING result,
    PSHORT rc);


// RexxMain main.
//
int main(
    int argc,
    char *argv[])
{
    int argCount;
    RXSTRING argList;
    int arg;
    RXSTRING result;
    APIRET apiret;
    SHORT rc;

    if (argc < 2)
    {
        printf("Usage: RexxMain <rexxfile>\n");
        return (1);
    }

    argCount = argc - 2;
    argList.strlength = 0;
    for (arg = 1; arg <= argCount; ++arg) {
        argList.strlength += strlen(argv[1 + arg]);
        if (arg < argCount) ++argList.strlength;
    }
    argList.strptr = malloc(argList.strlength + 1);
    argList.strptr[0] = '\0';
    for (arg = 1; arg <= argCount; ++arg) {
        strcat(argList.strptr, argv[1 + arg]);
        if (arg < argCount) strcat(argList.strptr, " ");
    }

    result.strptr = NULL;
    result.strlength = 0;

    apiret = Execute(argv[1], &argList, &result, &rc);

    if (apiret != 0)
    {
        printf("RexxStart error: %d.\n", apiret);
    }
    else
    {
        printf("Return code: %d.\n", rc);

        if (result.strptr == NULL)
        {
            printf("No result.\n");
        }
        else
        {
            printf("Result: \"%.*s\".\n", result.strlength, result.strptr);
        }
    }

    system("PAUSE");

    return (0);
}


// Execute.
//
static APIRET Execute(
    const char *fileName,
    PRXSTRING argList,
    PRXSTRING result,
    PSHORT rc)
{
    APIRET apiret;

    apiret = RexxStart(
        1,                              /* Number of arguments. */
        argList,                        /* Arguments. */
        fileName,                       /* Rexx file name. */
        NULL,                           /* Instore. */
        NULL,                           /* Environment name. */
        RXCOMMAND,                      /* Call type. */
        NULL,                           /* Exits. */
        rc,                             /* Rexx return code. */
        result);                        /* Rexx result. */

    return apiret;
}


// Dummy.
//
//      This routine is never called.
//      It is defined to generate an external reference to
//      the RexxIPC library which will not be optimized away
//      by the compiler.
//
void RexxMain_Dummy()
{
    IPCDropFuncs();
}


// $Log: rexxmain.c,v $
// Revision 1.2  1996/01/14 12:02:50  SFB
// Allows procedure parameters.
//
// Revision 1.1  1995/10/21 11:02:35  SFB
// Initial revision

