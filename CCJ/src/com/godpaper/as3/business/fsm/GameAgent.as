package com.godpaper.as3.business.fsm
{
	//--------------------------------------------------------------------------
	//
	//  Imports
	//
	//--------------------------------------------------------------------------
	import com.godpaper.as3.business.fsm.states.game.AnotherHumanState;
	import com.godpaper.as3.business.fsm.states.game.AnotherHumanWinState;
	import com.godpaper.as3.business.fsm.states.game.ComputerState;
	import com.godpaper.as3.business.fsm.states.game.ComputerWinState;
	import com.godpaper.as3.business.fsm.states.game.HumanState;
	import com.godpaper.as3.business.fsm.states.game.HumanWinState;
	import com.godpaper.as3.consts.CcjConstants;
	import com.lookbackon.AI.FSM.Agent;
	import com.lookbackon.AI.searching.ISearching;

	import mx.core.IVisualElement;


	/**
	 * GameAgent.as class.The game state agency class.
	 * @author yangboz
	 * @langVersion 3.0
	 * @playerVersion 9.0
	 * Created Dec 10, 2010 11:29:30 AM
	 */   	 
	public class GameAgent extends Agent
	{		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		//The agent obtains states.
		public var humanState:HumanState;
		public var computerState:ComputerState;
		public var anotherHumanState:AnotherHumanState;
		public var humanWinState:HumanWinState;
		public var computerWinState:ComputerWinState;
		public var anotherHumanWinState:AnotherHumanWinState;
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
		public function GameAgent(name:String, carrier:IVisualElement)
		{
			//TODO: implement function
			super(name, carrier);
			//
			this.humanState = new HumanState(this,null,CcjConstants.STATE_HUMAN);
			this.computerState = new ComputerState(this,null,CcjConstants.STATE_COMPUTER);
			this.anotherHumanState = new AnotherHumanState(this,null,CcjConstants.STATE_ANOTHER_HUMAN);
			this.humanWinState = new HumanWinState(this,null,CcjConstants.STATE_HUMAN_WIN);
			this.computerWinState = new ComputerWinState(this,null,CcjConstants.STATE_COMPUTER_WIN);
			this.anotherHumanWinState = new AnotherHumanWinState(this,null,CcjConstants.STATE_ANOTHER_HUMAN_WIN);
		}     	
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------

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

