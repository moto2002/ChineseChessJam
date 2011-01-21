package com.godpaper.model.vos
{
	import com.godpaper.business.managers.ChessPieceManager;
	import com.godpaper.business.managers.GameManager;
	import com.godpaper.consts.CcjConstants;
	import com.godpaper.consts.ChessPiecesConstants;
	import com.godpaper.core.IChessPiece;
	import com.godpaper.model.ChessPiecesModel;
	import com.godpaper.utils.LogUtil;
	import com.godpaper.views.components.ChessGasket;
	import com.godpaper.views.components.ChessPiece;
	import com.lookbackon.ds.BitBoard;

	import flash.events.EventDispatcher;
	import flash.geom.Point;

	import mx.logging.ILogger;

	/**
	 * This conduct entity model with basic information as follows:</p>
	 * 1.moved chess prototype(ChessPieces);</br>
	 * 2.moved destination position(Point(x,y));</br>
	 * 3.a brevity string such as "Pg3g4(兵3进4)";</br>
	 * 4."eat off" reference on be eatten off chess pieces;</br>
	 * 5.crossValue the current conductVO's zobrist key value;</br>
	 * @author Knight.zhou
	 * @history 2010-6-24,re-construct:newPositon to currentPosition,keep previousPosition.
	 * @history 2010-7-12,add-construct:eatOff,crossValue.
	 * @history 2010-12-02,reverse() added.
	 */
	public class ConductVO extends EventDispatcher
	{
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		private var _target:IChessPiece;  
		private var _prviousPosition:Point	=	new Point(-1,-1);
		//private var _currentPosition:Point  =  	new Point(-1,-1);
		private var _nextPosition:Point 	=	new Point(-1,-1);
		//
		private var _brevity:String="";
		//
		private var _eatOff:ChessPiece;
		//
		private var _crossValue:int;
		//----------------------------------
		//  CONSTANTS
		//----------------------------------
		private static const LOG:ILogger = LogUtil.getLogger(ConductVO);
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		//----------------------------------
		//  target(read-write)
		//----------------------------------
		public function get target():IChessPiece
		{
			return _target;
		}
		public function set target(value:IChessPiece):void
		{
			_target = value;
		}
		//----------------------------------
		//  previousPosition(read-write)
		//----------------------------------
		public function get previousPosition():Point
		{
			return _prviousPosition;
		}
		public function set previousPosition(value:Point):void
		{
			_prviousPosition = value;
		}
		//----------------------------------
		//  brevity(read-only)
		//----------------------------------
		public function get brevity():String
		{
			//generate brevity.
			return _brevity.concat((target as ChessPiece).name,previousPosition.x,previousPosition.y,nextPosition.x,nextPosition.y);
		}
		//----------------------------------
		//  currentPosition(read-only)
		//----------------------------------
		public function get currentPosition():Point
		{
			return _target.position;
		}
		//----------------------------------
		//  nextPosition(read-write)
		//----------------------------------
		public function set nextPosition(value:Point):void
		{
			_nextPosition = value;
			//
			var cGasket:ChessGasket = 
				ChessPieceManager.gaskets.gett(value.x,value.y) as ChessGasket;
			if(cGasket.numElements>=1)
			{
				//TODO:chess piece eat off.
				var removedPiece:ChessPiece = cGasket.getElementAt(0) as ChessPiece;
				var removedIndex:int = ChessPieceManager.calculatePieceIndex(removedPiece);
				LOG.debug("Eat Off@{0} target:{1}",cGasket.position.toString(),removedPiece.toString());
				//set eat off value.
				eatOff = removedPiece;
			}
		}
		public function get nextPosition():Point
		{
			return _nextPosition;
		}
		//----------------------------------
		//  eatOff(read-write)
		//----------------------------------
		public function get eatOff():ChessPiece
		{
			return _eatOff;
		}
		public function set eatOff(value:ChessPiece):void
		{
			_eatOff = value;
			//
			ChessPieceManager.eatOffs.push(value);
		}
		//----------------------------------
		//  crossValue(read-write)
		//----------------------------------
		public function get crossValue():int
		{
			return _crossValue;
		}
		public function set crossValue(value:int):void
		{
			_crossValue = value;
		}
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		/**
		 * Prints out all elements (for debug/demo purposes).
		 *
		 * @return A human-readable representation of the structure.
		 */
		public function dump():String
		{
			var s:String = "ConductVO";
			s += "\n{";
			s += "\n" + "\t";
			s += "target:"+target+","
				+"\n" + "\t"
				+"previousPosition:"+previousPosition.toString()+","
				+"\n" + "\t"
				+"currentPosition:"+currentPosition.toString()+","
				+"\n" + "\t"
				+"nextPosition:"+nextPosition.toString()+","
				+"\n" + "\t"
				+"brevity:"+brevity.toString()+","
				+"\n" + "\t"
				+"crossValue:"+crossValue.toString()+","
				+"\n" + "\t";
			if(null!=eatOff)
			{
				s +="eat off:"+eatOff.toString();
			}
			s += "\n}";
			return s;
		}
		/**
		 *
		 * @return reversed itself,for unmaking functions;
		 *
		 */		
		public function reverse():ConductVO
		{
			var reversedConductVO:ConductVO = new ConductVO();
			reversedConductVO.crossValue = this.crossValue;
			reversedConductVO.nextPosition = this.previousPosition;
			reversedConductVO.previousPosition = this.nextPosition;
			reversedConductVO.target = this.target;
			reversedConductVO.eatOff = this.eatOff;
			return reversedConductVO;
		}
	}
}

