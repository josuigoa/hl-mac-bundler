# HashLink OSX bundler

The HashLink VM is not very portable in OSX systems. The HL executable is looking for the libraries in the instalation paths even if the library is in the same folder. For example, HL will look for `libSDL2-2.0.0.dylib` in the `/usr/local/opt/sdl2/lib/` folder, where it is installed.

# What does this script do?

* Read the libraries needed by the `hdll` files that are close to the executable
* Copy to that folder all the `dylib` files needed.
* Update the `hdll` file to look for the libraries in the current folder.

# Limitations

This version only works if all the files are in the same folder, the executable and the hdll. It's working fine for me but I understand someone may want to get the libraries in another folder.

# Usage

I've used it in this way.

* Compile `main.hl``
* Copy (manually) the needed `hdll` files in the same folder.
* Run this command `haxe --run Main /path/to/main/file`.
* (Optional) Package the application
  * Create a shell script to execute the application (e.g. `./hl main.hl`)
  * Package the folder with [Platypus](https://sveinbjorn.org/platypus)
