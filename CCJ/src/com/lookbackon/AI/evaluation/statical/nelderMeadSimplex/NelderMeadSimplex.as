package com.lookbackon.AI.evaluation.statical.nelderMeadSimplex
{
//	public delegate double ObjectiveFunctionDelegate(double[] constants);
	/**
	 *
	 * @see http://code.google.com/p/nelder-mead-simplex/
	 * @see http://www.omatrix.com/manual/neldermead.htm
	 * @author Knight.zhou
	 * 
	 */	
	public class NelderMeadSimplex
	{
//		private static const JITTER:uint = 1e-10d;           // a small value used to protect against floating point noise
		private static const JITTER:uint = Math.E;
		public static function Regress(
			simplexConstants:Array,//SimplexConstant[]  
			convergenceTolerance:Number, 
			maxEvaluations:int,
			objectiveFunction:ObjectiveFunctionDelegate
		):RegressionResult
		{
			// confirm that we are in a position to commence
			if (objectiveFunction == null)
				throw new Error("ObjectiveFunction must be set to a valid ObjectiveFunctionDelegate");
			
			if (simplexConstants == null)
				throw new Error("SimplexConstants must be initialized");
			
			// create the initial simplex
			var numDimensions:int = simplexConstants.Length;
			var numVertices:int = numDimensions + 1;
//			Vector[] vertices = _initializeVertices(simplexConstants);
			var vertices:SimpleVector.<SimpleVector> = _initializeVertices(simplexConstants);
//			double[] errorValues = new double[numVertices];
			var errorValues:SimpleVector.<uint> = new SimpleVector.<uint>(numVertices);
			
			var evaluationCount:int = 0;
//			TerminationReason terminationReason = TerminationReason.Unspecified;
			var terminationReason:TerminationReason = TerminationReason.Unspecified;
			var errorProfile:ErrorProfile;
			
			errorValues = _initializeErrorValues(vertices, objectiveFunction);
			
			// iterate until we converge, or complete our permitted number of iterations
			while (true)
			{
				errorProfile = _evaluateSimplex(errorValues);
				
				// see if the range in point heights is small enough to exit
				if (_hasConverged(convergenceTolerance, errorProfile, errorValues))
				{
					terminationReason = TerminationReason.Converged;
					break;
				}
				
				// attempt a reflection of the simplex
//				double reflectionPointValue = _tryToScaleSimplex(-1.0, ref errorProfile, vertices, errorValues, objectiveFunction);
				var reflectionPointValue:Number = _tryToScaleSimplex(-1.0, errorProfile, vertices, errorValues, objectiveFunction);
				++evaluationCount;
				if (reflectionPointValue <= errorValues[errorProfile.LowestIndex])
				{
					// it's better than the best point, so attempt an expansion of the simplex
//					double expansionPointValue = _tryToScaleSimplex(2.0, ref errorProfile, vertices, errorValues, objectiveFunction);
					var expansionPointValue:Number = _tryToScaleSimplex(2.0, errorProfile, vertices, errorValues, objectiveFunction);
					++evaluationCount;
				}
				else if (reflectionPointValue >= errorValues[errorProfile.NextHighestIndex])
				{
					// it would be worse than the second best point, so attempt a contraction to look
					// for an intermediate point
					var currentWorst:Number = errorValues[errorProfile.HighestIndex];
					var contractionPointValue:Number = _tryToScaleSimplex(0.5, errorProfile, vertices, errorValues, objectiveFunction);
					++evaluationCount;
					if (contractionPointValue >= currentWorst)
					{
						// that would be even worse, so let's try to contract uniformly towards the low point;
						// don't bother to update the error profile, we'll do it at the start of the
						// next iteration
						_shrinkSimplex(errorProfile, vertices, errorValues, objectiveFunction);
						evaluationCount += numVertices; // that required one function evaluation for each vertex; keep track
					}
				}
				// check to see if we have exceeded our alloted number of evaluations
				if (evaluationCount >= maxEvaluations)
				{
					terminationReason = TerminationReason.MaxFunctionEvaluations;
					break;
				}
			}
			var regressionResult:RegressionResult = new RegressionResult(terminationReason,
				vertices[errorProfile.LowestIndex].Components, errorValues[errorProfile.LowestIndex], evaluationCount);
			return regressionResult;
		}
		
		/// <summary>
		/// Evaluate the objective function at each vertex to create a corresponding
		/// list of error values for each vertex
		/// </summary>
		/// <param name="vertices"></param>
		/// <returns></returns>
		private static function _initializeErrorValues( vertices:SimpleVector.<SimpleVector>, 
														objectiveFunction:ObjectiveFunctionDelegate):Array
		{
//			double[] errorValues = new double[vertices.Length];
			var errorValues:SimpleVector.<Number> = new SimpleVector.<Number>(vertices.Length);
			for (var i:int = 0; i < vertices.Length; i++)
			{
				errorValues[i] = objectiveFunction(vertices[i].Components);
			}
			return errorValues;
		}
		
		/// <summary>
		/// Check whether the points in the error profile have so little range that we
		/// consider ourselves to have converged
		/// </summary>
		/// <param name="errorProfile"></param>
		/// <param name="errorValues"></param>
		/// <returns></returns>
		private static function _hasConverged( 
			convergenceTolerance:Number, 
			errorProfile:ErrorProfile, 
			errorValues:Array
		):Boolean
		{
			var range:Number = 2 * Math.abs(errorValues[errorProfile.HighestIndex] - errorValues[errorProfile.LowestIndex]) /
				(Math.abs(errorValues[errorProfile.HighestIndex]) + Math.abs(errorValues[errorProfile.LowestIndex]) + JITTER);
			
			return (range < convergenceTolerance);
		}
		
		/// <summary>
		/// Examine all error values to determine the ErrorProfile
		/// </summary>
		/// <param name="errorValues"></param>
		/// <returns></returns>
		private static function _evaluateSimplex(errorValues:Array):ErrorProfile
		{
			var errorProfile:ErrorProfile = new ErrorProfile();
			if (errorValues[0] > errorValues[1])
			{
				errorProfile.HighestIndex = 0;
				errorProfile.NextHighestIndex = 1;
			}
			else
			{
				errorProfile.HighestIndex = 1;
				errorProfile.NextHighestIndex = 0;
			}
			
			for (var index:int = 0; index < errorValues.Length; index++)
			{
				var errorValue:Number = errorValues[index];
				if (errorValue <= errorValues[errorProfile.LowestIndex])
				{
					errorProfile.LowestIndex = index;
				}
				if (errorValue > errorValues[errorProfile.HighestIndex])
				{
					errorProfile.NextHighestIndex = errorProfile.HighestIndex; // downgrade the current highest to next highest
					errorProfile.HighestIndex = index;
				}
				else if (errorValue > errorValues[errorProfile.NextHighestIndex] && index != errorProfile.HighestIndex)
				{
					errorProfile.NextHighestIndex = index;
				}
			}
			
			return errorProfile;
		}
		
		/// <summary>
		/// Construct an initial simplex, given starting guesses for the constants, and
		/// initial step sizes for each dimension
		/// </summary>
		/// <param name="simplexConstants"></param>
		/// <returns></returns>
		private static function _initializeVertices(simplexConstants:Array):Array
		{
			var numDimensions:int = simplexConstants.Length;
			var vertices:SimpleVector.<SimpleVector> = new SimpleVector.<SimpleVector>(numDimensions + 1);
			
			// define one point of the simplex as the given initial guesses
			var p0:SimpleVector.<Number> = new SimpleVector.<Number>(numDimensions);
			for (var i:int = 0; i < numDimensions; i++)
			{
				p0[i] = simplexConstants[i].Value;
			}
			
			// now fill in the vertices, creating the additional points as:
			// P(i) = P(0) + Scale(i) * UnitVector(i)
			vertices[0] = p0;
			for (var i:int = 0; i < numDimensions; i++)
			{
				var scale:Number = simplexConstants[i].InitialPerturbation;
				var unitVector:SimpleVector.<Number> = new SimpleVector.<Number>(numDimensions);
				unitVector[i] = 1;
				vertices[i + 1] = p0.Add(unitVector.Multiply(scale));
			}
			return vertices;
		}
		
		/// <summary>
		/// Test a scaling operation of the high point, and replace it if it is an improvement
		/// </summary>
		/// <param name="scaleFactor"></param>
		/// <param name="errorProfile"></param>
		/// <param name="vertices"></param>
		/// <param name="errorValues"></param>
		/// <returns></returns>
		private static function _tryToScaleSimplex( 
														scaleFactor:Number, 
														errorProfile:ErrorProfile, 
														vertices:Array,
														errorValues:Array, 
														objectiveFunction//ObjectiveFunctionDelegate
													):Number
		{
			// find the centroid through which we will reflect
			var centroid:SimpleVector.<SimpleVector> = _computeCentroid(vertices, errorProfile);
			
			
			// define the vector from the centroid to the high point
			var centroidToHighPoint:SimpleVector.<SimpleVector> = vertices[errorProfile.HighestIndex].Subtract(centroid);
			
			// scale and position the vector to determine the new trial point
			var newPoint:SimpleVector.<SimpleVector> = centroidToHighPoint.Multiply(scaleFactor).Add(centroid);
			
			// evaluate the new point
			var newErrorValue:Number = objectiveFunction(newPoint.Components);
			
			// if it's better, replace the old high point
			if (newErrorValue < errorValues[errorProfile.HighestIndex])
			{
				vertices[errorProfile.HighestIndex] = newPoint;
				errorValues[errorProfile.HighestIndex] = newErrorValue;
			}
			
			return newErrorValue;
		}
		
		/// <summary>
		/// Contract the simplex uniformly around the lowest point
		/// </summary>
		/// <param name="errorProfile"></param>
		/// <param name="vertices"></param>
		/// <param name="errorValues"></param>
		private static function _shrinkSimplex( 
													errorProfile:ErrorProfile, 
													vertices:Array, 
													errorValues:Array,
													objectiveFunction//ObjectiveFunctionDelegate
												):void
		{
			var lowestVertex:SimpleVector.<SimpleVector> = vertices[errorProfile.LowestIndex];
			for (var i:int = 0; i < vertices.Length; i++)
			{
				if (i != errorProfile.LowestIndex)
				{
					vertices[i] = (vertices[i].Add(lowestVertex)).Multiply(0.5);
					errorValues[i] = objectiveFunction(vertices[i].Components);
				}
			}
		}
		
		/// <summary>
		/// Compute the centroid of all points except the worst
		/// </summary>
		/// <param name="vertices"></param>
		/// <param name="errorProfile"></param>
		/// <returns></returns>
		private static function _computeCentroid(vertices:SimpleVector.<SimpleVector>, errorProfile:ErrorProfile):SimpleVector
		{
			var numVertices:int = vertices.Length;
			// find the centroid of all points except the worst one
			var centroid:SimpleVector.<SimpleVector> = new SimpleVector(numVertices - 1);
			for (var i:int = 0; i < numVertices; i++)
			{
				if (i != errorProfile.HighestIndex)
				{
					centroid = centroid.Add(vertices[i]);
				}
			}
			return centroid.Multiply(1.0/ (numVertices - 1));
		}
		
	}
}
internal class ErrorProfile
{
	private var _highestIndex:int;

	public function get highestIndex():int
	{
		return _highestIndex;
	}

	public function set highestIndex(value:int):void
	{
		_highestIndex = value;
	}

	private var _nextHighestIndex:int;

	public function get nextHighestIndex():int
	{
		return _nextHighestIndex;
	}

	public function set nextHighestIndex(value:int):void
	{
		_nextHighestIndex = value;
	}

	private var _lowestIndex:int;

	public function get lowestIndex():int
	{
		return _lowestIndex;
	}

	public function set lowestIndex(value:int):void
	{
		_lowestIndex = value;
	}
	
}
internal class SimpleVector
{
	private var _components:SimpleVector.<Number>;
	private var _nDimensions:int;
	
	public function SimpleVector(dimensions:int)
	{
		_components = new SimpleVector.<Number>(dimensions);
		_nDimensions = dimensions;
	}
	
	public function get NDimensions():int
	{
		return _nDimensions;
	}
	
	/*public double this[int index]
	{
		get { return _components[index]; }
		set { _components[index] = value; }
	}*/
	
	public function get Components():SimpleVector.<Number>
	{
		return _components;
	}
	
	/// <summary>
	/// Add another vector to this one
	/// </summary>
	/// <param name="v"></param>
	/// <returns></returns>
	public function Add(v:SimpleVector):SimpleVector
	{
		if (v.NDimensions != this.NDimensions)
			throw new ArgumentError("Can only add vectors of the same dimensionality");
		
		var vector:SimpleVector = new SimpleVector(v.NDimensions);
		for (var i:int = 0; i < v.NDimensions; i++)
		{
			vector[i] = this[i] + v[i];
		}
		return vector;
	}
	
	/// <summary>
	/// Subtract another vector from this one
	/// </summary>
	/// <param name="v"></param>
	/// <returns></returns>
	public function Subtract(v:SimpleVector):SimpleVector
	{
		if (v.NDimensions != this.NDimensions)
			throw new ArgumentException("Can only subtract vectors of the same dimensionality");
		
		var vector:SimpleVector = new SimpleVector(v.NDimensions);
		for (var i:int = 0; i < v.NDimensions; i++)
		{
			vector[i] = this[i] - v[i];
		}
		return vector;
	}
	
	/// <summary>
	/// Multiply this vector by a scalar value
	/// </summary>
	/// <param name="scalar"></param>
	/// <returns></returns>
	public function Multiply(scalar:Number):SimpleVector
	{
		var scaledVector:SimpleVector = new SimpleVector(this.NDimensions);
		for (var i:int = 0; i < this.NDimensions; i++)
		{
			scaledVector[i] = this[i] * scalar;
		}
		return scaledVector;
	}
	
	/// <summary>
	/// Compute the dot product of this vector and the given vector
	/// </summary>
	/// <param name="v"></param>
	/// <returns></returns>
	public function DotProduct(v:SimpleVector):Number
	{
		if (v.NDimensions != this.NDimensions)
			throw new ArgumentException("Can only compute dot product for vectors of the same dimensionality");
		
		var sum:Number = 0;
		for (var i:int = 0; i < v.NDimensions; i++)
		{
			sum += this[i] * v[i];
		}
		return sum;
	}
	
	public function ToString():String
	{
		var components:SimpleVector.<String> = new SimpleVector.<String>(_components.Length);
		for (var i:int = 0; i < components.Length; i++)
		{
			components[i] = _components[i].ToString();
		}
		return "[ " + string.Join(", ", components) + " ]";
	}
}
