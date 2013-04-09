package.path = package.path .. ";../?.lua;?.lua;lib/?.lua"

local Object = require( "lib.object" )
local power = math.pow
local nroot = function ( num, root )
  return num^(1/root)
end

local teaLifeCalc = Object:extend{
	totalAsset = 0, -- Initial Asset
	totalYear = 30, -- Total Years
	defaultSalary = 60, -- Default Salary
	defaultCost = 20, -- Default Cost
	defaultROR = 1.063, -- Default Invest Rate of Return ( average market index ROR, since 1871 to 1998 )
	defaultInflation = 1.03, -- Default Inflation Rate
	defaultEvent = "", -- Default Event
	yearArray = nil, -- Records In Each Year
	lastYearArray = nil, -- Record last available year for all types
	
	SALARY = "salary", -- Salary CONST
	COST = "Cost", -- Cost CONST
	ROR = "ROR", -- ROR CONST
	INFLATION = "Inflation", -- Inflation CONST
	EVENT = "Event" -- Event CONST
}

function teaLifeCalc:new( obj )
	obj = Object.new( self, obj )
	
	obj.yearArray = {} -- Records In Each Year
	obj.lastYearArray = {} -- Record last available year for all types
	
	return obj
end

function teaLifeCalc:getYearArray( dataType )
	return self.yearArray[ dataType ]
end

function teaLifeCalc:setYearArray( dataType, yearArray )
	self.yearArray[ dataType ] = yearArray
end

function teaLifeCalc:getLastYear( dataType )
	return self.lastYearArray[ dataType ]
end

function teaLifeCalc:setLastYear( dataType, theYear )
	self.lastYearArray[ dataType ] = theYear
end

function teaLifeCalc:initYearArray( dataType, firstYear, firstRecord )
	if self:getYearArray( dataType ) == nil then
		self:setYearArray( dataType, {} ) -- Init it
	end
	
	self:getYearArray( dataType )[ firstYear ] = firstRecord -- Init value
	self:setLastYear( dataType, firstYear ) -- Default last year index is first year
end

function teaLifeCalc:getYearData( dataType, currentYear )
	if self:getYearArray( dataType )[ currentYear ] ~= nil then
		self:setLastYear( dataType, currentYear )
		-- Pointer move to current Year
		return self:getYearArray( dataType )[ currentYear ]
	elseif self:getYearArray( dataType )[ self:getLastYear( dataType ) ] ~= nil then
		-- Return LastYear Value
		return self:getYearArray( dataType )[ self:getLastYear( dataType ) ]
	end
	
	-- There's no data,return nil
	return nil
end

function teaLifeCalc:setYearData( dataType, currentYear, value )
	if self:getYearArray( dataType ) == nil then
		self:initYearArray( dataType, currentYear, value ) -- Init it
	end
	
	self:getYearArray( dataType )[ currentYear ] = value -- Set Data
	
	if self:getLastYear( dataType ) > currentYear then
		self:setLastYear( dataType, currentYear ) -- Last Year must be smallest when setting data.
	end
end

function teaLifeCalc:setSalary( currentYear, value )
	self:setYearData( self.SALARY, currentYear, value )
end

function teaLifeCalc:getSalary( currentYear )
	if self:getYearArray( self.SALARY ) == nil then
		self:setSalary( currentYear, self.defaultSalary ) -- Init it
	end
	
	return self:getYearData( self.SALARY, currentYear )
end

function teaLifeCalc:setCost( currentYear, value )
	self:setYearData( self.COST, currentYear, value )
end

function teaLifeCalc:getCost( currentYear )
	if self:getYearArray( self.COST ) == nil then
		self:setCost( currentYear, self.defaultCost ) -- Init it
	end
	
	return self:getYearData( self.COST, currentYear )
end

function teaLifeCalc:setROR( currentYear, value )
	self:setYearData( self.ROR, currentYear, value )
end

function teaLifeCalc:getROR( currentYear )
	if self:getYearArray( self.ROR ) == nil then
		self:setROR( currentYear, self.defaultROR ) -- Init it
	end
	
	return self:getYearData( self.ROR, currentYear )
end

function teaLifeCalc:setEvent( currentYear, value )
	self:setYearData( self.EVENT, currentYear, value )
end

function teaLifeCalc:getEvent( currentYear )
	if self:getYearArray( self.EVENT ) == nil then
		self:setEvent( currentYear, self.defaultEvent ) -- Init it
	end
	
	return self:getYearData( self.EVENT, currentYear )
end

function teaLifeCalc:setInflation( currentYear, value )
	self:setYearData( self.INFLATION, currentYear, value )
end

function teaLifeCalc:getInflation( currentYear )
	if self:getYearArray( self.INFLATION ) == nil then
		self:setInflation( currentYear, self.defaultInflation ) -- Init it
	end
	
	return self:getYearData( self.INFLATION, currentYear )
end

function teaLifeCalc:calcYearsInflation( targetYear )
	local rate = 1
	for currentYear = 1, targetYear do
		local nowInflation = self:getInflation( currentYear )
		rate = rate * nowInflation
	end
	
	return rate
end

function teaLifeCalc:calcYearsROR( targetYear )
	local rate = 1
	for currentYear = 1, targetYear do
		local nowROR = self:getROR( currentYear )
		rate = rate * nowROR
	end
	
	return nroot( rate, targetYear )
end

function teaLifeCalc:calc()
	local currentYear, totalAsset = 1, self.totalAsset
	print( string.format( "Average ROR:\t%0.2f", self:calcYearsROR( self.totalYear ) ) )
	for currentYear = 1, self.totalYear do
		local totalInflation = self:calcYearsInflation( currentYear )
		local nowSalary = self:getSalary( currentYear ) * totalInflation
		local nowCost = self:getCost( currentYear ) * totalInflation
		local monBalance = nowSalary - nowCost
		local nowROR = self:getROR( currentYear )
		local nowEvent = self:getEvent( currentYear )
		local nowPurchasingPower
		
		totalAsset = totalAsset * nowROR + monBalance
		
		if totalInflation ~= 0 then
			nowPurchasingPower = totalAsset / totalInflation
		else
			nowPurchasingPower = totalAsset
		end
		
		local firstLine = string.format( "Year:\t%d\tSalary:\t%d\tCost:\t%d\tTotal Inflation:\t%0.2f", 
			currentYear, nowSalary, nowCost, totalInflation )
		local secondLine = string.format( "Balance/mon:\t%d\tTotal Asset:\t%0.2f",
			monBalance, totalAsset )
		local thirdLine = string.format( "Purchasing Power:\t%d",
			nowPurchasingPower )
		
		print( string.format( "%s\n%s\n%s\n%s\n",
			firstLine, secondLine, thirdLine, nowEvent ) )
	end
end

return teaLifeCalc