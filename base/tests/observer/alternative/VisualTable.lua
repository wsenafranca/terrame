-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP.
--
-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.
--
-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or caonsequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: Pedro R. Andrade
-------------------------------------------------------------------------------------------

return{
	VisualTable = function(unitTest)
		local c = Cell{value = 5}

		local error_func = function()
			VisualTable{}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("subject"))

		error_func = function()
			VisualTable{subject = c, select = 5}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("select", "table", 5))

		error_func = function()
			VisualTable{subject = c, select = "mvalue"}
		end
		unitTest:assert_error(error_func, "Selected element 'mvalue' does not belong to the subject.")

		error_func = function()
			VisualTable{subject = c, select = {}}
		end
		unitTest:assert_error(error_func, "VisualTable must select at least one attribute.")

		local unit = Cell{}

		error_func = function()
			VisualTable{subject = unit}
		end
		unitTest:assert_error(error_func, "The subject does not have at least one valid attribute to be used.")
	end
}
