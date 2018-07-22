-- Based on https://github.com/tederis/mta-resources/blob/master/dffframe/bytedata.lua

-- ----------------------------------------------------------------------------
-- Kamil Marciniak <github.com/forkerer> wrote this code. As long as you retain this 
-- notice, you can do whatever you want with this stuff. If we
-- meet someday, and you think this stuff is worth it, you can
-- buy me a beer in return.
-- ----------------------------------------------------------------------------

BinaryConverter = {}
BinaryConverter.metatable = {
    __index = BinaryConverter,
}
setmetatable( BinaryConverter, { __call = function(self,...) return self:Get(...) end } )

function BinaryConverter:Get()
    if not self.instance then
        self.instance = self:New()
    end
    return self.instance
end

function BinaryConverter:New()
	local instance = setmetatable( {}, BinaryConverter.metatable )

	instance.endianness = "littleendian"

	return instance
end

function BinaryConverter:SetEndianness(val)
	if not(val == "bigendian" or val == "littleendian") then return false end
	self.endianness = val
end

-- Converts from string of length 8 to 64bit signed integer
function BinaryConverter:FromInt64(str)
	if self.endianness == "bigendian" then
		local b1,b2,b3,b4,b5,b6,b7,b8 = str:byte(1,8)
		local convertedNumber = b1*0x100000000000000+b2*0x1000000000000+b3*0x10000000000+b4*0x100000000+b5*0x1000000+b6*0x10000+b7*0x100+b8
		if convertedNumber > 0x7FFFFFFFFFFFFFFF then
			convertedNumber = convertedNumber-0x10000000000000000
		end
		return convertedNumber
	elseif self.endianness == "littleendian" then
		local b1,b2,b3,b4,b5,b6,b7,b8 = str:byte(1,8)
		local convertedNumber =  b8*0x100000000000000+b7*0x1000000000000+b6*0x10000000000+b5*0x100000000+b4*0x1000000+b3*0x10000+b2*0x100+b1
		if convertedNumber > 0x7FFFFFFFFFFFFFFF then
			convertedNumber = convertedNumber-0x10000000000000000
		end
		return convertedNumber
	end
	return false
end

-- Converts from string of length 4 to 32bit signed integer
function BinaryConverter:FromInt32(str)
	if self.endianness == "bigendian" then
		local b1,b2,b3,b4 = str:byte(1,4)
		local convertedNumber = b1*0x1000000+b2*0x10000+b3*0x100+b4
		if convertedNumber > 0x7FFFFFFF then
			convertedNumber = convertedNumber-0x100000000
		end
		return convertedNumber
	elseif self.endianness == "littleendian" then
		local b1,b2,b3,b4 = str:byte(1,4)
		local convertedNumber = b4*0x1000000+b3*0x10000+b2*0x100+b1
		if convertedNumber > 0x7FFFFFFF then
			convertedNumber = convertedNumber-0x100000000
		end
		return convertedNumber
	end
	return false
end

-- Converts from string of length 2 to 16bit signed integer
function BinaryConverter:FromInt16(str)
	if self.endianness == "bigendian" then
		local b1,b2 = str:byte(1,2)
		local convertedNumber = b1*0x100+b2
		if convertedNumber > 0x7FFF then
			convertedNumber = convertedNumber-0x10000
		end
		return convertedNumber
	elseif self.endianness == "littleendian" then
		local b1,b2 = str:byte(1,2)
		local convertedNumber = b2*0x100+b1
		if convertedNumber > 0x7FFF then
			convertedNumber = convertedNumber-0x10000
		end
		return convertedNumber
	end
	return false
end

-- Converts from string of length 1 to 8bit signed integer
function BinaryConverter:FromInt8(str)
	local b1 = str:byte(1)
	local convertedNumber = b1
	if convertedNumber > 0x7F then
		convertedNumber = convertedNumber-0x100
	end
	return convertedNumber
end


-- Converts from string of length 8 to 64bit unsigned integer
function BinaryConverter:FromUInt64(str)
	if self.endianness == "bigendian" then
		local b1,b2,b3,b4,b5,b6,b7,b8 = str:byte(1,8)
		local convertedNumber = b1*0x100000000000000+b2*0x1000000000000+b3*0x10000000000+b4*0x100000000+b5*0x1000000+b6*0x10000+b7*0x100+b8
		return convertedNumber
	elseif self.endianness == "littleendian" then
		local b1,b2,b3,b4,b5,b6,b7,b8 = str:byte(1,8)
		local convertedNumber =  b8*0x100000000000000+b7*0x1000000000000+b6*0x10000000000+b5*0x100000000+b4*0x1000000+b3*0x10000+b2*0x100+b1
		return convertedNumber
	end
	return false
end

-- Converts from string of length 4 to 32bit unsigned integer
function BinaryConverter:FromUInt32(str)
	if self.endianness == "bigendian" then
		local b1,b2,b3,b4 = str:byte(1,4)
		local convertedNumber = b1*0x1000000+b2*0x10000+b3*0x100+b4
		return convertedNumber
	elseif self.endianness == "littleendian" then
		local b1,b2,b3,b4 = str:byte(1,4)
		local convertedNumber = b4*0x1000000+b3*0x10000+b2*0x100+b1
		return convertedNumber
	end
	return false
end

-- Converts from string of length 2 to 16bit unsigned integer
function BinaryConverter:FromUInt16(str)
	if self.endianness == "bigendian" then
		local b1,b2 = str:byte(1,2)
		local convertedNumber = b1*0x100+b2
		return convertedNumber
	elseif self.endianness == "littleendian" then
		local b1,b2 = str:byte(1,2)
		local convertedNumber = b2*0x100+b1
		return convertedNumber
	end
	return false
end

-- Converts from string of length 1 to 16bit unsigned integer
function BinaryConverter:FromUInt8(str)
	local b1 = str:byte(1)
	local convertedNumber = b1
	return convertedNumber
end

-- Converts from string of length 4 to 32 bit floating point number
function BinaryConverter:FromFloat(str)
	local b1,b2,b3,b4
	if self.endianness == "bigendian" then
		b1,b2,b3,b4 = str:byte(1,4)
	elseif self.endianness == "littleendian" then
		b4,b3,b2,b1 = str:byte(1,4)
	end
	local mantissa = i2%0x80*0x10000+i3*0x100+i4
	local exp = math.floor(((i1%0x80)*0x100+i2)/0x80)-127
	local convertedNumber = 2^exp*(mantissa/0x800000+1)
	if i1 > 0x80 then -- First bit dictates sign
		convertedNumber = -convertedNumber 
	end
	return convertedNumber
end

-- Converts from string of length 8 to 64 bit floating point number
function BinaryConverter:FromDouble(str)
	local b1,b2,b3,b4,b5,b6,b7,b8
	if self.endianness == "bigendian" then
		b1,b2,b3,b4,b5,b6,b7,b8 = str:byte(1,8)
	elseif self.endianness == "littleendian" then
		b8,b7,b6,b5,b4,b3,b2,b1 = str:byte(1,8)
	end	
	local mantissa = (i2%0x10)*0x1000000000000+i3*0x10000000000+i4*0x100000000+i5*0x1000000+i6*0x10000+i7*0x100+i8
	local exp = math.floor(((i1%0x80)*0x100+i2)/0x10)-1023
	local convertedNumber = 2^exp*(mantissa/(0x10000000000000)+1)
	if i1 > 0x80 then 
		convertedNumber = -convertedNumber 
	end
	return convertedNumber
end

function BinaryConverter:FromCharArray(str)
	--iprint(str)
	local convertedString = str
	local endPoint = str:find('\0')
	if endPoint then 
		convertedString = convertedString:sub(1,endPoint-1) 
	end
	return convertedString
end