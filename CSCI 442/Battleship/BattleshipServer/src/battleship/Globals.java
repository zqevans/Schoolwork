/*
 * Author: Zach Evans
 * CSCI 442 Spring 2014
 * Battleship Project
 */
package battleship;
import java.util.*;

public class Globals {
	public static ArrayList<Player> activePlayers = new ArrayList<Player>();
	public static ArrayList<GameThread> activeGames = new ArrayList<GameThread>();
	
	public static synchronized void addPlayer(Player newPlayer){
		activePlayers.add(newPlayer);
	}
	
	public static synchronized void addGame(GameThread newGameThread){
		activeGames.add(newGameThread);
	}
	
	public static synchronized void removePlayer (Player remPlayer){
		remPlayer.disconnected = true; //The player has disconnected.
		
		if (remPlayer.getGame() != null){
			remPlayer.getGame().killGame();
		}
		activePlayers.remove(remPlayer);
	}
}
