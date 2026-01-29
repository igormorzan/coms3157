## Objective

Your task is to write a simple bash script to provide the basic functionality of a recycle bin. 
In addition to moving files or folders into the recycle bin directory, the script must be able to list and 
purge the files or folders that have been placed into the recycle bin. This script acts as a substitute for
the `rm` command, giving the user a chance to recover files deleted accidentally. 
Note that restoring the files is not part of this exercise.

You should consult the following websites for details about programming in bash:
- <http://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO.html>
- <https://tldp.org/LDP/abs/html>

## Problem

You will create a bash script called `junk.sh` that operates exactly as follows. Implement the `junk.sh` script inside the src directory and run it from there.

1. When the script is executed, it first parses the command line arguments. The usage message is shown below to help you determine what features you need to implement. Note: There are exactly 4 spaces at the start of the lines with `-h`, `-l`, `-p`, and `[list of files]`.

       $ ./junk.sh
       Usage: junk.sh [-hlp] [list of files]
           -h: Display help.
           -l: List junked files.
           -p: Purge all files.
           [list of files] with no other arguments to junk those files.

    Notice there are three flags `[h, l, p]` that the script must handle. You must use `getopts` in your solution to receive credit for this part of the assignment. When no arguments are supplied, the script should print the output seen in the box above to the standard error stream (2) and exit with 1. When the user passes `-h`, the script should print the same output to the standard out stream (1) and exit with 0.

    If an unexpected flag is found, the script should display an error message and repeat the correct usage. This is true even when both expected and unexpected flags are entered. If one flag is unknown, the script will terminate with the message seen below. If there are multiple erroneous flags, the script will only report the first erroneous flag and exit.

       $ ./junk.sh -z
       Error: Unknown option '-z'.
       Usage: junk.sh [-hlp] [list of files]
           -h: Display help.
           -l: List junked files.
           -p: Purge all files.
           [list of files] with no other arguments to junk those files.

    If more than one (distinct & valid) flag is specified, the script should display an error message and repeat the correct usage. See below.

       $ ./junk.sh -l -p
       Error: Too many options enabled.
       Usage: junk.sh [-hlp] [list of files]
           -h: Display help.
           -l: List junked files.
           -p: Purge all files.
           [list of files] with no other arguments to junk those files.

   A repeated valid flag such as `./junk.sh -lll` should not trigger an error.
   If one or more flags are specified and files are supplied, the script tell the user that too many options have been supplied.

       $ ./junk.sh -l note.txt
       Error: Too many options enabled.
       Usage: junk.sh [-hlp] [list of files]
           -h: Display help.
           -l: List junked files.
           -p: Purge all files.
           [list of files] with no other arguments to junk those files.

2. After parsing the command line arguments, the script checks for the presence of the `.junk` directory, which will be the recycle bin. The `.junk` directory should be placed under the home directory (`~/`) of the user currently logged into the system and running the script. If the directory is not found, the script creates it.

3. At this point, the script can assume that it is ready to do its main task. So, depending on what flag (if any) the user supplied, the script needs to either display the usage message, list the files in the recycle bin, purge the files in the recycle bin, or move the files or folders specified on the command line into the recycle bin.
 <br><br>
If a file or folder is not found, the junk script should warn the user. If the user is attempting to junk multiple files or folders and some of them are not found, the script should warn about the missing ones and actually move forward with moving the ones that exist to the `.junk` directory. See below for the expected output.

       $ ./junk.sh notfound1.txt found.txt notfound2
       Warning: 'notfound1.txt' not found
       Warning: 'notfound2' not found

4. When listing files in the recycle bin (when the `-l` flag is passed in), your output **must** match that of `ls -lAF`. *Note: you can just call `ls -lAF` directly.*<br>
   `-l` is for a long (detailed) listing. It will always begin with a total number of 1024-byte blocks occupied by the files in the listing.<br>
   `-A` lists almost all files, ignoring . and ..<br>
   `-F` appends an indicator to the end of each line. Possible indicators are found below.<br>

       / is a directory
       @ is a symlink
       | is a named pipe (fifo)
       = is a socket
       * for executable files
       > is for a "door" -- a file type currently not implemented for Linux, but supported on Sun/Solaris.

5. When purging files from the recycle bin, you must use `rm` or `find` paired with `rm` to remove all files in the folder. The junk folder may not be deleted at any point. You'll need to figure out how to delete all files and folders, including hidden files. ***Be careful not to inadvertently delete files outside the recycle bin folder.***

6. All error messages must be sent to standard error stream (2) and the script must exit with a 0 for success and 1 for an error, as other processes might need to know the return value of this script before proceeding. *Note: An execution with warnings (as shown in 4) should use the success exit code.*

## Sample Run Time Scenario
Below is the output expected when running this script on several common scenarios. Your output must match this output ***EXACTLY*** when run on the BB Server. *Note: The path before {UNI} does not matter. Additionally, the exact name of your local hw1 directory does not matter. In the below output, we are assuming that you have cloned into a hw1 directory.*

    $ pwd 
    .../UNI/cs3157/hw1
    $ cd src
    $ pwd
    .../UNI/cs3157/hw1/src

    $ touch junk0.txt 
    $ mkdir -p dir1
    $ mkdir -p dir2/dir3
    $ mkdir .hideme
    $ touch dir1/junk1.txt
    $ touch dir2/junk2.txt
    $ touch dir2/dir3/junk3.txt
    $ tree
    .
    ├── dir1
    │ └── junk1.txt
    ├── dir2
    │ ├── dir3
    │ │ └── junk3.txt
    │ └── junk2.txt
    ├── junk.sh
    └── junk0.txt

    4 directories, 5 files

    $ chmod u+x junk.sh
    $ ./junk.sh junk0.txt
    $ ./junk.sh -l
    total 1
    -rw------- 1 user student 0 Feb 3 17:50 junk0.txt
    <Of course, the date and time will be different. User should appear as your UNI.>

    $ ./junk.sh dir1/junk1.txt
    $ ./junk.sh -l
    total 1
    -rw------- 1 user student 0 Feb 3 17:50 junk0.txt
    -rw------- 1 user student 0 Feb 3 17:50 junk1.txt
    $ ./junk.sh dir2/dir3/junk3.txt

    $ ./junk.sh .hideme

    $ ./junk.sh -l
    total 2
    drwx------ 2 user student 2 Feb 3 17:50 .hideme/
    -rw------- 1 user student 0 Feb 3 17:50 junk0.txt
    -rw------- 1 user student 0 Feb 3 17:50 junk1.txt
    -rw------- 1 user student 0 Feb 3 17:50 junk3.txt

    $ tree
    .
    ├── dir1
    ├── dir2
    │ ├── dir3
    │ └── junk2.txt
    └── junk.sh

    4 directories, 2 files

    $ tree -a ~/.junk
    .../students231/<YOUR_UNI>/.junk
    ├── .hideme
    ├── junk0.txt
    ├── junk1.txt
    └── junk3.txt

    2 directories, 3 files

    $ ./junk.sh -p

    $ ./junk.sh -l
    total 0

    $ tree -a ~/.junk
    .../students231/<YOUR_UNI>/.junk

    0 directories, 0 files

## Additional Requirements
You must use:
1. `getopts` to parse command line arguments
2. a **here document** for constructing the help message
3. the `basename` utility inside the here document to get the script name without additional directory information
4. the `readonly` keyword when setting up the variable name for the `.junk` directory
5. the `shellcheck` tool to ensure your code is clean
