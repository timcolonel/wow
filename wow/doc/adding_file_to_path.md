#How to make command line executables


##Input
* Executable files(.exe, .sh, .bat,...)
* Script that need command line(.jar, .ruby, .py,...)
* 

##Output
* Run the executable by typing the command line <filename>



#Adding file to path:
##Case 1: file is aldready an executable
* Unix: Create a `symlink` to executable file and place it in `bin` folder
* Windows: Create `.bat` that call the exectuable and place it in `bin` folder

##Case 2: file is a script and need command line argument
* Genereate `sh/bat` that will call the script

List
* Java
* Ruby
* Python
