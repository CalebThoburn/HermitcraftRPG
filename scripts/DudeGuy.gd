extends CharacterBody2D
#
#const CREATURE = "CoolDude"
#const GRAVITY = 300.0
#
#var test = [[0, 1, 0], [0, 2, 0], [1, 1, 1]]
#var test2 = [[3, 2, 1], [2, 3, 1], [1, 1, 5]]
#var inventory = [[["air", 0]]]
#
#func _ready():
	#print(_matrix_multiply(test, test2))
#
#func _physics_process(delta):
	#
	#if not is_on_floor():
		#velocity.y += GRAVITY * delta
	#
	#move_and_slide()
#
#func _matrix_multiply(matrix1, matrix2):
	#
	#var outputMatrix = []
	#
	#for rowIndex in matrix1:
		#
		#outputMatrix.append([])
		#
		#for valueIndex in range(matrix1[rowIndex].size()):
			#
			#outputMatrix[rowIndex].append(0)
			#
			#for columnIndex in range(matrix2[0].size())
				#var outputValue = matrix1[rowIndex][rowIndex] * matrix1[rowIndex][rowIndex]
			#
			#
