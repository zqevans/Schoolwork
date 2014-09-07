/*
 * Author: Zach Evans
 * CSCI 442 Spring 2014
 * Battleship Project
 */
package battleship;
import java.util.*;
import java.net.*;
import java.io.*;

public class Player extends Thread{
	private GameThread currentGame = null; //Game the player is currently in
	private PrintWriter playerOut; //Output stream for the player client
	private BufferedReader playerIn; //Input stream for the player client
	private String playerName; //The player's name
	private ArrayList<Ship> ships; //A list of ships a player has
	public boolean allPlaced; //All of the ships have been placed
	public boolean moved;
	public boolean disconnected;
	
	/**
	 * <p>Constructor for a player</p>
	 * @param playerSock The socket for the player's client
	 */
	public Player(Socket playerSock){
		this.ships = new ArrayList<Ship>();
		this.allPlaced = false;
		this.moved = false;
		this.disconnected = false;
		
		try {
			this.playerOut = new PrintWriter(playerSock.getOutputStream(), true);
			this.playerIn = new BufferedReader(new InputStreamReader(playerSock.getInputStream()));
			
		} catch (IOException e) {
			System.out.println("Couldn't get socket output stream.");
		}
		Globals.addPlayer(this);
	}
	/**
	 * <p>This sends a message to the client</p>
	 * @param msg The message to send
	 */
	public void sendMessage(String msg){
		this.playerOut.println(msg);
	}
	/**
	 * <p>Sets the name of the player</p>
	 * @param name The name of the player
	 */
	public void setPlayer(String name){
		this.playerName = name;
	}
	
	/**
	 * <p>Getter for the player's name</p>
	 * @return The name of the player
	 */
	public String getPlayer(){
		return this.playerName;
	}
	/**
	 * <p>Setter for the game the player is in</p>
	 * @param newGame The game the player is in
	 */
	public void setGame(GameThread newGame){
		this.currentGame = newGame;
	}
	
	/**
	 * <p>Getter for the game the player is in</p>
	 * @return The game the player is in
	 */
	public GameThread getGame(){
		return this.currentGame;
	}
	
	/**
	 * <p>Adds a ship for the player</p>
	 * @param inShip The ship being added
	 */
	public void addShip(Ship inShip){
		this.ships.add(inShip);
	}
	
	/**
	 * <p>Checks if the ship is dead</p>
	 * @return Whether or not the ship is sunk
	 */
	public boolean isDead(){
		for (Ship s: ships){
			if (s.isAlive()){
				return false;
			}
		}
		return true;
	}
	
	/**
	 * <p>Checks if an attack is a hit or a miss</p>
	 * @param hitPoint The point being attacked
	 * @return Whether or not the attack hit a ship
	 */
	public boolean checkHit(Point hitPoint){ //See if it's hit or miss
		for (Ship possibleShip: this.ships){
			for (Point shipPoint : possibleShip.getPoints()){
				if (Point.samePoint(hitPoint, shipPoint)){
					return true;
				}
			}
		}
		return false;
	}
	
	/**
	 * <p>Attacks a ship and sees if it sinks</p>
	 * @param hitPoint The point being attacked
	 * @return Returns a ship if it's sunk, null otherwise
	 */
	public Ship takeHit(Point hitPoint){ //Hit ship and see if it sinks
		for (Ship possibleShip: this.ships){
			for (Point shipPoint : possibleShip.getPoints()){
				if (Point.samePoint(hitPoint, shipPoint)){
					possibleShip.takeHit(hitPoint);
					if (!possibleShip.isAlive()){
						return possibleShip;
					}
					
				}
			}
		}
		return null;
	}
	 
	/**
	 * <p>Processes a message from a player client</p>
	 * @param clientMessage The message coming from the client
	 */
	private void processClientMessage(String clientMessage){
		if (clientMessage.startsWith("Name: ")){
			this.setName(clientMessage.substring(6));
		}
		else if(clientMessage.startsWith("Ships: ")){
			
			String[] shipArray = clientMessage.substring(6).split(";");
			for (String shipInfo: shipArray){
				String[] shipParts = shipInfo.split(",");
				this.addShip(new Ship(shipParts[0], shipParts[1].trim().split(" ")));
			}
			this.allPlaced = true;
		}
		else if(clientMessage.startsWith("Attack: ")){
			String attackCoord = clientMessage.substring(8);
			Point attackPoint = new Point(attackCoord.charAt(0), Integer.parseInt(attackCoord.substring(1)));
			currentGame.attackEnemy(this, attackPoint);
			this.moved = true;
		}
		else{
			System.out.println("Unknown message: "+clientMessage);
		}
	}
	
	/**
	 * <p>Starts the player thread, allowing incoming messages to be received</p>
	 */
	public void run(){
		String clientMessage;
		try {
			while((clientMessage = playerIn.readLine()) != null){
				processClientMessage(clientMessage);
			}
			System.out.println("Client disconnected");
			Globals.removePlayer(this);
		} catch (IOException e) {
			Globals.removePlayer(this);
		}
	}
}
