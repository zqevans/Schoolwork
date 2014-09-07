package cs345evansz2;

import static cs345evansz2.GameGlobals.*;

public class Player {
	
	private String playerName;
	private Room currentRoom;
	
	Player(String inName){
		playerName = inName;
	}

	
	public Room getLocation(){
		return currentRoom;
	}
	
	
	public void apportTo(Room apportRoom){
		currentRoom = apportRoom;
		lookAround();
	}
	
	public void moveOnPath(Word pathWord){
		boolean didMove = false;
		
		for (Path p: currentRoom.getValidPaths()){
			for (Word w: p.getPathVocab().getWordList()){
				if((w.getType() == MatchType.EXACT && 
					pathWord == w) || 
					//If the word is of type EXACT and the words match and the path is valid	
					// OR	
					// The word is of type PREFIX and the words are a prefix match and the path is valid
					(w.getType() == MatchType.PREFIX &&
					GameUtil.isPrefixMatch(pathWord, w)) ){
						currentRoom = p.getDestRoom();
						lookAround();
						didMove = true;
				}
			}
		}
		if (!didMove){
			messageOut.printf("Unable to move %s.\n", pathWord.getWord());
		}
	}
	
	public void lookAround(){
		messageOut.println(currentRoom.getRoomDescription());
	}
	
	public String getName(){
		return playerName;
	}
	
}