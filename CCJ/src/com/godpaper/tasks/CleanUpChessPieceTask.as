package com.godpaper.tasks
{
	//--------------------------------------------------------------------------
	//
	//  Imports
	//
	//--------------------------------------------------------------------------
//	import com.adobe.cairngorm.task.Task;
	import com.godpaper.configs.BoardConfig;
	import com.godpaper.consts.CcjConstants;
	import com.godpaper.business.factory.ChessFactory;
	import com.godpaper.business.managers.ChessPieceManager;
	import com.godpaper.model.ChessPiecesModel;
	import com.godpaper.views.components.ChessGasket;
	import com.godpaper.views.components.ChessPiece;
	import com.godpaper.core.IChessPiece;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import mx.core.FlexGlobals;
	
	import org.spicefactory.lib.task.Task;
	
	/**
	 * CleanUpChessPieceTask.as class.   	
	 * @author yangboz
	 * @langVersion 3.0
	 * @playerVersion 9.0
	 * Created Dec 29, 2010 11:51:40 AM
	 */   	 
	public class CleanUpChessPieceTask extends Task
	{		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		[Bindable]
		private var chessPiecesModel:ChessPiecesModel = ChessPiecesModel.getInstance();
		//----------------------------------
		//  CONSTANTS
		//----------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  Public properties
		//
		//-------------------------------------------------------------------------- 
		
		//--------------------------------------------------------------------------
		//
		//  Protected properties
		//
		//-------------------------------------------------------------------------- 
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		public function CleanUpChessPieceTask()
		{
			//TODO: implement function
			super();
		}     	
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
//		override protected function performTask():void
		override protected function doStart():void	
		{
			//clean up chess piece
			for(var v:int=0;v<BoardConfig.yLines;v++)
			{
				for(var h:int=0;h<BoardConfig.xLines;h++)
				{
					var chessGasket:ChessGasket = (ChessPieceManager.gaskets.gett(h,v) as ChessGasket);
					if( chessGasket.chessPiece )
					{
						trace("removed piece:",ChessPiece(chessGasket.chessPiece).label );
						try{
							chessGasket.chessPiece.chessVO = null;
							chessGasket.chessPiece.omenVO = null;
							chessGasket.chessPiece = null;
//							chessGasket.removeElement( chessGasket.chessPiece );
							//
							chessPiecesModel.reds.length = 0;
							chessPiecesModel.blues.length = 0;
							//
						}catch(error:Error)
						{
							//
							trace(error);
						}
					}
				}
			}
			//
			this.complete();
		}
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------
	}
	
}