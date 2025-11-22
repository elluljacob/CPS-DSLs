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

    @Fix(TaskDSLValidator.INVALID_CELL_COORDINATE)
    def fixInvalidCell(Issue issue, IssueResolutionAcceptor acceptor) {
        acceptor.accept(issue,
            "Clamp cell coordinate into grid range",
            "Automatically adjusts the value so it fits inside the grid.",
            null,
            [ EObject element, IModificationContext context |
                val cell = element as LiveCell

                // get root model (assumes your root is something like 'Model' or 'Experiment')
                val root = cell.eResource().contents.head as goL.tasks.taskDSL.Model
                val grid = root.grid

                if (issue.data != null && !issue.data.isEmpty) {
                    // issue.getData() may contain strings if you passed data in validator
                }

                // clamp x
                if (cell.x < 0) {
                    cell.x = 0
                } else if (cell.x >= grid.sizeX) {
                    cell.x = grid.sizeX - 1
                }

                // clamp y
                if (cell.y < 0) {
                    cell.y = 0
                } else if (cell.y >= grid.sizeY) {
                    cell.y = grid.sizeY - 1
                }
            ] as ISemanticModification
        )
    }

    @Fix(TaskDSLValidator.UNKNOWN_VARIABLE)
    def fixUnknownVariable(Issue issue, IssueResolutionAcceptor acceptor) {
        val badName = if (issue.data != null && issue.data.length > 0) issue.data.head else "x"
        val allowed = TaskDSLValidator.VALID_VARIABLES

        for (option : allowed) {
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

    @Fix(TaskDSLValidator.UNKNOWN_FUNCTION)
	def fixUnknownFunction(Issue issue, IssueResolutionAcceptor acceptor) {
	
	    // Safe extraction of the "bad" function name
	    val data = issue.data
	    val bad = if (data !== null && data.length > 0) data.get(0) else "?"
	
	    val allowed = TaskDSLValidator.VALID_FUNCTIONS
	
	    for (fn : allowed) {
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
