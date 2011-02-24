package com.godpaper.as3.model.vos.ccjVO
{
	import com.godpaper.as3.consts.CcjConstants;
	import com.godpaper.as3.consts.CcjPiecesConstants;
	import com.godpaper.as3.model.ChessPiecesModel;
	import com.godpaper.as3.utils.LogUtil;
	import com.godpaper.as3.utils.MathUtil;
	import com.lookbackon.ds.BitBoard;

	import mx.logging.ILogger;
	import com.godpaper.as3.impl.AbstractChessVO;

	/**
	 * <strong>Positive Rays</strong></p>
	 * Attacks of Positive Ray-Directions:west,north,east,south
	 * @see getWest
	 * @see getNorth
	 * @see getNorth
	 * @see getSouth
	 * @author Knight.zhou
	 *
	 */	
	public class CannonVO extends AbstractChessVO
	{
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		//----------------------------------
		//  CONSTANTS
		//----------------------------------
		protected static const LOG:ILogger = LogUtil.getLogger(CannonVO);
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		public function CannonVO(width:int, height:int, rowIndex:int, colIndex:int,flag:int=0)
		{
			//TODO: implement function
			super(width, height, rowIndex, colIndex, flag);
		}
		/**
		 * @inheritDoc
		 */
		override public function initialization(rowIndex:int, colIndex:int,flag:int=0) : void
		{
			// s - *
			// -
			// *
			//about occupies.
			//serveral admental(炮隔子吃子问题)
			for(var r:int=0;r<this.row;r++)
			{
				this.occupies.setBitt(r,colIndex,true);
			}
			for(var c:int=0;c<this.column;c++)
			{
				this.occupies.setBitt(rowIndex,c,true);
			}
			LOG.debug("occupies:{0}",this.occupies.dump());
			//about legal moves.
			if(flag==CcjConstants.FLAG_RED)
			{
				this.moves = this.occupies.xor(this.occupies.and(ChessPiecesModel.getInstance().redPieces));
			}
			if(flag==CcjConstants.FLAG_BLUE)
			{
				this.moves = this.occupies.xor(this.occupies.and(ChessPiecesModel.getInstance().bluePieces));
			}
//			LOG.info("moves:{0}",this.moves.dump());//not complete generated here.
			//blocker
			blocker = this.occupies.xor(this.moves);
			//
			LOG.debug("blocker.isEmpty:{0}",blocker.isEmpty.toString());
			if(!blocker.isEmpty)
			{
				LOG.debug("blocker:{0}",blocker.dump());
//				LOG.debug("all pieces:{0}",ChessPiecesModel.getInstance().allPieces.dump());
				//
				var east:BitBoard = this.getEast(rowIndex,colIndex);
				var north:BitBoard = this.getNorth(rowIndex,colIndex);
				var west:BitBoard = this.getWest(rowIndex,colIndex);
				var south:BitBoard = this.getSouth(rowIndex,colIndex);
				LOG.debug("east:{0}",east.dump());
				LOG.debug("north:{0}",north.dump());
				LOG.debug("west:{0}",west.dump());
				LOG.debug("south:{0}",south.dump());
				this.moves = east.or(north.or(west.or(south)));
				LOG.debug("moves:{0}",this.moves.dump());
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
			LOG.debug("captures:{0}",this.captures.dump());
		}

		//----------------------------------
		//  X-ray attacks(override)
		//----------------------------------
		//west
		override public function getWest(rowIndex:int, colIndex:int):BitBoard
		{
			var mountIndex:int = -1;//find cannon mount().
			var bb:BitBoard = new BitBoard(this.column,this.row);
			for(var w:int=colIndex-1;w>=0;w--)
			{
				if(ChessPiecesModel.getInstance().allPieces.getBitt(rowIndex,w))
				{
					mountIndex = w;
					break;
				}else
				{
					bb.setBitt(rowIndex,w,true);
				}
			}
			if(mountIndex!=-1)
			{
				for(var m:int=mountIndex-1;m>=0;m--)
				{
					if(this.flag==CcjConstants.FLAG_BLUE)
					{
						if(ChessPiecesModel.getInstance().bluePieces.getBitt(rowIndex,m)) break;
						if(ChessPiecesModel.getInstance().redPieces.getBitt(rowIndex,m))
						{
							bb.setBitt(rowIndex,m,true);
							break;
						}
					}else
					{
						if(ChessPiecesModel.getInstance().redPieces.getBitt(rowIndex,m)) break;
						if(ChessPiecesModel.getInstance().bluePieces.getBitt(rowIndex,m))
						{
							bb.setBitt(rowIndex,m,true);
							break;
						}
					}
				}
			}
			return bb;
		}
		//north
		override public function getNorth(rowIndex:int, colIndex:int):BitBoard
		{
			var mountIndex:int = -1;//find cannon mount().
			var bb:BitBoard = new BitBoard(this.column,this.row);
			for(var n:int=rowIndex-1;n>=0;n--)
			{
				if(ChessPiecesModel.getInstance().allPieces.getBitt(n,colIndex))
				{
					mountIndex = n;
					break;
				}else
				{
					bb.setBitt(n,colIndex,true);
				}
			}
			if(mountIndex!=-1)
			{
				for(var m:int=mountIndex-1;m>=0;m--)
				{
					if(this.flag==CcjConstants.FLAG_BLUE)
					{
						if(ChessPiecesModel.getInstance().bluePieces.getBitt(m,colIndex)) break;
						if(ChessPiecesModel.getInstance().redPieces.getBitt(m,colIndex))
						{
							bb.setBitt(m,colIndex,true);
							break;
						}
					}else
					{
						if(ChessPiecesModel.getInstance().redPieces.getBitt(m,colIndex)) break;
						if(ChessPiecesModel.getInstance().bluePieces.getBitt(m,colIndex))
						{
							bb.setBitt(m,colIndex,true);
							break;
						}
					}
				}
			}
			return bb;
		}
		//east
		override public function getEast(rowIndex:int, colIndex:int):BitBoard
		{
			var mountIndex:int = -1;//find cannon mount().
			var bb:BitBoard = new BitBoard(this.column,this.row);
			for(var e:int=colIndex+1;e<this.column;e++)
			{
				if(ChessPiecesModel.getInstance().allPieces.getBitt(rowIndex,e))
				{
					mountIndex = e;
					break;
				}else
				{
					bb.setBitt(rowIndex,e,true);
				}
			}
			if(mountIndex!=-1)
			{
				for(var m:int=mountIndex+1;m<this.column;m++)
				{
					if(this.flag==CcjConstants.FLAG_BLUE)
					{
						if(ChessPiecesModel.getInstance().bluePieces.getBitt(rowIndex,m)) break;
						if(ChessPiecesModel.getInstance().redPieces.getBitt(rowIndex,m))
						{
							bb.setBitt(rowIndex,m,true);
							break;
						}
					}else
					{
						if(ChessPiecesModel.getInstance().redPieces.getBitt(rowIndex,m)) break;
						if(ChessPiecesModel.getInstance().bluePieces.getBitt(rowIndex,m))
						{
							bb.setBitt(rowIndex,m,true);
							break;
						}
					}
				}
			}
			return bb;
		}
		//south
		override public function getSouth(rowIndex:int, colIndex:int):BitBoard
		{
			var mountIndex:int = -1;//find cannon mount().
			var bb:BitBoard = new BitBoard(this.column,this.row);
			for(var s:int=rowIndex+1;s<this.row;s++)
			{
				if(ChessPiecesModel.getInstance().allPieces.getBitt(s,colIndex))
				{
					mountIndex = s;
					break;
				}else
				{
					bb.setBitt(s,colIndex,true);
				}
			}
			if(mountIndex!=-1)
			{
				for(var m:int=mountIndex+1;m<this.row;m++)
				{
					if(this.flag==CcjConstants.FLAG_BLUE)
					{
						if(ChessPiecesModel.getInstance().bluePieces.getBitt(m,colIndex)) break;
						if(ChessPiecesModel.getInstance().redPieces.getBitt(m,colIndex))
						{
							bb.setBitt(m,colIndex,true);
							break;
						}
					}else
					{
						if(ChessPiecesModel.getInstance().redPieces.getBitt(m,colIndex)) break;
						if(ChessPiecesModel.getInstance().bluePieces.getBitt(m,colIndex))
						{
							bb.setBitt(m,colIndex,true);
							break;
						}
					}
				}
			}
			return bb;
		}

	}
}

