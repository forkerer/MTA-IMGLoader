-- ----------------------------------------------------------------------------
-- Kamil Marciniak <github.com/forkerer> wrote this code. As long as you retain this 
-- notice, you can do whatever you want with this stuff. If we
-- meet someday, and you think this stuff is worth it, you can
-- buy me a beer in return.
-- ----------------------------------------------------------------------------

IMGLoader = {}
IMGLoader.metatable = {
    __index = IMGLoader,
}
setmetatable( IMGLoader, { __call = function(self,...) return self:New(...) end } )

function IMGLoader:New()
	local instance = setmetatable( {}, IMGLoader.metatable )

	instance.file = nil
	instance.binaryReader = nil

	instance.filesData = {}

	return instance
end

function IMGLoader:LoadFile(path, encryptionKey)
	if self.file then
		return false, "File is already opened in this instance of IMGLoader"
	end

	local exists = fileExists( path )
	if not exists then
		return false, "File of given path doesn't exist"
	end

	local file = fileOpen( path, true )
	if not file then
		return false, "Couldn't open IMG file"
	end

	self.file = file
	local encString = fileRead(self.file, 3)
	local isEncrypted = encString == "ENC"
	if isEncrypted then
		if not encryptionKey then
			return false, "IMG files is encrypted, but no encryption key was given"
		end
		local imgData = base64Decode( teaDecode( fileRead(self.file, fileGetSize( self.file ) - 3), encryptionKey ) )
		fileClose( self.file )
		self.file = imgData
	else
		fileSetPos( self.file, 0 )
	end

	return self:ProcessIMGFile()
end

function IMGLoader:CloseFile()
	if self.file then
		if type(self.file) ~= "string" then
			fileClose(self.file)
		end
		self.file = nil
		self.filesData = {}
	end
end

function IMGLoader:ProcessIMGFile()
	self.binaryReader = BinaryReader(self.file)
	self:ReadHeader()
	if self.version ~= "VER2" then
		self:CloseFile()
		return false, "Wrong IMG File version or wrong encryptionKey, closing file" 
	end

	if self.numEntries > 0 then
		self:ProcessDirectoryEntries()
	end
	return true
end

function IMGLoader:ReadHeader()
	self.version = self.binaryReader:ReadString(4)
	self.numEntries = self.binaryReader:ReadUInt32()
end

function IMGLoader:ProcessDirectoryEntries()
	for i=1, self.numEntries do
		local offset = self.binaryReader:ReadUInt32()
		local streamingSize = self.binaryReader:ReadUInt16()
		local sizeInArchive = self.binaryReader:ReadUInt16()
		local name = self.binaryReader:ReadString(24)
		local fileEntry = {offset = offset, streamingSize = streamingSize, sizeInArchive = sizeInArchive, name = name}
		self.filesData[name] = fileEntry
	end
end

function IMGLoader:GetFile(name)
	if not self.file then
		return false, "Tried to get file from IMG archive, but the archive isn't loaded"
	end
	if not self.filesData[name] then
		return false, "File with that name doesn't exist in archive"
	end
	local realOffset = self.filesData[name].offset * 2048
	local realSize = self.filesData[name].sizeInArchive * 2048
	if realSize == 0 then
		realSize = self.filesData[name].streamingSize * 2048
	end
	if type(self.file) == "string" then
		local retFile = self.file:sub(realOffset+1, realOffset+1+realSize)
		retFile = self:RemoveNullsFromEndOfFile(retFile)
		return retFile
	else
		fileSetPos(self.file, realOffset)
		local retFile = fileRead(self.file, realSize)
		retFile = self:RemoveNullsFromEndOfFile(retFile)
		return retFile
	end
	return false
end

function IMGLoader:RemoveNullsFromEndOfFile(file)
	local ind = #file
	while ind >= 1 and (file:sub(ind,ind) == "\0")  do
		ind = ind - 1
	end
	if ind <= 0 then return end

	return file:sub(1, ind)
end

function IMGLoader:EncryptFile(path, encryptionKey)
	if not encryptionKey then
		return false, "No encryption key given for IMG encryption"
	end
	if type(encryptionKey) ~= "string" then
		return false, "Unknown encryption key type given"
	end
	if encryptionKey == "" then
		return false, "Empty encryption key given"
	end

	local exists = fileExists( path )
	if not exists then
		return false, "File of given path doesn't exist"
	end

	local file = fileOpen( path, true )
	if not file then
		return false, "Couldn't open IMG file"
	end

	local content = fileRead(file, fileGetSize( file ))
	fileClose( file )
	if content then
		content = base64Encode( content )

		content = teaEncode( content, encryptionKey)
		content = "ENC"..content
		local newFile = fileCreate( path .. "e" ) -- e for encrypted
		if not newFile then
			return false, "Couldn't create new file"
		end
		fileWrite( newFile, content )
		fileFlush( newFile )
		fileClose( newFile)
		iprint("Succesfully encrypted file")
		return true
	end
	return false, "Couldn't read original IMG file"
end