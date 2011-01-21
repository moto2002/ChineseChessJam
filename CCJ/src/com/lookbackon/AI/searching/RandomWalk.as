package com.lookbackon.AI.searching
{
	import com.godpaper.utils.FilterUtil;
	import com.godpaper.consts.ChessPiecesConstants;
	import com.godpaper.business.managers.ChessPieceManager;
	import com.godpaper.business.managers.GameManager;
	import com.godpaper.model.vos.ConductVO;
	import com.godpaper.model.vos.PositionVO;
	import com.godpaper.utils.LogUtil;
	import com.godpaper.utils.MathUtil;
	
	import mx.logging.ILogger;
	
	/**
	 *
	 * This essay is a detailed explanation of one of the most important
	 * data structures ever created for Game Artificial Intelligence. 
	 * The minimax tree is at the heart of almost every board game program in existence.
	 * 
	 * @author Knight-errant
	 */	
	public class RandomWalk extends SearchingBase
	{
		private static const LOG:ILogger = LogUtil.getLogger(RandomWalk);
		/**
		 * About RandomWalkAI(瞎走)
		 * if(game over in current board position) return winner,
		 * children = all legal moves for player from this board
		 * if(max's turn) return maximal score of calling minimax on all the children.
		 * else (min's turn)
		 * return minimal score of calling minimax on all the children
		 * 
		 */		
		public function RandomWalk(gamePosition:PositionVO) 
		{
			//
			super(gamePosition);
		}	
		
		override public function run():void
		{
			var randomMoves:Vector.<ConductVO> = moves;//default randomMoves.
			//
			bestMove = new ConductVO();
			if(moves.length<=0)
			{
				GameManager.humanWin();//pluge to death.
			}else
			{
				//while checking,defends move first.
				trace(ChessPieceManager.isChecking);
				if(ChessPieceManager.isChecking)
				{
					randomMoves = moves.filter(FilterUtil.onDefends);
					//reset this flag
					ChessPieceManager.isChecking = false;
				}
				//for test.
				for(var t:int=0;t<randomMoves.length;t++)
				{
					LOG.info("randomMoves:#{0},detail:{1}",t.toString(),randomMoves[t].dump());
				}
				var randomStep:int = MathUtil.transactRandomNumberInRange(0,randomMoves.length-1);
				LOG.debug("randomStep:{0}",randomStep.toString());
				//evaluation.
				var pValue:int=-1;
				for(var i:int=0;i<randomMoves.length;i++)
				{
					if(doEvaluation(randomMoves[i],gamePosition)>pValue)
					{
						bestMove = randomMoves[i];
						pValue = doEvaluation(randomMoves[i],gamePosition);
					}
				}
				LOG.debug("randomed bestMove:{0}",bestMove.dump());
				LOG.debug("max position value:{0}",pValue);
				//
				this.processDone = true;
			}
		}
		
		//return random position value.
		override public function doEvaluation(conductVO:ConductVO,gamePosition:PositionVO):int
		{
			//Todo:doEvaluation about assumpted conductVO;
			var importantValue:int = ChessPiecesConstants[conductVO.target.type].important.gett(conductVO.nextPosition.x,conductVO.nextPosition.y);
			var fuzzyImportValue:int = ChessPiecesConstants[conductVO.target.type].convertedImportant.gett(conductVO.nextPosition.x,conductVO.nextPosition.y);
			//TODO:dynamic omenVO value to be calculated. 
			//precies evaluation value.
			return importantValue+fuzzyImportValue;
			//			return _positionEvaluation;
			//			return Math.random()*100;
			//			return super.doEvaluation(conductVO);
		};
		
	}	
	
}
