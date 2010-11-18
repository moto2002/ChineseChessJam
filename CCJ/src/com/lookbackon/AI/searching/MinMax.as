package com.lookbackon.AI.searching
{
	import com.lookbackon.ccj.CcjConstants;
	import com.lookbackon.ccj.ChessPiecesConstants;
	import com.lookbackon.ccj.managers.GameManager;
	import com.lookbackon.ccj.model.ChessPiecesModel;
	import com.lookbackon.ccj.model.vos.ConductVO;
	import com.lookbackon.ccj.model.vos.PositionVO;
	import com.lookbackon.ccj.utils.LogUtil;
	import com.lookbackon.ccj.utils.MathUtil;
	import com.lookbackon.ds.BitBoard;
	
	import de.polygonal.ds.Array2;
	
	import mx.logging.ILogger;

	/**
	 *
	 * This essay is a detailed explanation of one of the most important
	 * data structures ever created for Game Artificial Intelligence. 
	 * The minimax tree is at the heart of almost every board game program in existence.
	 */	
	public class MinMax extends SearchingBase
	{
		//
		private static const LOG:ILogger = LogUtil.getLogger(MinMax);
		private static const MAX_DEPTH:int = 5;
		//	
		/**
    	 * if(game over in current board position)
         * return winner
         * children = all legal moves for player from this board
         * if(max's turn)
         * return maximal score of calling minimax on all the children
         * else (min's turn)
         * return minimal score of calling minimax on all the children
		 * @see http://www.fierz.ch/strategy.htm
		*/		
		public function MinMax(gamePosition:PositionVO) 
		{
			super(gamePosition);
		}	
		//
		override public function execute():void
		{
			if( orderingMoves.length<=0 )
			{
				GameManager.humanWin();//pluge to death.
			}else
			{
				this.bestMove = this.tempMove;
				//	
				this.makeMove(MaxMove(gamePosition));
			}
		}
		/**
		 * 
		 * @param gamePosition the current game position.
		 * @return the MaxMove choose conductVO;
		 * 
		 */		
		private function MaxMove (gamePosition:PositionVO):ConductVO
		{
			/*if (GameEnded(game)) {
				return EvalGameState(game);
			}
			else {
				best_move < - {};
				moves <- GenerateMoves(game);
				ForEach moves {
					move <- MinMove(ApplyMove(game));
					if (Value(move) > Value(best_move)) {
						best_move < - move;
					}
				}
				return best_move;
			}*/
			//init ordering moves.
			orderingMoves = generateMoves(ChessPiecesModel.getInstance().blues);
			//depth auto increasement.
			depth++;
			trace("depth:",depth);
			//
			if( orderingMoves.length<=0 )
			{
				GameManager.humanWin();//pluge to death.
			}
			//
			if(depthLimitReached)
			{
				return bestMove;			
			}
			//			
			LOG.debug("Max orderingMoves.len:{0}",orderingMoves.length);
			var len:int = orderingMoves.length;
			var tempMoveValue:int;
			var bestMoveValue:int;
			for(var i:int=0;i<len;i++)
			{
				var conductVO:ConductVO = orderingMoves[i];
//				tempMove = MinMove(makeMove(conductVO));//FIXME:makeMove return void to be value assigned.
				var positionVO:PositionVO = new PositionVO();
				tempMove = MinMove(positionVO);
				tempMoveValue = doEvaluation(tempMove,positionVO);
				bestMoveValue = doEvaluation(bestMove,positionVO);
				if(tempMoveValue>bestMoveValue)
				{
					bestMove = tempMove;
					LOG.debug("Max bestMove:{0}",bestMove.dump());
					//
					this.alpha = tempMoveValue;
				}
				//Ignore the remaing moves.
				if(beta>alpha)
				{
					return bestMove;
				}
			}
			return bestMove;						   
		}
		/**
		 * 
		 * @param gamePosition the current game position.
		 * @return the MinMove choose conductVO;
		 * 
		 */			
		private function MinMove(gamePosition:PositionVO):ConductVO 
		{
			/*best_move <- {};
			moves <- GenerateMoves(game);
			ForEach moves {
				move <- MaxMove(ApplyMove(game));
			if (Value(move) > Value(best_move)) {
					best_move < - move;
				}
			}
			return best_move;*/
			//init ordering moves.
			orderingMoves = generateMoves(ChessPiecesModel.getInstance().reds);
			//
			if(orderingMoves.length<=0)
			{
				GameManager.computerWin();//pluge to death.
			}
			//
			if(depthLimitReached)
			{
				return bestMove;			
			}
			LOG.debug("Min orderingMoves.len:{0}",orderingMoves.length);
			var len:int = orderingMoves.length;
			var tempMoveValue:int;
			var bestMoveValue:int;
			for(var i:int=0;i<len;i++)
			{
				var conductVO:ConductVO = orderingMoves[i];
//				tempMove = MinMove(makeMove(conductVO));//FIXME:makeMove return void to be value assigned.
				var positionVO:PositionVO = new PositionVO();
				tempMove = MinMove(positionVO);
				tempMoveValue = doEvaluation(tempMove,positionVO);
				bestMoveValue = doEvaluation(bestMove,positionVO);
				if(tempMoveValue>bestMoveValue)
				{
					bestMove = tempMove;
					LOG.debug("Min bestMove:{0}",bestMove.dump());
					//
					this.beta = tempMoveValue;
				}
				// Ignore remaining moves
				if (beta < alpha)
				{
					return bestMove;
				}
			}
			return bestMove;
		}
		
		/*
		How long does this(MinMax) algorithm take? 
		For a simple game like tic tac toe, not too long - it is certainly possible to search all possible positions.
		For a game like Chess or Go however, the running time is prohibitively expensive.
		In fact, to completely search either of these games, we would first need to develop interstellar travel, 
		as by the time we finish analyzing a move the sun will have gone nova and the earth will no longer exist. 
		Therefore, all real computer games will search, not to the end of the game, but only a few moves ahead. 
		Of course, now the program must determine whether a certain board position is 'good' or 'bad' for a certainly player. 
		This is often done using an evaluation function. This function is the key to a strong computer game; 
		after all, it does little good to be able to look ahead 20 moves,
		if, after we do, we decide that the position is good for us, when in fact, it is terrible! 
		*/
		override public function doEvaluation(conductVO:ConductVO,gamePosition:PositionVO):int
		{
//			return MathUtil.transactRandomNumberInRange(0,100);
			//Todo:doEvaluation about assumpted conductVO;
			var importantValue:int = ChessPiecesConstants[conductVO.target.type].important.gett(conductVO.nextPosition.x,conductVO.nextPosition.y);
			var fuzzyImportValue:int = ChessPiecesConstants[conductVO.target.type].convertedImportant.gett(conductVO.nextPosition.x,conductVO.nextPosition.y);
			//TODO:dynamic omenVO value to be calculated. 
			//precies evaluation value.
			return importantValue+fuzzyImportValue;
		};
		//
		private function get depthLimitReached():Boolean
		{
			return depth>=MAX_DEPTH;
		}
	}	
	
}