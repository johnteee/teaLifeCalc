package.path = package.path .. ";../?.lua;?.lua;lib/?.lua"

local teaLifeCalc = require( "lib.teaLifeCalc" )

local myCalc = teaLifeCalc:new()

myCalc:setSalary( 1, 60 ) -- Newbie at Work,Loooow Salary
myCalc:setCost( 1, 20 ) -- Life( one person )
myCalc:setEvent( 1, "Newbie at Work,Loooow Salary\nLife( one person )" )

myCalc:setSalary( 3, 80 ) -- Salary Increased
myCalc:setCost( 3, 80 ) -- Wedding( costs lots money ) & Life( two people )
myCalc:setEvent( 3, "Salary Increased\nWedding( costs lots money )\nLife( two people )" )

myCalc:setCost( 4, 40 ) -- Life( two people )
myCalc:setEvent( 4, "Life( two people )" )

myCalc:setSalary( 5, 90 ) -- Salary Increased
myCalc:setCost( 5, 60 ) -- First child has been borned & Life( three people )
myCalc:setEvent( 5, "Salary Increased\nFirst child has been borned\nLife( three people )" )

myCalc:setEvent( 6, "Life( three people )" )

myCalc:setROR( 1, 1.2 ) -- Invest ROR

myCalc:calc()

myCalc:setROR( 1, 1 ) --No ROR

myCalc:calc()