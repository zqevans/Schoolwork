/*
 * Author: Zach Evans
 * CSCI 442 Spring 2014
 * Battleship Project
 */
package battleship;
import java.net.*;

import java.io.*;
public class ServerMain {

	public static void main(String[] args) {
		
		Player waitingPlayer = null;
		if (args.length == 0){
			System.out.println("Usage: java -jar BattleshipServer.jar [port#]");
			return;
		}
		try {
			ServerSocket servSock = new ServerSocket(Integer.parseInt(args[0])); //Create and bind Socket
			boolean running = true;
			System.out.println("Starting loop...");
			while(running){ //Client accept loop
				Socket newClientSock = servSock.accept();
				Player newPlayer = new Player(newClientSock);
				newPlayer.start();
				if (waitingPlayer != null){ //Found match for waiting player
					GameThread newGame = new GameThread(waitingPlayer, newPlayer);
					Globals.addGame(newGame);
					newGame.start();
					waitingPlayer = null;
				}
				else{
					waitingPlayer = newPlayer;
					System.out.println("Player waiting");
				}
			}
			
			
			
			
		} catch (IOException e) {
			System.out.println("IOException: "+e.getMessage());
		}
		finally{
			for(GameThread t: Globals.activeGames){
				t.interrupt();
			}
		}
		
		
		
	}

}
