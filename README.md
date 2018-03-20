# MTA-IMGLoader
This resource gives ability to load, and extract files from IMG Version 2 archives. It also support encrypting archives using TeaEncode.
&nbsp;

 # Note about using encrypted archives
Encypted archives are kept loaded in memory while they're in use, while normal archives are accessed using normal file access methods. Due to that I wouldn't recommend using encrypted archives for large files storage.
&nbsp;

# File structure:
 - The resource is made of 3 classes:
   - IMGLoader class, it's used to load IMG files, and extract files from them. It aslo supplies function used to encrypt IMG files.
   - BinaryReader class, each instance of this class is new reader, it's used to read binary data from files, and convert it to lua data formats using BinaryConverter class.
   - BinaryConverter class, it's a singleton that provides funtions used to convert binary data to lua data formats. (based on https://github.com/tederis/mta-resources/blob/master/dffframe/bytedata.lua)
 - This resource doesn't export any functions because custom classes can't be exported properly along with their metatables easily.

# Operating on IMG files
Example code showing usage of IMG files
```lua
    -- This will open IMG file and process it so files can be extracted from it
    local IMG = IMGLoader():LoadFile( "exampleFile.img" )
    
    -- This will extract file called example.dff from it
    local dffStream = IMG:GetFile( "example.dff" )
    
    -- And this will load it into mta
    local dff = engineLoadDFF( dffStream )
    
    -- Close img file since it's not needed anymore.
    IMG:CloseFile()
```   
Usage of encrypted files:
```lua
    -- This will encrypt out file using "ExampleKey123!" key, 
    -- and place it in the same folder as original file, with ".imge" extension
    IMGLoader():EncryptFile( "exampleFile.img", "ExampleKey123!" )
    
    -- And now we can operate on this file
    local IMG = IMGLoader():LoadFile( "exampleFile.imge", "ExampleKey123!" )
    local dffStream = IMG:GetFile( "example.dff" )
    local dff = engineLoadDFF( dffStream )
    
    -- Close img file since it's not needed anymore.
    IMG:CloseFile()
```

# All functions availible for IMGLoader:
```lua
    IMGLoader:LoadFile( path, encryptionKey ) --Loads IMG file, if the file is encrypted, the given encryption key is used to open it.
    IMGLoader:GetFile( fileName ) --Gets file of name fileName
    IMGLoader:CloseFile() --Closes IMG file, removes data from memory if it's encypted file
    IMGLoader:EncryptFile( path, encryptionKey ) --Encypts file pointed by path using encryptionKey as encryption key
```
Functions in BinaryReader and BinaryConverter classes aren't documented here, as they aren't the focus of this repository.



License
----
> ----------------------------------------------------------------------------
> Kamil Marciniak <github.com/forkerer> wrote this code. As long as you retain this 
> notice, you can do whatever you want with this stuff. If we
> meet someday, and you think this stuff is worth it, you can
> buy me a beer in return.
 ----------------------------------------------------------------------------


