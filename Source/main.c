/***************************************************************************//*!
* \file main.c
* \author 
* \copyright . All Rights Reserved.
* \date 10/15/2025 11:37:28 AM
* \brief Used to create an example of how the library should be used
* 
* Main should contain a series of functions from the library demonstrating how
* 	its expected to be used. Make sure to comment adequetly if anything might be
* 	confusing. It should cover every public function of the library.
* 
* If there is a debug panel for the library, also add the ability to launch
* 	it as a standalone application.
* 
* To use main.c, include it in the build and change the build target to Executable
*******************************************************************************/

//! \cond
/// REGION START HEADER
//! \endcond
//==============================================================================
// Include files

#include "TestLib.h"
#include <formatio.h>
#include <ansi_c.h>
#include <cvirte.h>		
#include <userint.h>
#include "toolbox.h"
#include <string.h>

//==============================================================================
// Constants

//==============================================================================
// Types

//==============================================================================
// Static global variables

//==============================================================================
// Static functions

static void usage (char *name)
{
	fprintf (stderr, "usage: %s <argument>\n", name);
	fprintf (stderr, "A short summary of the functionality.\n");
	fprintf (stderr, "    <argument>    is an argument\n");
	fprintf (stderr, "Order of operation: Change based on library\n");
	fprintf (stderr, "flag: function 1\n");
	fprintf (stderr, "flag: function 2\n");
	exit (1);
}

//==============================================================================
// Global variables

//==============================================================================
// Global functions

//! \cond
/// REGION END

/// REGION START Main
//! \endcond
int main (int argc, char *argv[])
{
	char errmsg[ERRLEN] = {0};
	fnInit;
	
	fprintf (stderr, "Use --help to see instructions\n");
	if(argc > 1 && (!strcmp(argv[1], "--help") || !strcmp(argv[1], "-h")))
		usage(argv[0]);
	
	fprintf (stderr, "Initializing Library\n");
	tsErrChk (Initialize_TestLib(errmsg),errmsg);
	fprintf (stderr, "Library Initialized\n");

Error:
	/* clean up */
	if (error)
	{
		fprintf (stderr, errmsg);
		GetKey();
	}
	return error;
}
//! \cond
/// REGION END
//! \endcond