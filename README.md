wow
===
[![Build Status](https://travis-ci.org/timcolonel/wow.svg?branch=master)](https://travis-ci.org/timcolonel/wow)

Wow packer. Cross platform package manager

#Requirements
* `> Ruby 2.0.0`

#Planned features
* Distribute files(Copying file on user computer) 
* Create some command line executables and add them to `PATH`
* Create some desktop application link
* Change version of a program(Rvm style): Switch active version of the program(Only the active version program will be added to the path)

# Commands

## Pack
Pack the code into a package read to upload to the server
Platform option:
* `any`: This will include all the files for all the platforms specified in the config.If the overal files is `src/` the unix sepcific config contains `files=['unix/']` and windows specific config contains `files=['windows/']` then all the 3 folder will be include in the package. On the other hand if `files_exclude` is used in platform specific then it will be ignored for building a package.
* `<plaform`: This will only include the files for the platform, excluding the files for the other platform. If the platform as subplatform the same apply as `any` for the subplatforms.
