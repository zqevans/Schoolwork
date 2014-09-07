package cs345evansz2;

import java.util.*;

public class Room {
	
	private String roomName;
	private String roomDescription = new String("");
	private Collection<Path> validPaths = new HashSet<Path>();
	
	Room(String inName, String inDesc){
		roomName = inName;
		roomDescription = inDesc;
	}
	
	public static Room makeRoom(String inName, String inDesc){
		
		return new Room(inName, inDesc);
		
	}
	
	public Collection<Path> getValidPaths(){
		return validPaths;
	}
	
	public void addPath(Path inPath){
		validPaths.add(inPath);
	}
	
	public String getName(){
		return roomName;
	}
	
	public String getRoomDescription(){
		return roomDescription;
	}

}
