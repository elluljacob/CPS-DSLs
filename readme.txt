Group 42: DSL Assignment (Jacob Ellul, Keith Farrugia)

The language defined is declarative and designed for simplicity. Cells can be set to alive or dead
manually using the Static/StaticErase keywords. A 'Random' keyword is also provided to allow a random
fill of the board. Shapes and pre-coded design patterns are also provided to the user of the language
allowing the user to define triangles, squares and circles that may be filled or not or may be used to
erase certain cells so that that area is dead. The pre-coded design patterns are the patterns
defined by the wikipedia for the Game Of Life. A user can also define re-usable patterns 
that consist of a set of alive and dead cells. A user can also define functions to be executed
that can set cells alive within a given tolerance. 

To write a script you must go inside the short.life runtime workspace directory and create 
a new .tdsl (or edit gol.tdsl) inside models. A script starts with the 'Experiment' title
followed by a grid definition which takes in a size for the Grid and an InitialState which
uses list of commands such as the Static/StaticErase, Random, and so on to be
executed in order to provide an initial configuration for the grid. Further instructions
are provided in each of the .tdsl script files.

After the Grid comes the Rules where a user must specify the conditions for Survival, Death
and Birth within this Game Of Life Configuration. Several sample scripts are provided each
showcasing several features of the language including the commands being showcased as well
as some Validation Errors and Warnings being triggered along with the quickfix feature 
being showcased. For the final mark the quickfix feature was chosen.

For detailed instructions and explanations on the language refer to the .xtext and .xtend files 
which defines how the language is to be written, generated and validated. The following source 
files are where we wrote this code:
gameOfLife/src/goL.tasks/TaskDSL.xtext
gameOfLife/src/goL.tasks.validation/TaskDSLValidator.xtend
gameOfLife/src/goL.tasks.generator/TaskDSLGenerator.xtend
gameOfLife.ui/src/goL.tasks.ui.quickfix/TaskDSLQuickFixProvider.xtend

The runtime workspace then has several sample script files as mentioned before as well as the needed
java files.
