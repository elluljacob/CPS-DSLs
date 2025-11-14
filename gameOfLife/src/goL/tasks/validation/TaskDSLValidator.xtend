package goL.tasks.validation

import org.eclipse.xtext.validation.Check
import goL.tasks.taskDSL.LiveCell
import goL.tasks.taskDSL.TaskDSLPackage
import goL.tasks.taskDSL.Operator
import goL.tasks.taskDSL.Model
import goL.tasks.taskDSL.BirthRule
import goL.tasks.taskDSL.SurvivalRule
import goL.tasks.taskDSL.DeathRule
import goL.tasks.taskDSL.Grid

/**
 * Custom validation rules for the Game of Life DSL.
 */
class TaskDSLValidator extends AbstractTaskDSLValidator {
	
	// --- Rule 1 (Error): Checks if a LiveCell is placed outside the defined grid boundaries. ---
	
	public static val INVALID_CELL_COORDINATE = 'invalid_cell_coordinate'
	
	@Check
	def checkLiveCellCoordinatesInBounds(LiveCell liveCell) {
		// Traverse up the containment hierarchy to find the Model and Grid.
		// LiveCell -> Grid -> Model
		val Grid grid = liveCell.eContainer as Grid
		
		if (grid === null) return // Safety check
		
		val gridSizeX = grid.sizeX
		val gridSizeY = grid.sizeY
		
		// The cell is invalid if its x-coordinate is outside [0, sizeX-1]
		if (liveCell.x < 0 || liveCell.x >= gridSizeX) {
			error(
				'Cell X coordinate (' + liveCell.x + ') is outside the grid bounds [0, ' + (gridSizeX - 1) + '].',
				TaskDSLPackage.Literals.LIVE_CELL__X,
				INVALID_CELL_COORDINATE
			)
		}
		
		// The cell is invalid if its y-coordinate is outside [0, sizeY-1]
		if (liveCell.y < 0 || liveCell.y >= gridSizeY) {
			error(
				'Cell Y coordinate (' + liveCell.y + ') is outside the grid bounds [0, ' + (gridSizeY - 1) + '].',
				TaskDSLPackage.Literals.LIVE_CELL__Y,
				INVALID_CELL_COORDINATE
			)
		}
	}
	
	// --- Rule 2 (Error): Ensures the neighbor count in any rule is logically possible (between 0 and 8). ---
	
	public static val NEIGHBOR_COUNT_IMPOSSIBLE = 'neighbor_count_impossible'
	
	// Helper method to check all rule types
	private def checkRuleCount(int count, Operator operator, Object rule, String ruleType) {
		// Basic sanity check: count must be non-negative.
		if (count < 0) {
			error(
				'Neighbor count must be 0 or greater for ' + ruleType + '.',
				TaskDSLPackage.Literals.BIRTH_RULE__COUNT, // Use a generic literal for count on a rule type
				NEIGHBOR_COUNT_IMPOSSIBLE
			)
			return // Stop processing this rule
		}
		
		// Check for impossible scenarios where a condition can *never* be met (e.g., Neighbors = 9 or Neighbors > 8)
		if (count > 8 && (operator == Operator.EQUAL || operator == Operator.GREATER_THAN)) {
			error(
				ruleType + ' count ' + operator.literal + ' ' + count + ' is impossible. A cell can only have up to 8 neighbors.',
				TaskDSLPackage.Literals.BIRTH_RULE__COUNT, // Use a generic literal for count
				NEIGHBOR_COUNT_IMPOSSIBLE
			)
		}
	}
	
	@Check
	def checkBirthRuleCount(BirthRule rule) {
		checkRuleCount(rule.count, rule.operator, rule, 'Birth Rule')
	}
	
	@Check
	def checkSurvivalRuleCount(SurvivalRule rule) {
		checkRuleCount(rule.count, rule.operator, rule, 'Survival Rule')
	}

	@Check
	def checkDeathRuleCount(DeathRule rule) {
		checkRuleCount(rule.count, rule.operator, rule, 'Death Rule')
	}
	
	// --- Rule 3 (Warning): Warns about logically redundant or potentially confusing rules. ---
	
	public static val REDUNDANT_RULE = 'redundant_rule'
	
	// Helper method to warn about rules that are always true or always false within 0-8 range
	private def warnAboutRedundantRule(int count, Operator operator, Object rule, String ruleType) {
		
		// Case A: Rule is ALWAYS TRUE (e.g., '< 9' or '> -1')
		if (operator == Operator.LESS_THAN && count > 8) {
			warning(
				ruleType + ' condition is always true (a cell always has < 9 neighbors). This rule is redundant.',
				TaskDSLPackage.Literals.BIRTH_RULE__COUNT, // Use a generic literal for count
				REDUNDANT_RULE
			)
		}
		
		if (operator == Operator.GREATER_THAN && count < 0) {
			warning(
				ruleType + ' condition is always true (a cell always has >= 0 neighbors). This rule is redundant.',
				TaskDSLPackage.Literals.BIRTH_RULE__COUNT, // Use a generic literal for count
				REDUNDANT_RULE
			)
		}
		
		// Case B: Rule is ALWAYS FALSE (e.g., '< 0') - Rule 2 already handles impossible cases like '= 9' and '> 8'.
		if (operator == Operator.LESS_THAN && count <= 0) {
			// '< 0' is always false. '<= 0' is always false (only 0 is possible, so '< 0' is definitely false).
			warning(
				ruleType + ' condition is always false (a cell cannot have < 0 neighbors). This rule is redundant.',
				TaskDSLPackage.Literals.BIRTH_RULE__COUNT, // Use a generic literal for count
				REDUNDANT_RULE
			)
		}
	}

	@Check
	def warnAboutRedundantBirthRule(BirthRule rule) {
		warnAboutRedundantRule(rule.count, rule.operator, rule, 'Birth Rule')
	}

	@Check
	def warnAboutRedundantSurvivalRule(SurvivalRule rule) {
		warnAboutRedundantRule(rule.count, rule.operator, rule, 'Survival Rule')
	}

	@Check
	def warnAboutRedundantDeathRule(DeathRule rule) {
		warnAboutRedundantRule(rule.count, rule.operator, rule, 'Death Rule')
	}
}