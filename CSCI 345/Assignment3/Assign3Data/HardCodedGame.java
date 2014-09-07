/**
 * This work is licensed under the Creative Commons Attribution 3.0
 * Unported License. To view a copy of this license, visit/Users/zqevans/Documents/Programming/CSCI 345/Assignment3/Assign3Data/HardCodedGame.java
 * http://creativecommons.org/licenses/by/3.0/ or send a letter to
 * Creative Commons, 444 Castro Street, Suite 900,
 * Mountain View, California, 94041, USA. 
 */

package cs345evansz2;

import static cs345evansz2.GameGlobals.*;

/**
 * This class builds a hard coded game.
 * 
 * @author Chris Reedy (Chris.Reedy@wwu.edu)
 */
public class HardCodedGame implements GameBuilder {
	
	HardCodedGame() {}
	
	@Override
	public void build() {
		
		final Word wQuit = Word.makeWord("quit", MatchType.PREFIX);
		final Word wExit = Word.makeWord("exit", MatchType.PREFIX);
		final Word wMove = Word.makeWord("move", MatchType.PREFIX);
		final Word wGo = Word.makeWord("go", MatchType.PREFIX);
		final Word wMagic = Word.makeWord("magic", MatchType.EXACT);
		final Word wLook = Word.makeWord("look", MatchType.PREFIX);
		final Word wKill = Word.makeWord("kill", MatchType.PREFIX);
		final Word wExecute = Word.makeWord("execute", MatchType.PREFIX);

		final Word wNorth = Word.makeWord("north", MatchType.PREFIX);
		final Word wSouth = Word.makeWord("south", MatchType.PREFIX);
		
		final VocabItem vQuit = VocabItem.makeVocab("quit", wQuit, wExit);
		final VocabItem vMove = VocabItem.makeVocab("move", wMove, wGo);
		final VocabItem vDirect = VocabItem.makeVocab("direction", wNorth, wSouth);
		final VocabItem vLook = VocabItem.makeVocab("look", wLook);
		final VocabItem vKill = VocabItem.makeVocab("kill", wKill, wExecute);
		final VocabItem vMagic = VocabItem.makeVocab("magic", wMagic);
		final VocabItem vNorth = VocabItem.makeVocab("north", wNorth);
		final VocabItem vSouth = VocabItem.makeVocab("south", wSouth);
		
		final Room rNorth = Room.makeRoom("northroom", "You are in the north end of the Big Room. The room extends south from here.");
		final Room rSouth = Room.makeRoom("southroom", "You are in the south end of the Big Room. The room extends north from here.");
		final Room rMagic = Room.makeRoom("magicroom", "You are in the magic workshop. There are no doors in any of the walls.");
		
		Path.makePath("south", vSouth, rNorth, rSouth);
		Path.makePath("north", vNorth, rSouth, rNorth);
		
		allActions.add(new Action(vQuit, null) {
			public void doAction(Word w1, Word w2) {
				interp.setExit(true);
			}
		});
		
		allActions.add(new Action(vMove, vDirect) {
			public void doAction(Word w1, Word w2) {
				thePlayer.moveOnPath(w2);
			}
		});
		
		allActions.add(new Action(vLook, null) {
			public void doAction(Word w1, Word w2) {
				thePlayer.lookAround();
			}
		});
		
		allActions.add(new Action(vMagic, null) {
			final Room fromRoom = rSouth;
			final Room toRoom = rMagic;
			
			public void doAction(Word w1, Word w2) {
				Room loc = thePlayer.getLocation();
				if (loc == fromRoom) {
					/* Can do this, we're in the right location. */
					thePlayer.apportTo(toRoom);
				} else if (loc == toRoom) {
					/* Good idea, the magic word gets you out again. */
					thePlayer.apportTo(fromRoom);
				} else {
					/* Wrong location. Act like we don't know the word. */
					messageOut.printf("I don't understand %s.", w1.word);
				}
			}
		});
		
		allActions.add(new Action(vKill, null) {
			public void doAction(Word w1, Word w2) {
				messageOut.printf("What exactly is it you want me to %s?", w1.getWord());
			}
		});
		
		thePlayer = new Player("You");
		thePlayer.apportTo(rNorth);

	}

}
