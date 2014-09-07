/**
 * This work is licensed under the Creative Commons Attribution 3.0
 * Unported License. To view a copy of this license, visit
 * http://creativecommons.org/licenses/by/3.0/ or send a letter to
 * Creative Commons, 444 Castro Street, Suite 900,
 * Mountain View, California, 94041, USA. 
 */

package cs345evansz2;

import static cs345evansz2.GameGlobals.*;

import java.util.Set;

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
		final Word wEast = Word.makeWord("east", MatchType.PREFIX);
		final Word wWest = Word.makeWord("west", MatchType.PREFIX);
		
		noiseWords.add(MatchType.PREFIX, "a", "an", "the", "and", "it",
				"that", "this", "to", "at", "with", "room");
		final VocabItem vQuit = VocabItem.makeVocab("quit", wQuit, wExit);
		final VocabItem vMove = VocabItem.makeVocab("move", wMove, wGo);
		final VocabItem vDirect = VocabItem.makeVocab("direction", wNorth, wSouth, wEast, wWest);
		final VocabItem vLook = VocabItem.makeVocab("look", wLook);
		final VocabItem vKill = VocabItem.makeVocab("kill", wKill, wExecute);
		final VocabItem vMagic = VocabItem.makeVocab("magic", wMagic);
		final VocabItem vNorth = VocabItem.makeVocab("north", wNorth);
		final VocabItem vSouth = VocabItem.makeVocab("south", wSouth);
		final VocabItem vEast = VocabItem.makeVocab("east", wEast);
		final VocabItem vWest = VocabItem.makeVocab("south", wWest);
		
		final Room rNorth = Room.makeRoom("northroom", "You are in the north end of the Big Room. The room extends south from here.");
		final Room rSouth = Room.makeRoom("southroom", "You are in the south end of the Big Room. The room extends north from here. "
											+ "There is a door to the east.");
		final Room rBallroom = Room.makeRoom("ballroom", "You have entered the ballroom. The room has a high ceiling with two magnificent crystal chandeliers which illuminate the room. "
											+ "The floor is a polished wooden parquet with flowers inlaid around the edge. "
											+ "The north wall is lined with mirrors while the south wall has large windows which look out on a beautiful garden. "
											+ "There is a door in the west wall of the room.");
		final Room rMagic = Room.makeRoom("magicroom", "You are in the magic workshop. There are no doors in any of the walls.");
		
		final Word wExamine = Word.makeWord("examine", MatchType.PREFIX);
		final Word wInventory = Word.makeWord("inventory", MatchType.PREFIX);
		final Word wGet = Word.makeWord("get", MatchType.PREFIX);
		final Word wDrop = Word.makeWord("drop", MatchType.PREFIX);
		final Word wRead = Word.makeWord("read", MatchType.PREFIX);
		
		final Word wPaper = Word.makeWord("paper", MatchType.PREFIX);
		final Word wMessage = Word.makeWord("message", MatchType.PREFIX);
		final Word wCoin1 = Word.makeWord("goldcoin", MatchType.PREFIX);
		final Word wCoin2 = Word.makeWord("coin", MatchType.PREFIX);
		
		final VocabItem vExamine = VocabItem.makeVocab("examine", wExamine);
		final VocabItem vInventory = VocabItem.makeVocab("inventory", wInventory);
		final VocabItem vGet = VocabItem.makeVocab("get", wGet);
		final VocabItem vDrop = VocabItem.makeVocab("drop", wDrop);
		final VocabItem vMessage = VocabItem.makeVocab("message", wMessage, wPaper);
		final VocabItem vCoin = VocabItem.makeVocab("coin", wCoin1, wCoin2);
		final VocabItem vItems = VocabItem.makeVocab("items", wMessage, wPaper, wCoin1, wCoin2);
		final VocabItem vRead = VocabItem.makeVocab("read", wRead);
		
		Path.makePath("south", vSouth, rNorth, rSouth);
		Path.makePath("north", vNorth, rSouth, rNorth);
		Path.makePath("east", vEast, rSouth, rBallroom);
		Path.makePath("west", vWest, rBallroom, rSouth);
		
		final GameItem iMessage = GameItem.makeItem("paper", vMessage,
				"a piece of paper",
				"There is a piece of paper here.",
				"It's a piece of paper with some writing on it.");
		
		final GameItem iCoin = GameItem.makeItem("coin", vCoin, "a gold coin",
				"There is a gold coin here.",
				"It's a US golden double eagle.");
		
		rNorth.addItem(iCoin);
		rBallroom.addItem(iMessage);
		
		allActions.add(new Action(vQuit, null) {
			@Override public void doAction(Word w1, Word w2) {
				interp.setExit(true);
			}
		});
		
		allActions.add(new Action(vMove, vDirect) {
			@Override public void doAction(Word w1, Word w2) {
				thePlayer.moveOnPath(w2);
			}
		});
		
		allActions.add(new Action(vLook, null) {
			@Override public void doAction(Word w1, Word w2) {
				thePlayer.lookAround();
			}
		});
		
		allActions.add(new Action(vMagic, null) {
			final Room fromRoom = rSouth;
			final Room toRoom = rMagic;
			
			@Override public void doAction(Word w1, Word w2) {
				Room loc = thePlayer.getLocation();
				if (loc == fromRoom) {
					/* Can do this, we're in the right location. */
					thePlayer.apportTo(toRoom);
				} else if (loc == toRoom) {
					/* Good idea, the magic word gets you out again. */
					thePlayer.apportTo(fromRoom);
				} else {
					/* Wrong location. Act like we don't know the word. */
					messageOut.printf("I don't understand %s.", w1.getWord());
				}
			}
		});
		
		allActions.add(new Action(vKill, null) {
			@Override public void doAction(Word w1, Word w2) {
				messageOut.printf("What exactly is it you want me to %s?", w1.getWord());
			}
		});
		
		allActions.add(new Action(vGet, vItems) {
			@Override public void doAction(Word w1, Word w2) {
				GameItem item = findItem(w2);
				assert (item != null);
				if (thePlayer.contains(item)) {
					messageOut.printf("You're already carrying %s.", item.getInventoryDesc());
				} else if (thePlayer.getLocation().contains(item)) {
					thePlayer.getLocation().removeItem(item);
					thePlayer.addItem(item);
					messageOut.printf("You're now carrying %s.", item.getInventoryDesc());
				} else {
					messageOut.printf("I can't find %s here.", item.getInventoryDesc());
				}
			}
		});
		
		allActions.add(new Action(vDrop, vItems) {
			@Override public void doAction(Word w1, Word w2) {
				GameItem item = findItem(w2);
				assert (item != null);
				if (thePlayer.contains(item)) {
					thePlayer.removeItem(item);
					thePlayer.getLocation().addItem(item);
					messageOut.printf("You've dropped %s.", item.getInventoryDesc());
				} else {
					messageOut.printf("You're not carrying %s.", item.getInventoryDesc());
				}
			}
		});
		
		allActions.add(new Action(vExamine, vItems) {
			@Override public void doAction(Word w1, Word w2) {
				GameItem item = findItem(w2);
				assert (item != null);
				if (thePlayer.contains(item)) {
					messageOut.print(item.getLongDesc());
				} else {
					messageOut.printf("You are not carrying %s.", item.getInventoryDesc());
				}
			}
		});
		
		allActions.add(new Action(vInventory, null) {
			@Override public void doAction(Word w1, Word w2) {
				Set<GameItem> c = thePlayer.getContents();
				if (c.isEmpty()) {
					messageOut.println("You are not carrying anything.");
				} else {
					messageOut.print("You are carrying ");
					boolean first = true;
					for (GameItem item : c) {
						if (first)
							first = false;
						else
							messageOut.print(", ");
						messageOut.print(item.getInventoryDesc());
					}
					messageOut.println(".");
				}
			}
		});
		
		allActions.add(new Action(vRead, vMessage) {
			@Override public void doAction(Word w1, Word w2) {
				messageOut.printf("The %s says enjoy your game.", w2.getWord());
			}
		});

		thePlayer = new Player("You");
		thePlayer.apportTo(rNorth);

	}

}
