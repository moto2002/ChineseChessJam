package com.godpaper.as3.core
{
	//--------------------------------------------------------------------------
	//
	//  Imports
	//
	//--------------------------------------------------------------------------
	import com.godpaper.as3.model.vos.ConductVO;
	import com.godpaper.as3.model.vos.OmenVO;

	import flash.geom.Point;


	/**
	 * The interface of ChessFactory.as;
	 * @author yangboz
	 * @langVersion 3.0
	 * @playerVersion 9.0
	 * Created Jan 27, 2011 4:34:33 PM
	 */
	public interface IChessFactory
	{
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
		//  Public methods
		//
		//--------------------------------------------------------------------------
		function createChessPiece(position:Point, flag:int=0):IChessPiece;

		function createChessGasket(position:Point):IChessGasket;

		function generateChessVO(conductVO:ConductVO):IChessVO;

		function generateOmenVO(conductVO:ConductVO):OmenVO;
	}
}

