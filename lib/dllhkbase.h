/*
A part of Elten - EltenLink / Elten Network desktop client.
Copyright (C) 2014-2021 Dawid Pieper
Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 
*/

#ifndef _DLLHKBASE_H_
#define _DLLHKBASE_H_
#include <windows.h>

#define DLLIMPORT __declspec(dllexport)

typedef struct HKEntry {
int id;
UINT modifiers;
UINT vk;
} HKEntry;

extern "C" {
int DLLIMPORT initHK(HKEntry *entries, int size);
void DLLIMPORT destroyHK(void);
WPARAM DLLIMPORT getHK();
}
#endif