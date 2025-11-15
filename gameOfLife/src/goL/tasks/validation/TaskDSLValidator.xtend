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
}