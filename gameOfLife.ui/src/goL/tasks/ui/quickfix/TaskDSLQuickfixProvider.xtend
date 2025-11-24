package goL.tasks.ui.quickfix

import org.eclipse.xtext.ui.editor.quickfix.DefaultQuickfixProvider
import org.eclipse.xtext.ui.editor.quickfix.Fix
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor
import org.eclipse.xtext.validation.Issue
import org.eclipse.xtext.ui.editor.model.edit.ISemanticModification
import org.eclipse.xtext.ui.editor.model.edit.IModificationContext

import goL.tasks.taskDSL.*
import goL.tasks.validation.TaskDSLValidator
import org.eclipse.emf.ecore.EObject

class TaskDSLQuickfixProvider extends DefaultQuickfixProvider {
	
	/**
	 * Clamps invalid cell coordinates (x/y) to the nearest valid grid boundary (0 to size-1).
	 */
    @Fix(TaskDSLValidator.INVALID_CELL_COORDINATE)
    def fixInvalidCell(Issue issue, IssueResolutionAcceptor acceptor) {
        acceptor.accept(issue,
            "Clamp cell coordinate into grid range",
            "Automatically adjusts the value so it fits inside the grid.",
            null,
            [ EObject element, IModificationContext context |
                val cell = element as LiveCell

				// Get the Grid dimensions from the root Model
                val root = cell.eResource().contents.head as goL.tasks.taskDSL.Model
                val grid = root.grid

                // Clamp X coordinate: set to 0 if < 0, or sizeX - 1 if too large
                if (cell.x < 0) {
                    cell.x = 0
                } else if (cell.x >= grid.sizeX) {
                    cell.x = grid.sizeX - 1
                }

                // Clamp Y coordinate: set to 0 if < 0, or sizeY - 1 if too large
                if (cell.y < 0) {
                    cell.y = 0
                } else if (cell.y >= grid.sizeY) {
                    cell.y = grid.sizeY - 1
                }
            ] as ISemanticModification
        )
    }
	
	/**
	 * Replace an unknown variable reference with one of the allowed variables (c, r, GRID_WIDTH, ...)
	 */
    @Fix(TaskDSLValidator.UNKNOWN_VARIABLE)
    def fixUnknownVariable(Issue issue, IssueResolutionAcceptor acceptor) {
        val badName = if (issue.data !== null && issue.data.length > 0) issue.data.head else "x"
        val allowed = TaskDSLValidator.VALID_VARIABLES // Get all valid options

        for (option : allowed) {
        	// Create a quickfix for every allowed variable
            acceptor.accept(issue,
                "Replace with '" + option + "'",
                "Replace variable '" + badName + "' with '" + option + "'.",
                null,
                [ EObject element, IModificationContext context |
                    (element as VariableRef).varName = option
                ] as ISemanticModification
            )
        }
    }

	/**
	 * Replace an unknown function name with one of the valid function names (sin, cos, sqrt, ...)
	 */
    @Fix(TaskDSLValidator.UNKNOWN_FUNCTION)
	def fixUnknownFunction(Issue issue, IssueResolutionAcceptor acceptor) {
		
		// Extract the invalid function name from issue data
	    val data = issue.data
	    val bad = if (data !== null && data.length > 0) data.get(0) else "?"
	
	    val allowed = TaskDSLValidator.VALID_FUNCTIONS // Get all valid options
	
	    for (fn : allowed) {
	    	// Create a quickfix for every allowed function
	        acceptor.accept(
	            issue,
	            "Replace with '" + fn + "'",
	            "Replace unknown function '" + bad + "' with '" + fn + "'.",
	            null,
	            [ EObject element, IModificationContext context |
	                (element as FunctionCall).funcName = fn
	            ] as ISemanticModification
	        )
	    }
	}

}
