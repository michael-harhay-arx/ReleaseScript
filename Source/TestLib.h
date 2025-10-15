/***************************************************************************//*!
* \file TestLib.h
* \author 
* \copyright . All Rights Reserved.
* \date 10/15/2025 11:37:28 AM
*******************************************************************************/

#ifndef __TestLib_H__
#define __TestLib_H__

#ifdef __cplusplus
    extern "C" {
#endif

//==============================================================================
// Include files

#include "cvidef.h"
#include "ArxtronToolslib.h"

//==============================================================================
// Constants

//==============================================================================
// Types
		
//==============================================================================
// Global vaiables

//==============================================================================
// External variables

//==============================================================================
// Global functions

int TestLib_CheckVersionCompatibility (IN int ExpectedVersionMajor, IN int ExpectedVersionMinor, int *VersionMajor, int *VersionMinor);
int Initialize_TestLib (char errmsg[ERRLEN]);

#ifdef __cplusplus
    }
#endif

#endif  /* ndef __TestLib_H__ */