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

Model_ = {
	--- Function to show a graphical interface to configure the parameters of a given Model.
	-- This function can be used in scripts that implement a Model. If the Model belongs to
	-- a package, then it should not be called, as TerraME will do it automatically when one
	-- selects the Model to be configured.
	-- @usage -- DONTRUN
	-- Tube = Model{
	--     initialWater = 20,
	--     flow = 1,
	--     finalTime = 20,
	--     execute = function(model)
	--         model.water = model.water - model.flow
	--     end,
	--     init = function(model)
	--         model.water = model.initialWater
	--
	--         model.chart = Chart{target = model, select = "water"}
	--
	--         model.timer = Timer{
	--             Event{action = model},
	--             Event{action = model.chart}
	--         }
	--     end
	-- }
	--
	-- Tube:configure()
	configure = function()
	end,
	--- User-defined function to execute the Model in a given time step. It is useful
	-- when using the Model as an action for a given Event.
	-- @usage Tube = Model{
	--     water = 20,
	--     flow = 1,
	--     finalTime = 20,
	--     execute = function(model)
	--         model.water = model.water - model.flow
	--     end,
	--     init = function (model)
	--         model.chart = Chart{
	--             target = model,
	--             select = "water"
	--         }
	--     end
	-- }
	execute = function()
	end,
	--- Return if a Model uses random numbers. This can be configured with the argument random
	-- while creating a Model.
	-- @usage RandomModel = Model{
	--     random = true,
	--     finalTime = 10,
	--     init = function(model)
	--         model.timer = Timer{
	--             Event{action = function()
	--                 print(Random():number())
	--             end}
	--        }
	--     end
	-- }
	--
	-- print(RandomModel:isRandom())
	isRandom = function()
	end,
	--- Run the Model instance. It requires that the Model instance has attribute finalTime.
	-- @usage Tube = Model{
	--     initialWater = 200,
	--     flow = 20,
	--     init = function(model)
	--         model.finalTime = 10
	--
	--         model.timer = Timer{
	--             Event{action = function()
	--                 -- ...
	--             end}
	--         }
	--     end
	-- }
	--
	-- m = Tube{initialWater = 100, flow = 10}
	--
	-- m:run()
	run = function(self)
		forEachOrderedElement(self, function(_, value, mtype)
			if mtype == "Timer" then
				value:run(self.finalTime)
				return false
			elseif mtype == "Environment" then
				local found = false
				forEachElement(value, function(_, _, mmtype)
					if mmtype == "Timer" then
						found = true
						return false
					end
				end)

				if found then
					value:run(self.finalTime)
					return false
				end
			end
		end)
	end,
	--- User-defined function to create the objects of the Model. It is recommended that
	-- all the created objects should be placed in the model instance itself, to guarantee
	-- the content of the Model into a single object. It is also possible to verify
	-- whether the model has correct arguments. The internal verification of Model ensures that
    -- the type of the arguments is valid, acording to the definition of the Model.
    -- See Utils:toLabel(), for using names of arguments
    -- in error messages when building a Model to work with graphical interfaces.
	-- This function is executed automatically when one instantiates a given Model.
	-- @usage Tube = Model{
	--     initialWater = 200,
	--     flow = 20,
	--     init = function(model)
	--         verify(model.flow < model.initialWater, toLabel("flow").." should be less than "..toLabel("initialWater")..".")
	--         model.finalTime = 10
	--         model.timer = Timer{
	--             Event{action = function()
	--                 -- ...
	--             end}
	--         }
	--     end
	-- }
	--
	-- m = Tube{initialWater = 100, flow = 10}
	-- print(m.finalTime) -- 10
	-- @see ErrorHandling:verify
	-- @see ErrorHandling:customError
	init = function()
	end,
	--- Return the parameters of the Model as they were defined. The result must not
	-- be changed, otherwise it might affect the Model itself.
	-- @usage model = Model{
	--     par1 = 3,
	--     par2 = Choice{"low", "medium", "high"},
	--     par3 = {min = 3, max = 5},
	--     finalTime = 20,
	--     init = function(model)
	--         model.timer = Timer{
	--             Event{action = function()
	--                 -- ...
	--             end}
	--         }
	--     end
	-- }
	--
	-- params = model:getParameters()
	-- print(params.par1)
	-- print(type(params.par2))
	-- print(params.init) -- nil
	getParameters = function()
	end,
	--- User-defined function to define the distribution of components in the graphical
	-- interface. If this function is not
	-- implemented in the Model, the components will be distributed automatically. This function
	-- should return a table with tables composed by strings. Each position of the table describes
	-- a column of components in the interface.
	-- In the example below, the first column of the graphical interface will show the string
	-- argument in the top ("mapFile") and the three arguments of "agents" in the bottom of the
	-- first column. The second column will contain the arguments of "block" in the top and the
	-- boolean argument ("showGraphics") in the bottom. The elements that do not belong to the
	-- table will not be shown in the graphical interface (in the example, "season").
	-- Note that all Compulsory arguments must belong to the graphical interface to allow
	-- instantiate Model instances properly.
	-- @usage -- DONTRUN
	-- Sugarscape = Model{
	--     mapFile        = "sugar-map.csv",
	--     showGraphics   = true,
	--     agents = {
	--         quantity   = 10,
	--         wealth     = Choice{min = 5, max = 25},
	--         metabolism = Choice{min = 1, max = 4}
	--     },
	--     block = {
	--         xmin       = 0,
	--         xmax       = math.huge,
	--         ymin       = 0,
	--         ymax       = math.huge
	--     },
	--     season = {
	--         summerGrowthRate = 1,
	--         winterGrowthRate = 0.125
	--     },
	--     interface = function()
	--         return {
	--             {"string", "agents"},
	--             {"block", "boolean"}
	--         }
	--     end,
	--     init = function(model)
	--         model.timer = Timer{
	--             Event{action = function() end}
	--         }
	--     end
	-- }
	--
	-- Sugarscape:configure()
	interface = function()
	end,
	--- Notify the Observers of the Model instance.
	-- @arg modelTime A number representing the notification time. The default value is zero.
	-- It is also possible to use an Event as argument. In this case, it will use the result of
	-- Event:getTime().
	-- @usage Tube = Model{
	--     water = 200,
	--     init = function(model)
	--         model.finalTime = 100
	--
	--         Chart{
	--             target = model,
	--             select = "water"
	--         }
	--
	--         model.timer = Timer{
	--             Event{action = function(ev)
	--                 model.water = model.water - 1
	--                 model:notify(ev)
	--             end}
	--         }
	--     end
	-- }
	--
	-- scenario1 = Tube{water = 100}
	--
	-- scenario1:run()
	notify = function(self, modelTime)
		self.cObj_:notify(modelTime) -- SKIP
	end,
	--- Return a title for the Model instance according to its parameters.
	-- It uses only the parameters that are different from the default values.
	-- If the Model was instantiated without any parameter, its title will be "default".
	-- @usage Tube = Model{
	--     water = 200,
	--     init = function(model)
	--         model.finalTime = 100
	--
	--         Chart{
	--             target = model,
	--             select = "water"
	--         }
	--
	--         model.timer = Timer{
	--             Event{action = function(ev)
	--                 model.water = model.water - 1
	--                 model:notify(ev)
	--             end}
	--         }
	--     end
	-- }
	--
	-- scenario1 = Tube{water = 100}
	-- print(scenario1:title()) -- "water = 100"
	title = function()
	end
}

--- Type that defines a model. The user can use Model to describe the arguments of a model
-- and how it can be built. The returning value of a Model is an object that can be used
-- directly to simulate (as long as it does not have any Mandatory parameter) or used to create
-- as many instances as needed to simulate the Model with different parameters.
-- A tutorial about Models in TerraME is available at
--  http://github.com/pedro-andrade-inpe/terrame/wiki/Models.
-- @arg attrTab.finalTime A number with the final time of the simulation.
-- If the Model does not have this as argument, it must be defined within function Model:init().
-- @arg attrTab.random An optional boolean value indicating that the model uses random numbers.
-- The default value is false.
-- @arg attrTab.init A mandatory function to describe how an instance of Model is created.
-- @arg attrTab.execute An optional function to define the changes of the Model in each time step.
-- it the Model does not have a Timer after Model:init() but it has this function, a Timer will
-- be automatically created and will add an Event with the Model as its action.
-- @arg attrTab.interface. An optional function to describe how the graphical interface is
-- displayed. See Model:interface().
-- See Model:init(). If the Model does not have argument finalTime, this function should
-- create the attribute finalTime to allow the Model instance to be run.
-- @arg attrTab.... Arguments of the Model. The values of each
-- argument have an associated semantic. See the table below:
-- @tabular ...
-- Attribute type & Description & Default value \
-- number or bool & The instance has to belong to such type. & The value itself. \
-- string & The instance has to be a string. If it is in the format "*.a;*.b;...", it
-- describes a file extension. The modeler then has to use a filename as argument with one of the
-- extensions defined by this string. & The value itself. \
-- Choice & The instance must have a value that belongs to the Choice. & The default value of the Choice. \
-- Mandatory & A mandatory argument, which means that the use must use a value witht the type
-- defined in the Mandatory to build the model instance correctly. If Mandatory is "table", then
-- the model instance must have all its elements belonging to the same type. & No default value.\
-- named table & It will verify each attribute according to the rules above. & The table itself.
-- It is possible to define only part of the table in the instance, keeping the other default values. \
-- @output parent The Model used to create the object. This object only exists in the Model instance,
-- but not in the Model itself.
-- @usage Tube = Model{
--     initialWater = 20,
--     flow = 1,
--     finalTime = 20,
--     init = function(model)
--         model.water = model.initialWater
--
--         model.chart = Chart{target = model, select = "water"}
--
--         model:notify()
--         model.timer = Timer{
--             Event{action = function()
--                 model.water = model.water - model.flow
--              end},
--             Event{action = model.chart}
--         }
--     end
-- }
--
-- print(type(Tube)) -- "Model"
-- Tube:run() -- One can run a Model directly...
--
-- MyTube = Tube{initialWater = 50} -- ... or create instances using it
-- print(type(MyTube)) -- "Tube"
-- print(MyTube:title()) -- "Initial Water = 50"
-- MyTube:run()
--
-- pcall(function() MyTube2 = Tube{initialwater = 100} end)
-- -- Warning: Argument 'initialwater' is unnecessary. Do you mean 'initialWater'?
-- -- (when executing TerraME with mode=strict)
--
-- _, err = pcall(function() MyTube2 = Tube{flow = false} end)
-- print(err)
-- -- Error: Incompatible types. Argument 'flow' expected number, got boolean.
function Model(attrTab)
	if type(attrTab.interface) == "function" then
		local minterface = attrTab.interface()
		local elements = {}

		if type(minterface) ~= "table" then
			customError("The returning value of interface() should be a table, got "..type(minterface)..".")
		end

		forEachElement(minterface, function(_, value, mtype)
			if mtype ~= "table" then
				customError("There is an element in the interface() that is not a table.")
			end

			forEachElement(value, function(_, mvalue, mmtype)
				if mmtype ~= "string" then
					customError("All the elements in each interface() vector should be string, got "..mmtype..".")
				end

				if elements[mvalue] then
					customError("Argument '"..mvalue.."' cannot be displayed twice in the interface().")
				else
					elements[mvalue] = true
				end

				if belong(mvalue, {"string", "number", "boolean", "Choice", "Mandatory"}) then
					local found = false
					forEachElement(attrTab, function(_, _, attrtype)
						if attrtype == mvalue then
							found = true
							return false
						end
					end)

					if not found then
						customWarning("There is no argument '"..mvalue.."' in the Model, although it is described in the interface().")
					end
				else -- named table
					if attrTab[mvalue] == nil then
						customError("interface() element '"..mvalue.."' is not an argument of the Model.")
					elseif type(attrTab[mvalue]) ~= "table" then
						customError("interface() element '"..mvalue.."' is not a table in the Model.")
					elseif #attrTab[mvalue] > 0 then
						customError("interface() element '"..mvalue.."' is a vector in the Model.")
					elseif getn(attrTab[mvalue]) == 0 then
						customError("interface() element '"..mvalue.."' is empty in the Model.")
					end
				end
			end)
		end)
	end

	if attrTab.finalTime ~= nil then
		local t = type(attrTab.finalTime)
		if t == "Choice" then
			if type(attrTab.finalTime.default) ~= "number" then
				customError("finalTime can only be a Choice with 'number' values, got '"..type(attrTab.finalTime.default).."'.")
			end
		elseif t == "Mandatory" then
			if attrTab.finalTime.value ~= "number" then
				customError("finalTime can only be Mandatory('number'), got Mandatory('"..attrTab.finalTime.value.."').")
			end
		else
			optionalTableArgument(attrTab, "finalTime", "number")
		end
	end

	if attrTab.random ~= nil then
		defaultTableValue(attrTab, "random", false)
	end

	forEachElement(attrTab, function(name, value, mtype)
		if mtype == "table" then
			forEachElement(value, function(iname, _, itype)
				if type(iname) ~= "string" then
					customError("It is not possible to use a vector in a Model (parameter '"..name.."').")
				elseif not belong(itype, {"Choice", "Mandatory", "number", "string", "function", "boolean"}) then
					customError("Type "..itype.." (parameter '"..name.."."..iname.."') is not supported as argument of Model.")
				end
			end)
		elseif not belong(mtype, {"Choice", "Mandatory", "number", "string", "function", "boolean"}) then
			customError("Type "..mtype.." (parameter '"..name.."') is not supported as argument of Model.")
		end
	end)

	mandatoryTableArgument(attrTab, "init", "function")
	optionalTableArgument(attrTab, "execute", "function")

	if attrTab.title then customError("'title' cannot be an argument for a Model.") end
	if attrTab.getParameters then customError("'getParameters' cannot be an argument for a Model.") end

	local function getExtensions(value)
		local extensions = {}
		local i = 1
		while i <= value:len() do
			if value:sub(i, i) == "." and value:sub(i - 1, i - 1) == "*" then
				local j = i + 1
				while value:sub(j, j) ~= ";" and j <= value:len() do
					j = j + 1
				end

				if value:sub(j, j) == ";" then
					table.insert(extensions, value:sub(i + 1, j - 1))
				else
					table.insert(extensions, value:sub(i + 1, j))
				end
			end
			i = i + 1
		end
		return extensions
	end

	local model

	local callFunction = function(_, v)
		if v == nil then v = {} end

		if type(v) ~= "table" then
			customError("Models can only be instantiated using a 'table' as argument, got '"..type(v).."'.")
		end

		return model(v, debug.getinfo(1).name)
	end

	local random = attrTab.random
	attrTab.random = nil

	local indexFunction = function(mmodel, v) -- in this case, the type of this model will be "model"
		local options = {
			run = function()
				local m = mmodel{}
				m:run()
				return m
			end,
			configure = function()
				_Gtme.configure(mmodel, "model") -- SKIP
			end,
			interface = function()
				if attrTab.interface then
					return attrTab.interface()
				end
			end,
			isRandom = function()
				return random
			end,
			getParameters = function()
				local result = {}

				forEachElement(attrTab, function(idx, value, mtype)
					if mtype ~= "function" then
						result[idx] = value
					end
				end)

				return result
			end
		}

		local mresult = options[v]

		if not mresult then
			mresult = rawget(mmodel, v)
			if not mresult and v ~= "interface" then
				customError("It is not possible to call any function from a Model but run() or configure().")
			end
		end
		return mresult
	end

	local tostringFunction = function()
		return _Gtme.tostring(attrTab)
	end

	local mmodel = {type_ = "Model"}
	setmetatable(mmodel, {
		__call = callFunction,
		__index = indexFunction,
		__tostring = tostringFunction
	})

	model = function(argv, typename)
		if #argv > 0 then
			customError("All the arguments must be named.")
		end

		-- verify whether there are some arguments in the instance that do not belong to the Model
		local names = {}
		forEachElement(attrTab, function(name)
			table.insert(names, name)
		end)

		verifyUnnecessaryArguments(argv, names)

		forEachElement(argv, function(name, value, mtype)
			if mtype == "table" then
				local attrTabValue = attrTab[name]

				if type(attrTabValue) ~= "table" then
					return -- this error will be shown later on
				end

				-- unnecessary arguments will be removed after forEachElement
				-- to avoid problems changing a table while traversing it
				local remove = {}

				forEachElement(value, function(mname)
					if attrTabValue[mname] == nil then
						remove[mname] = true
						local msg = "Argument '"..name.."."..mname.."' is unnecessary."
						local s = suggestion(mname, attrTabValue)

						if s then
							msg = msg.." Do you mean '"..name.."."..s.."'?"
						end

						customWarning(msg)
					end
				end)

				forEachElement(remove, function(idx)
					value[idx] = nil
				end)
			end
		end)

		-- set the default values
		optionalTableArgument(argv, "finalTime", "number")

		forEachElement(attrTab, function(name, value, mtype)
			if mtype == "Choice" then
				if argv[name] == nil then
					argv[name] = value.default
				end
			elseif mtype == "Mandatory" then
				if argv[name] == nil then
					mandatoryArgumentError(name)
				end
			elseif mtype == "table" then
				defaultTableValue(argv, name, {})

				local iargv = argv[name]

				forEachElement(value, function(iname, ivalue, itype)
					if itype == "Choice" and iargv[iname] == nil then
						iargv[iname] = ivalue.default
					elseif itype == "Mandatory" and iargv[iname] == nil then
						mandatoryArgumentError(name.."."..iname)
					elseif iargv[iname] == nil and itype ~= "string" then
						iargv[iname] = ivalue
					end
				end)
			elseif argv[name] == nil and mtype ~= "string" then
				argv[name] = value
			end
		end)

		local namedChoices = {}

		forEachElement(attrTab, function(idx, value, mtype)
			if mtype == "Choice" and value.values and #value.values == 0 then
				namedChoices[idx] = true
			end
		end)

		-- check types and values
		forEachOrderedElement(attrTab, function(name, value, mtype)
			if namedChoices[name] then
				if type(argv[name]) ~= type(value.default) then
					incompatibleTypeError(name, type(value.default), argv[name])
				elseif value.values[argv[name]] == nil then
					local str = "one of {"
					forEachOrderedElement(value.values, function(v)
						str = str.."'"..v.."', "
					end)

					str = string.sub(str, 1, str:len() - 2).."}"
					incompatibleValueError(name, str, argv[name])
				else
					argv[name] = value.values[argv[name]] -- updating idx by its value
				end
			elseif mtype == "Choice" then
				if value.values then
					if type(argv[name]) ~= type(value.default) then
						incompatibleTypeError(name, type(value.default), argv[name])
					elseif not belong(argv[name], value.values) then
						local str = "one of {"
						forEachElement(value.values, function(_, v)
							str = str..v..", "
						end)

						str = string.sub(str, 1, str:len() - 2).."}"
						incompatibleValueError(name, str, argv[name])
					end
				else
					if type(argv[name]) ~= "number" then
						incompatibleTypeError(name, "number", argv[name])
					elseif value.min and argv[name] < value.min then
						customError("Argument "..toLabel(name).." should be greater than or equal to "..value.min..".")
					elseif value.max and argv[name] > value.max then
						customError("Argument "..toLabel(name).." should be less than or equal to "..value.max..".")
					elseif value.step then
						local remainder = (argv[name] - value.min) % value.step

						if math.abs(remainder - value.step) < sessionInfo().round then
							-- There is a problem in Lua with operator % using numbers between 0 and 1
							-- For example, 0.7 % 0.1 == 0.1, but should be 0.0. That's why we need
							-- to multiplicate by 1000 above
							remainder = remainder - value.step
						end

						if math.abs(remainder) > sessionInfo().round then
							customError("Invalid value for argument "..toLabel(name).." ("..argv[name]..").")
						end
					end
				end
			elseif mtype == "Mandatory" then
				if type(argv[name]) ~= value.value then
					incompatibleTypeError(name, value.value, argv[name])
				end
			elseif mtype == "string" then
				local e = getExtensions(value)

				if #e > 0 then
					if type(argv[name]) == "string" then
						argv[name] = File(argv[name])
					end

					mandatoryTableArgument(argv, name, "File")
					local ext = argv[name]:extension()

					if ext == "" then
						customError("No file extension for parameter "..toLabel(name)..". It should be one of '"..value.."'.")
					elseif not belong(ext, e) then
						customError("Invalid file extension for parameter "..toLabel(name)..". It should be one of '"..value.."'.")
					elseif not argv[name]:exists() then
						resourceNotFoundError(toLabel(name), argv[name])
					end
				elseif argv[name] == nil then
					argv[name] = attrTab[name]
				end
			elseif mtype == "table" and #value == 0 then
				local internalNamedChoices = {}

				forEachElement(attrTab[name], function(idx, ivalue, imtype)
					if imtype == "Choice" and ivalue.values and #ivalue.values == 0 then
						internalNamedChoices[idx] = true
					end
				end)

				local iargv = argv[name]
				forEachOrderedElement(value, function(iname, ivalue, itype)
					if internalNamedChoices[iname] then
						if type(iargv[iname]) ~= type(ivalue.default) then
							incompatibleTypeError(iname, type(ivalue.default), iargv[iname])
						elseif ivalue.values[iargv[iname]] == nil then
							local str = "one of {"
							forEachOrderedElement(ivalue.values, function(v)
								str = str.."'"..v.."', "
							end)

							str = string.sub(str, 1, str:len() - 2).."}"
							incompatibleValueError(iname, str, iargv[iname])
						else
							iargv[iname] = ivalue.values[iargv[iname]] -- updating idx by its value
						end
					elseif itype == "Choice" then
						if ivalue.values then
							if type(iargv[iname]) ~= type(ivalue.default) then
								incompatibleTypeError(name.."."..iname, type(ivalue.default), iargv[iname])
							elseif not belong(iargv[iname], ivalue.values) then
								local str = "one of {"
								forEachElement(ivalue.values, function(_, v)
									str = str..v..", "
								end)
								str = string.sub(str, 1, str:len() - 2).."}"
								incompatibleValueError(name.."."..iname, str, iargv[iname])
							end
						else
							if type(iargv[iname]) ~= "number" then
								incompatibleTypeError(name.."."..iname, "number", iargv[iname])
							elseif ivalue.min and iargv[iname] < ivalue.min then
								customError("Argument "..toLabel(iname, name).." should be greater than or equal to "..ivalue.min..".")
							elseif ivalue.max and iargv[iname] > ivalue.max then
								customError("Argument "..toLabel(iname, name).." should be less than or equal to "..ivalue.max..".")
							elseif ivalue.step then
								local remainder = (iargv[iname] - ivalue.min) % ivalue.step

								if math.abs(remainder - ivalue.step) < sessionInfo().round then
									remainder = remainder - ivalue.step
								end

								if remainder > sessionInfo().round then
									customError("Invalid value for argument "..toLabel(iname, name).." ("..iargv[iname]..").")
								end
							end
						end
					elseif itype == "Mandatory" then
						if type(iargv[iname]) ~= ivalue.value then
							incompatibleTypeError(name.."."..iname, ivalue.value, iargv[iname])
						end
					elseif itype == "string" then
						local e = getExtensions(ivalue)

						if type(iargv[iname]) == "string" then
							iargv[iname] = File(iargv[iname])
						end

						if #e > 0 then
							if type(iargv[iname]) ~= "File" then
								if iargv[iname] == nil then
									mandatoryArgumentError(toLabel(iname, name))
								else
									incompatibleTypeError(name.."."..iname, "File", iargv[iname])
								end
							end

							mandatoryTableArgument(iargv, iname, "File")
							local ext = iargv[iname]:extension()

							if ext == "" then
								customError("No file extension for parameter "..toLabel(iname, name)..". It should be one of '"..ivalue.."'.")
							elseif not belong(ext, e) then
								customError("Invalid file extension for parameter "..toLabel(iname, name)..". It should be one of '"..ivalue.."'.")
							elseif not iargv[iname]:exists() then
								resourceNotFoundError(toLabel(iname, name), iargv[iname])
							end
						elseif iargv[iname] == nil then
							iargv[iname] = attrTab[name][iname]
						end
					elseif itype ~= type(iargv[iname]) then
						incompatibleTypeError(name.."."..iname, itype, iargv[iname])
					end
				end)
			elseif type(argv[name]) ~= mtype then
				incompatibleTypeError(name, mtype, argv[name])
			end
		end)

		argv.run = attrTab.run
		argv.type_ = typename
		argv.parent = mmodel

		argv.cObj_ = TeCell()
		argv.cObj_:setReference(argv)

		argv.notify = function(self, modelTime)
			if modelTime == nil then
				modelTime = 0
			elseif type(modelTime) == "Event" then
				modelTime = modelTime:getTime()
			else
				optionalArgument(1, "number", modelTime)
				positiveArgument(1, modelTime, true)
			end

			if self.obsattrs_ then
				forEachElement(self.obsattrs_, function(idx)
					self[idx.."_"] = self[idx](self)
				end)
			end

			self.cObj_:notify(modelTime)
		end

		local parameters = argv.parent:getParameters()
		local titleStr = ""

		forEachOrderedElement(parameters, function(idx, value, mtype)
			if mtype == "Choice" then
				if value.values and #value.values == 0 then -- Choice with named values
					if value.values[value.default] ~= argv[idx] then
						forEachElement(value.values, function(midx, mvalue)
							if argv[idx] == mvalue then
								titleStr = table.concat{titleStr, _Gtme.stringToLabel(idx), " = ", _Gtme.stringToLabel(midx), ", "}
							end
						end)
					end
				elseif argv[idx] ~= value.default and idx ~= "finalTime" then
					if type(argv[idx]) == "string" then
						titleStr = table.concat{titleStr, _Gtme.stringToLabel(idx), " = ", _Gtme.stringToLabel(argv[idx]), ", "}
					else
						titleStr = table.concat{titleStr, _Gtme.stringToLabel(idx), " = ", vardump(argv[idx]), ", "}
					end
				end
			elseif argv[idx] ~= value and idx ~= "finalTime" then
				titleStr = table.concat{titleStr, _Gtme.stringToLabel(idx), " = ", vardump(argv[idx]), ", "}
			end
		end)

		if titleStr == "" then
			titleStr = "Default"
		else
			titleStr = string.sub(titleStr, 1, -3)
		end

		argv.title = function()
			return titleStr
		end

		attrTab.init(argv)

		mandatoryTableArgument(argv, "finalTime", "number")

		-- check whether the model instance has a timer or an Environment with at least one Timer
		local text = ""
		local exec
		forEachOrderedElement(argv, function(name, value, mtype)
			if mtype == "Timer" then
				if text == "" then
					text = "'"..name.."' (Timer)"
					exec = value
				else
					customError("The object has two running objects: '"..name.."' (Timer) and "..text..".")
				end
			elseif mtype == "Environment" then
				forEachElement(value, function(_, _, mmtype)
					if mmtype == "Timer" then
						if text == "" then
							text = "'"..name.."' (Environment)"
							exec = value
							return false
						else
							customError("The object has two running objects: '"..name.."' (Environment) and "..text..".")
						end
					end
				end)
			end
		end)

		if not exec and argv.execute then
			argv.timer_ = Timer{
				Event{action = argv}
			}

			exec = true
		end

		verify(exec, "The object does not have a Timer or an Environment with at least one Timer.")

		setmetatable(argv, {__tostring = _Gtme.tostring})
		return argv
	end

	setmetatable(attrTab, {__index = Model_})

	return mmodel
end

