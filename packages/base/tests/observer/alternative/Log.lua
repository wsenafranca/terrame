-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.

-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.

-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this software and its documentation.
--
-------------------------------------------------------------------------------------------

return{
	Log = function(unitTest)
		local c = Cell{value = 5}

		local error_func = function()
			Log(2)
		end
		unitTest:assertError(error_func, namedArgumentsMsg())

		error_func = function()
			Log{}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("target"))

		local e = Event{action = function() end}
		error_func = function()
			Log{target = e}
		end
		unitTest:assertError(error_func, "Invalid type. Log only works with Cell, CellularSpace, Agent, and Society.")

		error_func = function()
			Log{target = c, select = 5}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("select", "table", 5))

		error_func = function()
			Log{target = c, overwrite = 5}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("overwrite", "boolean", 5))

		error_func = function()
			Log{target = c, select = "mvalue"}
		end
		unitTest:assertError(error_func, "Selected element 'mvalue' does not belong to the target.")

		error_func = function()
			Log{target = c, select = {}}
		end
		unitTest:assertError(error_func, "Log must select at least one attribute.")

		error_func = function()
			Log{target = c, file = 2}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("file", "string", 2))

		error_func = function()
			Log{target = c, separator = 2}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("separator", "string", 2))

		local unit = Cell{}

		error_func = function()
			Log{target = unit}
		end
		unitTest:assertError(error_func, "The target does not have at least one valid attribute to be used.")
	end
}

