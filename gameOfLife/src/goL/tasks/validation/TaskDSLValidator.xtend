package goL.tasks.validation

import org.eclipse.xtext.validation.Check
import goL.tasks.taskDSL.LiveCell
import goL.tasks.taskDSL.TaskDSLPackage
import goL.tasks.taskDSL.Operator
import goL.tasks.taskDSL.BirthRule
import goL.tasks.taskDSL.SurvivalRule
import goL.tasks.taskDSL.DeathRule
import goL.tasks.taskDSL.Grid
import goL.tasks.taskDSL.StaticState
import goL.tasks.taskDSL.Grid
import goL.tasks.taskDSL.FunctionState
import goL.tasks.taskDSL.VariableRef
import goL.tasks.taskDSL.Expr
import goL.tasks.taskDSL.NumberLiteral
import goL.tasks.taskDSL.Add
import goL.tasks.taskDSL.Sub
import goL.tasks.taskDSL.Mul
import goL.tasks.taskDSL.Div
import goL.tasks.taskDSL.FunctionCall
import goL.tasks.taskDSL.ParenExpr

/**
 * Custom validation rules for the Game of Life DSL.
 */
class TaskDSLValidator extends AbstractTaskDSLValidator {
	
	// --- Rule 1 (Error): Checks if a LiveCell is placed outside the defined grid boundaries. ---
	
	public static val INVALID_CELL_COORDINATE = 'invalid_cell_coordinate'
	
	@Check
	def checkLiveCellCoordinates(Grid grid) {
	    val sizeX = grid.sizeX
	    val sizeY = grid.sizeY
	
	    // 1. Check if the initial state is static (i.e., not random)
	    if (grid.stateOption instanceof StaticState) {
	        
	        // 2. Cast the stateOption to StaticState to access the 'cells' list
	        val staticState = grid.stateOption as StaticState
	        
	        // 3. Iterate over the cells contained within the StaticState
	        for (LiveCell cell : staticState.cells) {
	            
	            // Check Rule 1: LiveCell coordinates must be within grid bounds
	            if (cell.x < 0 || cell.x >= sizeX) {
	                // Issue error on the 'x' feature
	                error(
	                    'Cell X coordinate (' + cell.x + ') is outside the grid bounds [0, ' + (sizeX - 1) + '].',
	                    cell,
	                    TaskDSLPackage.Literals.LIVE_CELL__X,
	                    INVALID_CELL_COORDINATE // Your custom error code
	                )
	            }
	            if (cell.y < 0 || cell.y >= sizeY) {
	                // Issue error on the 'y' feature
	                error(
	                    'Cell Y coordinate (' + cell.y + ') is outside the grid bounds [0, ' + (sizeY - 1) + '].',
	                    cell,
	                    TaskDSLPackage.Literals.LIVE_CELL__Y,
	                    INVALID_CELL_COORDINATE
	                )
	            }
	        }
	    }
	    // If it's RandomState, there are no individual cells to validate here.
	}
		
	// --- Rule 2 (Error): Ensures the neighbor count in any rule is logically possible (between 0 and 8). ---
	
	public static val NEIGHBOR_COUNT_IMPOSSIBLE = 'neighbor_count_impossible'
	
	@Check
	def checkBirthRuleCount(BirthRule rule) {
	    val count = rule.count
	    val operator = rule.operator
	    
	    if (count < 0) {
	        error(
	            'Neighbor count must be 0 or greater for Birth Rule.',
	            rule,
	            TaskDSLPackage.Literals.BIRTH_RULE__COUNT, // CORRECT LITERAL for BirthRule
	            NEIGHBOR_COUNT_IMPOSSIBLE
	        )
	    } else if (count > 8 && (operator == Operator.EQUAL || operator == Operator.GREATER_THAN)) {
	        error(
	            'Birth Rule count ' + operator.literal + ' ' + count + ' is impossible. A cell can only have up to 8 neighbors.',
	            rule,
	            TaskDSLPackage.Literals.BIRTH_RULE__COUNT, // CORRECT LITERAL
	            NEIGHBOR_COUNT_IMPOSSIBLE
	        )
	    }
	}
	
	@Check
	def checkSurvivalRuleCount(SurvivalRule rule) {
	    val count = rule.count
	    val operator = rule.operator
	    
	    if (count < 0) {
	        error(
	            'Neighbor count must be 0 or greater for Survival Rule.',
	            rule,
	            TaskDSLPackage.Literals.SURVIVAL_RULE__COUNT, // CORRECT LITERAL for SurvivalRule
	            NEIGHBOR_COUNT_IMPOSSIBLE
	        )
	    } else if (count > 8 && (operator == Operator.EQUAL || operator == Operator.GREATER_THAN)) {
	        error(
	            'Survival Rule count ' + operator.literal + ' ' + count + ' is impossible. A cell can only have up to 8 neighbors.',
	            rule,
	            TaskDSLPackage.Literals.SURVIVAL_RULE__COUNT, // CORRECT LITERAL
	            NEIGHBOR_COUNT_IMPOSSIBLE
	        )
	    }
	}
	
	@Check
	def checkDeathRuleCount(DeathRule rule) {
	    val count = rule.count
	    val operator = rule.operator
	    
	    if (count < 0) {
	        error(
	            'Neighbor count must be 0 or greater for Death Rule.',
	            rule,
	            TaskDSLPackage.Literals.DEATH_RULE__COUNT, // CORRECT LITERAL for DeathRule
	            NEIGHBOR_COUNT_IMPOSSIBLE
	        )
	    } else if (count > 8 && (operator == Operator.EQUAL || operator == Operator.GREATER_THAN)) {
	        error(
	            'Death Rule count ' + operator.literal + ' ' + count + ' is impossible. A cell can only have up to 8 neighbors.',
	            rule,
	            TaskDSLPackage.Literals.DEATH_RULE__COUNT, // CORRECT LITERAL
	            NEIGHBOR_COUNT_IMPOSSIBLE
	        )
	    }
	}
	// --- Rule 3 (Warning): Warns about logically redundant or potentially confusing rules. ---
	
	public static val REDUNDANT_RULE = 'redundant_rule'
	
	@Check
	def warnAboutRedundantBirthRule(BirthRule rule) {
	    val count = rule.count
	    val operator = rule.operator
	    val literal = TaskDSLPackage.Literals.BIRTH_RULE__COUNT // Use the correct literal
	    
	    // Case A: Rule is ALWAYS TRUE (e.g., '< 9' or '> -1')
	    if (operator == Operator.LESS_THAN && count > 8) {
	        warning(
	            'Birth Rule condition is always true (a cell always has < 9 neighbors). This rule is redundant.',
	            rule,
	            literal,
	            REDUNDANT_RULE
	        )
	    } else if (operator == Operator.GREATER_THAN && count < 0) {
	        warning(
	            'Birth Rule condition is always true (a cell always has >= 0 neighbors). This rule is redundant.',
	            rule,
	            literal,
	            REDUNDANT_RULE
	        )
	    }
	    
	    // Case B: Rule is ALWAYS FALSE (e.g., '< 0')
	    else if (operator == Operator.LESS_THAN && count <= 0) {
	        warning(
	            'Birth Rule condition is always false (a cell cannot have < 0 neighbors). This rule is redundant.',
	            rule,
	            literal,
	            REDUNDANT_RULE
	        )
	    }
	}
	
	@Check
	def warnAboutRedundantSurvivalRule(SurvivalRule rule) {
	    val count = rule.count
	    val operator = rule.operator
	    val literal = TaskDSLPackage.Literals.SURVIVAL_RULE__COUNT // Use the correct literal
	    
	    if (operator == Operator.LESS_THAN && count > 8) {
	        warning(
	            'Survival Rule condition is always true (a cell always has < 9 neighbors). This rule is redundant.',
	            rule,
	            literal,
	            REDUNDANT_RULE
	        )
	    } else if (operator == Operator.GREATER_THAN && count < 0) {
	        warning(
	            'Survival Rule condition is always true (a cell always has >= 0 neighbors). This rule is redundant.',
	            rule,
	            literal,
	            REDUNDANT_RULE
	        )
	    }
	    else if (operator == Operator.LESS_THAN && count <= 0) {
	        warning(
	            'Survival Rule condition is always false (a cell cannot have < 0 neighbors). This rule is redundant.',
	            rule,
	            literal,
	            REDUNDANT_RULE
	        )
	    }
	}
	
	@Check
	def warnAboutRedundantDeathRule(DeathRule rule) {
	    val count = rule.count
	    val operator = rule.operator
	    val literal = TaskDSLPackage.Literals.DEATH_RULE__COUNT // Use the correct literal
	    
	    if (operator == Operator.LESS_THAN && count > 8) {
	        warning(
	            'Death Rule condition is always true (a cell always has < 9 neighbors). This rule is redundant.',
	            rule,
	            literal,
	            REDUNDANT_RULE
	        )
	    } else if (operator == Operator.GREATER_THAN && count < 0) {
	        warning(
	            'Death Rule condition is always true (a cell always has >= 0 neighbors). This rule is redundant.',
	            rule,
	            literal,
	            REDUNDANT_RULE
	        )
	    }
	    else if (operator == Operator.LESS_THAN && count <= 0) {
	        warning(
	            'Death Rule condition is always false (a cell cannot have < 0 neighbors). This rule is redundant.',
	            rule,
	            literal,
	            REDUNDANT_RULE
	        )
	    }
	}
	// ---------------------------
	//  Expression & identifier validation
	// ---------------------------

	public static val UNKNOWN_VARIABLE 	= 'unknown_variable'
	public static val UNKNOWN_FUNCTION 	= 'unknown_function'
	public static val VALID_VARIABLES 	= #["c","r","GRID_WIDTH","GRID_HEIGHT"]
	public static val VALID_FUNCTIONS 	= #["sin","cos","tan","sqrt","abs"]
	/**
	 * Validate a VariableRef node: only allow c, r, GRID_WIDTH, GRID_HEIGHT.
	 */
	@Check
	def checkVariableRef(VariableRef varRef) {
	    val name = varRef.varName
	    if (!VALID_VARIABLES.contains(name)) {
	        error(
	            "Unknown variable '" + name + "'. Allowed variables: " + VALID_VARIABLES.join(", "),
	            varRef,
	            TaskDSLPackage.Literals.VARIABLE_REF__VAR_NAME,
	            UNKNOWN_VARIABLE
	        )
	    }
	}
	
	/**
	 * Validate a FunctionCall node: only allow sin, cos, tan, sqrt, abs.
	 */
	@Check
	def checkFunctionCall(FunctionCall fc) {
	    val fname = fc.funcName
	    if (!VALID_FUNCTIONS.contains(fname)) {
	        error(
	            "Unknown function '" + fname + "'. Allowed functions: " + VALID_FUNCTIONS.join(", "),
	            fc,
	            TaskDSLPackage.Literals.FUNCTION_CALL__FUNC_NAME,
	            UNKNOWN_FUNCTION
	        )
	    }
	}
	
	/**
	 * Helper that converts expressions to Java strings — used by other code.
	 * It also enforces the same identifier/function restrictions (safe-guard).
	 * If an unknown identifier/function is found it throws IllegalArgumentException.
	 */
	def String exprToJava(Expr expr) {
	
	    // ----- Literals -----
	    if (expr instanceof NumberLiteral) {
	        return (expr as NumberLiteral).value.toString
	
	    // ----- Variables (c, r, GRID_WIDTH, GRID_HEIGHT) -----
	    } else if (expr instanceof VariableRef) {
	        val v = (expr as VariableRef).varName
	        if (VALID_VARIABLES.contains(v)) {
	            return v
	        } else {
	            // prefer a clear message so callers can map to validation error
	            throw new IllegalArgumentException("Unknown identifier: " + v + ". Allowed: " + VALID_VARIABLES.join(", "))
	        }
	
	    // ----- Binary operations -----
	    } else if (expr instanceof Add) {
	        val e = expr as Add
	        return "(" + exprToJava(e.left) + " + " + exprToJava(e.right) + ")"
	
	    } else if (expr instanceof Sub) {
	        val e = expr as Sub
	        return "(" + exprToJava(e.left) + " - " + exprToJava(e.right) + ")"
	
	    } else if (expr instanceof Mul) {
	        val e = expr as Mul
	        return "(" + exprToJava(e.left) + " * " + exprToJava(e.right) + ")"
	
	    } else if (expr instanceof Div) {
	        val e = expr as Div
	        return "(" + exprToJava(e.left) + " / " + exprToJava(e.right) + ")"
	
	    // ----- Function calls -----
	    } else if (expr instanceof FunctionCall) {
	        val fc = expr as FunctionCall
	        val fname = fc.funcName
	        val arg = exprToJava(fc.argument)
	
	        if (!VALID_FUNCTIONS.contains(fname)) {
	            throw new IllegalArgumentException("Unknown function: " + fname + ". Allowed: " + VALID_FUNCTIONS.join(", "))
	        }
	
	       switch (fname) {
		    case "sin":  return "Math.sin("  + arg + ")"
		    case "cos":  return "Math.cos("  + arg + ")"
		    case "tan":  return "Math.tan("  + arg + ")"
		    case "sqrt": return "Math.sqrt(" + arg + ")"
		    case "abs":  return "Math.abs("  + arg + ")"
		    default: throw new IllegalArgumentException(
		        "Unknown function: " + fname + ". Allowed: " + VALID_FUNCTIONS.join(', ')
		    )
		}
	    // ----- Parentheses -----
	    } else if (expr instanceof ParenExpr) {
	        return "(" + exprToJava((expr as ParenExpr).expr) + ")"
	
	    // ----- Fallback -----
	    } else {
	        throw new IllegalStateException("Unhandled expr type: " + expr.class.name)
	    }
	}
	
}