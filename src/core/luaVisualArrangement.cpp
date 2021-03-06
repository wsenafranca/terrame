/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

This code is part of the TerraME framework.
This framework is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The framework provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this software and its documentation.
*************************************************************************************/

#include "luaVisualArrangement.h"

#include "visualArrangement.h"

#include "luna.h"

#include "terrameGlobals.h"

luaVisualArrangement::luaVisualArrangement(lua_State* L)
{
	luaL = L;
}

luaVisualArrangement::~luaVisualArrangement(void)
{
}

int luaVisualArrangement::setFile(lua_State* L)
{
	string f = luaL_checkstring(L, -1);

	VisualArrangement::getInstance()->setFile(f);

	return 0;
}

int luaVisualArrangement::addPosition(lua_State *L)
{
	int id = luaL_checknumber(L, -3);
	int x  = luaL_checknumber(L, -2);
	int y  = luaL_checknumber(L, -1);

	PositionVisualArrangement s;
	s.x = x;
	s.y = y;

	VisualArrangement::getInstance()->addPosition(id, s);

	return 0;
}

int luaVisualArrangement::addSize(lua_State *L)
{
	int id = luaL_checknumber(L, -3);
	int width  = luaL_checknumber(L, -2);
	int height  = luaL_checknumber(L, -1);

	SizeVisualArrangement s;
	s.width = width;
	s.height = height;

	VisualArrangement::getInstance()->addSize(id, s);

	return 0;
}

