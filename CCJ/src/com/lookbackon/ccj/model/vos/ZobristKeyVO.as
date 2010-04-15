package com.lookbackon.ccj.model.vos
{
	import com.lookbackon.ccj.CcjConstants;
	import com.lookbackon.ds.BitBoard;
	
	import de.polygonal.ds.Array2;
	
	import flash.events.EventDispatcher;

	/**
	 * 
	 * @author Knight.zhou
	 * 
	 */
	public class ZobristKeyVO extends EventDispatcher
	{
		//chess colour bit board.
		[Bindable]public var color:Array2 = new Array2(CcjConstants.BOARD_H_LINES,CcjConstants.BOARD_V_LINES);
		//chess type bit board.
		[Bindable]public var type:Array2 = new Array2(CcjConstants.BOARD_H_LINES,CcjConstants.BOARD_V_LINES);
		//chess position bit board.
		[Bindable]public var position:Array2 = new Array2(CcjConstants.BOARD_H_LINES,CcjConstants.BOARD_V_LINES);
		/**
		 * Prints out all elements (for debug/demo purposes).
		 * 
		 * @return A human-readable representation of the structure.
		 */
		public function dump():String
		{
			var s:String = "ZobristKeyVO";
			s += "\n{";
			s += "\n" + "\t";
			s += "color:"+color+","+"type:"+type+","+"position:"+position;
			s += "\n}";
			return s;
		}
	}
}
