package com.godpaper.as3.model.vos.ccjVO
{
	import com.godpaper.as3.consts.CcjConstants;
	import com.godpaper.as3.consts.CcjPiecesConstants;
	import com.godpaper.as3.model.ChessPiecesModel;
	import com.godpaper.as3.model.ZobristKeysModel;
	import com.godpaper.as3.model.vos.ZobristKeyVO;
	import com.godpaper.as3.utils.LogUtil;
	import com.godpaper.as3.utils.MathUtil;
	
	import mx.logging.ILogger;
	import com.godpaper.as3.impl.AbstractChessVO;

	/**
	 * 
	 * @author Knight.zhou
	 * 
	 */	
	public class BishopVO extends AbstractChessVO
	{
		private static const LOG:ILogger = LogUtil.getLogger(BishopVO);
		/**
		 * @inheritDoc
		 */
		public function BishopVO(width:int, height:int, rowIndex:int, colIndex:int,flag:int=0)
		{
			//TODO: implement function
			super(width, height, rowIndex, colIndex, flag);
		}
		/**
		 * @inheritDoc
		 */
		override public function initialization(rowIndex:int, colIndex:int,flag:int=0) : void
		{
			// * - -
			// - - -
			// - - *
			//about occupies.
			//serveral admental(象田心问题，象过河问题)
			if(!ChessPiecesModel.getInstance().allPieces.getBitt(rowIndex+1,colIndex+1))
			{
				//serveral admental(象过河问题)
				if(flag==CcjConstants.FLAG_BLUE)
				{
					if(rowIndex<4)
					{
						this.occupies.setBitt(rowIndex+2,colIndex+2,true);
					}
				}else
				{
					this.occupies.setBitt(rowIndex+2,colIndex+2,true);
				}
			}
			if(!ChessPiecesModel.getInstance().allPieces.getBitt(rowIndex+1,colIndex-1))
			{
				//serveral admental(象过河问题)
				if(flag==CcjConstants.FLAG_BLUE)
				{
					if(rowIndex<4)
					{
						this.occupies.setBitt(rowIndex+2,colIndex-2,true);
					}
				}else
				{
					this.occupies.setBitt(rowIndex+2,colIndex-2,true);
				}
			}
			if(!ChessPiecesModel.getInstance().allPieces.getBitt(rowIndex-1,colIndex+1))
			{
				//serveral admental(象过河问题)
				if(flag==CcjConstants.FLAG_RED)
				{
					if(rowIndex>5)
					{
						this.occupies.setBitt(rowIndex-2,colIndex+2,true);
					}
				}else
				{
					this.occupies.setBitt(rowIndex-2,colIndex+2,true);
				}
			}
			if(!ChessPiecesModel.getInstance().allPieces.getBitt(rowIndex-1,colIndex-1))
			{
				//serveral admental(象过河问题)
				if(flag==CcjConstants.FLAG_RED)
				{
					if(rowIndex>5)
					{
						this.occupies.setBitt(rowIndex-2,colIndex-2,true);
					}
				}else
				{
					this.occupies.setBitt(rowIndex-2,colIndex-2,true);
				}
			}
			//about legal moves.
//			LOG.info("redPieces:{0}",ChessPositionModelLocator.getInstance().redPieces.dump());
//			LOG.info("bluePieces:{0}",ChessPositionModelLocator.getInstance().bluePieces.dump());
			if(flag==CcjConstants.FLAG_RED)
			{
				this.moves = this.occupies.xor(this.occupies.and(ChessPiecesModel.getInstance().redPieces));
			}
			if(flag==CcjConstants.FLAG_BLUE)
			{
				this.moves = this.occupies.xor(this.occupies.and(ChessPiecesModel.getInstance().bluePieces));
			}
			//about attacked captures.
			if(flag==CcjConstants.FLAG_RED)
			{
				this.captures = this.moves.and(ChessPiecesModel.getInstance().bluePieces);
			}
			if(flag==CcjConstants.FLAG_BLUE)
			{
				this.captures = this.moves.and(ChessPiecesModel.getInstance().redPieces);
			}
			//
			LOG.debug("occupies:{0}",this.occupies.dump());
			LOG.debug("moves:{0}",this.moves.dump());
			LOG.debug("captures:{0}",this.captures.dump());
		}
	}
}